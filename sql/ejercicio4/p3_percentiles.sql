-- Objetivo: Percentiles de las variables principales por tipo
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
UNPIVOT (
    SELECT taxi,
           quantile_cont(trip_distance, [0.05, 0.25, 0.5, 0.75, 0.95, 0.99]) AS distancia_mi,
           quantile_cont(duracion_min, [0.05, 0.25, 0.5, 0.75, 0.95, 0.99]) AS duracion_min,
           quantile_cont(total_amount, [0.05, 0.25, 0.5, 0.75, 0.95, 0.99]) AS total_usd,
           quantile_cont(passenger_count, [0.05, 0.25, 0.5, 0.75, 0.95, 0.99]) AS pasajeros
    FROM viajes_limpios
    GROUP BY taxi
) ON distancia_mi, duracion_min, total_usd, pasajeros INTO NAME variable VALUE percentiles;
