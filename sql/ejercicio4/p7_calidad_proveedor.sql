-- Objetivo: Tasa de registros inválidos por proveedor
-- Fuente: vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet
SELECT taxi, vendor_id,
       CASE vendor_id WHEN 1 THEN 'Creative Mobile' WHEN 2 THEN 'Curb Mobility'
            WHEN 6 THEN 'Myle' WHEN 7 THEN 'Helix' ELSE 'otro' END AS proveedor,
       count(*) AS registros,
       round(100.0 * count_if(calidad <> 'valido') / count(*), 2) AS pct_invalidos,
       mode(calidad) FILTER (WHERE calidad <> 'valido') AS falla_principal
FROM viajes_calidad
GROUP BY ALL
ORDER BY taxi, vendor_id;
