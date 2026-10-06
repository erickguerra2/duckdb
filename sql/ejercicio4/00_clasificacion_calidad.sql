-- Objetivo: Cuántos registros descarta cada regla de calidad
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
SELECT taxi, calidad, count(*) AS registros,
       round(100.0 * count(*) / sum(count(*)) OVER (PARTITION BY taxi), 2) AS pct
FROM viajes_calidad
GROUP BY taxi, calidad
ORDER BY taxi, registros DESC;
