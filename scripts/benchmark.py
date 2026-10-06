#!/usr/bin/env python3
"""Benchmark: consultas sobre Parquet contra tabla materializada en DuckDB.

Uso:
    python scripts/benchmark.py
    python scripts/benchmark.py --repeticiones 3 --escala "2026"

Para cada escala de datos:
  1. Crea vistas temporales sobre los Parquet de esa escala.
  2. Materializa la misma vista en una tabla y mide el tiempo de carga.
  3. Ejecuta cada consulta de sql/benchmark/ sobre ambas fuentes,
     alternando el orden en cada repeticion.

Resultados:
    docs/benchmark/tiempos.csv          una fila por ejecucion
    docs/benchmark/materializacion.csv  costo de crear cada tabla
"""

import argparse
import csv
import os
import sys
import time
from pathlib import Path

import duckdb

sys.path.insert(0, str(Path(__file__).resolve().parent))
import taxi_db  # noqa: E402

RAIZ = taxi_db.RAIZ
DIR_CONSULTAS = RAIZ / "sql" / "benchmark"
DIR_SALIDA = Path("docs/benchmark")
DB_BENCH = Path("data/processed/benchmark.duckdb")

ESCALAS = {
    "1 mes": ["2026-01"],
    "2026": [2026],
    "2024+2026": [2024, 2026],
    "2024-2026": [2024, 2025, 2026],
}
FUENTES = {"parquet": "viajes", "tabla": "viajes_tbl"}


def cargar_consultas() -> dict:
    return {p.stem: p.read_text(encoding="utf-8") for p in sorted(DIR_CONSULTAS.glob("*.sql"))}


def medir(con, sql: str) -> float:
    inicio = time.perf_counter()
    con.sql(sql).fetchall()
    return time.perf_counter() - inicio


def correr_escala(nombre, periodos, consultas, repeticiones) -> tuple:
    DB_BENCH.parent.mkdir(parents=True, exist_ok=True)
    DB_BENCH.unlink(missing_ok=True)
    con = duckdb.connect(str(DB_BENCH))
    con.execute(f"SET memory_limit = '{taxi_db.MEMORIA}'")
    taxi_db.crear_vistas(con, periodos, temporal=True)
    con.execute("CREATE TABLE zonas AS SELECT LocationID AS location_id, Borough AS borough, "
                "Zone AS zona FROM read_csv('data/raw/zones/taxi_zone_lookup.csv', header = true)")

    inicio = time.perf_counter()
    con.execute("CREATE TABLE viajes_tbl AS SELECT * FROM viajes")
    con.execute("CHECKPOINT")
    carga = time.perf_counter() - inicio
    filas = con.sql("SELECT count(*) FROM viajes_tbl").fetchone()[0]
    mib_parquet = sum(
        p.stat().st_size for t in taxi_db.TIPOS for per in periodos
        for p in (Path("data/raw") / t / str(per)[:4]).glob(
            f"{t}_tripdata_{per}.parquet" if "-" in str(per) else "*.parquet")
    ) / 2**20
    materializacion = {
        "escala": nombre, "filas": filas, "segundos_carga": round(carga, 3),
        "mib_parquet": round(mib_parquet, 1), "mib_duckdb": round(DB_BENCH.stat().st_size / 2**20, 1),
    }
    print(f"\n=== {nombre}: {filas:,} filas, carga {carga:.1f} s ===")

    tiempos = []
    for consulta, plantilla in consultas.items():
        for rep in range(1, repeticiones + 1):
            orden = list(FUENTES) if rep % 2 else list(FUENTES)[::-1]
            for fuente in orden:
                segundos = medir(con, plantilla.format(fuente=FUENTES[fuente]))
                tiempos.append({"escala": nombre, "filas": filas, "consulta": consulta,
                                "fuente": fuente, "repeticion": rep, "segundos": round(segundos, 4)})
        resumen = {f: sorted(t["segundos"] for t in tiempos
                             if t["consulta"] == consulta and t["fuente"] == f)[repeticiones // 2]
                   for f in FUENTES}
        print(f"  {consulta:22} parquet {resumen['parquet']:7.3f} s   tabla {resumen['tabla']:7.3f} s")

    con.close()
    return materializacion, tiempos


def guardar(ruta: Path, filas: list) -> None:
    ruta.parent.mkdir(parents=True, exist_ok=True)
    with ruta.open("w", newline="", encoding="utf-8") as archivo:
        escritor = csv.DictWriter(archivo, fieldnames=list(filas[0]))
        escritor.writeheader()
        escritor.writerows(filas)


def main() -> int:
    parser = argparse.ArgumentParser(description="Benchmark Parquet contra tabla DuckDB.")
    parser.add_argument("--repeticiones", type=int, default=5)
    parser.add_argument("--escala", nargs="+", choices=list(ESCALAS), default=list(ESCALAS))
    parser.add_argument("--conservar", action="store_true", help="no borra benchmark.duckdb al final")
    argumentos = parser.parse_args()

    os.chdir(RAIZ)
    consultas = cargar_consultas()
    materializaciones, tiempos = [], []
    for nombre in argumentos.escala:
        m, t = correr_escala(nombre, ESCALAS[nombre], consultas, argumentos.repeticiones)
        materializaciones.append(m)
        tiempos += t

    guardar(DIR_SALIDA / "materializacion.csv", materializaciones)
    guardar(DIR_SALIDA / "tiempos.csv", tiempos)
    if not argumentos.conservar:
        DB_BENCH.unlink(missing_ok=True)
    print(f"\nResultados en {DIR_SALIDA}/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
