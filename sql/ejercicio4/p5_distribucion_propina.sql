-- Objetivo: Distribución del porcentaje de propina con tarjeta
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
SELECT CASE WHEN tip_amount = 0 THEN '0'
            WHEN pct < 15 THEN '0 a 15'
            WHEN pct < 19 THEN '15 a 19'
            WHEN pct < 24 THEN '19 a 24'
            WHEN pct < 29 THEN '24 a 29'
            WHEN pct < 35 THEN '29 a 35'
            ELSE '35 o más' END AS rango_pct,
       count(*) AS viajes,
       round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS pct_viajes
FROM (SELECT tip_amount, 100 * tip_amount / (total_amount - tip_amount) AS pct
      FROM viajes_limpios
      WHERE payment_type = 1 AND taxi = 'yellow' AND total_amount - tip_amount > 0)
GROUP BY rango_pct
ORDER BY min(pct);
