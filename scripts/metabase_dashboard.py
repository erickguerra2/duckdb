#!/usr/bin/env python3
"""Construye el tablero de indicadores en Metabase desde sql/indicadores/.

Uso, dentro del contenedor lab:
    python scripts/metabase_dashboard.py

Desde la computadora anfitriona, con captura del tablero en Edge o Chrome:
    python scripts/metabase_dashboard.py --url http://127.0.0.1:3000 --capturas

Cada archivo .sql de sql/indicadores/ es una pregunta nativa de Metabase.
Las lineas de encabezado "-- clave: valor" definen titulo, tipo de grafico,
dimensiones y metricas. El script es idempotente: si la tarjeta o el tablero
ya existen, los actualiza.

Metabase abre una base DuckDB en memoria que adjunta taxi.duckdb en modo solo
lectura. El init_sql incluye la fecha de modificacion del archivo: cuando la
base se reconstruye, el script cambia ese valor y Metabase abre una conexion
nueva, sin tener que reiniciar el servicio.

Credenciales del administrador local, configurables por variables de entorno:
    MB_EMAIL     por defecto lab8@example.com
    MB_PASSWORD  por defecto Lab8-DuckDB-2026
"""

import argparse
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

import requests

RAIZ = Path(__file__).resolve().parent.parent
DIR_INDICADORES = RAIZ / "sql" / "indicadores"
DIR_CAPTURAS = RAIZ / "docs" / "figuras"
NAVEGADORES = [
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    "msedge", "google-chrome", "chromium", "chromium-browser",
]
NOMBRE_BASE = "Taxis NYC DuckDB"
NOMBRE_TABLERO = "Taxis NYC 2024-2026"
RUTA_DUCKDB = "/workspace/data/processed/taxi.duckdb"
EMAIL = os.environ.get("MB_EMAIL", "lab8@example.com")
PASSWORD = os.environ.get("MB_PASSWORD", "Lab8-DuckDB-2026")
ANCHO = 24


def leer_indicador(ruta: Path) -> dict:
    meta, cuerpo = {}, []
    for linea in ruta.read_text(encoding="utf-8").splitlines():
        if linea.startswith("-- ") and ":" in linea and not cuerpo:
            clave, valor = linea[3:].split(":", 1)
            meta[clave.strip()] = valor.strip()
        elif not linea.startswith("--"):
            cuerpo.append(linea)
    meta["sql"] = "\n".join(cuerpo).strip().rstrip(";")
    meta["archivo"] = ruta.stem
    lista = lambda c: [x.strip() for x in meta.get(c, "").split(",") if x.strip()]
    meta["dimensiones"], meta["metricas"] = lista("dimensiones"), lista("metricas")
    return meta


def ajustes_visuales(ind: dict) -> dict:
    if ind["grafico"] == "scalar":
        return {}
    ajustes = {"graph.dimensions": ind["dimensiones"], "graph.metrics": ind["metricas"],
               "graph.x_axis.title_text": ind["dimensiones"][0], "graph.y_axis.title_text": ind["metricas"][0]}
    if ind.get("escala") == "log":
        ajustes["graph.y_axis.scale"] = "log"
    if ind.get("apilado") == "si":
        ajustes["stackable.stack_type"] = "stacked"
    return ajustes


class Metabase:
    def __init__(self, url: str):
        self.url = url.rstrip("/")
        self.s = requests.Session()

    def llamar(self, metodo, ruta, **kw):
        r = self.s.request(metodo, f"{self.url}/api/{ruta}", timeout=300, **kw)
        if not r.ok:
            raise RuntimeError(f"{metodo} {ruta}: {r.status_code} {r.text[:300]}")
        return r.json() if r.content and "json" in r.headers.get("Content-Type", "") else r.content

    def esperar(self):
        for _ in range(60):
            try:
                if self.s.get(f"{self.url}/api/health", timeout=5).ok:
                    return
            except requests.RequestException:
                pass
            time.sleep(5)
        raise RuntimeError("Metabase no responde")

    def iniciar_sesion(self):
        props = self.llamar("GET", "session/properties")
        if not props.get("has-user-setup"):
            print("  configurando administrador inicial")
            self.llamar("POST", "setup", json={
                "token": props["setup-token"],
                "user": {"email": EMAIL, "password": PASSWORD, "first_name": "Lab", "last_name": "Ocho",
                         "site_name": "Lab 8 DuckDB"},
                "prefs": {"site_name": "Lab 8 DuckDB", "site_locale": "es", "allow_tracking": False},
            })
        sesion = self.llamar("POST", "session", json={"username": EMAIL, "password": PASSWORD})
        self.s.headers["X-Metabase-Session"] = sesion["id"]

    def base_duckdb(self) -> int:
        """Registra o refresca base."""
        local = RAIZ / "data" / "processed" / "taxi.duckdb"
        version = int(local.stat().st_mtime) if local.exists() else 0
        detalles = {"database_file": ":memory:", "read_only": False, "old_implicit_casting": True,
                    "memory_limit": "3GB",
                    "init_sql": f"ATTACH IF NOT EXISTS '{RUTA_DUCKDB}' AS taxi (READ_ONLY); USE taxi; "
                                f"SELECT {version} AS version_taxi_duckdb;"}
        bases = self.llamar("GET", "database")
        bases = bases.get("data", bases)
        for b in bases:
            if b["name"] == NOMBRE_BASE:
                if b.get("details", {}).get("init_sql") != detalles["init_sql"]:
                    print("  la base cambio, se refresca la conexion")
                    self.llamar("PUT", f"database/{b['id']}", json={"details": detalles})
                return b["id"]
        print("  registrando la base DuckDB en modo solo lectura")
        b = self.llamar("POST", "database", json={
            "engine": "duckdb", "name": NOMBRE_BASE, "is_full_sync": True, "details": detalles,
        })
        return b["id"]

    def guardar_tarjeta(self, ind: dict, base_id: int, existentes: dict) -> int:
        cuerpo = {
            "name": ind["titulo"], "description": ind.get("pregunta", ""), "display": ind["grafico"],
            "dataset_query": {"type": "native", "database": base_id,
                              "native": {"query": ind["sql"], "template-tags": {}}},
            "visualization_settings": ajustes_visuales(ind), "collection_id": None,
        }
        if ind["titulo"] in existentes:
            return self.llamar("PUT", f"card/{existentes[ind['titulo']]}", json=cuerpo)["id"]
        return self.llamar("POST", "card", json=cuerpo)["id"]

    def guardar_tablero(self, tarjetas: list) -> int:
        tableros = [d for d in self.llamar("GET", "dashboard") if d["name"] == NOMBRE_TABLERO and not d.get("archived")]
        if tableros:
            tablero_id = tableros[0]["id"]
        else:
            tablero_id = self.llamar("POST", "dashboard", json={
                "name": NOMBRE_TABLERO,
                "description": "Indicadores de taxis amarillos y verdes de NYC calculados con DuckDB"})["id"]

        celdas, kpis, graficos = [], [t for t in tarjetas if t[1] == "scalar"], [t for t in tarjetas if t[1] != "scalar"]
        ancho_kpi = ANCHO // max(len(kpis), 1)
        for i, (card_id, _) in enumerate(kpis):
            celdas.append({"card_id": card_id, "row": 0, "col": i * ancho_kpi, "size_x": ancho_kpi, "size_y": 3})
        for i, (card_id, _) in enumerate(graficos):
            celdas.append({"card_id": card_id, "row": 3 + 7 * (i // 2), "col": 12 * (i % 2), "size_x": 12, "size_y": 7})
        for i, c in enumerate(celdas, start=1):
            c.update({"id": -i, "parameter_mappings": [], "visualization_settings": {}})
        self.llamar("PUT", f"dashboard/{tablero_id}", json={"dashcards": celdas})
        return tablero_id

    def enlace_publico(self, tablero_id: int) -> str:
        self.llamar("PUT", "setting/enable-public-sharing", json={"value": True})
        uuid = self.llamar("POST", f"dashboard/{tablero_id}/public_link")["uuid"]
        return f"/public/dashboard/{uuid}"


def main() -> int:
    parser = argparse.ArgumentParser(description="Publica el tablero de indicadores en Metabase.")
    parser.add_argument("--url", default=os.environ.get("MB_URL", "http://metabase:3000"))
    parser.add_argument("--capturas", action="store_true", help="guarda un PNG por tarjeta en docs/tablero/")
    argumentos = parser.parse_args()

    mb = Metabase(argumentos.url)
    mb.esperar()
    mb.iniciar_sesion()
    base_id = mb.base_duckdb()
    mb.llamar("POST", f"database/{base_id}/sync_schema")

    existentes = {c["name"]: c["id"] for c in mb.llamar("GET", "card") if not c.get("archived")}
    tarjetas = []
    for ruta in sorted(DIR_INDICADORES.glob("*.sql")):
        ind = leer_indicador(ruta)
        card_id = mb.guardar_tarjeta(ind, base_id, existentes)
        resultado = mb.llamar("POST", f"card/{card_id}/query", json={})
        estado = resultado.get("status") if isinstance(resultado, dict) else "?"
        filas = resultado.get("row_count") if isinstance(resultado, dict) else "?"
        print(f"  {ind['archivo']:26} tarjeta {card_id:3}  {estado}  filas={filas}")
        if estado != "completed":
            print(f"      {resultado.get('error', '')[:300]}")
        tarjetas.append((card_id, ind["grafico"]))

    tablero_id = mb.guardar_tablero(tarjetas)
    publico = mb.enlace_publico(tablero_id)
    print(f"\nTablero  : http://127.0.0.1:3000/dashboard/{tablero_id}")
    print(f"Publico  : http://127.0.0.1:3000{publico}")
    print(f"Usuario  : {EMAIL}")
    if argumentos.capturas:
        capturar(argumentos.url.rstrip("/") + publico, DIR_CAPTURAS / "tablero_metabase.png")
    return 0


def capturar(url: str, destino: Path) -> None:
    """Captura con navegador headless."""
    navegador = next((n for n in NAVEGADORES if Path(n).exists() or shutil.which(n)), None)
    if not navegador:
        print("  no se encontro Edge ni Chrome, se omite la captura")
        return
    destino.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run([navegador, "--headless=new", "--disable-gpu", "--hide-scrollbars",
                    "--window-size=1600,2250", "--virtual-time-budget=60000",
                    f"--screenshot={destino}", url], capture_output=True, timeout=180)
    print(f"Captura  : {destino}" if destino.exists() else "  la captura fallo")


if __name__ == "__main__":
    sys.exit(main())
