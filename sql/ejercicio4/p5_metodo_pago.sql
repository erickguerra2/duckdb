-- Objetivo: Método de pago y propina según tipo de taxi
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
SELECT taxi,
       CASE payment_type WHEN 0 THEN '0 flex fare' WHEN 1 THEN '1 tarjeta' WHEN 2 THEN '2 efectivo'
            WHEN 3 THEN '3 sin cargo' WHEN 4 THEN '4 disputa' ELSE 'otro o nulo' END AS metodo,
       count(*) AS viajes,
       round(100.0 * count(*) / sum(count(*)) OVER (PARTITION BY taxi), 2) AS pct_viajes,
       round(avg(tip_amount), 2) AS propina_prom,
       round(100.0 * sum(tip_amount) / nullif(sum(fare_amount), 0), 2) AS pct_propina_sobre_tarifa,
       round(100.0 * count_if(tip_amount > 0) / count(*), 1) AS pct_con_propina
FROM viajes_limpios
GROUP BY taxi, metodo
ORDER BY taxi, metodo;
