-- Objetivo: Detectar viajes repetidos con la misma huella
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
SELECT count(*) AS grupos_repetidos, coalesce(sum(n - 1), 0) AS filas_sobrantes
FROM (
    SELECT VendorID, tpep_pickup_datetime, tpep_dropoff_datetime, PULocationID, DOLocationID,
           trip_distance, total_amount, count(*) AS n
    FROM read_parquet('data/raw/yellow/2026/*.parquet', union_by_name = true)
    GROUP BY ALL
    HAVING count(*) > 1
);
