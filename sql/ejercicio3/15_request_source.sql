-- Objetivo: Explorar la columna nueva request_source por mes
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
SELECT split_part(filename, '/', 3) AS taxi,
       regexp_extract(filename, '(\d{4}-\d{2})', 1) AS mes,
       coalesce(request_source, 'NULL') AS request_source,
       count(*) AS registros
FROM read_parquet('data/raw/*/2026/*.parquet', union_by_name = true, filename = true)
WHERE regexp_extract(filename, '(\d{4}-\d{2})', 1) >= '2026-05'
GROUP BY ALL
ORDER BY taxi, mes, registros DESC;
