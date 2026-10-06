-- Objetivo: Aporte promedio de cada componente al total
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
UNPIVOT (
    SELECT taxi,
           avg(fare_amount) AS tarifa, avg(extra) AS extra, avg(mta_tax) AS mta_tax,
           avg(tip_amount) AS propina, avg(tolls_amount) AS peajes,
           avg(improvement_surcharge) AS improvement, avg(congestion_surcharge) AS congestion_nys,
           avg(coalesce(airport_fee, 0)) AS aeropuerto, avg(coalesce(cbd_congestion_fee, 0)) AS cbd,
           avg(total_amount) AS total
    FROM viajes_limpios
    GROUP BY taxi
) ON COLUMNS(* EXCLUDE (taxi)) INTO NAME componente VALUE usd;
