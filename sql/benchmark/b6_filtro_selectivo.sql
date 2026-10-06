-- Objetivo: viajes a JFK en la primera semana de 2026
-- Tipo: filtro muy selectivo sobre fecha
SELECT taxi, count(*) AS viajes, avg(total_amount) AS monto_prom
FROM {fuente}
WHERE pickup >= TIMESTAMP '2026-01-01' AND pickup < TIMESTAMP '2026-01-08'
  AND ratecode_id = 2
GROUP BY taxi
ORDER BY taxi;
