-- Objetivo: Verificar si los nulos se concentran en un tipo de pago
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
SELECT payment_type,
       count(*) AS registros,
       count_if(passenger_count IS NULL) AS pasajeros_nulo,
       count_if(RatecodeID IS NULL) AS ratecode_nulo,
       count_if(store_and_fwd_flag IS NULL) AS flag_nulo,
       count_if(Airport_fee IS NULL) AS airport_fee_nulo,
       round(avg(total_amount), 2) AS total_promedio
FROM read_parquet('data/raw/yellow/2026/*.parquet', union_by_name = true)
GROUP BY payment_type
ORDER BY payment_type;
