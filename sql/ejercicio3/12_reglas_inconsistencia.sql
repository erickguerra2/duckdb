-- Objetivo: Contar registros que violan reglas básicas de negocio
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
WITH v AS (
    SELECT split_part(filename, '/', 3) AS taxi,
           coalesce(tpep_pickup_datetime, lpep_pickup_datetime) AS pickup,
           coalesce(tpep_dropoff_datetime, lpep_dropoff_datetime) AS dropoff,
           *
    FROM read_parquet('data/raw/*/2026/*.parquet', union_by_name = true, filename = true)
)
SELECT taxi,
       count(*) AS registros,
       count_if(dropoff <= pickup) AS duracion_no_positiva,
       count_if(dropoff - pickup > INTERVAL 6 HOUR) AS duracion_mayor_6h,
       count_if(trip_distance = 0) AS distancia_cero,
       count_if(trip_distance > 100) AS distancia_mayor_100,
       count_if(total_amount < 0) AS total_negativo,
       count_if(total_amount = 0) AS total_cero,
       count_if(total_amount > 1000) AS total_mayor_1000,
       count_if(passenger_count = 0) AS pasajeros_cero,
       count_if(passenger_count IS NULL) AS pasajeros_nulo,
       count_if(PULocationID IN (264, 265)) AS zona_desconocida
FROM v
GROUP BY taxi;
