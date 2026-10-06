-- Objetivo: Viajes cuya fecha no corresponde al mes del archivo
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
SELECT split_part(filename, '/', 3) AS taxi,
       count(*) AS registros,
       count_if(strftime(coalesce(tpep_pickup_datetime, lpep_pickup_datetime), '%Y-%m')
                <> regexp_extract(filename, '(\d{4}-\d{2})', 1)) AS fuera_de_mes,
       min(coalesce(tpep_pickup_datetime, lpep_pickup_datetime)) AS fecha_minima,
       max(coalesce(tpep_pickup_datetime, lpep_pickup_datetime)) AS fecha_maxima
FROM read_parquet('data/raw/*/2026/*.parquet', union_by_name = true, filename = true)
GROUP BY taxi;
