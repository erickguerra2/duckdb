-- Objetivo: Contar los archivos Parquet de 2026 por tipo de taxi
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
SELECT split_part(file, '/', 3) AS taxi,
       count(*) AS archivos,
       min(regexp_extract(file, '(\d{4}-\d{2})', 1)) AS primer_mes,
       max(regexp_extract(file, '(\d{4}-\d{2})', 1)) AS ultimo_mes
FROM glob('data/raw/*/2026/*.parquet')
GROUP BY taxi
ORDER BY taxi;
