-- Objetivo: Distribución del borough de origen por tipo
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
SELECT v.taxi, z.Borough AS borough, count(*) AS viajes,
       round(100.0 * count(*) / sum(count(*)) OVER (PARTITION BY v.taxi), 1) AS pct
FROM viajes_limpios v
JOIN read_csv('data/raw/zones/taxi_zone_lookup.csv') z ON v.pu_location_id = z.LocationID
GROUP BY v.taxi, z.Borough
ORDER BY v.taxi, viajes DESC;
