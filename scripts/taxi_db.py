#!/usr/bin/env python3
"""Vistas sobre Parquet con DuckDB.

Uso desde Python:
    import taxi_db
    taxi_db.crear_vistas(con, [2026])

Crea las vistas viajes, viajes_calidad y viajes_limpios definidas en
sql/01_vistas.sql, sin importar datos.
"""

import os
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
SQL_VISTAS = RAIZ / "sql" / "01_vistas.sql"
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
