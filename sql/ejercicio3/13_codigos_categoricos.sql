-- Objetivo: Revisar códigos contra el diccionario de la TLC
-- Fuente: data/raw/{yellow,green}/2026/*.parquet
SELECT 'payment_type' AS campo, payment_type::VARCHAR AS codigo, count(*) AS registros
FROM read_parquet('data/raw/yellow/2026/*.parquet', union_by_name = true) GROUP BY ALL
UNION ALL
SELECT 'RatecodeID', RatecodeID::VARCHAR, count(*)
FROM read_parquet('data/raw/yellow/2026/*.parquet', union_by_name = true) GROUP BY ALL
UNION ALL
SELECT 'VendorID', VendorID::VARCHAR, count(*)
FROM read_parquet('data/raw/yellow/2026/*.parquet', union_by_name = true) GROUP BY ALL
ORDER BY campo, codigo;
