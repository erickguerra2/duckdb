-- Objetivo: Perfil comparativo de taxis amarillos y verdes
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
SELECT v.taxi,
       count(*) AS viajes,
       round(avg(trip_distance), 2) AS distancia_prom,
       round(median(duracion_min), 1) AS duracion_mediana,
       round(avg(total_amount), 2) AS ticket_prom,
       round(avg(passenger_count), 2) AS pasajeros_prom,
       round(100.0 * count_if(payment_type = 1) / count(*), 1) AS pct_tarjeta,
       round(100.0 * count_if(payment_type = 2) / count(*), 1) AS pct_efectivo,
       round(100.0 * count_if(z.borough = 'Manhattan') / count(*), 1) AS pct_origen_manhattan,
       round(100.0 * count_if(pu_location_id IN (1, 132, 138)) / count(*), 1) AS pct_origen_aeropuerto,
       round(100.0 * count_if(coalesce(cbd_congestion_fee, 0) > 0) / count(*), 1) AS pct_cargo_cbd
FROM viajes_limpios v
LEFT JOIN read_csv('data/raw/zones/taxi_zone_lookup.csv') z ON v.pu_location_id = z.LocationID
GROUP BY v.taxi;
