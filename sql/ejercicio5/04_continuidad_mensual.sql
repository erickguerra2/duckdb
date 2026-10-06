-- Objetivo: Verificar que cada mes tenga datos en ambos años
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2026}/*.parquet
SELECT mes_archivo AS mes,
       sum(CASE WHEN anio_archivo = 2024 AND taxi = 'yellow' THEN 1 END) AS yellow_2024,
       sum(CASE WHEN anio_archivo = 2026 AND taxi = 'yellow' THEN 1 END) AS yellow_2026,
       sum(CASE WHEN anio_archivo = 2024 AND taxi = 'green' THEN 1 END) AS green_2024,
       sum(CASE WHEN anio_archivo = 2026 AND taxi = 'green' THEN 1 END) AS green_2026
FROM viajes
GROUP BY mes
ORDER BY mes;
