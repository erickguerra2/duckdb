-- titulo: Viajes mensuales por tipo de taxi
-- pregunta: Como evoluciona la demanda mes a mes en cada tipo de taxi
-- grafico: line
-- dimensiones: mes, taxi
-- metricas: viajes
-- escala: log
SELECT date_trunc('month', pickup)::DATE AS mes, taxi, count(*) AS viajes
FROM viajes_limpios_tbl
GROUP BY ALL
ORDER BY mes, taxi;
