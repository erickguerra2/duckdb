-- Objetivo: Contar registros leyendo los archivos completos
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
SELECT 'yellow' AS taxi, count(*) AS registros FROM read_parquet('data/raw/yellow/2026/*.parquet', union_by_name = true)
UNION ALL
SELECT 'green', count(*) FROM read_parquet('data/raw/green/2026/*.parquet', union_by_name = true);
