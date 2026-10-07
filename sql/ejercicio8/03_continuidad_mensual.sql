-- Objetivo: Archivos con datos por mes, tipo y año
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2025,2026}/*.parquet
SELECT * FROM (
    PIVOT (SELECT anio_archivo, mes_archivo, taxi FROM viajes)
    ON taxi || '_' || anio_archivo USING count(*)
)
ORDER BY mes_archivo;
