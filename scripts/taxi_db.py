#!/usr/bin/env python3
"""Vistas sobre Parquet y materializacion de la base DuckDB.

Uso:
    python scripts/taxi_db.py                         # todos los anios descargados
    python scripts/taxi_db.py --anio 2024 2026
    python scripts/taxi_db.py --db data/processed/otra.duckdb

Crea data/processed/taxi.duckdb con:
    zonas               catalogo de zonas TLC
    viajes_tbl          viajes amarillos y verdes con columna de calidad
    viajes_limpios_tbl  vista con los viajes validos
"""

import argparse
import os
import sys
import time
from pathlib import Path

import duckdb

RAIZ = Path(__file__).resolve().parent.parent
SQL_VISTAS = RAIZ / "sql" / "01_vistas.sql"
SQL_MATERIALIZAR = RAIZ / "sql" / "02_materializar.sql"
DB_POR_DEFECTO = Path("data/processed/taxi.duckdb")
TIPOS = ("yellow", "green")
MEMORIA = os.environ.get("DUCKDB_MEMORY", "6GB")


def anios_disponibles() -> list:
    return sorted({int(p.name) for t in TIPOS for p in (RAIZ / "data/raw" / t).glob("[0-9]" * 4)})


def sql_vistas(anios=None, temporal=False) -> str:
    """Acepta anios o meses."""
    sql = SQL_VISTAS.read_text(encoding="utf-8")
    if anios:
        for t in TIPOS:
            rutas = []
            for a in sorted(map(str, anios)):
                if "-" in a:
                    rutas.append(f"'data/raw/{t}/{a[:4]}/{t}_tripdata_{a}.parquet'")
                else:
                    rutas.append(f"'data/raw/{t}/{a}/*.parquet'")
            sql = sql.replace(f"'data/raw/{t}/*/*.parquet'", f"[{', '.join(rutas)}]")
    if temporal:
        sql = sql.replace("CREATE OR REPLACE VIEW", "CREATE OR REPLACE TEMP VIEW")
    return sql


def crear_vistas(con, anios=None, temporal=False) -> None:
    con.execute(sql_vistas(anios, temporal))


def materializar(destino=DB_POR_DEFECTO, anios=None) -> dict:
    """Construye y reemplaza base."""
    destino = Path(destino)
    destino.parent.mkdir(parents=True, exist_ok=True)
    temporal = destino.with_name(destino.stem + "_nuevo.duckdb")
    temporal.unlink(missing_ok=True)
    temporal.with_name(temporal.name + ".wal").unlink(missing_ok=True)

    inicio = time.perf_counter()
    con = duckdb.connect(str(temporal))
    con.execute("SET preserve_insertion_order = false")
    con.execute(f"SET memory_limit = '{MEMORIA}'")
    con.execute(f"SET temp_directory = '{destino.parent / 'tmp'}'")
    crear_vistas(con, anios, temporal=True)
    con.execute(SQL_MATERIALIZAR.read_text(encoding="utf-8"))
    filas = con.sql("SELECT count(*) FROM viajes_tbl").fetchone()[0]
    con.execute("CHECKPOINT")
    con.close()
    segundos = time.perf_counter() - inicio

    os.replace(temporal, destino)
    return {"db": str(destino), "anios": anios or anios_disponibles(), "filas": filas,
            "segundos": round(segundos, 1), "mib": round(destino.stat().st_size / 2**20, 1)}


def main() -> int:
    parser = argparse.ArgumentParser(description="Materializa los viajes en una base DuckDB.")
    parser.add_argument("--anio", type=int, nargs="+", help="anios a incluir (por defecto: todos)")
    parser.add_argument("--db", type=Path, default=DB_POR_DEFECTO, help="archivo destino")
    argumentos = parser.parse_args()

    os.chdir(RAIZ)
    try:
        resultado = materializar(argumentos.db, argumentos.anio)
    except duckdb.IOException as error:
        print(f"ERROR: {error}")
        print("Si Metabase tiene la base abierta: docker compose stop metabase")
        return 1
    for clave, valor in resultado.items():
        print(f"  {clave:8}: {valor}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
