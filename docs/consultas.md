# Catálogo de consultas

Generado automáticamente por notebooks/Lab8_DuckDB.ipynb. Cada consulta está en sql con el mismo nombre.

| Consulta | Objetivo | Fuente | Filas | Segundos |
|---|---|---|---|---|
| sql/ejercicio3/01_cantidad_archivos.sql | Contar los archivos Parquet de 2026 por tipo de taxi | data/raw/{yellow,green}/2026/*.parquet | 2 | 0.05 |
| sql/ejercicio3/02_cantidad_registros.sql | Contar registros leyendo los archivos completos | data/raw/{yellow,green}/2026/*.parquet | 2 | 0.09 |
| sql/ejercicio3/03_registros_metadatos.sql | Contar registros solo desde los metadatos Parquet | data/raw/{yellow,green}/2026/*.parquet | 2 | 0.05 |
| sql/ejercicio3/04_columnas_por_archivo.sql | Columnas y tipo físico presentes en cada archivo | data/raw/{yellow,green}/2026/*.parquet | 43 | 0.05 |
| sql/ejercicio3/05_tipos_yellow.sql | Tipos lógicos que DuckDB asigna a las columnas de taxis amarillos | data/raw/{yellow,green}/2026/*.parquet | 21 | 0.04 |
| sql/ejercicio3/06_tipos_green.sql | Tipos lógicos que DuckDB asigna a las columnas de taxis verdes | data/raw/{yellow,green}/2026/*.parquet | 22 | 0.04 |
| sql/ejercicio3/07_muestra_yellow.sql | Muestra reproducible de viajes amarillos | data/raw/{yellow,green}/2026/*.parquet | 5 | 0.21 |
| sql/ejercicio3/08_muestra_green.sql | Muestra reproducible de viajes verdes | data/raw/{yellow,green}/2026/*.parquet | 5 | 0.11 |
| sql/ejercicio3/09_perfil_yellow.sql | Perfil estadístico de todas las columnas amarillas | data/raw/{yellow,green}/2026/*.parquet | 21 | 11.44 |
| sql/ejercicio3/10_perfil_green.sql | Perfil estadístico de todas las columnas verdes | data/raw/{yellow,green}/2026/*.parquet | 22 | 0.33 |
| sql/ejercicio3/11_fechas_fuera_de_archivo.sql | Viajes cuya fecha no corresponde al mes del archivo | data/raw/{yellow,green}/2026/*.parquet | 2 | 0.88 |
| sql/ejercicio3/12_reglas_inconsistencia.sql | Contar registros que violan reglas básicas de negocio | data/raw/{yellow,green}/2026/*.parquet | 2 | 1.58 |
| sql/ejercicio3/13_codigos_categoricos.sql | Revisar códigos contra el diccionario de la TLC | data/raw/{yellow,green}/2026/*.parquet | 18 | 0.59 |
| sql/ejercicio3/14_nulos_flex_fare.sql | Verificar si los nulos se concentran en un tipo de pago | data/raw/{yellow,green}/2026/*.parquet | 6 | 0.49 |
| sql/ejercicio3/15_request_source.sql | Explorar la columna nueva request_source por mes | data/raw/{yellow,green}/2026/*.parquet | 29 | 0.32 |
| sql/ejercicio3/16_duplicados.sql | Detectar viajes repetidos con la misma huella | data/raw/{yellow,green}/2026/*.parquet | 1 | 1.88 |
| sql/ejercicio4/00_clasificacion_calidad.sql | Cuántos registros descarta cada regla de calidad | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 17 | 1.4 |
| sql/ejercicio4/p1_viajes_diarios.sql | Viajes válidos por día y tipo de taxi | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 486 | 1.48 |
| sql/ejercicio4/p1_viajes_mensuales.sql | Viajes válidos y promedio diario por mes | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 16 | 1.59 |
| sql/ejercicio4/p1_dias_extremos.sql | Días con menos y más viajes amarillos | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 10 | 1.46 |
| sql/ejercicio4/p2_hora_dia_semana.sql | Viajes promedio por hora y día de la semana | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 168 | 1.64 |
| sql/ejercicio4/p3_percentiles.sql | Percentiles de las variables principales por tipo | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 8 | 9.35 |
| sql/ejercicio4/p3_histograma_distancia.sql | Histograma de distancia en intervalos de media milla | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 82 | 1.55 |
| sql/ejercicio4/p4_comparacion_tipos.sql | Perfil comparativo de taxis amarillos y verdes | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 2 | 2.81 |
| sql/ejercicio4/p4_borough_origen.sql | Distribución del borough de origen por tipo | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 15 | 1.63 |
| sql/ejercicio4/p5_metodo_pago.sql | Método de pago y propina según tipo de taxi | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 10 | 1.59 |
| sql/ejercicio4/p5_distribucion_propina.sql | Distribución del porcentaje de propina con tarjeta | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 7 | 1.62 |
| sql/ejercicio4/p6_componentes_total.sql | Aporte promedio de cada componente al total | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 20 | 2.1 |
| sql/ejercicio4/p7_calidad_proveedor.sql | Tasa de registros inválidos por proveedor | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 7 | 1.6 |
| sql/ejercicio4/p7_atipicos_iqr.sql | Atípicos de monto y distancia según regla IQR entre válidos | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 2 | 7.75 |
| sql/ejercicio4/p7_ejemplos_extremos.sql | Ejemplos de registros descartados más extremos | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 8 | 1.62 |
| sql/ejercicio4/p8_velocidad_hora.sql | Velocidad promedio por hora y tipo de taxi | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2026}/*.parquet | 48 | 1.48 |
| sql/ejercicio5/01_registros_por_anio.sql | Registros, fechas y archivos por año y tipo en la vista | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2026}/*.parquet | 4 | 3.21 |
| sql/ejercicio5/02_esquema_por_anio.sql | Columnas presentes por año para detectar cambios de esquema | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2026}/*.parquet | 9 | 0.1 |
| sql/ejercicio5/03_columnas_nuevas.sql | Cómo se ven las columnas nuevas al unir años | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2026}/*.parquet | 4 | 0.41 |
| sql/ejercicio5/04_continuidad_mensual.sql | Verificar que cada mes tenga datos en ambos años | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2026}/*.parquet | 12 | 0.32 |
| sql/ejercicio5/05_comparacion_anual.sql | Perfil comparativo por año con la misma lógica del ejercicio 4 | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2026}/*.parquet | 4 | 3.33 |
| sql/indicadores/i01_viajes_mensuales.sql | Como evoluciona la demanda mes a mes en cada tipo de taxi | data/processed/taxi.duckdb 2024, 2025 y 2026 | 64 | 2.737 |
| sql/indicadores/i02_participacion_verde.sql | Que peso tienen los taxis verdes dentro del total de viajes | data/processed/taxi.duckdb 2024, 2025 y 2026 | 32 | 0.962 |
| sql/indicadores/i03_demanda_hora.sql | En que horas se concentra la demanda entre semana y en fin de semana | data/processed/taxi.duckdb 2024, 2025 y 2026 | 48 | 0.853 |
| sql/indicadores/i04_ticket_mensual.sql | Como cambia el monto pagado por viaje a lo largo del tiempo | data/processed/taxi.duckdb 2024, 2025 y 2026 | 64 | 1.472 |
| sql/indicadores/i05_propina_mensual.sql | Cambia la generosidad de los pasajeros entre meses y tipos de taxi | data/processed/taxi.duckdb 2024, 2025 y 2026 | 64 | 2.535 |
| sql/indicadores/i06_mezcla_pago.sql | Como se reparte el metodo de pago y como cambia entre anios | data/processed/taxi.duckdb 2024, 2025 y 2026 | 12 | 1.18 |
| sql/indicadores/i07_velocidad_hora.sql | Cuando es mas lento moverse en Manhattan y cambio entre anios | data/processed/taxi.duckdb 2024, 2025 y 2026 | 72 | 3.366 |
| sql/indicadores/i08_top_zonas.sql | Donde se originan la mayoria de los viajes | data/processed/taxi.duckdb 2024, 2025 y 2026 | 10 | 0.639 |
| sql/indicadores/i09_aeropuertos.sql | Que tan dependiente es el servicio de los aeropuertos JFK, LaGuardia y Newark | data/processed/taxi.duckdb 2024, 2025 y 2026 | 32 | 0.667 |
| sql/indicadores/i10_cargo_cbd.sql | Que alcance tiene el cargo por la zona de congestion vigente desde enero 2025 | data/processed/taxi.duckdb 2024, 2025 y 2026 | 32 | 1.026 |
| sql/indicadores/i11_calidad_mensual.sql | Que proporcion de registros no pasa las reglas de calidad cada mes | data/processed/taxi.duckdb 2024, 2025 y 2026 | 64 | 0.263 |
| sql/indicadores/k01_viajes_validos.sql | Cuantos viajes validos hay en el periodo analizado | data/processed/taxi.duckdb 2024, 2025 y 2026 | 1 | 0.061 |
| sql/indicadores/k02_ticket_promedio.sql | Cuanto paga en promedio un pasajero por viaje | data/processed/taxi.duckdb 2024, 2025 y 2026 | 1 | 0.076 |
| sql/indicadores/k03_propina_tarjeta.sql | Que porcentaje de la tarifa se deja de propina al pagar con tarjeta | data/processed/taxi.duckdb 2024, 2025 y 2026 | 1 | 0.15 |
| sql/ejercicio8/01_evolucion_anual.sql | Indicadores clave por año en enero a agosto | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2025,2026}/*.parquet | 3 | 5.94 |
| sql/ejercicio8/02_viajes_mes_anio.sql | Viajes por día según mes y año para comparar estacionalidad | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2025,2026}/*.parquet | 64 | 5.35 |
| sql/ejercicio8/03_continuidad_mensual.sql | Archivos con datos por mes, tipo y año | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2025,2026}/*.parquet | 12 | 0.97 |
| sql/ejercicio8/04_velocidad_cbd.sql | Velocidad y duración de viajes que entran o salen de Manhattan bajo la calle 60 | vistas de sql/01_vistas.sql sobre data/raw/{yellow,green}/{2024,2025,2026}/*.parquet | 6 | 6.28 |
