-- Objetivo: Columnas presentes por año para detectar cambios de esquema
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2026}/*.parquet
SELECT name AS columna,
       count(DISTINCT file_name) FILTER (WHERE file_name LIKE '%/2024/%') AS archivos_2024,
       count(DISTINCT file_name) FILTER (WHERE file_name LIKE '%/2026/%') AS archivos_2026,
       string_agg(DISTINCT type, ', ') AS tipos
FROM parquet_schema(['data/raw/*/2024/*.parquet', 'data/raw/*/2026/*.parquet'])
WHERE name <> 'schema'
GROUP BY name
HAVING archivos_2024 <> 24 OR archivos_2026 <> 16 OR count(DISTINCT type) > 1
ORDER BY columna;
