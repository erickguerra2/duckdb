-- Objetivo: volumen de viajes por mes y tipo de taxi
-- Tipo: agregacion completa con pocas columnas
SELECT taxi, date_trunc('month', pickup) AS mes, count(*) AS viajes
FROM {fuente}
GROUP BY ALL
ORDER BY taxi, mes;
