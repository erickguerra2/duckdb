-- Objetivo: Ejemplos de registros descartados más extremos
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
SELECT calidad, taxi, pickup, dropoff, round(duracion_min, 1) AS duracion_min, trip_distance,
       fare_amount, total_amount, pu_location_id, do_location_id
FROM viajes_calidad
WHERE calidad <> 'valido'
QUALIFY row_number() OVER (PARTITION BY calidad ORDER BY abs(trip_distance) + abs(total_amount) DESC) = 1
ORDER BY calidad;
