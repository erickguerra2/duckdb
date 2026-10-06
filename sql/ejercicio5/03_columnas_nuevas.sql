-- Objetivo: Cómo se ven las columnas nuevas al unir años
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2026}/*.parquet
SELECT anio_archivo AS anio, taxi,
       count(*) AS registros,
       count(cbd_congestion_fee) AS con_cbd,
       count(request_source) AS con_request_source,
       count(airport_fee) AS con_airport_fee,
       count(trip_type) AS con_trip_type
FROM viajes
GROUP BY ALL
ORDER BY anio, taxi;
