-- titulo: Metodo de pago por anio en %
-- pregunta: Como se reparte el metodo de pago y como cambia entre anios
-- grafico: bar
-- dimensiones: anio, metodo
-- metricas: pct_viajes
-- apilado: si
SELECT year(pickup)::VARCHAR AS anio,
       CASE payment_type
           WHEN 0 THEN 'flex fare'
           WHEN 1 THEN 'tarjeta'
           WHEN 2 THEN 'efectivo'
           ELSE 'otro'
       END AS metodo,
       round(100.0 * count(*) / sum(count(*)) OVER (PARTITION BY year(pickup)), 2) AS pct_viajes
FROM viajes_limpios_tbl
GROUP BY year(pickup), metodo
ORDER BY anio, metodo;
