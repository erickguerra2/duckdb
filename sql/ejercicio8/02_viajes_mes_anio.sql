-- Objetivo: Viajes por día según mes y año para comparar estacionalidad
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2025,2026}/*.parquet
SELECT year(pickup)::VARCHAR AS anio, month(pickup) AS mes, taxi,
       round(count(*) / count(DISTINCT pickup::DATE)) AS viajes_por_dia
FROM viajes_limpios
GROUP BY ALL
ORDER BY anio, mes;
