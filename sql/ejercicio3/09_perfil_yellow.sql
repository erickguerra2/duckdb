-- Objetivo: Perfil estadístico de todas las columnas amarillas
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
SUMMARIZE SELECT * FROM read_parquet('data/raw/yellow/2026/*.parquet', union_by_name = true);
