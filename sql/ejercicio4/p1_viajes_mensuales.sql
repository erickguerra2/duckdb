-- Objetivo: Viajes válidos y promedio diario por mes
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
SELECT month(pickup) AS mes, taxi, count(*) AS viajes,
       round(count(*) / count(DISTINCT pickup::DATE)) AS viajes_por_dia
FROM viajes_limpios
GROUP BY ALL
ORDER BY taxi, mes;
