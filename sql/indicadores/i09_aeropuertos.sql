-- titulo: Viajes con origen en aeropuertos en %
-- pregunta: Que tan dependiente es el servicio de los aeropuertos JFK, LaGuardia y Newark
-- grafico: line
-- dimensiones: mes
-- metricas: pct_aeropuerto
SELECT date_trunc('month', pickup)::DATE AS mes,
       round(100.0 * count_if(pu_location_id IN (1, 132, 138)) / count(*), 2) AS pct_aeropuerto
FROM viajes_limpios_tbl
GROUP BY mes
ORDER BY mes;
