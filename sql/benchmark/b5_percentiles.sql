-- Objetivo: percentiles de distancia y monto por tipo de taxi
-- Tipo: agregados holisticos, costosos en memoria
SELECT taxi,
       quantile_cont(trip_distance, [0.5, 0.9, 0.99]) AS distancia_p50_p90_p99,
       quantile_cont(total_amount, [0.5, 0.9, 0.99]) AS monto_p50_p90_p99
FROM {fuente}
GROUP BY taxi
ORDER BY taxi;
