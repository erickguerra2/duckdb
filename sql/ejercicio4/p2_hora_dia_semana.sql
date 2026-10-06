-- Objetivo: Viajes promedio por hora y día de la semana
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
SELECT isodow(pickup) AS dia, hour(pickup) AS hora,
       count(*) / count(DISTINCT pickup::DATE) AS viajes_por_dia
FROM viajes_limpios
GROUP BY ALL;
