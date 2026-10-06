-- Objetivo: porcentaje de propina por tipo de taxi y metodo de pago
-- Tipo: agregacion con varias columnas numericas
SELECT taxi, payment_type,
       count(*) AS viajes,
       sum(tip_amount) / nullif(sum(fare_amount), 0) * 100 AS pct_propina
FROM {fuente}
WHERE fare_amount > 0
GROUP BY ALL
ORDER BY taxi, payment_type;
