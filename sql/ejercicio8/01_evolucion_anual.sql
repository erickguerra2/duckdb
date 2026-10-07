-- Objetivo: Indicadores clave por año en enero a agosto
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2025,2026}/*.parquet
SELECT year(pickup) AS anio,
       count(*) AS viajes,
       round(count(*) / count(DISTINCT pickup::DATE)) AS viajes_por_dia,
       round(100.0 * count_if(taxi = 'green') / count(*), 2) AS pct_verdes,
       round(avg(total_amount), 2) AS ticket_prom,
       round(avg(fare_amount), 2) AS tarifa_prom,
       round(avg(trip_distance), 2) AS distancia_prom,
       round(100.0 * sum(tip_amount) FILTER (WHERE payment_type = 1)
             / sum(fare_amount) FILTER (WHERE payment_type = 1), 2) AS pct_propina_tarjeta,
       round(100.0 * count_if(payment_type = 2) / count(*), 2) AS pct_efectivo,
       round(100.0 * count_if(payment_type = 0) / count(*), 2) AS pct_flex_fare,
       round(100.0 * count_if(pu_location_id IN (1, 132, 138)) / count(*), 2) AS pct_aeropuerto,
       round(100.0 * count_if(coalesce(cbd_congestion_fee, 0) > 0) / count(*), 2) AS pct_cargo_cbd,
       round(sum(coalesce(cbd_congestion_fee, 0)) / 1e6, 2) AS cbd_recaudado_musd
FROM viajes_limpios
WHERE mes_archivo <= 8
GROUP BY anio
ORDER BY anio;
