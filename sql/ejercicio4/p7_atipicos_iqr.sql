-- Objetivo: Atípicos de monto y distancia según regla IQR entre válidos
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
WITH limites AS (
    SELECT taxi,
           quantile_cont(total_amount, 0.25) AS q1_t, quantile_cont(total_amount, 0.75) AS q3_t,
           quantile_cont(trip_distance, 0.25) AS q1_d, quantile_cont(trip_distance, 0.75) AS q3_d
    FROM viajes_limpios GROUP BY taxi
)
SELECT v.taxi,
       round(any_value(q3_t + 1.5 * (q3_t - q1_t)), 2) AS limite_total,
       round(100.0 * count_if(total_amount > q3_t + 1.5 * (q3_t - q1_t)) / count(*), 2) AS pct_total_atipico,
       round(any_value(q3_d + 1.5 * (q3_d - q1_d)), 2) AS limite_distancia,
       round(100.0 * count_if(trip_distance > q3_d + 1.5 * (q3_d - q1_d)) / count(*), 2) AS pct_dist_atipica,
       round(100.0 * count_if(trip_distance > q3_d + 1.5 * (q3_d - q1_d) AND pu_location_id IN (1, 132, 138)
             OR trip_distance > q3_d + 1.5 * (q3_d - q1_d) AND do_location_id IN (1, 132, 138))
             / nullif(count_if(trip_distance > q3_d + 1.5 * (q3_d - q1_d)), 0), 1) AS pct_atipicos_aeropuerto
FROM viajes_limpios v JOIN limites USING (taxi)
GROUP BY v.taxi;
