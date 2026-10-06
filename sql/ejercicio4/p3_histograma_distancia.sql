-- Objetivo: Histograma de distancia en intervalos de media milla
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
SELECT taxi, least(floor(trip_distance * 2) / 2, 20) AS intervalo, count(*) AS viajes
FROM viajes_limpios
GROUP BY ALL
ORDER BY taxi, intervalo;
