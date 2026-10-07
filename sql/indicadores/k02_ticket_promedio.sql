-- titulo: Ticket promedio en USD
-- pregunta: Cuanto paga en promedio un pasajero por viaje
-- grafico: scalar
-- metricas: ticket_promedio
SELECT round(avg(total_amount), 2) AS ticket_promedio
FROM viajes_limpios_tbl;
