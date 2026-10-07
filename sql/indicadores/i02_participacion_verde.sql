-- titulo: Participacion de taxis verdes en %
-- pregunta: Que peso tienen los taxis verdes dentro del total de viajes
-- grafico: line
-- dimensiones: mes
-- metricas: pct_verdes
SELECT date_trunc('month', pickup)::DATE AS mes,
       round(100.0 * count_if(taxi = 'green') / count(*), 2) AS pct_verdes
FROM viajes_limpios_tbl
GROUP BY mes
ORDER BY mes;
