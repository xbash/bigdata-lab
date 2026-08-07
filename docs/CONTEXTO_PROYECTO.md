# CONTEXTO_PROYECTO

## 2026-07-28

### Estado actual

- Proyecto: `bigdata-lab`
- Estado general: implementacion inicial del stack `v0.1.0` creada y validada en vivo
- Objetivo vigente: disponer de una base reusable del curso para `Java + Hadoop/HDFS + Pig + Spark` en `4` contenedores, con extensiones futuras previstas

### Alcance implementado

- `compose.yml` con `master`, `worker1`, `worker2`, `worker3`
- imagenes:
  - `bigdata-core-base:v0.1.0`
  - `bigdata-master:v0.1.0`
  - `bigdata-worker:v0.1.0`
- configuracion externa en:
  - `conf/hadoop/`
  - `conf/spark/`
  - `conf/pig/`
  - `conf/hive/`
- scripts operativos en `containers/scripts/`
- estructura de laboratorios en `data/shared/lab01` a `lab08`

### Evidencia verificada

- El stack levanto en vivo con `4` contenedores `healthy`.
- `hdfs dfsadmin -report` mostro `3` DataNode activos.
- `spark-submit --version` respondio correctamente.
- `pig -version` respondio correctamente.
- El smoke test final quedo registrado en:
  - `evidencia/smoke-test-20260728-135606.log`

### Material de laboratorios disponible

- `lab01/docs/` contiene PDF, ZIP y datasets de Wikipedia.
- `lab02/docs/` contiene PDF, ZIP y un archivo `hadooppass.txt`.
- `lab03/docs/` contiene PDF, ZIP y `imdb-stars.tsv`.
- `lab04/docs/` contiene PDF y ZIP.
- `lab05` a `lab08` tienen estructura creada, pero sin material cargado al cierre.

### Supuestos vigentes

- Runtime Java local alineado al remoto:
  - Java `11.0.26`
- Versiones elegidas para implementacion:
  - Hadoop `2.10.2`
  - Spark `3.3.2`
  - Pig `0.18.0`
- Estas versiones son decisiones de implementacion del proyecto, no evidencia del curso.

### Riesgos y limitaciones

- El smoke test valida arranque, membresia HDFS y disponibilidad de herramientas, pero no ejecuta aun un job real de Hadoop, Spark o Pig sobre datasets del curso.

### Actualizacion de cierre adicional

- El usuario confirmo que regreso al laptop y solicito instrucciones operativas.
- Se entrego un instructivo paso a paso para:
  - construir imagenes
  - levantar el stack
  - revisar estado
  - ejecutar smoke test
  - entrar al `master`
  - detener el stack
  - resetear datos persistentes
- Se entrego tambien un instructivo corto de operacion diaria basado en `up.ps1`, `status.ps1`, `shell-master.ps1`, `smoke-test.ps1` y `down.ps1`.

## 2026-07-29

### Estado adicional

- Se confirmo por inspeccion remota que el ambiente docente usa:
  - Java `11.0.26`
  - Hadoop `2.10.0`
  - Pig `0.18.0-SNAPSHOT`
  - Spark `3.3.2`
  - Elasticsearch `6.8.10`
- Se copiaron al proyecto referencias remotas priorizadas en:
  - `data/shared/lab05/notes/remote-configs/20260729/`
- Se incorporo la muestra correcta de `lab05`:
  - `data/shared/lab05/datasets/es-wiki-articles-1k.tsv.gz`

### Estado del overlay `ir`

- Se creo `compose.ir.yml` como overlay local de Elasticsearch para `lab05`.
- El overlay conserva semantica remota relevante:
  - `cluster.name = es-pmd`
  - alias de red `cm`
  - transporte en `9300`
- El overlay adapta la topologia al laptop:
  - `1` nodo Elasticsearch
  - `1` shard
  - `0` replicas

### Limite actual

- El overlay `ir` queda listo a nivel de infraestructura y wrappers operativos.
- La implementacion del codigo Java de `lab05` sigue pendiente para cerrar la replica funcional completa.
- El cambio local de runtime a Java `11.0.26` queda implementado en `containers/base/Containerfile`, pero sigue pendiente revalidacion en vivo tras rebuild.
- La combinacion `Hadoop 2.10.2` + `Spark 3.3.2` queda preparada en los manifests locales, pero no debe asumirse compatible hasta revalidarla en vivo.
- Para Pig, el build local usa `0.18.0` publico mientras que el servidor del curso reporta `0.18.0-SNAPSHOT`.

### Cierre de sesion

- Se validaron por sintaxis los wrappers `PowerShell` presentes en `containers/scripts/`:
  - `build.ps1`
  - `down-ir.ps1`
  - `down.ps1`
  - `prepare-lab05.ps1`
  - `reset-data.ps1`
  - `run-lab02-wordcount.ps1`
  - `run-lab03-starcount.ps1`
  - `run-spark-smoke.ps1`
  - `shell-elastic.ps1`
  - `shell-master.ps1`
  - `smoke-test.ps1`
  - `status-ir.ps1`
  - `status.ps1`
  - `up-ir.ps1`
  - `up.ps1`
- El modo de reconstruccion limpia queda absorbido por `build.ps1 -NoCache`.
- Los wrappers `bash` equivalentes quedaron revisados estructuralmente, pero no validados con `bash -n` ni ejecutados en Linux real.
- Evidencia del limite actual:
  - el intento de `bash -n` desde este laptop fallo porque `WSL` no tiene distribuciones instaladas
- Por solicitud del usuario, en este cierre no se reconstruyeron imagenes ni se levantaron contenedores.

## 2026-07-31

### Decision vigente de baseline reusable

- El baseline reusable queda fijado en:
  - Java `11.0.26`
  - Hadoop `2.10.0`
  - Spark `3.3.2`
  - Pig `0.18.0-SNAPSHOT`
- Esta decision alinea el baseline reusable con el entorno observado en vivo en el servidor del curso.

### Alcance de la actualizacion

 - Se ajusto `containers/base/Containerfile` para usar una imagen base `Temurin 11.0.26`.
 - Se ajustaron los manifests a:
  - Hadoop `2.10.0`
  - Spark `3.3.2`
  - Pig `0.18.0-SNAPSHOT`
 - El build exacto de Pig queda sujeto a proveer un `PIG_DOWNLOAD_URL` verificado para el snapshot del curso.

### Limite actual

- No se ejecuto rebuild ni smoke test despues de fijar el baseline alineado al curso.
- La compatibilidad real del baseline definitivo sigue pendiente de revalidacion en vivo con Podman.

## 2026-07-31

### Estado adicional verificado

- Se ejecuto rebuild remoto exitoso del baseline alineado al curso en `orcl01-chg`.
- Se verificaron en la imagen base remota:
  - Java `11.0.26`
  - Hadoop `2.10.0`
  - Pig `0.18.0-SNAPSHOT`
  - Spark `3.3.2`
- Se publicaron las imagenes en Docker Hub:
  - `xbash/bigdata-core-base:v0.1.0`
  - `xbash/bigdata-master:v0.1.0`
  - `xbash/bigdata-worker:v0.1.0`
- En el laptop local se revalido el stack con jobs reales:
  - `SparkPi`
  - `lab02` WordCount
  - `lab03` star-count
- Evidencia local principal:
  - `evidencia/smoke-test-20260731-015423.log`

### Ajustes tecnicos verificados

- `compose.yml` dejo de montar `logs/` en el stack base para evitar bloqueos de permisos que impedian arrancar Hadoop/YARN en Linux remoto.
- Se agrego `conf/hadoop/capacity-scheduler.xml` para que `ResourceManager` pueda inicializar `root.default`.
- Se agrego `containers/scripts/run-lab02-wordcount.sh` para ejecucion Linux/Oracle.
- Se endurecieron wrappers `PowerShell` para jobs reales:
  - manejo de `stderr` sin falsos fallos por warnings de Java/Hadoop
  - eliminacion de problemas de quoting/CRLF mediante scripts temporales `.sh` copiados al contenedor
  - generacion de scripts Pig sin `BOM`

### Riesgos y limitaciones vigentes

- El mensaje `text: Unable to write to output stream.` puede seguir apareciendo al truncar vistas previas de salida HDFS. En la evidencia observada no implico fallo funcional del job.
- Los wrappers `bash` del stack base no quedaron validados en un host Linux local independiente del servidor Oracle; la evidencia Linux actual corresponde al servidor remoto.

## 2026-08-01

### Estado adicional verificado

- Se descargaron desde Docker Hub y se levantaron localmente las imagenes publicadas:
  - `xbash/bigdata-core-base:v0.1.0`
  - `xbash/bigdata-master:v0.1.0`
  - `xbash/bigdata-worker:v0.1.0`
- El stack base quedo nuevamente operativo en el laptop con:
  - `bigdata-master`
  - `bigdata-worker1`
  - `bigdata-worker2`
  - `bigdata-worker3`
- Se revalido en vivo:
  - `status.ps1`
  - `smoke-test.ps1`
  - `smoke-test.ps1 -IncludeRealJobs`
- La evidencia local principal de esta revalidacion quedo en:
  - `evidencia/smoke-test-20260731-202220.log`
  - `evidencia/smoke-test-20260731-202424.log`

### Estado adicional de laboratorios

- `lab04` quedo validado a nivel de preparacion y ejecucion base:
  - `prepare-lab04.ps1` extrae `gdd-spark`
  - `run-lab04.ps1 -Utility WordCountTask` paso como smoke tecnico
  - `run-lab04.ps1 -Utility AverageSeriesRating` paso con:
    - `imdb-ratings-two.tsv`
    - `imdb-ratings.tsv`
- Los datasets correctos de `lab04` quedaron copiados a:
  - `data/shared/lab04/datasets/imdb-ratings-two.tsv`
  - `data/shared/lab04/datasets/imdb-ratings.tsv`
- Hallazgo verificado de `lab04`:
  - el dataset local copiado es correcto para el laboratorio
  - la version Java 8 original de `AverageSeriesRating` incluida en el ZIP no estaba alineada con el schema real del TSV
  - evidencia:
    - el TSV observado tiene `8` columnas y usa `TV_SERIES`
    - la variante Java 7 del mismo proyecto ya venia alineada a ese schema
    - la variante Java 8 original produjo salidas HDFS vacias hasta ajustar indices y filtro
  - implicancia:
    - el ejemplo Java 8 del ZIP requiere ajuste de schema antes de usarlo como base para `AverageSeriesRating` e `InfoSeriesRating`
- `lab05` quedo con wrappers operacionales preparados para:
  - indexacion
  - busqueda
- El codigo fuente del curso para `lab05` ya quedo completado en:
  - indexacion
  - salida de busqueda
- Dataset adicional disponible para `lab05` al `2026-08-01`:
  - `data/shared/lab05/datasets/es-wiki-articles.tsv.gz`
  - este dataset corresponde a la corrida funcional completa indicada por el PDF

### Estado adicional verificado de `lab05`

- El `2026-08-01` se revalido en vivo la secuencia operativa base de `lab05`:
  - `prepare-lab05.ps1`
  - `up-ir.ps1`
  - `status-ir.ps1`
  - `run-lab05-index.ps1`
  - `run-lab05-search.ps1`
- Hallazgos verificados:
  - `prepare-lab05.ps1` tenia un bug de PowerShell porque `param(...)` no estaba al inicio del script; fue corregido
  - el overlay `ir` no podia arrancar con `Elasticsearch 6.8.10` porque `conf/elasticsearch/elasticsearch.yml` incluia:
    - `index.number_of_shards`
    - `index.number_of_replicas`
  - esos settings de indice a nivel de nodo provocaban:
    - `java.lang.IllegalArgumentException: node settings must not contain any index level settings`
  - tras quitar esos settings del YAML, el contenedor `bigdata-elasticsearch` quedo arriba y respondio dentro del contenedor en `http://localhost:9200`
- Limite funcional verificado:
  - el fallo original del `TransportClient` quedo resuelto al ejecutar `lab05` como `jar` empaquetado con `META-INF` y dependencias embebidas, consistente con `build.xml`
  - el runtime del contenedor no tiene `ant`, por lo que los wrappers tuvieron que replicar manualmente ese empaquetado
  - `run-lab05-index.ps1` paso y creo los indices `wiki-lab05` y `wiki-lab05-v2`
  - evidencia verificada posterior:
    - `wiki-lab05-v2/_count` devolvio `1000`
    - `wiki-lab05-v2/_mapping` conserva `URL`, `TITLE`, `ABSTRACT`, `MODIFIED`
    - una busqueda directa por HTTP mostro documentos con:
      - `TITLE`
      - `ABSTRACT`
      - `MODIFIED`
      - `URL`
  - implicancia funcional:
    - el bloqueo ya no es de infraestructura ni de `TransportClient`
    - la indexacion ya carga `TITLE`, `ABSTRACT` y `MODIFIED`
    - la busqueda ya imprime `TITLE`, `URL` y `ABSTRACT`
  - `run-lab05-search.ps1` ya no falla por `TransportClient` y ahora corta correctamente al recibir `EOF`
  - por lo tanto, al `2026-08-01`, `lab05` queda con infraestructura local operativa, cliente Java funcional e indexacion/busqueda base validadas con el dataset de muestra
  - ajuste adicional local pendiente de revalidacion:
    - `BuildWikiIndexBulk.java` quedo corregido para crear el indice con:
      - `1` shard
      - `0` replicas
    - motivo:
      - antes el payload de creacion del indice declaraba solo `mappings`
      - `Elasticsearch 6.8.10` completaba por defecto `5` shards y `1` replica

### Estado adicional verificado de `lab06`

- El `2026-08-01` se implemento y revalido en vivo el flujo minimo de `lab06` sobre el `core` actual, sin crear un overlay nuevo:
  - `prepare-lab06.ps1`
  - `run-lab06-pagerank.ps1`
- Hallazgos verificados:
  - el proyecto `gdd-giraph` del ZIP compila y ejecuta `Giraph` sobre el cluster local ya operativo
  - para lanzar `Giraph` localmente fue necesario ejecutar:
    - `org.apache.giraph.GiraphRunner` por `java -cp`
    - `-ca giraph.SplitMasterWorker=false`
  - sin esos ajustes, el flujo fallaba por:
    - conflicto entre `Main-Class` del jar y `GiraphRunner`
    - restriccion de `LocalJobRunner` reportada por Giraph
  - el codigo del laboratorio en `PageRank.java` requeria completar los `@TODO` del enunciado:
    - reparto de `D * rank / outdegree`
    - acumulacion de `(1-D) * rank`
    - acumulacion de `rank` completo para vertices dangling
  - una vez completados esos `@TODO`, el smoke real dejo de producir ranks triviales `0.0`
- Evidencia funcional observada con el dataset local de prueba `pr-ex-local.tsv`:
  - salida HDFS PageRank:
    - `a    0.3750543823020529`
    - `b    0.1949370588413848`
    - `c    0.3925085588565619`
    - `d    0.03749999999999999`
  - salida ordenada:
    - `c    0.3925085588565619`
    - `a    0.3750543823020529`
    - `b    0.1949370588413848`
    - `d    0.03749999999999999`
  - rutas HDFS verificadas:
    - `/outputs/lab06/pagerank-20260731-231056`
    - `/outputs/lab06/pagerank-sorted-20260731-231056`
- Implicancia funcional:
  - al `2026-08-01`, `lab06` queda validado a nivel de smoke tecnico real sobre el runtime reusable
  - para el avance actual basta el dataset local de smoke ya validado
  - el dataset real queda copiado al proyecto, pero su ejecucion se difiere como pendiente final
  - segun el PDF del laboratorio, el objetivo de `lab06` es usar `PageRank` para mejorar el ranking de resultados de `lab05`
  - por lo tanto, la corrida funcional completa de `lab06` requiere como insumo los resultados de busqueda/indexacion de `lab05`

### Riesgos y limitaciones vigentes

- En `lab04`, la compilacion del proyecto sobre el bind mount fallo al escribir `dist/gdd-spark.jar`; la ejecucion quedo estabilizada compilando en `/tmp` dentro del contenedor.
- Persisten warnings de `illegal reflective access` de `Hadoop 2.10.0` sobre `Java 11.0.26`; en las validaciones de esta fecha no bloquearon la operacion.
- El mensaje `text: Unable to write to output stream.` quedo mitigado en los wrappers ajustando las vistas previas HDFS para no cortar la tuberia con `head`.

## 2026-08-01

### Estado adicional de baseline reusable

- Se formalizo el insumo exacto de `Pig 0.18.0-SNAPSHOT` usado por el baseline:
  - `.artifacts/pig-0.18.0-SNAPSHOT-course.tgz`
- Se verifico localmente su `SHA256`:
  - `CAE27FD40AF1DE9C1FE45B920B6B5EA4A6D9351B50DB3290FCB95D10B21466AF`
- La linea base reusable quedo marcada para su siguiente iteracion como:
  - `v0.2.0`
- Los scripts de build y el `Containerfile` base quedaron endurecidos para fallar si el artefacto de Pig no coincide exactamente con el `SHA256` registrado.

### Limite actual

- En esta sesion solo quedo resuelto el criterio local de reproducibilidad del artefacto de Pig.
- Sigue pendiente:
  - aplicar y validar `v0.2.0` en `orcl01-chg`
  - construir y publicar las imagenes `v0.2.0` en Docker Hub
- El flujo de pull desde Docker Hub ya quedo documentado en:
  - `docs/FLUJO_PULL_DOCKER_HUB.md`
- La evidencia de pull + rehidratacion sigue siendo la verificada con `v0.1.0` el `2026-08-01`.
- Validacion adicional de `lab02` el `2026-08-01`:
  - el flujo real de WordCount corrio exitosamente sobre el stack local
  - salida HDFS observada:
    - `/outputs/lab02/wordcount-20260801-010019`
  - esto valida la logica operativa actual usada tambien por `run-lab02-wordcount.sh`
  - la ejecucion estricta del wrapper `.sh` sobre host Linux sigue diferida a `ServidorQA`
- El archivo `lab02/docs/hadooppass.txt` ya no forma parte del proyecto:
  - el usuario indico que fue eliminado el `2026-08-01`

## 2026-08-01

### Estado adicional del overlay `sql-hive`

- Se resolvio la definicion funcional pendiente sobre `compose.hive.yml`.
- Decision vigente:
  - desarrollar el overlay `sql-hive`
  - incorporar `Hue` como visualizador de consultas SQL del ambiente reusable
- Componentes declarados en el overlay:
  - `sql-ui`
  - `Hive Metastore`
  - `HiveServer2`
- Impacto de versionado:
  - la siguiente iteracion local del baseline reusable pasa a:
    - `v0.3.0`
- Limite actual:
  - el cambio queda registrado en manifests y scripts de build
  - la validacion funcional completa del overlay queda pendiente para la fase final en `ServidorQA`
## 2026-08-01

### Estado remoto actual en `ServidorQA`

- El checkout remoto `/home/opc/bigdata-lab` fue reconstruido con una ronda 1 de sincronizacion.
- Alcance sincronizado:
  - todo el proyecto
  - excepto `data/shared/lab01..lab08/datasets`
- El baseline `v0.3.0` ya fue construido en Linux real.
- Imagenes verificadas en `ServidorQA`:
  - `bigdata-core-base:v0.3.0`
  - `bigdata-master:v0.3.0`
  - `bigdata-worker:v0.3.0`
  - `bigdata-sql-ui:v0.3.0`
- Stack base levantado y saludable:
  - `bigdata-master`
  - `bigdata-worker1`
  - `bigdata-worker2`
  - `bigdata-worker3`

### Limite actual

- Aun faltan los datasets de `lab01..lab08` en el remoto.
- El overlay `ir` ya fue levantado y validado funcionalmente en `ServidorQA`:
  - `bigdata-elasticsearch`
  - `9200/tcp`
  - `9300/tcp`
  - `_cat/health = green`
- El overlay `sql-hive` ya fue levantado y validado a nivel de accesibilidad en `ServidorQA`:
  - `Hue` en `8888/tcp`
  - `Hive Metastore` en `9083/tcp`
  - `HiveServer2` en `10000/tcp`
  - `HiveServer2` web en `10002/tcp`
- Riesgo abierto del overlay `sql-hive`:
  - `bigdata-hive-metastore` registra `NoClassDefFoundError: org/apache/hadoop/yarn/util/SystemClock` en tareas internas de housekeeping
  - no impidio el arranque ni la exposicion de endpoints, pero sigue pendiente decidir si requiere correccion antes del cierre final
- Aun no se ejecutan jobs funcionales reales en `ServidorQA` contra datasets del curso.

### Convencion actual de scripts por laboratorio

- La ubicacion canonica de los wrappers de laboratorio pasa a ser:
  - `data/shared/lab0X/scripts/`
- `containers/scripts/` queda reservado para:
  - scripts operacionales del ambiente reusable
  - wrappers de compatibilidad hacia scripts canonicos de laboratorio

### Resumen principal actualizado

- copiar manualmente los `datasets/` al remoto: `OK`
- levantar y validar `up-ir.sh`: `OK`
- levantar y validar `up-hive.sh`: `OK`
- ejecutar jobs reales del curso en `ServidorQA`: siguiente

## 2026-08-01

### Estado adicional de `lab01`

- Se reviso el material real de `lab01` dentro de:
  - `data/shared/lab01/docs/`
  - `data/shared/lab01/datasets/`
  - `data/shared/lab01/scripts/`
- Hallazgo verificado:
  - `lab01` ya contiene el laboratorio real y sus datasets:
    - `gdd_lab01.zip`
    - `es-wiki-abstracts-1k.txt`
    - `es-wiki-abstracts.txt.gz`
  - el proyecto Java ejecutable queda disponible en:
    - `data/shared/lab01/work/gdd_lab01/gdd-wiki`
- Se alinearon los scripts de `lab01` a la estructura actual del repositorio:
  - `datasets/`
  - `work/gdd_lab01/gdd-wiki`
  - `logs/lab01`
  - `results/`
- Compatibilidad preservada:
  - los artefactos historicos ya existentes en:
    - `data/shared/lab01/work/work_lab01`
  - no fueron eliminados ni movidos
  - los scripts intentan reaprovecharlos de forma no destructiva

### Validacion controlada de `lab01` con `n=51`

- Se ejecuto realmente en Windows local:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_lab01_experiments.ps1 -UseSample -SkipInMemory -RunExternalPipeline -ExternalN 51 -Heap 1024M -BatchSize 10000 -TopK 20`
- Alcance de la prueba:
  - dataset pequeno `es-wiki-abstracts-1k.txt`
  - pipeline externo completo:
    - `ExtractNGrams`
    - `ExternalMergeSort`
    - `CountDuplicates`
    - `ExternalMergeSort -r`
    - `Head`
- Resultado verificado:
  - `external_01_extract_sample-1k_n51`: `OK`
  - `external_02_sort_sample-1k_n51_b10000`: `OK`
  - `external_03_count_sample-1k_n51`: `OK`
  - `external_04_rank_sample-1k_n51_b10000`: `OK`
  - `external_05_head_sample-1k_n51_top20`: `OK`
- Artefactos generados en:
  - `data/shared/lab01/results/`
  - archivos principales:
    - `es-wiki-abstracts-n51-grams.txt`
    - `es-wiki-abstracts-n51-grams-s.txt`
    - `es-wiki-abstracts-n51-grams-c.txt`
    - `es-wiki-abstracts-n51-grams-c-s.txt`
    - `es-wiki-abstracts-n51-grams-c-s-top20.txt`
- Evidencia adicional:
  - `data/shared/lab01/logs/lab01/runs_summary.csv`

### Limitacion observada

- Bajo sandbox de Codex, la escritura local dentro de `lab01/results/` y `tmp/` devolvio `Access denied`.
- La validacion real de `n=51` solo pudo cerrarse ejecutando el script fuera del sandbox.
- Esto no invalida la logica de `lab01`, pero si deja una limitacion operacional del entorno de agente para futuras corridas locales pesadas.

## 2026-08-02

### Estado actual de estructura y destinos de `lab01`

- Se reviso y ajusto el comportamiento de los runners de `lab01`:
  - `data/shared/lab01/scripts/run_lab01_experiments.ps1`
  - `data/shared/lab01/scripts/run_lab01_experiments_macos.sh`
  - `data/shared/lab01/scripts/abrir-powershell-lab01.cmd`
- Estado estructural verificado en el checkout:
  - `data/shared/lab01/results/` contiene los artefactos conservados de resultados
  - `data/shared/lab01/logs/` contiene directamente trazas, `runs_summary.csv`, `*.meta.txt`, `*.stderr.log`, `*.stdout.txt` y `*.done`
  - `data/shared/lab01/work/` conserva solo:
    - `gdd_lab01/`
- Rutas historicas ya no presentes como directorios fisicos:
  - `data/shared/lab01/work/work_lab01`
  - `data/shared/lab01/logs/lab01`

### Politica actual de escritura en `lab01`

- Los resultados del laboratorio deben quedar solo en:
  - `data/shared/lab01/results/`
- Las trazas y evidencia operativa deben quedar solo en:
  - `data/shared/lab01/logs/`
- Los runners ya no declaran fallback hacia:
  - `work/work_lab01`
  - `logs/lab01`
- Comportamiento nuevo verificado por inspeccion de scripts:
  - si `results/` no es escribible, el runner falla
  - si `logs/` no es escribible, el runner falla

### Limite actual

- En esta sesion no se reejecuto `lab01` despues del cambio de rutas planas a `results/` y `logs/`.
- Por lo tanto:
  - la correccion de estructura queda verificada a nivel de scripts
  - la revalidacion runtime posterior a esos cambios queda pendiente
- La restriccion `Access denied` desde el sandbox del agente sigue observada en esta sesion para pruebas de escritura simples; no queda resuelto si ese bloqueo aplica solo al entorno gestionado del agente o tambien a ejecuciones manuales del usuario.

## 2026-08-02

### Cierre funcional adicional de `lab01`

- El usuario reporto ejecucion manual exitosa posterior a la normalizacion de rutas de:
  - pipeline externo controlado sobre muestra `1k`
  - corridas en memoria:
    - `RunWordCountInMemory`
    - `RunNGramCountInMemory -n 2`
  - pipeline externo completo para `n=51`
- Evidencia verificada en el checkout:
  - `data/shared/lab01/logs/runs_summary.csv` ya contiene corridas del `2026-08-02` sobre muestra `1k`
  - el laboratorio mantiene artefactos finales en:
    - `data/shared/lab01/results/`
- Limite:
  - en esta sesion no se releyeron uno por uno todos los nuevos `stdout/stderr` de `lab01`
  - el cierre adicional de runtime se apoya en:
    - evidencia local existente
    - confirmacion explicita del usuario de ejecucion `OK`

### Estado adicional de `lab02`

- El proyecto de `lab02` fue materializado en:
  - `data/shared/lab02/work/gdd-hadoop`
- Estado del codigo fuente:
  - `WordCount.java` se mantiene como base del ZIP del laboratorio
  - `LetterCount.java` fue implementado en:
    - `data/shared/lab02/work/gdd-hadoop/src/org/mdp/hadoop/cli/LetterCount.java`
  - `Main.java` fue ajustado para exponer:
    - `WordCount`
    - `LetterCount`
- Compilacion local verificada:
  - el `jar` fue compilado y empaquetado correctamente en:
    - `data/shared/lab02/work/gdd-hadoop/dist/gdd-hadoop.jar`
  - decision de compilacion local usada:
    - `javac --release 8`
- Ejecucion local verificada/parcialmente verificada:
  - `WordCount`:
    - se observo en consola `map 100% reduce 100%`
    - se observo `completed successfully`
    - evidencia local:
      - `data/shared/lab02/logs/20260802-wordcount-run.log`
      - `data/shared/lab02/logs/20260802-wordcount-top20.txt`
  - `LetterCount`:
    - el usuario confirmo obtencion del resultado final
    - evidencia local disponible:
      - `data/shared/lab02/logs/20260802-lettercount-run.log`
      - `data/shared/lab02/logs/20260802-lettercount-results.txt`
      - `data/shared/lab02/results/20260802-lettercount-a-z.txt`
- Cierre academico util:
  - `20260802-lettercount-a-z.txt` conserva las `26` lineas `a-z` pedidas por el PDF como artefacto de entrega

### Estado inicial cargado de `lab03`

- El enunciado de `lab03` ya fue releido desde:
  - `data/shared/lab03/docs/lab03.pdf`
- Estado actual verificado:
  - existe dataset pequeno:
    - `data/shared/lab03/datasets/imdb-stars-test.tsv`
  - existe dataset full:
    - `data/shared/lab03/datasets/imdb-stars.tsv`
  - existe wrapper canonico:
    - `data/shared/lab03/scripts/run-lab03-starcount.ps1`
  - existe script base:
    - `data/shared/lab03/scripts/star-count.template.pig`
- Alcance pendiente:
  - el checkout actual solo deja listo el flujo `star-count`
  - el objetivo principal del PDF sigue siendo adaptar hacia `costar-count`

### Modularizacion adicional de runners de `lab01`

- La interfaz principal de `lab01` queda consolidada en un solo script por plataforma:
  - `data/shared/lab01/scripts/run_lab01_experiments.ps1`
  - `data/shared/lab01/scripts/run_lab01_experiments.sh`
- La logica comun queda modularizada en:
  - `data/shared/lab01/scripts/lab01-common.ps1`
  - `data/shared/lab01/scripts/run_lab01_common.sh`
- Los wrappers especializados quedan solo como aliases de compatibilidad:
  - `data/shared/lab01/scripts/run_lab01_inmemory.ps1`
  - `data/shared/lab01/scripts/run_lab01_external.ps1`
  - `data/shared/lab01/scripts/run_lab01_inmemory.sh`
  - `data/shared/lab01/scripts/run_lab01_external.sh`
  - `data/shared/lab01/scripts/run_lab01_experiments_macos.sh`
- Interfaz oficial:
  - `-Mode InMemory`
  - `-Mode External`
  - `-Mode Both`
- Compatibilidad transitoria:
  - `-RunExternalPipeline`
  - `-SkipInMemory`
  - se mantienen solo para no romper comandos historicos
- Politica preservada:
  - resultados en `data/shared/lab01/results/`
  - trazas y evidencia en `data/shared/lab01/logs/`
  - sin fallback a rutas legacy
- Verificacion ejecutada:
  - parseo `PowerShell` `OK` de:
    - `lab01-common.ps1`
    - `run_lab01_inmemory.ps1`
    - `run_lab01_external.ps1`
    - `run_lab01_experiments.ps1`
- Limite:
  - la validacion `bash -n` no pudo ejecutarse en este host por `Access denied` al crear instancia Bash/WSL
  - no se reejecuto `lab01` despues de la consolidacion final a `-Mode`

### Consolidacion operativa adicional de `lab01` el `2026-08-02`

- Se agrego una referencia operativa breve en:
  - `docs/COMANDOS_OPERATIVOS_LAB01.md`
- El documento separa:
  - comando
  - objetivo
  - estado de validacion
- Estado registrado:
  - los comandos con `-Mode` quedan como interfaz oficial
  - la mayor parte queda aun como `pendiente de revalidacion` especifica con el wrapper consolidado

### Separacion operativa de `lab02` el `2026-08-02`

- `lab02` queda dividido en dos wrappers `PowerShell` explicitos:
  - `data/shared/lab02/scripts/run-lab02-wordcount.ps1`
  - `data/shared/lab02/scripts/run-lab02-lettercount.ps1`
- Ambos wrappers ahora compilan desde el arbol de trabajo actual:
  - `data/shared/lab02/work/gdd-hadoop`
- Ya no dependen del ZIP original como fuente de compilacion efectiva.
- Evidencia local prevista por los wrappers:
  - `WordCount`:
    - `data/shared/lab02/logs/*-wordcount-run.log`
    - `data/shared/lab02/logs/*-wordcount-top20.txt`
  - `LetterCount`:
    - `data/shared/lab02/logs/*-lettercount-run.log`
    - `data/shared/lab02/results/*-lettercount-a-z.txt`
- Tambien quedan alineados los wrappers `bash`:
  - `data/shared/lab02/scripts/run-lab02-wordcount.sh`
  - `data/shared/lab02/scripts/run-lab02-lettercount.sh`
- Limite:
  - en esta sesion no se reejecutaron los nuevos wrappers de `lab02`
  - la equivalencia funcional de los `.sh` queda validada por inspeccion, no por corrida real

### Avance real de `lab03` hacia `costar-count` el `2026-08-02`

- El entregable real del PDF ya no queda solo como idea:
  - se creo `data/shared/lab03/scripts/costar-count.template.pig`
  - se creo `data/shared/lab03/scripts/run-lab03-costarcount.ps1`
- El wrapper de `costar-count` deja evidencia local en:
  - `data/shared/lab03/logs/*-costarcount-run.log`
  - `data/shared/lab03/results/*-costarcount-top20.txt`
- Tambien se ajusto `run-lab03-starcount.ps1` para dejar:
  - `logs/*-starcount-run.log`
  - `results/*-starcount-top20.txt`
- Ejecucion real observada:
  - el usuario ejecuto `run-lab03-costarcount.ps1`
  - primero fallo por sintaxis Pig en la construccion del `CROSS`
  - luego fallo por plan fisico invalido de Pig al intentar producir multiples salidas en el bloque anterior
- Correcciones aplicadas despues de esos errores:
  - se simplifico `costar-count.template.pig`
  - se reemplazo el bloque `FOREACH ... { ... }` por un self-join por `movie_id`
  - se mejoraron los mensajes de error de `run-lab03-costarcount.ps1` y `run-lab03-starcount.ps1` para reportar causa resumida y ruta del log local
- Limite:
  - en ese momento no existia aun una corrida exitosa verificada de `costar-count` despues del ultimo ajuste del script Pig
  - `lab03` quedaba entonces en estado de implementacion avanzada con revalidacion runtime pendiente

### Estado actualizado de `lab03` tras corrida exitosa el `2026-08-02`

- Ya existe una corrida exitosa verificada de:
  - `data/shared/lab03/scripts/run-lab03-costarcount.ps1`
- Evidencia verificada:
  - `FinalApplicationStatus=SUCCEEDED` y `Success!` en:
    - `data/shared/lab03/logs/20260802-034543-costarcount-run.log`
  - salida HDFS:
    - `/outputs/lab03/costar-count-20260802-034543`
  - preview local:
    - `data/shared/lab03/results/20260802-034543-costarcount-top20.txt`
  - artefacto formal de entrega parcial:
    - `data/shared/lab03/results/20260802-034543-costarcount-entrega.md`
- Ajuste posterior aplicado al wrapper:
  - la regeneracion de `imdb-stars-test.tsv` ahora usa lectura explicita `UTF-8`
  - el preview local ahora excluye lineas `WARNING:`
- Limite metodologico vigente:
  - la corrida verificada corresponde a la muestra `imdb-stars-test.tsv`
  - si se quiere declarar cierre completo del laboratorio segun el PDF, sigue pendiente una corrida equivalente sobre `imdb-stars.tsv` full

### Estado actualizado de `lab06` al `2026-08-03`

- Estado verificado del codigo:
  - `lab06` ya cuenta con:
    - `data/shared/lab06/work/gdd-giraph/src/org/mdp/hadoop/cli/PageRank.java`
    - `data/shared/lab06/work/gdd-giraph/src/org/mdp/hadoop/cli/SortByRank.java`
    - `data/shared/lab06/scripts/run-lab06-pagerank.ps1`
    - `data/shared/lab06/scripts/prepare-lab06.ps1`
- Estado verificado de evidencia previa:
  - existe smoke real previo con evidencia local en:
    - `data/shared/lab06/logs/20260802-181303-lab06-pagerank-run.log`
    - `data/shared/lab06/results/20260802-181303-lab06-pagerank-top10.txt`
    - `data/shared/lab06/results/20260802-181303-lab06-pagerank-sorted-top10.txt`
- Estado verificado de la corrida full en esta sesion:
  - el usuario reintento el dataset real:
    - `data/shared/lab06/datasets/es-wiki-links.tsv.gz`
  - se probaron al menos estos ajustes operativos:
    - `-Workers 1`
    - `-MapMemoryMb 4096`
    - `-MapJavaOpts "-Xmx3276m"`
  - se confirmo dentro de la VM WSL de Podman:
    - ~`16 GB` efectivos en un intento intermedio
    - ~`24 GB` efectivos al cierre de esta sesion
  - evidencia verificada del aumento final:
    - `podman machine ssh cat /proc/meminfo` reporto `MemTotal: 24610416 kB`
- Fallas reales observadas en la corrida full:
  - fallo por `Java heap space` en intentos previos
  - fallo por `exit code 137` / `Killed by external signal` en YARN
  - un reintento fallo transitoriamente por `Name node is in safe mode` tras reiniciar el cluster
  - el ultimo reintento del usuario con evidencia local:
    - `data/shared/lab06/logs/20260802-202734-lab06-pagerank-run.log`
    - siguio fallando sobre el dataset full
- Dependencia funcional con `lab05`:
  - para calcular PageRank y ordenar ranks:
    - `elasticsearch` no es requerido
  - para integrar `ranks.s.tsv` en busqueda y comparar consultas con/sin PageRank:
    - si se requiere reusar la base de `lab05`
- Estado de cierre:
  - `lab06` queda validado en muestra controlada
  - `lab06` full sobre `es-wiki-links.tsv.gz` sigue pendiente de cierre runtime satisfactorio

### Estado actualizado de `lab07` al `2026-08-03`

- Se cargo y reviso el enunciado:
  - `data/shared/lab07/docs/lab07.pdf`
- Tema verificado:
  - laboratorio de `Apache Cassandra`, `cqlsh`, `nodetool`, `keyspaces`, tablas, inserciones, consultas, indices secundarios y llaves primarias compuestas
- Se inspecciono el servidor docente por SSH de solo lectura para confirmar implementacion Cassandra:
  - Cassandra `2.0.7`
  - `cqlsh 4.1.1`
  - CQL `3.1.1`
  - Thrift `19.39.0`
  - puertos observados: `9042`, `9160`, `7199`
  - topologia docente observada: 5 nodos `UN`
- Se implemento el overlay local `nosql-cassandra` sobre los contenedores existentes:
  - `bigdata-master`
  - `bigdata-worker1`
  - `bigdata-worker2`
  - `bigdata-worker3`
- Archivos clave agregados o actualizados:
  - `compose.cassandra.yml`
  - `containers/scripts/bash/start-cassandra.sh`
  - `containers/scripts/up-cassandra.ps1`
  - `containers/scripts/status-cassandra.ps1`
  - `containers/scripts/down-cassandra.ps1`
  - `containers/scripts/shell-cassandra.ps1`
  - equivalentes `.sh` en `containers/scripts/bash/`
  - `containers/scripts/run-lab07-cassandra.ps1`
  - `data/shared/lab07/scripts/run-lab07-cassandra.ps1`
  - `data/shared/lab07/README.md`
  - `profiles/nosql-cassandra/README.md`
- Decision operativa importante:
  - los scripts de habilitacion Cassandra quedan en `containers/scripts/`
  - no se conserva `containers/common/`
- Validacion local observada:
  - build de imagenes `bigdata-core-base`, `bigdata-master`, `bigdata-worker` con Cassandra `2.0.7` y `python2`
  - `podman compose -f .\compose.yml -f .\compose.cassandra.yml config --services` mostro solo:
    - `master`
    - `worker1`
    - `worker2`
    - `worker3`
  - overlay levantado con `up-cassandra.ps1`
  - `nodetool status` reporto 4 nodos `UN`
  - `SHOW VERSION` reporto Cassandra `2.0.7`, `cqlsh 4.1.1`, CQL `3.1.1`, Thrift `19.39.0`
- Desarrollo de Lab07:
  - se creo wrapper reproducible:
    - `data/shared/lab07/scripts/run-lab07-cassandra.ps1`
  - se creo wrapper delegador:
    - `containers/scripts/run-lab07-cassandra.ps1`
  - el script genera:
    - `data/shared/lab07/results/*-comandos-entrega.cql`
    - `data/shared/lab07/results/*-resumen.txt`
    - `data/shared/lab07/logs/*-run.log`
- Evidencia final verificada:
  - comandos CQL finales:
    - `data/shared/lab07/results/20260803-215924-lab07-cassandra-comandos-entrega.cql`
  - resumen final:
    - `data/shared/lab07/results/20260803-215924-lab07-cassandra-resumen.txt`
  - log final:
    - `data/shared/lab07/logs/20260803-215924-lab07-cassandra-run.log`
- Limitacion metodologica verificada:
  - `CREATE INDEX` se ejecuta, pero en Cassandra `2.0.7` via Thrift las consultas por indice pueden devolver `0 rows` aunque la fila exista
  - el script registra ese limite y valida consultas por edad mediante tablas orientadas a consulta:
    - `byage_*`
    - `bycolor_*`
- Estado de cierre:
  - `lab07` queda ejecutable localmente con overlay Cassandra `1 master + 3 workers`
  - no replica exactamente los 5 nodos docentes, pero conserva version Cassandra y flujo CQL del laboratorio con alternativas documentadas

## 2026-08-04

### Estado actualizado del ambiente reusable

- Al cierre actual, el ambiente reusable queda alineado en grado alto con la progresion real de laboratorios:
  - `core`: `Hadoop` + `HDFS` + `YARN` + `Pig`
  - `lab04`: overlay `Spark`
  - `lab05`: overlay `IR`
  - `lab06`: perfil `graph` con `Giraph`
  - `lab07`: overlay `Cassandra`
  - `lab08`: `MongoDB` sigue pendiente de implementacion local
- La refactorizacion actual queda referenciada localmente por defecto como `v0.4.0` en los scripts y manifests operativos del ambiente.

### Estado verificado de `lab06`

- Ya existe corrida full satisfactoria de `lab06` sobre:
  - `data/shared/lab06/datasets/es-wiki-links.tsv.gz`
- Evidencia verificada:
  - log:
    - `data/shared/lab06/logs/20260804-000726-lab06-pagerank-run.log`
  - previews locales:
    - `data/shared/lab06/results/20260804-000726-lab06-pagerank-top10.txt`
    - `data/shared/lab06/results/20260804-000726-lab06-pagerank-sorted-top10.txt`
  - salidas HDFS:
    - `/outputs/lab06/pagerank-20260804-000726`
    - `/outputs/lab06/pagerank-sorted-20260804-000726`
- El wrapper `data/shared/lab06/scripts/run-lab06-pagerank.ps1` ya expone:
  - `-MapMemoryMb`
  - `-MapJavaOpts`
  - la salida HDFS ordenada como dato observable en el log y la consola

### Estado verificado de la integracion `lab06 -> lab05`

- La integracion final con busqueda queda implementada y validada en:
  - `data/shared/lab06/scripts/run-lab06-lab05-integration.ps1`
- El flujo exporta ranks desde HDFS y genera:
  - `data/shared/lab06/results/lab05-rank-integration/ranks.s.tsv`
  - `data/shared/lab06/results/lab05-rank-integration/20260804-001746-lab05-rank-compare-estados-unidos.md`
- En `lab05`, la indexacion y la busqueda ya aceptan parametros de ranking:
  - `run-lab05-index.ps1`:
    - `-RanksLocalPath`
    - `-RanksHostPath`
  - `run-lab05-search.ps1`:
    - `-UseRank`
    - `-RankFactor`
    - `-ShowRank`
    - `-ShowScore`

### Criterio operativo vigente

- `Elasticsearch` no se necesita para calcular `PageRank`; solo vuelve a ser necesario al integrar `lab06` con `lab05`.
- Para este laptop, el criterio vigente sigue siendo:
  - `Elasticsearch single-node`
  - sin distribuirlo entre nodos Hadoop existentes
- La razon operativa es conservar RAM para YARN/Giraph y evitar sobrecoste innecesario de memoria en la fase local.

### Limites vigentes

- En esta sesion de cierre no se revalidaron wrappers `bash`; el backlog Linux queda explicitamente diferido al final del proceso.
- `MongoDB` sigue como fase siguiente; no existe aun overlay operativo local equivalente a `lab04` a `lab07`.

### Ajuste estructural adicional del `2026-08-04`

- Se simplifico la superficie operativa del proyecto sin introducir nuevos overlays ni revalidaciones en vivo.
- Los wrappers `bash` del ambiente reusable quedaron concentrados en:
  - `containers/scripts/bash/`
- Los scripts `PowerShell` privados u orientados a operacion remota ya no forman parte del arbol operativo principal:
  - `docs/private/pull-images-and-up.ps1`
  - `docs/private/sync-servidorqa.ps1`
- El build limpio ya no usa un wrapper separado:
  - `containers/scripts/build.ps1 -NoCache`
- `containers/scripts/reset-data.ps1` deja de ser una limpieza ambigua y pasa a operar como `factory reset` del runtime local:
  - baja el stack con `down-all.ps1`
  - elimina solo volumenes persistentes de Podman del cluster
  - no borra `data/shared/lab0X/*`, `docs/`, `evidencia/` ni otros archivos del repositorio

### Limites verificados de esta sesion adicional

- La simplificacion fue validada de forma estatica:
  - parseo `PowerShell` de `build.ps1` y `reset-data.ps1`: `OK`
  - verificacion de rutas movidas/eliminadas: `OK`
- No se ejecutaron:
  - `build.ps1`
  - `reset-data.ps1`
  - `test-operational.ps1`
  - overlays o jobs reales posteriores a la refactorizacion
- `lab08 / MongoDB` sigue sin implementarse porque la unica evidencia local observable del ambiente docente confirma:
  - `MongoDB shell version v4.4.14`
  - pero no confirma con el mismo nivel de certeza la version real del daemon `mongod`
## 2026-08-05

### Estado actual del proyecto

- El repositorio se sigue consolidando como ambiente base reusable para replicar los laboratorios del modulo de Big Data, no como reemplazo del ambiente docente.
- El `README.md` principal y los `README.md` por laboratorio/perfil fueron ajustados para:
  - explicar la finalidad del proyecto con menos redundancia
  - separar la descripcion general del detalle operativo de `lab01` a `lab08`
  - dejar explicito que los componentes ya fueron implementados y validados funcionalmente en los labs trabajados
- Se creo:
  - `profiles/spark/README.md`
  - para documentar el overlay `Spark` dentro de la progresion del ambiente reusable

### Estado observado del trabajo en curso

- El arbol de trabajo actual contiene cambios documentales y del overlay `MongoDB` aun no cerrados en Git:
  - `compose.mongodb.yml`
  - wrappers `up/status/down/shell` en `PowerShell` y `bash`
  - actualizaciones en `README.md`, `profiles/*/README.md` y `data/shared/lab0X/README.md`
- Se observo una modificacion previa no trabajada por esta sesion en:
  - `containers/scripts/common.ps1`
- Existen ademas salidas y datasets no versionados en `data/` y `evidencia/`; no se limpiaron ni alteraron en esta sesion.

### Inspeccion remota docente de solo lectura

- Se uso el archivo privado de accesos solo para conexion de lectura y verificacion operacional, sin copiar credenciales a la documentacion.
- Conexion remota verificada:
  - host docente accesible por `SSH`
  - `hostname`: `cluster-01`
  - usuario remoto observado: `uhadoop`
- Componentes observados en ejecucion:
  - `MongoDB`
  - `Cassandra`
  - `Elasticsearch`
- Observacion remota de `MongoDB`:
  - bases listadas:
    - `admin`
    - `config`
    - `local`
    - `test`
    - `tvdb`
    - `vtdb`
  - en `tvdb` se observaron las colecciones:
    - `crew`
    - `series`
    - `crewAvatar`
- Observacion remota de `Cassandra`:
  - el acceso funcional a `cqlsh` se logro contra `10.10.10.1 9160`
  - `DESCRIBE KEYSPACES;` y `DESCRIBE KEYSPACE cc66i;` confirmaron que el esquema puede exportarse como DDL

### Criterio vigente derivado de esta sesion

- Si se requiere replicar o respaldar el ambiente docente, la exportacion de esquemas ya cargados es metodologicamente posible al menos para:
  - `MongoDB`, mediante inspeccion/export de metadatos y colecciones
  - `Cassandra`, mediante `DESCRIBE` y/o export de definiciones
- La inspeccion realizada fue de solo lectura; no se ejecutaron cargas, modificaciones ni eliminaciones en el servidor docente.
