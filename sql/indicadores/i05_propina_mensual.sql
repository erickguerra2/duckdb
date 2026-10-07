-- titulo: Propina con tarjeta en % de la tarifa
-- pregunta: Cambia la generosidad de los pasajeros entre meses y tipos de taxi
-- grafico: line
-- dimensiones: mes, taxi
-- metricas: pct_propina
SELECT date_trunc('month', pickup)::DATE AS mes, taxi,
       round(sum(tip_amount) / sum(fare_amount) * 100, 2) AS pct_propina
FROM viajes_limpios_tbl
WHERE payment_type = 1 AND fare_amount > 0
GROUP BY ALL
ORDER BY mes, taxi;
