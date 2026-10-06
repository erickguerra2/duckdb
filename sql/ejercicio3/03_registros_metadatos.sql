-- Objetivo: Contar registros solo desde los metadatos Parquet
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
SELECT split_part(file_name, '/', 3) AS taxi,
       count(DISTINCT file_name) AS archivos,
       sum(row_group_num_rows) FILTER (WHERE column_id = 0) AS registros,
       count(*) FILTER (WHERE column_id = 0) AS row_groups
FROM parquet_metadata('data/raw/*/2026/*.parquet')
GROUP BY taxi
ORDER BY taxi;
