# Lab 8 - DuckDB

Repositorio base del laboratorio 8 del curso **CC3084 - Data Science**
(Universidad del Valle de Guatemala, Ciclo 2, 2026).

Este es el repositorio **proporcionado por el docente**. Contiene la estructura
del proyecto, el ambiente de ejecucion basado en Docker y un script que descarga
los datos de **2026**. Todo lo demas debe ser construido por cada equipo.

## Trabajo con fork

El laboratorio se desarrolla y se entrega sobre un **fork** de este repositorio.
No se trabaja directamente sobre el repositorio del docente.

1. Realice un fork de este repositorio:
   <https://github.com/menene/duckdb>

2. Clone **su propio fork** (no el del docente):

   ```bash
   git clone https://github.com/<su-usuario>/duckdb.git
   cd duckdb
   ```

3. Opcional, para recibir correcciones publicadas por el docente:

   ```bash
   git remote add upstream https://github.com/menene/duckdb.git
   git fetch upstream
   ```

Realice commits frecuentes y descriptivos: el historial del repositorio es parte
de la evaluacion. **La entrega del laboratorio es la URL de su fork.**

## Estructura

```text
duckdb/
|
+-- data/
|   +-- raw/
|   +-- processed/
|
+-- notebooks/
|
+-- scripts/
|
+-- sql/
|
+-- docs/
|
+-- Dockerfile
+-- metabase.Dockerfile
+-- docker-compose.yml
+-- README.md
```

## Requisitos

- Docker, con Docker Compose
- Git

La primera construccion del ambiente descarga varios cientos de MB y puede
tardar algunos minutos.

Considere el espacio en disco: las imagenes de Docker ocupan unos 3 GB y los
datos de los tres anios del laboratorio superan 1.5 GB, a los que se suma la
base materializada del Ejercicio 6. Se recomienda tener al menos 10 GB libres.

## Datos

El repositorio incluye `scripts/download_data.py`, que descarga los archivos de
2026 publicados por la TLC (`--help` muestra las opciones disponibles). Los
archivos se guardan en `data/raw/<tipo>/<anio>/`.

La TLC publica cada mes con varias semanas de atraso, por lo que los ultimos
meses de 2026 todavia no existen. El script consulta al servidor que meses estan
publicados, de modo que vuelve a ejecutarse sin problema conforme aparezcan
nuevos archivos.

Los datos descargados **no deben incluirse en el repositorio Git**. El archivo
`.gitignore` ya esta configurado para evitarlo.

Fuente de datos: NYC TLC Trip Record Data
<https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page>

Dentro de los contenedores, la carpeta `data/` del proyecto esta montada en
`/workspace/data`. Esa es la ruta que deben usar las herramientas que corren
dentro del ambiente, no la ruta de su computadora.

> **Nota sobre DuckDB:** un archivo `.duckdb` admite un solo proceso con permiso
> de escritura a la vez. Si conecta una herramienta externa a su base de datos,
> use el modo de solo lectura (`read_only`) en esa conexion; de lo contrario los
> demas procesos no podran abrir el archivo.

## Material a entregar

Al finalizar, su fork debe contener:

- el codigo fuente modificado y los scripts de descarga;
- las consultas SQL desarrolladas;
- el notebook o notebooks utilizados;
- la documentacion de las consultas;
- los scripts utilizados para los benchmarks;
- el codigo de los indicadores y visualizaciones;
- el tablero o la evidencia del tablero desarrollado;
- este `README.md`, completado segun la siguiente seccion.

Los archivos de datos descargados **no** deben incluirse.

---

# Documentacion del equipo

Las siguientes secciones deben ser completadas por cada equipo. El README final
debe permitir que una persona que no participo en el desarrollo pueda levantar el
ambiente, descargar los datos, ejecutar el analisis, reproducir los benchmarks y
generar los resultados principales.

Fork del equipo: https://github.com/erickguerra2/duckdb

## Como levantar el ambiente

Requisitos: Docker Desktop con Docker Compose, Git y al menos 10 GB libres. Se probó en Windows 11 con Docker 29.2.

1. Clonar el fork y entrar a la carpeta:

        git clone https://github.com/erickguerra2/duckdb.git
        cd duckdb

2. Construir y levantar los dos servicios en segundo plano. La primera vez tarda varios minutos:

        docker compose up --build -d

3. Verificar que ambos contenedores estén arriba y respondan:

        docker compose ps
        curl http://127.0.0.1:8888/lab
        curl http://127.0.0.1:3000/api/health

   La última respuesta debe ser {"status":"ok"}.

Servicios disponibles:

| Servicio | Contenedor | Dirección | Contenido |
|---|---|---|---|
| JupyterLab | lab8-lab | http://127.0.0.1:8888 | Python 3.11, DuckDB 1.5.5, pandas, pyarrow, matplotlib, requests |
| Metabase | lab8-metabase | http://127.0.0.1:3000 | Metabase 0.63 con el driver de DuckDB 1.5.5 |

Todos los comandos siguientes se ejecutan desde la raíz del repositorio. Los que empiezan con docker compose exec lab corren dentro del contenedor de análisis, donde la raíz está montada en /workspace. En Git Bash para Windows conviene anteponer MSYS_NO_PATHCONV=1 a los comandos que usan rutas como /workspace.

Para detener el ambiente sin borrar nada:

    docker compose stop

## Como descargar los datos

El script scripts/download_data.py descarga los Parquet mensuales de taxis amarillos y verdes desde la TLC:

    docker compose exec lab python scripts/download_data.py                  # 2024 y 2026
    docker compose exec lab python scripts/download_data.py --anio 2026      # solo 2026
    docker compose exec lab python scripts/download_data.py --anio 2024 2026 --taxi green
    docker compose exec lab python scripts/download_data.py --verificar      # valida sin descargar

Los archivos quedan en data/raw/tipo/año/nombre-original.parquet y el catálogo de zonas en data/raw/zones/taxi_zone_lookup.csv. Los archivos de 2024 y 2026 ocupan unos 1.2 GB.

Cambios realizados al script original:

- El año dejó de ser una constante fija. Todas las funciones lo reciben como parámetro y el argumento --anio acepta uno o varios años.
- En el año en curso solo se consultan los meses hasta la fecha actual.
- Cada descarga compara los bytes recibidos con el Content-Length del servidor y se descarta si no coinciden.
- Al terminar se valida cada archivo local: tamaño contra el servidor, lectura de metadatos Parquet, filas, columnas y huecos de meses intermedios.
- El resultado de la validación se guarda en docs/manifest_descargas.csv.
- Se descarga el catálogo de zonas de la TLC.
- Se mantuvo la regla de no volver a descargar archivos existentes y la escritura atómica con archivo .part.

Cómo se verifica que la descarga está completa: ningún mes publicado queda sin descargar, no hay meses faltantes en medio, todos los tamaños coinciden con el servidor y todos los archivos abren como Parquet. Las bitácoras de cada ejecución están en docs/logs. Con datos hasta agosto de 2026 el resultado es de 40 archivos y 71,870,407 registros.

## Como ejecutar el analisis

<!-- TODO -->

## Como reproducir los benchmarks

    docker compose exec lab python scripts/benchmark.py
    docker compose exec lab python scripts/benchmark.py --repeticiones 3 --escala "1 mes" 2026

Para cada escala de datos, un mes, 2026, 2024 más 2026 y los tres años, el script materializa una tabla en data/processed/benchmark.duckdb, mide su costo de carga y ejecuta cada consulta de sql/benchmark cinco veces sobre Parquet y cinco sobre la tabla, alternando el orden. Tarda unos 10 minutos. Resultados:

- docs/benchmark/tiempos.csv: una fila por ejecución
- docs/benchmark/materializacion.csv: filas, segundos de carga y tamaños
- docs/logs/benchmark.txt: resumen con medianas

El notebook lee esos archivos en el ejercicio 6. Para que los regenere él mismo se cambia CORRER_BENCHMARK a True.

## Como generar los resultados principales

<!-- TODO -->
