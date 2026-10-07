-- titulo: Velocidad promedio por hora en mph, origen Manhattan
-- pregunta: Cuando es mas lento moverse en Manhattan y cambio entre anios
-- grafico: line
-- dimensiones: hora, anio
-- metricas: mph
SELECT hour(v.pickup) AS hora,
       year(v.pickup)::VARCHAR AS anio,
       round(sum(v.trip_distance) / sum(v.duracion_min / 60), 2) AS mph
FROM viajes_limpios_tbl v
JOIN zonas z ON v.pu_location_id = z.location_id
WHERE z.borough = 'Manhattan'
GROUP BY ALL
ORDER BY anio, hora;
