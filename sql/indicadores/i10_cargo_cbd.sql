-- titulo: Viajes con cargo de congestion CBD en %
-- pregunta: Que alcance tiene el cargo por la zona de congestion vigente desde enero 2025
-- grafico: line
-- dimensiones: mes
-- metricas: pct_con_cargo
SELECT date_trunc('month', pickup)::DATE AS mes,
       round(100.0 * count_if(coalesce(cbd_congestion_fee, 0) > 0) / count(*), 2) AS pct_con_cargo,
       round(avg(cbd_congestion_fee) FILTER (WHERE cbd_congestion_fee > 0), 2) AS cargo_promedio
FROM viajes_limpios_tbl
GROUP BY mes
ORDER BY mes;
