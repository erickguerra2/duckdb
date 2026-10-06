-- Objetivo: distancia y monto promedio por hora del dia
-- Tipo: agregacion con expresion sobre fecha y filtro
SELECT hour(pickup) AS hora,
       count(*) AS viajes,
       avg(trip_distance) AS distancia_prom,
       avg(total_amount) AS monto_prom
FROM {fuente}
WHERE total_amount > 0 AND trip_distance > 0
GROUP BY hora
ORDER BY hora;
