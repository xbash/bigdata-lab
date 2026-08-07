# REGISTRO_CAMBIOS

## 2026-07-28

### Cambios realizados en la sesion

- Se analizo el material de `docs/` y se consolido un diseno versionado `v0.1.0`.
- Se implemento el stack base:
  - `compose.yml`
  - `compose.hive.yml`
  - `README.md`
  - `containers/base/Containerfile`
  - `containers/master/Containerfile`
  - `containers/worker/Containerfile`
  - `containers/master/entrypoint.sh`
  - `containers/worker/entrypoint.sh`
  - `conf/hadoop/*`
  - `conf/spark/*`
  - `conf/pig/*`
  - `containers/scripts/*.ps1`
- Se agregaron placeholders para extensiones futuras:
  - `conf/hive/README.md`
  - `profiles/sql-hive/README.md`
  - `profiles/ir/README.md`
  - `profiles/nosql-cassandra/README.md`
  - `profiles/nosql-mongodb/README.md`
  - `profiles/graph/README.md`
- Se ajusto la implementacion real para usar volumenes de Podman en HDFS interno.
- Se ejecuto build real de imagenes y validacion real del stack.
- Se dejo evidencia de smoke tests en `evidencia/`.
- Se creo la estructura `data/shared/lab01` a `lab08` con:
  - `docs/`
  - `datasets/`
  - `scripts/`
  - `results/`
  - `notes/`

### Archivos de continuidad creados

- `docs/CONTEXTO_PROYECTO.md`
- `docs/DECISIONES_TECNICAS.md`
- `docs/PENDIENTES.md`
- `docs/REGISTRO_CAMBIOS.md`
- `docs/BITACORA_CODEX.md`
- `docs/BITACORA_AGENTES.md`

### Actualizacion posterior del mismo dia

- Se verifico la presencia de material en `data/shared/lab01` a `lab04`.
- Se confirmo que `results/` ya cubre el almacenamiento de resultados por laboratorio y no hace falta crear otro directorio.
- Se entrego instructivo paso a paso de operacion del stack.
- Se entrego instructivo corto de operacion diaria.

## 2026-07-29

### Cambios realizados en la sesion

- Se inspecciono en modo solo lectura el cluster docente remoto.
- Se copiaron configuraciones remotas priorizadas a:
  - `data/shared/lab05/notes/remote-configs/20260729/`
- Se copio la muestra correcta de `lab05`:
  - `data/shared/lab05/datasets/es-wiki-articles-1k.tsv.gz`
- Se implemento el overlay `ir`:
  - `compose.ir.yml`
  - `conf/elasticsearch/elasticsearch.yml`
  - `containers/scripts/up-ir.ps1`
  - `containers/scripts/status-ir.ps1`
  - `containers/scripts/down-ir.ps1`
  - `containers/scripts/shell-elastic.ps1`
  - `containers/scripts/prepare-lab05.ps1`
- Se cambio el runtime base de contenedores desde `Temurin 8` a `Temurin 11` en `containers/base/Containerfile`.
- Se cambiaron las versiones objetivo del stack local a:
  - Hadoop `2.10.2`
  - Spark `3.3.2`
  - Pig `0.18.0`
- Se fijo la imagen base Java a `eclipse-temurin:11.0.26_4-jdk-jammy`.
- Se agregaron wrappers `bash` para Linux:
  - `build.sh`
  - `build-clean.sh`
  - `up.sh`
  - `status.sh`
  - `down.sh`
  - `shell-master.sh`
  - `prepare-lab05.sh`
  - `up-ir.sh`
  - `status-ir.sh`
  - `down-ir.sh`
  - `shell-elastic.sh`
- Se actualizo documentacion de continuidad y uso del overlay.
- Se validaron por sintaxis todos los wrappers `PowerShell` en `containers/scripts/*.ps1`.
- Se intento validar `bash` desde este laptop, pero el intento fallo por ausencia de distribuciones `WSL`.
- Por solicitud del usuario, no se ejecuto rebuild ni arranque de contenedores en este cierre.

## 2026-07-31

### Cambios realizados en la sesion

- Se consolidaron como definitivas las versiones del baseline reusable alineado al curso:
  - Java `11.0.26`
  - Hadoop `2.10.0`
  - Spark `3.3.2`
  - Pig `0.18.0-SNAPSHOT`
- Se actualizo `containers/base/Containerfile` para usar `eclipse-temurin:11.0.26_4-jdk-jammy`.
- Se ajustaron `compose.yml` y los `Containerfile` derivados a `Hadoop 2.10.0` y `Pig 0.18.0-SNAPSHOT`.
- Se dejo el build exacto de Pig sujeto a un `PIG_DOWNLOAD_URL` verificado para el snapshot del curso.
- Se ajusto la documentacion de contexto, decisiones, pendientes y README para reflejar el baseline alineado al curso.
- No se ejecuto rebuild ni validacion en vivo en esta sesion.

### Cambios realizados en la sesion de validacion y cierre

- Se empaqueto y reutilizo el artefacto exacto de `Pig 0.18.0-SNAPSHOT` observado en el curso.
- Se ejecuto rebuild remoto exitoso en `orcl01-chg`.
- Se publicaron las imagenes:
  - `xbash/bigdata-core-base:v0.1.0`
  - `xbash/bigdata-master:v0.1.0`
  - `xbash/bigdata-worker:v0.1.0`
- Se corrigio `compose.yml` para quitar el bind mount de `logs/` del stack base.
- Se agrego `conf/hadoop/capacity-scheduler.xml`.
- Se agrego `containers/scripts/run-lab02-wordcount.sh`.
- Se corrigieron wrappers `PowerShell`:
  - `containers/scripts/smoke-test.ps1`
  - `containers/scripts/run-spark-smoke.ps1`
  - `containers/scripts/run-lab02-wordcount.ps1`
  - `containers/scripts/run-lab03-starcount.ps1`
- Se completo en el laptop local el smoke test con jobs reales:
  - `SparkPi`
  - `lab02` WordCount
  - `lab03` star-count
- Evidencia principal:
  - `evidencia/smoke-test-20260731-015423.log`

## 2026-08-01

### Cambios realizados en la sesion

- Se endurecieron y documentaron wrappers operacionales del stack:
  - comentarios breves de finalidad en scripts `ps1` y `sh`
  - validaciones minimas de `podman` y artefactos requeridos
- Se agrego flujo operativo para reutilizar imagenes publicadas sin rebuild local:
  - `containers/scripts/pull-images-and-up.ps1`
  - `containers/scripts/pull-images-and-up.sh`
- Se agregaron wrappers de `lab04`:
  - `containers/scripts/prepare-lab04.ps1`
  - `containers/scripts/run-lab04.ps1`
- Se ajusto `containers/scripts/run-lab04.ps1` para compilar en `/tmp` dentro del contenedor.
- Se agregaron wrappers de `lab05`:
  - `containers/scripts/run-lab05-index.ps1`
  - `containers/scripts/run-lab05-search.ps1`
  - `containers/scripts/run-lab05-index.sh`
  - `containers/scripts/run-lab05-search.sh`
- Se creo el plan incremental de implementacion:
  - `docs/PLAN_IMPLEMENTACION_LABS_04_06.md`
- Se descargaron y copiaron a `lab04/datasets/` los archivos:
  - `imdb-ratings-two.tsv`
  - `imdb-ratings.tsv`
- Se revalidaron en vivo:
  - `status.ps1`
  - `smoke-test.ps1`
  - `smoke-test.ps1 -IncludeRealJobs`
  - `prepare-lab04.ps1`
  - `run-lab04.ps1 -Utility WordCountTask`
  - `run-lab04.ps1 -Utility AverageSeriesRating`
- Se documento un hallazgo funcional de `lab04`:
  - el dataset `imdb-ratings*.tsv` copiado localmente es correcto para el laboratorio
  - la variante Java 8 original de `AverageSeriesRating` en `gdd_lab04.zip` no estaba alineada al schema real de `8` columnas
  - fue necesario ajustar indices y filtro para evitar salidas HDFS vacias
- Se corrigio un bug operacional en `prepare-lab05.ps1`:
  - `param(...)` quedo movido al inicio del script para que PowerShell pueda interpretarlo correctamente

### Evidencia principal de la sesion

- `evidencia/smoke-test-20260731-202220.log`
- `evidencia/smoke-test-20260731-202424.log`

### Observaciones de cierre

- `lab05` quedo mejor preparado a nivel de wrappers, pero el codigo fuente del curso sigue con `TODO` funcionales.
- `lab04` ya tiene datasets correctos y validacion base completada sobre el runtime reusable.

### Cambios realizados en la sesion de `lab05` y `lab06`

- Se corrigio el overlay `ir` para `lab05`:
  - `conf/elasticsearch/elasticsearch.yml`
  - se quitaron settings de indice invalidos a nivel de nodo para `Elasticsearch 6.8.10`
- Se completo el codigo fuente minimo del laboratorio en:
  - `data/shared/lab05/work/gdd-elastic/src/cl/uchile/pmd/BuildWikiIndexBulk.java`
  - `data/shared/lab05/work/gdd-elastic/src/cl/uchile/pmd/SearchWikiIndex.java`
- Se ajustaron wrappers de `lab05` para empaquetar y ejecutar el proyecto como `jar` completo:
  - `containers/scripts/run-lab05-index.ps1`
  - `containers/scripts/run-lab05-search.ps1`
  - `containers/scripts/run-lab05-index.sh`
  - `containers/scripts/run-lab05-search.sh`
- Se revalido en vivo `lab05`:
  - `prepare-lab05.ps1`
  - `up-ir.ps1`
  - `status-ir.ps1`
  - `run-lab05-index.ps1`
  - `run-lab05-search.ps1`
- Se verifico para `lab05`:
  - indice `wiki-lab05-v2` con `1000` documentos
  - mapping y documentos de ejemplo con `TITLE`, `ABSTRACT`, `MODIFIED` y `URL`
  - salida de busqueda real para la consulta `Andorra`
- Se agregaron wrappers de `lab06`:
  - `containers/scripts/prepare-lab06.ps1`
  - `containers/scripts/run-lab06-pagerank.ps1`
- Se completo el codigo fuente minimo del laboratorio en:
  - `data/shared/lab06/work/gdd-giraph/src/org/mdp/hadoop/cli/PageRank.java`
- Se revalido en vivo `lab06` sobre un dataset local de smoke:
  - ejecucion de `Giraph`
  - ejecucion de `SortByRank`
  - salida HDFS no trivial de PageRank
- Se actualizaron documentos de continuidad:
  - `docs/CONTEXTO_PROYECTO.md`
  - `docs/DECISIONES_TECNICAS.md`
  - `docs/PENDIENTES.md`

### Cambios realizados en la sesion de baseline `v0.2.0`

- Se formalizo el artefacto exacto de `Pig 0.18.0-SNAPSHOT` como insumo congelado del baseline:
  - `.artifacts/pig-0.18.0-SNAPSHOT-course.tgz`
  - `.artifacts/pig-0.18.0-SNAPSHOT-course.tgz.sha256`
- Se endurecio la construccion del baseline para verificar integridad del artefacto de Pig en:
  - `containers/base/Containerfile`
  - `containers/scripts/build.ps1`
  - `containers/scripts/build-clean.ps1`
  - `containers/scripts/build.sh`
  - `containers/scripts/build-clean.sh`
- Se cambio la version objetivo del baseline reusable a:
  - `v0.2.0`
- Se actualizaron referencias de version en:
  - `compose.yml`
  - `containers/master/Containerfile`
  - `containers/worker/Containerfile`
  - `containers/scripts/pull-images-and-up.ps1`
  - `containers/scripts/pull-images-and-up.sh`
- Se agrego documentacion dedicada del artefacto de Pig:
  - `docs/ARTEFACTO_PIG_0_18_0_SNAPSHOT.md`
- En esta sesion no se ejecuto aun validacion remota en `orcl01-chg` ni publicacion de imagenes `v0.2.0`.

### Cambios realizados en la revision estatica de wrappers Linux

- Se endurecieron wrappers `bash` todavia pendientes de validacion en Linux real:
  - `containers/scripts/prepare-lab05.sh`
  - `containers/scripts/status-ir.sh`
  - `containers/scripts/run-lab02-wordcount.sh`
  - `containers/scripts/run-lab05-index.sh`
  - `containers/scripts/run-lab05-search.sh`
- Ajustes aplicados:
  - eliminacion de rutas fijas `/usr/bin/podman`
  - extraccion del ZIP de `lab05` mediante `python3` + `zipfile`
  - codificacion `base64` de la consulta en `run-lab05-search.sh`
  - mensaje explicito cuando `curl` no esta disponible en `status-ir.sh`
- En esta sesion no se ejecuto validacion real de estos wrappers porque este laptop sigue sin distribuciones `WSL` instaladas.
- Por solicitud del usuario, quedaron explicitamente diferidos al backlog final de `ServidorQA`:
  - validacion de wrappers `sh` en Linux real
  - aplicacion final de cambios, construccion de imagenes/contenedores y validacion integral en `ServidorQA`

### Cambios realizados en la documentacion del flujo de pull desde Docker Hub

- Se documento el flujo publico de rehidratacion sin rebuild local en:
  - `docs/FLUJO_PULL_DOCKER_HUB.md`
- Se aclaro el limite de version:
  - evidencia historica verificada para `v0.1.0`
  - revalidacion publica de `v0.2.0` pendiente hasta su publicacion
- Se actualizaron referencias en:
  - `README.md`
  - `docs/CONTEXTO_PROYECTO.md`
  - `docs/DECISIONES_TECNICAS.md`
  - `docs/PENDIENTES.md`

### Cambios realizados para alinear shards y replicas de `lab05` al overlay compacto

- Se ajusto `BuildWikiIndexBulk.java` en:
  - `data/shared/lab05/work/gdd-elastic/src/cl/uchile/pmd/BuildWikiIndexBulk.java`
  - `data/shared/lab05/docs/gdd_lab05/gdd-elastic/src/cl/uchile/pmd/BuildWikiIndexBulk.java`
- Cambio aplicado:
  - el payload de creacion del indice ahora declara:
    - `number_of_shards = 1`
    - `number_of_replicas = 0`
- Motivo:
  - sin esos `settings`, `Elasticsearch 6.8.10` aplicaba sus defaults de `5` shards y `1` replica
- En esta sesion no se revalido aun el indexado posterior con esa correccion.

### Cambios realizados para limpiar el mensaje residual de salida HDFS

- Se ajustaron las vistas previas HDFS para evitar el mensaje:
  - `text: Unable to write to output stream.`
- Causa corregida:
  - las previsualizaciones usaban `head`, cerrando la tuberia antes de tiempo
- Ajuste aplicado:
  - reemplazo por `awk` que imprime solo las primeras lineas sin interrumpir prematuramente al proceso emisor
- Scripts ajustados:
  - `containers/scripts/run-lab02-wordcount.ps1`
  - `containers/scripts/run-lab02-wordcount.sh`
  - `containers/scripts/run-lab03-starcount.ps1`
  - `containers/scripts/run-lab04.ps1`
  - `containers/scripts/run-lab06-pagerank.ps1`

### Cambios realizados en la validacion funcional de `lab02`

- Se ejecuto nuevamente el flujo real de WordCount de `lab02` el `2026-08-01`.
- Resultado observado:
  - job completado correctamente sobre YARN
  - salida HDFS:
    - `/outputs/lab02/wordcount-20260801-010019`
  - contadores relevantes:
    - `Map input records = 1000`
    - `Reduce output records = 19483`
- Alcance de esta validacion:
  - valida la logica operativa actual que comparte el wrapper Linux
  - no sustituye la ejecucion directa del `.sh` sobre un host Linux real, que sigue diferida a `ServidorQA`

### Cambio registrado sobre `lab02/docs/hadooppass.txt`

- El pendiente de revision de `lab02/docs/hadooppass.txt` quedo cerrado el `2026-08-01`.
- Estado final informado por el usuario:
  - el archivo fue eliminado del proyecto

### Cambio registrado sobre el dataset full de `lab05`

- El dataset full requerido por el PDF de `lab05` quedo disponible en el proyecto:
  - `data/shared/lab05/datasets/es-wiki-articles.tsv.gz`
- Fecha observada en el checkout:
  - `2026-08-01`

### Consolidado adicional para proxima sesion

- Se agrego:
  - `docs/pendientes_lista.md`
- Objetivo:
  - dejar un resumen operativo de los pendientes trabajados, su estado y el backlog final de `ServidorQA`

### Cambios realizados en la definicion funcional de `lab06`

- Se actualizo la continuidad para dejar explicito que:
  - para el avance actual de `lab06` basta el dataset pequeno ya validado
  - el dataset real ya fue copiado al proyecto
  - la prueba con dataset real queda diferida como pendiente final
  - segun el PDF, `lab06` usa `PageRank` para mejorar el ranking de resultados de `lab05`
  - por lo tanto, `lab06` requiere como insumo los resultados de `lab05`

### Cambios realizados para incorporar `sql-ui` al baseline reusable

- Se resolvio la definicion pendiente sobre `compose.hive.yml`:
  - deja de ser placeholder neutro
  - pasa a declararse el overlay `sql-hive`
- Se incorporo el componente visual objetivo:
  - `Hue` como `sql-ui`
- Cambios aplicados en manifests y build:
  - `compose.hive.yml`
  - `containers/sql-ui/Containerfile`
  - `containers/scripts/up-hive.ps1`
  - `containers/scripts/status-hive.ps1`
  - `containers/scripts/down-hive.ps1`
  - `containers/scripts/shell-hive.ps1`
  - `containers/scripts/shell-sql-ui.ps1`
  - `containers/scripts/up-hive.sh`
  - `containers/scripts/status-hive.sh`
  - `containers/scripts/down-hive.sh`
  - `containers/scripts/shell-hive.sh`
  - `containers/scripts/shell-sql-ui.sh`
  - `containers/scripts/build.ps1`
  - `containers/scripts/build-clean.ps1`
  - `containers/scripts/build.sh`
  - `containers/scripts/build-clean.sh`
  - `containers/scripts/up.ps1`
  - `containers/scripts/up.sh`
  - `containers/scripts/pull-images-and-up.ps1`
  - `containers/scripts/pull-images-and-up.sh`
- Se actualizo la version objetivo local del baseline reusable a:
  - `v0.3.0`
- Se actualizo continuidad asociada en:
  - `README.md`
  - `profiles/sql-hive/README.md`
  - `conf/hive/README.md`
  - `conf/hue/README.md`
  - `docs/PENDIENTES.md`
  - `docs/pendientes_lista.md`
  - `docs/CONTEXTO_PROYECTO.md`
  - `docs/DECISIONES_TECNICAS.md`
- Limite actual:
  - el parseo local de los nuevos wrappers `PowerShell` quedo `OK`
  - `podman compose ... config` no pudo validarse en este sandbox por acceso denegado a `C:\\Users\\xbash\\AppData\\Roaming\\containers\\containers.conf`
  - no se ejecuto aun build ni validacion funcional del overlay `sql-hive`
  - la validacion final se mantiene diferida a `ServidorQA`

### Cambios realizados durante la validacion Linux real en `ServidorQA`

- Se sincronizo al checkout remoto `/home/opc/bigdata-lab` el estado local necesario para continuar despues el flujo completo en `ServidorQA`, incluyendo:
  - `.artifacts/`
  - `compose.yml`
  - `compose.ir.yml`
  - `compose.hive.yml`
  - `README.md`
  - `containers/`
  - `conf/`
  - `profiles/`
  - `data/shared/lab05/`
  - `data/shared/lab06/`
  - `docs/`
- Validaciones ejecutadas en `ServidorQA` el `2026-08-01`:
  - `bash -n` sobre todos los `containers/scripts/*.sh`
  - `status.sh`
  - `status-ir.sh`
  - `status-hive.sh`
  - `down.sh`
  - `down-ir.sh`
  - `down-hive.sh`
- Hallazgos verificados:
  - `podman-compose 1.0.6` no soporta `--profile` en el flujo usado por `sql-hive`
  - se corrigio el overlay `sql-hive` para activarse solo por archivo `compose.hive.yml`
  - el host presenta errores de locks huérfanos en el runtime rootless de Podman
  - los contenedores `v0.1.0` remotos estaban detenidos y luego fueron removidos por `down.sh`
  - quedaron verificados en el remoto archivos criticos de:
    - baseline `v0.3.0`
    - artefacto congelado de `Pig 0.18.0-SNAPSHOT`
    - dataset full de `lab05`
    - dataset real de `lab06`
    - codigo fuente actualizado de `lab05` y `lab06`
- Limite actual:
  - aun no se ejecutan `up.sh`, `up-ir.sh`, `up-hive.sh`
  - aun no se ejecutan `build.sh`, `build-clean.sh`
  - `run-lab02-wordcount.sh` sigue pendiente de corrida real en el host

### Sincronizacion local -> `ServidorQA` endurecida el `2026-08-01`

- Se agrego `containers/scripts/sync-servidorqa.ps1`
- Objetivo:
  - sincronizar el baseline reusable y los laboratorios desde el checkout local al remoto
  - preservar rutas relativas correctas bajo `/home/opc/bigdata-lab`
  - evitar que `lab05` y `lab06` vuelvan a copiarse en la raiz remota
- Implementacion:
  - usa `tar` + `plink`
  - sincroniza por defecto:
    - `.artifacts`
    - `compose*.yml`
    - `README.md`
    - `conf/`
    - `containers/`
    - `profiles/`
    - `docs/`
    - `data/shared/lab05/`
    - `data/shared/lab06/`
- Observacion verificada en este host local:
  - `rsync` no esta instalado
  - `WSL` no tiene distribuciones instaladas
  - por eso no se dejo aun un flujo `rsync` ejecutable desde este laptop

### WSL + `rsync` habilitados el `2026-08-01`

- Se instalo una distro dedicada `UbuntuRsync` mediante:
  - `wsl.exe --install Ubuntu --web-download --name UbuntuRsync --no-launch`
- Se instalo `rsync` dentro de esa distro
- Version verificada:
  - `rsync 3.4.1`
- Se agrego `containers/scripts/sync-servidorqa-rsync.ps1`
- Objetivo:
  - sincronizar el checkout local al remoto con `rsync`
  - reutilizar `plink.exe` y la llave `.ppk` ya usada por el proyecto
  - mantener el mapeo correcto bajo `/home/opc/bigdata-lab`

### `rsync.exe` local habilitado el `2026-08-01`

- Se detecto `rsync.exe` local en:
  - `C:\ProgramData\chocolatey\bin\rsync.exe`
- Version verificada:
  - `rsync 3.2.5`
- `containers/scripts/sync-servidorqa-rsync.ps1` se ajusto para:
  - usar `rsync.exe` local en vez de depender de `WSL`
  - mantener `plink.exe` como transporte SSH
  - sincronizar por defecto:
    - `.artifacts`
    - `compose*.yml`
    - `README.md`
    - `conf/`
    - `containers/`
    - `profiles/`
    - `docs/`
    - `data/shared/lab05/`
    - `data/shared/lab06/`
### Sincronizacion remota ronda 1, build limpio y arranque base en `ServidorQA` el `2026-08-01`

- Se reconstruyo `/home/opc/bigdata-lab` con `containers/scripts/sync-servidorqa.ps1`.
- Alcance aplicado:
  - todo el proyecto
  - excluyendo solo `data/shared/lab01..lab08/datasets`
- Resultado verificado:
  - quedaron sincronizados:
    - `.artifacts`
    - `conf/`
    - `containers/`
    - `data/` base del ambiente reusable
    - `docs/`
    - `evidencia/`
    - `logs/`
    - `profiles/`
    - contenido no-`datasets` de `lab01..lab08`
- Se corrigio `containers/base/Containerfile`:
  - la comparacion interna de `SHA256` del artefacto Pig ahora normaliza a mayusculas
- Se corrigio el warning de build no consumido en:
  - `containers/scripts/build.sh`
  - `containers/scripts/build.ps1`
  - `containers/master/Containerfile`
  - `containers/worker/Containerfile`
- Resultado verificado en `ServidorQA`:
  - build limpio
  - imagenes construidas:
    - `bigdata-core-base:v0.3.0`
    - `bigdata-master:v0.3.0`
    - `bigdata-worker:v0.3.0`
    - `bigdata-sql-ui:v0.3.0`
  - `bash ./containers/scripts/up.sh` ejecutado realmente
  - contenedores `healthy`:
    - `bigdata-master`
    - `bigdata-worker1`
    - `bigdata-worker2`
    - `bigdata-worker3`
- Limitacion vigente:
  - los datasets de `lab01..lab08` siguen pendientes de copia manual en una segunda ronda

### Validacion real de overlays `ir` y `sql-hive` en `ServidorQA` el `2026-08-01`

- Se ejecuto realmente:
  - `bash ./containers/scripts/up-ir.sh`
  - `bash ./containers/scripts/status-ir.sh`
  - `bash ./containers/scripts/up-hive.sh`
  - `bash ./containers/scripts/status-hive.sh`
- Resultado verificado para `ir`:
  - `bigdata-elasticsearch` arriba
  - puertos `9200` y `9300` expuestos
  - `curl http://127.0.0.1:9200/_cat/health?v` en estado `green`
- Resultado verificado para `sql-hive`:
  - `bigdata-sql-ui` arriba en `8888`
  - `bigdata-hive-metastore` arriba en `9083`
  - `bigdata-hive-server` arriba en `10000` y `10002`
  - `Hue` responde `HTTP/1.1 302 Found`
  - `HiveServer2` web responde `HTTP/1.1 200 OK`
- Hallazgo operativo:
  - el primer `status-ir.sh` puede consultar demasiado pronto y devolver `Connection refused` mientras Elasticsearch aun termina de iniciar
  - `up-hive.sh` tuvo un arranque inicial largo por descarga y bootstrap de imagenes/servicios
- Riesgo abierto:
  - `bigdata-hive-metastore` registra `NoClassDefFoundError: org/apache/hadoop/yarn/util/SystemClock` al iniciar tareas internas de housekeeping
  - el overlay no quedo caido por ese error, pero el cierre funcional total de `sql-hive` sigue sujeto a decidir si ese warning debe corregirse

### Reordenamiento de wrappers por laboratorio el `2026-08-01`

- Se movio la ubicacion canonica de los scripts directamente asociados a laboratorios hacia sus respectivas rutas:
  - `data/shared/lab02/scripts/`
  - `data/shared/lab03/scripts/`
  - `data/shared/lab04/scripts/`
  - `data/shared/lab05/scripts/`
  - `data/shared/lab06/scripts/`
- Scripts reubicados:
  - `run-lab02-wordcount.ps1`
  - `run-lab02-wordcount.sh`
  - `run-lab03-starcount.ps1`
  - `prepare-lab04.ps1`
  - `run-lab04.ps1`
  - `prepare-lab05.ps1`
  - `prepare-lab05.sh`
  - `run-lab05-index.ps1`
  - `run-lab05-index.sh`
  - `run-lab05-search.ps1`
  - `run-lab05-search.sh`
  - `prepare-lab06.ps1`
  - `run-lab06-pagerank.ps1`
- Compatibilidad mantenida:
  - `containers/scripts/` conserva wrappers delegadores para no romper comandos, documentacion ni habitos de uso ya existentes

### Alineacion de `lab01` a estructura autocontenida y validacion `n=51` el `2026-08-01`

- Archivos ajustados:
  - `data/shared/lab01/scripts/run_lab01_experiments.ps1`
  - `data/shared/lab01/scripts/run_lab01_experiments_macos.sh`
  - `data/shared/lab01/scripts/abrir-powershell-lab01.cmd`
- Cambios aplicados:
  - rutas internas actualizadas desde `app/` y `data/` hacia:
    - `datasets/`
    - `work/gdd_lab01/gdd-wiki`
    - `logs/lab01`
    - `results/`
  - preservacion no destructiva de artefactos historicos en:
    - `data/shared/lab01/work/work_lab01`
  - documentacion operativa del caso `n=51` agregada al `.cmd`
- Verificacion ejecutada:
  - corrida real del pipeline externo de `lab01` con:
    - dataset `1k`
    - `ExternalN=51`
    - `BatchSize=10000`
    - `TopK=20`
  - etapas `extract`, `sort`, `count`, `rank` y `head`: `OK`
- Artefactos nuevos verificados:
  - `data/shared/lab01/results/es-wiki-abstracts-n51-grams.txt`
  - `data/shared/lab01/results/es-wiki-abstracts-n51-grams-s.txt`
  - `data/shared/lab01/results/es-wiki-abstracts-n51-grams-c.txt`
  - `data/shared/lab01/results/es-wiki-abstracts-n51-grams-c-s.txt`
  - `data/shared/lab01/results/es-wiki-abstracts-n51-grams-c-s-top20.txt`
- Limitacion observada:
  - la corrida dentro del sandbox del agente fallo por `Access denied`
  - la validacion real debio ejecutarse fuera del sandbox

### Normalizacion final de destinos de `lab01` el `2026-08-02`

- Archivos modificados:
  - `data/shared/lab01/scripts/run_lab01_experiments.ps1`
  - `data/shared/lab01/scripts/run_lab01_experiments_macos.sh`
  - `data/shared/lab01/scripts/abrir-powershell-lab01.cmd`
- Cambios aplicados:
  - `results/` queda como unico destino valido de resultados
  - `logs/` queda como unico destino valido de trazas y evidencia
  - se elimino el fallback a:
    - `work/work_lab01`
    - `logs/lab01`
  - ambos runners ahora fallan explicitamente si `results/` o `logs/` no son escribibles
- Estado del arbol verificado al cierre:
  - `data/shared/lab01/work/` conserva solo `gdd_lab01/`
  - `data/shared/lab01/logs/` contiene directamente la evidencia operativa
  - ya no existen como directorios:
    - `data/shared/lab01/work/work_lab01`
    - `data/shared/lab01/logs/lab01`
- Verificacion realizada:
  - parseo sintactico `OK` del runner `PowerShell`
  - inspeccion literal `OK` de ausencia de referencias activas a `work_lab01` y `logs/lab01` en scripts de `lab01`
- Limite:
  - no se reejecuto `lab01` tras esta normalizacion

### Cierre adicional de `lab01` y consolidacion de `lab02` el `2026-08-02`

- `lab01`:
  - el usuario reporto ejecucion manual `OK` de:
    - pipeline externo sobre muestra `1k`
    - `RunWordCountInMemory`
    - `RunNGramCountInMemory -n 2`
    - pipeline externo full `n=51`
  - evidencia local ya presente:
    - `data/shared/lab01/logs/runs_summary.csv`
    - `data/shared/lab01/results/`
- `lab02`:
  - se implemento:
    - `data/shared/lab02/work/gdd-hadoop/src/org/mdp/hadoop/cli/LetterCount.java`
  - se ajusto:
    - `data/shared/lab02/work/gdd-hadoop/src/org/mdp/hadoop/cli/Main.java`
  - se materializo el proyecto completo en:
    - `data/shared/lab02/work/gdd-hadoop`
  - se compilo y empaqueto el `jar`:
    - `data/shared/lab02/work/gdd-hadoop/dist/gdd-hadoop.jar`
  - evidencia local verificada:
    - `data/shared/lab02/logs/20260802-wordcount-run.log`
    - `data/shared/lab02/logs/20260802-wordcount-top20.txt`
    - `data/shared/lab02/logs/20260802-lettercount-run.log`
    - `data/shared/lab02/logs/20260802-lettercount-results.txt`
    - `data/shared/lab02/results/20260802-lettercount-a-z.txt`
  - decision de compilacion local usada:
    - `javac --release 8`

### Carga inicial de contexto de `lab03` el `2026-08-02`

- Se releyo el enunciado real desde:
  - `data/shared/lab03/docs/lab03.pdf`
- Se verifico la base actual del laboratorio:
  - `data/shared/lab03/datasets/imdb-stars-test.tsv`
  - `data/shared/lab03/datasets/imdb-stars.tsv`
  - `data/shared/lab03/scripts/run-lab03-starcount.ps1`
  - `data/shared/lab03/scripts/star-count.template.pig`
- Conclusion de arranque:
  - el flujo `star-count` ya esta preparado
  - `costar-count` sigue pendiente de implementacion/adaptacion

### Modularizacion de runners de `lab01` en `PowerShell` y `bash` el `2026-08-02`

- `PowerShell`:
  - se agrego:
    - `data/shared/lab01/scripts/lab01-common.ps1`
    - `data/shared/lab01/scripts/run_lab01_inmemory.ps1`
    - `data/shared/lab01/scripts/run_lab01_external.ps1`
  - `data/shared/lab01/scripts/run_lab01_experiments.ps1` quedo apoyado en el nucleo comun
  - parseo `PowerShell` verificado `OK`
- `bash`:
  - se agrego:
    - `data/shared/lab01/scripts/run_lab01_common.sh`
    - `data/shared/lab01/scripts/run_lab01_inmemory.sh`
    - `data/shared/lab01/scripts/run_lab01_external.sh`
    - `data/shared/lab01/scripts/run_lab01_experiments.sh`
  - `data/shared/lab01/scripts/run_lab01_experiments_macos.sh` paso a ser wrapper de compatibilidad
- Consolidacion posterior:
  - `run_lab01_experiments.ps1` y `run_lab01_experiments.sh` quedan como entradas principales
  - el modo oficial de ejecucion queda en `-Mode InMemory|External|Both`
  - `run_lab01_inmemory.*` y `run_lab01_external.*` pasan a delegar al script principal
  - `-RunExternalPipeline` y `-SkipInMemory` quedan solo como compatibilidad transitoria
- Politica preservada:
  - escritura en `results/`
  - escritura en `logs/`
  - sin rutas fallback legacy
- Limite:
  - la verificacion `bash -n` no pudo cerrarse en este host por `Access denied` al instanciar Bash/WSL

### Consolidacion final de `lab01` y avance operativo de `lab02`/`lab03` el `2026-08-02`

- `lab01`:
  - se agrego:
    - `docs/COMANDOS_OPERATIVOS_LAB01.md`
  - la referencia deja `-Mode` como interfaz oficial y distingue comandos pendientes de revalidacion
- `lab02`:
  - se reescribio:
    - `data/shared/lab02/scripts/run-lab02-wordcount.ps1`
    - `data/shared/lab02/scripts/run-lab02-wordcount.sh`
  - se agrego:
    - `data/shared/lab02/scripts/run-lab02-lettercount.ps1`
    - `data/shared/lab02/scripts/run-lab02-lettercount.sh`
  - `Main.java` fue ajustado para anunciar tambien `LetterCount`
  - los wrappers ahora compilan desde:
    - `data/shared/lab02/work/gdd-hadoop`
  - los wrappers dejan evidencia local en:
    - `data/shared/lab02/logs/`
    - `data/shared/lab02/results/`
- `lab03`:
  - se agrego:
    - `data/shared/lab03/scripts/costar-count.template.pig`
    - `data/shared/lab03/scripts/run-lab03-costarcount.ps1`
  - se ajusto:
    - `data/shared/lab03/scripts/run-lab03-starcount.ps1`
  - se agrego persistencia local de evidencia:
    - `data/shared/lab03/logs/*-run.log`
    - `data/shared/lab03/results/*-top20.txt`
  - el usuario ejecuto `run-lab03-costarcount.ps1` y se observaron dos fallas reales:
    - error de parseo Pig en el bloque `CROSS`
    - error `Invalid physical operators in the physical plan`
  - luego se simplifico `costar-count.template.pig` a una estrategia de self-join por `movie_id`
  - tambien se mejoraron los mensajes de error de `lab03` para reportar causa resumida y log local
- Validacion:
  - parseo `PowerShell` `OK` de:
    - `run-lab02-wordcount.ps1`
    - `run-lab02-lettercount.ps1`
    - `run-lab03-costarcount.ps1`
    - `run-lab03-starcount.ps1`
- Limite:
  - en ese punto aun no existia corrida exitosa verificada de `costar-count` despues del ultimo ajuste del script Pig

### Cierre parcial verificado de `lab03` el `2026-08-02`

- Se verifico una corrida exitosa de:
  - `data/shared/lab03/scripts/run-lab03-costarcount.ps1`
- Evidencia observada:
  - `FinalApplicationStatus=SUCCEEDED` en Hadoop/YARN
  - `Success!` en Pig
  - salida HDFS:
    - `/outputs/lab03/costar-count-20260802-034543`
  - evidencia local:
    - `data/shared/lab03/logs/20260802-034543-costarcount-run.log`
    - `data/shared/lab03/results/20260802-034543-costarcount-top20.txt`
    - `data/shared/lab03/results/20260802-034543-costarcount-entrega.md`
- Ajustes adicionales aplicados al wrapper:
  - lectura explicita `UTF-8` al regenerar `imdb-stars-test.tsv`
  - limpieza de lineas `WARNING:` al construir el preview local
- Limites metodologicos:
  - la corrida verificada corresponde a la muestra `imdb-stars-test.tsv`
  - sigue pendiente una corrida equivalente sobre `imdb-stars.tsv` completo si se quiere declarar cierre total segun el PDF

### Diagnostico y reconfiguracion de `lab06` el `2026-08-03`

- Se verifico que `podman machine set -m ...` no aplica a la maquina `wsl`; la memoria se ajusto via:
  - `C:\Users\xbash\.wslconfig`
- Se validaron internamente dos hitos de memoria efectiva:
  - ~`16 GB`
  - ~`24 GB`
- Se reinicio `WSL` y la `podman machine` para aplicar los cambios.
- Se reelevo el stack base con:
  - `bigdata-master`
  - `bigdata-worker1`
  - `bigdata-worker2`
  - `bigdata-worker3`
- Se mantuvo `bigdata-elasticsearch` detenido para liberar RAM durante `lab06`.
- Se ejecuto un nuevo reintento full de `lab06` y se observo un fallo transitorio por:
  - `Name node is in safe mode`
- Luego se verifico:
  - `hdfs dfsadmin -safemode get`: `OFF`
  - `hdfs dfsadmin -report`: `OK` sin bloques faltantes ni corruptos
- El usuario realizo un nuevo intento full posterior y reporto que la corrida siguio fallando.

### Implementacion y validacion de `lab07` Cassandra el `2026-08-03`

- Se agrego overlay Cassandra:
  - `compose.cassandra.yml`
  - `profiles/nosql-cassandra/README.md`
- Se actualizo la imagen base para instalar:
  - `Apache Cassandra 2.0.7`
  - `python2` para compatibilidad con `cqlsh 4.1.1`
- Se agregaron scripts operativos en `containers/scripts/`:
  - `start-cassandra.sh`
  - `up-cassandra.ps1`
  - `status-cassandra.ps1`
  - `down-cassandra.ps1`
  - `shell-cassandra.ps1`
  - `up-cassandra.sh`
  - `status-cassandra.sh`
  - `down-cassandra.sh`
  - `shell-cassandra.sh`
  - `run-lab07-cassandra.ps1`
- Se ajustaron:
  - `containers/master/entrypoint.sh`
  - `containers/worker/entrypoint.sh`
  - `containers/base/Containerfile`
  - `compose.yml`
  - `README.md`
- Se agrego desarrollo especifico de Lab07:
  - `data/shared/lab07/scripts/run-lab07-cassandra.ps1`
  - `data/shared/lab07/README.md`
- Se valido:
  - parseo `PowerShell` de scripts nuevos
  - `bash -n` de scripts Bash nuevos
  - `podman compose -f .\compose.yml -f .\compose.cassandra.yml config --services`
  - build local de imagenes
  - overlay local con 4 nodos Cassandra `UN`
  - `SHOW VERSION` con Cassandra `2.0.7`, `cqlsh 4.1.1`, CQL `3.1.1`, Thrift `19.39.0`
  - corrida final de Lab07 con evidencia:
    - `data/shared/lab07/results/20260803-215924-lab07-cassandra-comandos-entrega.cql`
    - `data/shared/lab07/results/20260803-215924-lab07-cassandra-resumen.txt`
    - `data/shared/lab07/logs/20260803-215924-lab07-cassandra-run.log`
- Observacion:
  - `CREATE INDEX` se ejecuta pero las consultas por indice secundario no fueron confiables en Cassandra `2.0.7` via Thrift
  - se documentaron alternativas con tablas orientadas a consulta

## 2026-08-04

### Cambios realizados en la sesion

- Se consolido documentalmente el cierre actual del ambiente reusable en:
  - `README.md`
  - `docs/CONTEXTO_PROYECTO.md`
  - `docs/DECISIONES_TECNICAS.md`
  - `docs/PENDIENTES.md`
  - `docs/REGISTRO_CAMBIOS.md`
  - `docs/BITACORA_CODEX.md`
  - `docs/BITACORA_AGENTES.md`
- Se actualizo `README.md` para reflejar:
  - el estado revalidado al `2026-08-04`
  - la progresion `core + overlays`
  - la referencia local de version `v0.4.0`
  - los parametros visibles nuevos de `lab05` y `lab06`
  - el flujo opcional de integracion `lab06 -> lab05`

### Cambios funcionales consolidados en esta etapa

- `lab06`:
  - se consolido el uso de:
    - `-MapMemoryMb`
    - `-MapJavaOpts`
  - el wrapper deja visible la salida HDFS ordenada para reutilizarla despues
- `lab05`:
  - se consolido la indexacion enriquecida con ranks mediante:
    - `-RanksLocalPath`
    - `-RanksHostPath`
  - se consolido la busqueda enriquecida con:
    - `-UseRank`
    - `-RankFactor`
    - `-ShowRank`
    - `-ShowScore`
- `lab06 -> lab05`:
  - queda disponible el wrapper:
    - `data/shared/lab06/scripts/run-lab06-lab05-integration.ps1`
  - se apoya en evidencia local de:
    - `ranks.s.tsv`
    - comparacion markdown de consulta con/sin rank

### Evidencia principal consolidada

- corrida full de `lab06`:
  - `data/shared/lab06/logs/20260804-000726-lab06-pagerank-run.log`
  - `data/shared/lab06/results/20260804-000726-lab06-pagerank-top10.txt`
  - `data/shared/lab06/results/20260804-000726-lab06-pagerank-sorted-top10.txt`
- integracion `lab06 -> lab05`:
  - `data/shared/lab06/results/lab05-rank-integration/ranks.s.tsv`
  - `data/shared/lab06/results/lab05-rank-integration/20260804-001746-lab05-rank-compare-estados-unidos.md`
  - `data/shared/lab05/results/20260804-001754-lab05-index-summary.txt`
  - `data/shared/lab05/results/20260804-001811-lab05-index-summary.txt`
  - `data/shared/lab05/results/20260804-001832-lab05-search-estados-unidos.txt`
  - `data/shared/lab05/results/20260804-001847-lab05-search-estados-unidos.txt`

### Limite de esta sesion

- En esta sesion de cierre no se ejecutaron wrappers `bash`; el backlog Linux sigue abierto para la fase final del proceso.

### Cambios realizados en la sesion de simplificacion estructural

- Se reordenaron los wrappers `bash` del ambiente reusable a:
  - `containers/scripts/bash/`
- Se agregaron los wrappers `bash` faltantes para `Spark`:
  - `up-spark.sh`
  - `status-spark.sh`
  - `down-spark.sh`
- Se elimino duplicacion en `PowerShell`:
  - `containers/scripts/build-clean.ps1` deja de existir
  - su comportamiento queda absorbido por `containers/scripts/build.ps1 -NoCache`
- Se retiraron del arbol operativo principal los scripts privados:
  - `docs/private/pull-images-and-up.ps1`
  - `docs/private/sync-servidorqa.ps1`
- Se elimino el experimento descartado:
  - `containers/scripts/sync-servidorqa-rsync.ps1`
- Se redefinio:
  - `containers/scripts/reset-data.ps1`
  - ahora actua como `factory reset` del runtime local del cluster
- Se actualizo documentacion de continuidad y uso:
  - `README.md`
  - `docs/CONTEXTO_PROYECTO.md`
  - `docs/DECISIONES_TECNICAS.md`
  - `docs/PENDIENTES.md`
  - `docs/REGISTRO_CAMBIOS.md`
  - `docs/BITACORA_CODEX.md`
  - `docs/BITACORA_AGENTES.md`

### Verificaciones ejecutadas en esta sesion

- Parseo `PowerShell`:
  - `containers/scripts/build.ps1`: `OK`
  - `containers/scripts/reset-data.ps1`: `OK`
- Verificacion estructural:
  - ya no quedan `.sh` en la raiz `containers/scripts/`
  - `build-clean.ps1` y `sync-servidorqa-rsync.ps1` ya no existen en el arbol operativo
  - `pull-images-and-up.ps1` y `sync-servidorqa.ps1` quedaron movidos a `docs/private/`

### Limites de esta sesion adicional

- No se ejecutaron builds, resets, overlays ni jobs reales despues de la simplificacion.
- No se implemento el overlay `MongoDB` porque la evidencia local solo confirma con certeza el `shell` `v4.4.14`, no la version real del daemon `mongod`.
## 2026-08-05

### Cambios realizados en la sesion

- Se ajusto el relato principal del proyecto en:
  - `README.md`
  - para enfatizar:
    - finalidad del ambiente reusable
    - progresion por laboratorio
    - diferencia respecto del ambiente docente
    - estado funcional validado de los componentes implementados
- Se actualizaron `README.md` de laboratorios y perfiles para descargar detalle desde el documento principal y mantener coherencia con el estado actual del proyecto.
- Se creo:
  - `profiles/spark/README.md`
- Se mantuvo y reviso el overlay `MongoDB` ya preparado en el arbol de trabajo:
  - `compose.mongodb.yml`
  - wrappers `PowerShell`
  - wrappers `bash`

### Verificaciones realizadas

- Se inspecciono el archivo privado de accesos solo para obtener parametros de conexion; no se documentaron secretos.
- Se verifico conectividad remota de solo lectura al servidor docente.
- Se confirmo observabilidad remota de:
  - `MongoDB`
  - `Cassandra`
  - `Elasticsearch`
- Se confirmo en `MongoDB` remoto la existencia de la base:
  - `tvdb`
  - con colecciones:
    - `crew`
    - `series`
    - `crewAvatar`
- Se confirmo en `Cassandra` remoto la posibilidad de exportar esquema mediante:
  - `DESCRIBE KEYSPACES;`
  - `DESCRIBE KEYSPACE cc66i;`

### Limites de la sesion

- La inspeccion remota fue de solo lectura.
- No se ejecuto aun una exportacion completa a archivos de los esquemas remotos.
- No se revalidaron en esta sesion `Hive` ni `Elasticsearch` con el mismo nivel de detalle que `MongoDB` y `Cassandra`.
