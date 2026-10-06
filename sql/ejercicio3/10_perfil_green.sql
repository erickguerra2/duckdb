-- Objetivo: Perfil estadístico de todas las columnas verdes
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
SUMMARIZE SELECT * FROM read_parquet('data/raw/green/2026/*.parquet', union_by_name = true);
