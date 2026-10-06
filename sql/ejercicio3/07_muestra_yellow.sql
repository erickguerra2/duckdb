-- Objetivo: Muestra reproducible de viajes amarillos
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
SELECT * FROM read_parquet('data/raw/yellow/2026/*.parquet', union_by_name = true)
USING SAMPLE reservoir(5 ROWS) REPEATABLE (42);
