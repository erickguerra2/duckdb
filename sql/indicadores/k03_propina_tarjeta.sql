-- titulo: Propina promedio con tarjeta en %
-- pregunta: Que porcentaje de la tarifa se deja de propina al pagar con tarjeta
-- grafico: scalar
-- metricas: pct_propina
SELECT round(sum(tip_amount) / sum(fare_amount) * 100, 1) AS pct_propina
FROM viajes_limpios_tbl
WHERE payment_type = 1 AND fare_amount > 0;
