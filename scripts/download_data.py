#!/usr/bin/env python3
"""Descarga los archivos Parquet del NYC TLC Trip Record Data.

Descarga los registros de viajes de taxis amarillos (yellow) y verdes (green)
para uno o varios anios. Por defecto descarga 2024, 2025 y 2026.

Fuente oficial de los datos:
    https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

Uso:
    python scripts/download_data.py                          # 2024, 2025 y 2026
    python scripts/download_data.py --anio 2026              # solo 2026
    python scripts/download_data.py --anio 2024 2026 --taxi green
    python scripts/download_data.py --verificar              # no descarga, solo valida

Los archivos se guardan en:
    data/raw/<tipo>/<anio>/<nombre-original>.parquet

Comportamiento:
  - La TLC publica cada mes con varias semanas de atraso. El script consulta al
    servidor que meses estan publicados en lugar de suponerlos.
  - Un archivo que ya existe localmente no se vuelve a descargar.
  - La descarga se hace sobre un nombre temporal y solo se renombra al
    terminar, de modo que una interrupcion no deja archivos .parquet a medias.
  - Al terminar se valida cada archivo local: tamanio igual al publicado,
    metadatos Parquet legibles y cantidad de filas. El resultado se guarda en
    docs/manifest_descargas.csv.
"""

import argparse
import csv
import sys
from datetime import date
from pathlib import Path

import pyarrow.parquet as pq
import requests

ANIOS_POR_DEFECTO = (2024, 2025, 2026)
TIPOS_TAXI = ("yellow", "green")
URL_BASE = "https://d37ci6vzurychx.cloudfront.net/trip-data"
DIR_DESTINO = Path("data/raw")
MANIFIESTO = Path("docs/manifest_descargas.csv")
URL_ZONAS = "https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv"
RUTA_ZONAS = DIR_DESTINO / "zones" / "taxi_zone_lookup.csv"

TIEMPO_ESPERA = 60
INTENTOS = 3
BLOQUE = 1024 * 1024
SUFIJO_TEMPORAL = ".part"


def construir_nombre(tipo: str, anio: int, mes: int) -> str:
    return f"{tipo}_tripdata_{anio}-{mes:02d}.parquet"


def construir_url(tipo: str, anio: int, mes: int) -> str:
    return f"{URL_BASE}/{construir_nombre(tipo, anio, mes)}"


def ruta_destino(tipo: str, anio: int, mes: int) -> Path:
    return DIR_DESTINO / tipo / str(anio) / construir_nombre(tipo, anio, mes)


def meses_posibles(anio: int) -> range:
    """Meses posibles hasta hoy."""
    hoy = date.today()
    if anio > hoy.year:
        return range(1, 1)
    ultimo = hoy.month if anio == hoy.year else 12
    return range(1, ultimo + 1)


def tamanio_publicado(url: str):
    """Bytes publicados o None."""
    for _ in range(INTENTOS):
        try:
            respuesta = requests.head(url, timeout=TIEMPO_ESPERA, allow_redirects=True)
        except requests.RequestException:
            continue
        if not respuesta.ok:
            return None
        return int(respuesta.headers.get("Content-Length", 0)) or -1
    return None


def formato_tamanio(n: float) -> str:
    for unidad in ("B", "KiB", "MiB", "GiB"):
        if n < 1024 or unidad == "GiB":
            return f"{n:.1f} {unidad}"
        n /= 1024
    return f"{n:.1f} GiB"


def descargar_archivo(url: str, destino: Path) -> int:
    destino.parent.mkdir(parents=True, exist_ok=True)
    temporal = destino.with_name(destino.name + SUFIJO_TEMPORAL)

    ultimo_error = None
    for intento in range(1, INTENTOS + 1):
        try:
            with requests.get(url, stream=True, timeout=TIEMPO_ESPERA) as respuesta:
                respuesta.raise_for_status()
                esperado = int(respuesta.headers.get("Content-Length", 0))
                escritos = 0
                with temporal.open("wb") as archivo:
                    for bloque in respuesta.iter_content(chunk_size=BLOQUE):
                        if bloque:
                            archivo.write(bloque)
                            escritos += len(bloque)
            if escritos == 0:
                raise requests.RequestException("el servidor devolvio un archivo vacio")
            if esperado and escritos != esperado:
                raise requests.RequestException(f"descarga incompleta: {escritos} de {esperado} bytes")
            temporal.replace(destino)
            return escritos
        except requests.RequestException as error:
            ultimo_error = error
            temporal.unlink(missing_ok=True)
            if intento < INTENTOS:
                print(f"      intento {intento}/{INTENTOS} fallido ({error}); reintentando")

    raise requests.RequestException(f"no se pudo descargar {url}: {ultimo_error}")


def descargar(tipo: str, anio: int, solo_verificar: bool) -> dict:
    """Descarga un tipo y anio."""
    print(f"\n=== {tipo.upper()} {anio} ===")
    resumen = {"descargados": 0, "omitidos": 0, "no_publicados": [], "fallidos": []}

    for mes in meses_posibles(anio):
        etiqueta = f"{anio}-{mes:02d}"
        destino = ruta_destino(tipo, anio, mes)

        if destino.exists() and destino.stat().st_size > 0:
            print(f"  {etiqueta}  ya existe, se omite")
            resumen["omitidos"] += 1
            continue

        if solo_verificar:
            print(f"  {etiqueta}  no existe localmente")
            resumen["no_publicados"].append(etiqueta)
            continue

        url = construir_url(tipo, anio, mes)
        if tamanio_publicado(url) is None:
            print(f"  {etiqueta}  aun no publicado por la TLC")
            resumen["no_publicados"].append(etiqueta)
            continue

        print(f"  {etiqueta}  descargando...")
        try:
            escritos = descargar_archivo(url, destino)
        except requests.RequestException as error:
            print(f"  {etiqueta}  ERROR: {error}")
            resumen["fallidos"].append(etiqueta)
        else:
            print(f"  {etiqueta}  listo ({formato_tamanio(escritos)}) -> {destino}")
            resumen["descargados"] += 1

    return resumen


def descargar_zonas() -> None:
    """Catalogo de zonas TLC."""
    if RUTA_ZONAS.exists() and RUTA_ZONAS.stat().st_size > 0:
        print(f"\nZonas: {RUTA_ZONAS} ya existe, se omite")
        return
    print(f"\nZonas: descargando {URL_ZONAS}")
    descargar_archivo(URL_ZONAS, RUTA_ZONAS)


def validar_local(tipos, anios, consultar_servidor: bool) -> list:
    """Arma el manifiesto local."""
    filas = []
    for tipo in tipos:
        for anio in anios:
            meses_locales = []
            for mes in meses_posibles(anio):
                destino = ruta_destino(tipo, anio, mes)
                if not destino.exists():
                    continue
                meses_locales.append(mes)
                local = destino.stat().st_size
                remoto = tamanio_publicado(construir_url(tipo, anio, mes)) if consultar_servidor else None
                try:
                    meta = pq.ParquetFile(destino).metadata
                    registros, columnas, legible = meta.num_rows, meta.num_columns, True
                except Exception:
                    registros, columnas, legible = 0, 0, False
                filas.append({
                    "tipo": tipo, "anio": anio, "mes": mes,
                    "archivo": destino.as_posix(),
                    "bytes_local": local,
                    "bytes_servidor": remoto if remoto else "",
                    "tamanio_ok": (remoto == local) if remoto else "",
                    "parquet_legible": legible,
                    "registros": registros,
                    "columnas": columnas,
                })
            huecos = [m for m in range(1, max(meses_locales, default=0) + 1) if m not in meses_locales]
            if huecos:
                print(f"  AVISO {tipo} {anio}: faltan meses intermedios {huecos}")
    return filas


def guardar_manifiesto(filas: list) -> None:
    if not filas:
        return
    MANIFIESTO.parent.mkdir(parents=True, exist_ok=True)
    with MANIFIESTO.open("w", newline="", encoding="utf-8") as archivo:
        escritor = csv.DictWriter(archivo, fieldnames=list(filas[0]))
        escritor.writeheader()
        escritor.writerows(filas)


def main() -> int:
    parser = argparse.ArgumentParser(description="Descarga los datos de taxis del NYC TLC.")
    parser.add_argument(
        "--taxi", choices=(*TIPOS_TAXI, "all"), default="all",
        help="tipo de taxi a descargar (por defecto: all)",
    )
    parser.add_argument(
        "--anio", type=int, nargs="+", default=list(ANIOS_POR_DEFECTO),
        help="uno o varios anios (por defecto: 2024 2025 2026)",
    )
    parser.add_argument(
        "--verificar", action="store_true",
        help="no descarga nada, solo valida los archivos locales contra el servidor",
    )
    argumentos = parser.parse_args()

    tipos = TIPOS_TAXI if argumentos.taxi == "all" else (argumentos.taxi,)
    anios = sorted(set(argumentos.anio))

    total = {"descargados": 0, "omitidos": 0, "no_publicados": [], "fallidos": []}
    for tipo in tipos:
        for anio in anios:
            resumen = descargar(tipo, anio, argumentos.verificar)
            total["descargados"] += resumen["descargados"]
            total["omitidos"] += resumen["omitidos"]
            total["no_publicados"] += [f"{tipo} {m}" for m in resumen["no_publicados"]]
            total["fallidos"] += [f"{tipo} {m}" for m in resumen["fallidos"]]

    if not argumentos.verificar:
        descargar_zonas()

    print("\nValidando archivos locales...")
    filas = validar_local(tipos, anios, consultar_servidor=True)
    guardar_manifiesto(filas)
    malos = [f["archivo"] for f in filas if not f["parquet_legible"] or f["tamanio_ok"] is False]

    print("\n" + "=" * 60)
    print("RESUMEN")
    print("=" * 60)
    print(f"  anios         : {', '.join(map(str, anios))}")
    print(f"  descargados   : {total['descargados']}")
    print(f"  ya existian   : {total['omitidos']}")
    print(f"  no publicados : {len(total['no_publicados'])}")
    if total["no_publicados"]:
        print(f"      {', '.join(total['no_publicados'])}")
    print(f"  fallidos      : {len(total['fallidos'])}")
    if total["fallidos"]:
        print(f"      {', '.join(total['fallidos'])}")
    print(f"  archivos locales validados : {len(filas)}")
    print(f"  registros totales          : {sum(f['registros'] for f in filas):,}")
    print(f"  archivos con problemas     : {len(malos)}")
    for m in malos:
        print(f"      {m}")
    if filas:
        print(f"  manifiesto                 : {MANIFIESTO}")
    print("=" * 60)

    return 1 if total["fallidos"] or malos else 0


if __name__ == "__main__":
    sys.exit(main())
