-- titulo: Diez zonas con mas viajes de origen
-- pregunta: Donde se originan la mayoria de los viajes
-- grafico: row
-- dimensiones: zona
-- metricas: viajes
SELECT z.borough || ' - ' || z.zona AS zona, count(*) AS viajes
FROM viajes_limpios_tbl v
JOIN zonas z ON v.pu_location_id = z.location_id
GROUP BY ALL
ORDER BY viajes DESC
LIMIT 10;
