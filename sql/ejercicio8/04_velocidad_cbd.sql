-- Objetivo: Velocidad y duración de viajes que entran o salen de Manhattan bajo la calle 60
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2025,2026}/*.parquet
WITH z AS (SELECT location_id FROM read_csv('data/raw/zones/taxi_zone_lookup.csv', header = true)
                t(location_id, borough, zona, service_zone)
           WHERE borough = 'Manhattan' AND zona NOT IN (
               'Central Harlem', 'Central Harlem North', 'East Harlem North', 'East Harlem South',
               'Hamilton Heights', 'Inwood', 'Inwood Hill Park', 'Manhattanville', 'Morningside Heights',
               'Washington Heights North', 'Washington Heights South', 'Upper West Side North',
               'Upper West Side South', 'Upper East Side North', 'Upper East Side South',
               'Lincoln Square East', 'Lincoln Square West', 'Bloomingdale', 'Yorkville East', 'Yorkville West',
               'Central Park', 'Randalls Island', 'Marble Hill', 'Highbridge Park', 'Lenox Hill East',
               'Lenox Hill West', 'Roosevelt Island'))
SELECT year(pickup) AS anio,
       CASE WHEN hour(pickup) BETWEEN 7 AND 19 AND isodow(pickup) <= 5 THEN 'laboral 7 a 19h' ELSE 'resto' END AS franja,
       count(*) AS viajes,
       round(sum(trip_distance) / sum(duracion_min / 60), 2) AS mph,
       round(median(duracion_min), 1) AS duracion_mediana
FROM viajes_limpios
WHERE taxi = 'yellow' AND mes_archivo <= 8
  AND pu_location_id IN (SELECT location_id FROM z) AND do_location_id IN (SELECT location_id FROM z)
GROUP BY ALL
ORDER BY franja, anio;
