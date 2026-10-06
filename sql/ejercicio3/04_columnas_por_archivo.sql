-- Objetivo: Columnas y tipo físico presentes en cada archivo
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
SELECT split_part(file_name, '/', 3) AS taxi,
       name AS columna,
       type AS tipo_fisico,
       logical_type,
       count(DISTINCT file_name) AS archivos_con_columna,
       min(regexp_extract(file_name, '(\d{4}-\d{2})', 1)) AS desde
FROM parquet_schema('data/raw/*/2026/*.parquet')
WHERE name <> 'schema'
GROUP BY ALL
ORDER BY taxi, columna;
