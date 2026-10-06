-- Materializa en DuckDB
-- Requiere 01_vistas.sql

CREATE OR REPLACE TABLE zonas AS
SELECT
    LocationID   AS location_id,
    Borough      AS borough,
    Zone         AS zona,
    service_zone
FROM read_csv('data/raw/zones/taxi_zone_lookup.csv', header = true);

-- Orden por fecha
CREATE OR REPLACE TABLE viajes_tbl AS
SELECT * FROM viajes_calidad
ORDER BY pickup;

-- Viajes validos materializados
CREATE OR REPLACE VIEW viajes_limpios_tbl AS
SELECT * FROM viajes_tbl WHERE calidad = 'valido';
