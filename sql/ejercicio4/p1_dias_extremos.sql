-- Objetivo: Días con menos y más viajes amarillos
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
(SELECT 'menos' AS tipo, pickup::DATE AS fecha, dayname(pickup::DATE) AS dia, count(*) AS viajes
 FROM viajes_limpios WHERE taxi = 'yellow' GROUP BY ALL ORDER BY viajes LIMIT 5)
UNION ALL
(SELECT 'mas', pickup::DATE, dayname(pickup::DATE), count(*)
 FROM viajes_limpios WHERE taxi = 'yellow' GROUP BY ALL ORDER BY count(*) DESC LIMIT 5);
