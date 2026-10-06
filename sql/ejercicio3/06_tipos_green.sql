-- Objetivo: Tipos lógicos que DuckDB asigna a las columnas de taxis verdes
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
DESCRIBE SELECT * FROM read_parquet('data/raw/green/2026/*.parquet', union_by_name = true);
