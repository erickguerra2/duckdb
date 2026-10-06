-- Objetivo: Perfil comparativo por año con la misma lógica del ejercicio 4
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2026}/*.parquet
SELECT anio_archivo AS anio, taxi,
       count(*) AS viajes,
       round(count(*) / count(DISTINCT pickup::DATE)) AS viajes_por_dia,
       round(avg(trip_distance), 2) AS distancia_prom,
       round(avg(total_amount), 2) AS ticket_prom,
       round(100.0 * count_if(payment_type = 2) / count(*), 1) AS pct_efectivo,
       round(avg(coalesce(cbd_congestion_fee, 0)), 2) AS cbd_prom
FROM viajes_limpios
WHERE mes_archivo <= 8
GROUP BY ALL
ORDER BY taxi, anio;
