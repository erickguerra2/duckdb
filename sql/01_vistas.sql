-- Vistas sobre Parquet
-- Ejecutar desde la raiz
-- taxi_db.py ajusta los anios

-- Esquema comun garantizado
CREATE OR REPLACE VIEW esquema_base AS
SELECT
    NULL::VARCHAR   AS taxi,
    NULL::VARCHAR   AS filename,
    NULL::INTEGER   AS VendorID,
    NULL::TIMESTAMP AS pickup,
    NULL::TIMESTAMP AS dropoff,
    NULL::BIGINT    AS passenger_count,
    NULL::DOUBLE    AS trip_distance,
    NULL::BIGINT    AS RatecodeID,
    NULL::VARCHAR   AS store_and_fwd_flag,
    NULL::INTEGER   AS PULocationID,
    NULL::INTEGER   AS DOLocationID,
    NULL::BIGINT    AS payment_type,
    NULL::BIGINT    AS trip_type,
    NULL::DOUBLE    AS fare_amount,
    NULL::DOUBLE    AS extra,
    NULL::DOUBLE    AS mta_tax,
    NULL::DOUBLE    AS tip_amount,
    NULL::DOUBLE    AS tolls_amount,
    NULL::DOUBLE    AS improvement_surcharge,
    NULL::DOUBLE    AS congestion_surcharge,
    NULL::DOUBLE    AS Airport_fee,
    NULL::DOUBLE    AS cbd_congestion_fee,
    NULL::DOUBLE    AS ehail_fee,
    NULL::DOUBLE    AS total_amount,
    NULL::VARCHAR   AS request_source
WHERE false;

CREATE OR REPLACE VIEW yellow_raw AS
SELECT 'yellow' AS taxi,
       * RENAME (tpep_pickup_datetime AS pickup, tpep_dropoff_datetime AS dropoff)
FROM read_parquet('data/raw/yellow/*/*.parquet', union_by_name = true, filename = true);

CREATE OR REPLACE VIEW green_raw AS
SELECT 'green' AS taxi,
       * RENAME (lpep_pickup_datetime AS pickup, lpep_dropoff_datetime AS dropoff)
FROM read_parquet('data/raw/green/*/*.parquet', union_by_name = true, filename = true);

-- Vista unificada homologada
CREATE OR REPLACE VIEW viajes AS
SELECT
    taxi,
    CAST(regexp_extract(filename, '_(\d{4})-\d{2}\.parquet$', 1) AS INTEGER) AS anio_archivo,
    CAST(regexp_extract(filename, '_\d{4}-(\d{2})\.parquet$', 1) AS INTEGER) AS mes_archivo,
    VendorID                         AS vendor_id,
    pickup,
    dropoff,
    CAST(passenger_count AS INTEGER) AS passenger_count,
    trip_distance,
    CAST(RatecodeID AS INTEGER)      AS ratecode_id,
    store_and_fwd_flag,
    PULocationID                     AS pu_location_id,
    DOLocationID                     AS do_location_id,
    CAST(payment_type AS INTEGER)    AS payment_type,
    CAST(trip_type AS INTEGER)       AS trip_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    congestion_surcharge,
    Airport_fee                      AS airport_fee,
    cbd_congestion_fee,
    ehail_fee,
    total_amount,
    request_source
FROM (
    SELECT * FROM esquema_base
    UNION ALL BY NAME SELECT * FROM yellow_raw
    UNION ALL BY NAME SELECT * FROM green_raw
);

-- Primera regla fallida
CREATE OR REPLACE VIEW viajes_calidad AS
SELECT
    *,
    date_diff('second', pickup, dropoff) / 60.0 AS duracion_min,
    CASE
        WHEN year(pickup) <> anio_archivo OR month(pickup) <> mes_archivo THEN 'fecha_fuera_de_archivo'
        WHEN dropoff <= pickup                                            THEN 'duracion_no_positiva'
        WHEN date_diff('second', pickup, dropoff) > 6 * 3600              THEN 'duracion_mayor_6h'
        WHEN trip_distance IS NULL OR trip_distance <= 0                  THEN 'distancia_no_positiva'
        WHEN trip_distance > 100                                          THEN 'distancia_mayor_100mi'
        WHEN total_amount IS NULL OR total_amount <= 0 OR fare_amount < 0 THEN 'monto_no_positivo'
        WHEN total_amount > 1000                                          THEN 'monto_mayor_1000'
        WHEN trip_distance / (date_diff('second', pickup, dropoff) / 3600.0) > 80
                                                                          THEN 'velocidad_mayor_80mph'
        ELSE 'valido'
    END AS calidad
FROM viajes;

CREATE OR REPLACE VIEW viajes_limpios AS
SELECT * FROM viajes_calidad WHERE calidad = 'valido';
