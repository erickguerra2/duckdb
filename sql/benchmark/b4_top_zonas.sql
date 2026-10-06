-- Objetivo: diez zonas de origen con mas viajes
-- Tipo: agregacion de alta cardinalidad con join
SELECT z.borough, z.zona, count(*) AS viajes
FROM {fuente} v
JOIN zonas z ON v.pu_location_id = z.location_id
GROUP BY ALL
ORDER BY viajes DESC
LIMIT 10;
