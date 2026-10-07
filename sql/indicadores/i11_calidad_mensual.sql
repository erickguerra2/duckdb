-- titulo: Registros descartados por calidad en %
-- pregunta: Que proporcion de registros no pasa las reglas de calidad cada mes
-- grafico: line
-- dimensiones: mes, taxi
-- metricas: pct_descartados
SELECT make_date(anio_archivo, mes_archivo, 1) AS mes, taxi,
       round(100.0 * count_if(calidad <> 'valido') / count(*), 2) AS pct_descartados
FROM viajes_tbl
GROUP BY ALL
ORDER BY mes, taxi;
