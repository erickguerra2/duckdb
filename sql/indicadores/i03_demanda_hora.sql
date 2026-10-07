-- titulo: Viajes promedio por hora del dia
-- pregunta: En que horas se concentra la demanda entre semana y en fin de semana
-- grafico: line
-- dimensiones: hora, tipo_dia
-- metricas: viajes_por_dia
SELECT hour(pickup) AS hora,
       CASE WHEN isodow(pickup) IN (6, 7) THEN 'fin de semana' ELSE 'entre semana' END AS tipo_dia,
       round(count(*) / count(DISTINCT pickup::DATE), 0) AS viajes_por_dia
FROM viajes_limpios_tbl
GROUP BY ALL
ORDER BY tipo_dia, hora;
