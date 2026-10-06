-- Objetivo: Viajes válidos por día y tipo de taxi
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
SELECT pickup::DATE AS fecha, taxi, count(*) AS viajes
FROM viajes_limpios
GROUP BY ALL
ORDER BY fecha;
