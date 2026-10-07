-- titulo: Ticket promedio mensual en USD
-- pregunta: Como cambia el monto pagado por viaje a lo largo del tiempo
-- grafico: line
-- dimensiones: mes, taxi
-- metricas: ticket_promedio
SELECT date_trunc('month', pickup)::DATE AS mes, taxi,
       round(avg(total_amount), 2) AS ticket_promedio
FROM viajes_limpios_tbl
GROUP BY ALL
ORDER BY mes, taxi;
