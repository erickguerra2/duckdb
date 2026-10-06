-- Objetivo: Registros, fechas y archivos por año y tipo en la vista
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2026}/*.parquet
SELECT anio_archivo AS anio, taxi,
       count(DISTINCT mes_archivo) AS meses,
       count(*) AS registros,
       min(pickup) FILTER (WHERE calidad = 'valido') AS primer_viaje,
       max(pickup) FILTER (WHERE calidad = 'valido') AS ultimo_viaje,
       round(100.0 * count_if(calidad <> 'valido') / count(*), 2) AS pct_invalidos
FROM viajes_calidad
GROUP BY ALL
ORDER BY anio, taxi;
