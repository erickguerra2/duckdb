-- Objetivo: Velocidad promedio por hora y tipo de taxi
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
SELECT taxi, hour(pickup) AS hora,
       round(sum(trip_distance) / sum(duracion_min / 60), 2) AS mph
FROM viajes_limpios
GROUP BY ALL
ORDER BY taxi, hora;
