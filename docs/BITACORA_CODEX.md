# BITACORA_CODEX

## 2026-07-28

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + Podman machine
- Accion:
  - analisis de documentos del curso
  - diseno versionado `v0.1.0`
  - implementacion del stack `core`
  - validacion real del stack
  - preparacion de estructura por laboratorios
- Resultado verificado:
  - `4` contenedores `healthy`
  - `3` DataNode en HDFS
  - `spark-submit --version` y `pig -version` operativos
- Evidencia principal:
  - `evidencia/smoke-test-20260728-135606.log`
- Observaciones:
  - fue necesario cambiar HDFS de bind mounts de Windows a volumenes de Podman por permisos POSIX
  - se confirmo posteriormente que `data/shared/lab01` a `lab04` contienen material fuente util para replica
  - se entrego guia operativa breve para uso diario del stack desde el laptop

## 2026-07-29

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - reconstruccion de continuidad
  - preparacion de ejecuciones reales para Spark, Hadoop y Pig
  - ampliacion de `smoke-test.ps1` con opcion `-IncludeRealJobs`
- Resultado verificado:
  - continuidad documental reconstruida desde la sesion del `2026-07-28`
  - `podman ps` no conecto al socket local en esta fecha
- Resultado no verificado:
  - ejecucion real de `run-spark-smoke.ps1`
  - ejecucion real de `run-lab02-wordcount.ps1`
  - ejecucion real de `run-lab03-starcount.ps1`
- Observaciones:
  - la falta de conexion al socket de Podman impidio revalidacion en vivo
  - `lab02` se preparo para compilar contra el Hadoop instalado en el contenedor, sin depender de `ant`
  - se confirmo ademas acceso remoto de solo lectura al cluster docente
  - se copiaron referencias remotas priorizadas a `data/shared/lab05/notes/remote-configs/20260729/`
  - se creo el overlay local `ir` para `lab05`
  - se alineo el runtime Java local a `11` para acercarlo al entorno docente remoto
  - se fijaron los manifests locales a `Java 11.0.26`, `Hadoop 2.10.2`, `Spark 3.3.2` y `Pig 0.18.0`
  - se agregaron wrappers `bash` para ejecucion en Rocky Linux o VPS Linux

## 2026-07-29

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - cierre de sesion
  - consolidacion documental
  - validacion sintactica de wrappers `PowerShell`
  - intento de validacion tecnica de wrappers `bash`
- Resultado verificado:
  - `16` scripts `PowerShell` en `containers/scripts/*.ps1` quedaron con parseo correcto
- Resultado no verificado:
  - ejecucion real de los wrappers `bash`
  - rebuild del stack con las nuevas versiones objetivo
- Observaciones:
  - `bash -n` no pudo ejecutarse desde este laptop porque `WSL` no tiene distribuciones instaladas
  - por solicitud del usuario, no se construyeron imagenes en este cierre

## 2026-07-31

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - ajuste de baseline reusable
  - contraste en vivo con el servidor del curso
  - consolidacion documental de versiones alineadas al curso
- Resultado verificado:
  - el servidor del curso expone `Java 11.0.26`, `Hadoop 2.10.0`, `Pig 0.18.0-SNAPSHOT` y `Spark 3.3.2` tras cargar `~/.profile`
  - `containers/base/Containerfile` quedo apuntando a `Temurin 11.0.26`
  - `compose.yml` y los `Containerfile` quedaron alineados a `Hadoop 2.10.0`, `Spark 3.3.2` y `Pig 0.18.0-SNAPSHOT`
- Resultado no verificado:
  - build real del baseline exacto con `Pig 0.18.0-SNAPSHOT`
  - smoke test posterior a la realineacion
- Observaciones:
  - el artefacto exacto de `Pig 0.18.0-SNAPSHOT` no quedo identificado en una fuente publica verificada en esta sesion; el build exige un `PIG_DOWNLOAD_URL` explicito para reproducirlo sin inventar equivalencias

## 2026-07-31

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + Oracle Linux remoto + Podman
- Accion:
  - rebuild remoto en `orcl01-chg`
  - diagnostico y correccion de `ResourceManager`
  - publicacion de imagenes en Docker Hub
  - correccion iterativa de wrappers `PowerShell` para smoke tests con jobs reales
  - revalidacion local completa de `SparkPi`, `lab02` y `lab03`
- Resultado verificado:
  - imagenes remotas alineadas al curso construidas correctamente
  - `YARN ResourceManager` operativo tras agregar `capacity-scheduler.xml`
  - imagenes publicadas en `xbash/*:v0.1.0`
  - `smoke-test.ps1 -IncludeRealJobs` completado con evidencia local
- Evidencia principal:
  - `evidencia/smoke-test-20260731-015423.log`
- Observaciones:
  - fue necesario quitar el bind mount de `logs/` del stack base
  - `lab02` y `lab03` requirieron endurecer wrappers frente a `stderr`, `CRLF` y `BOM`
  - persiste un mensaje cosmetico al truncar algunas salidas HDFS, sin invalidar el resultado funcional observado

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell + Podman
- Accion:
  - endurecimiento minimo de wrappers `ps1` y `sh`
  - incorporacion de comentarios de finalidad en scripts operacionales
  - implementacion de flujo `pull + tag + up --no-build`
  - implementacion de wrappers `lab04` y `lab05`
  - copia remota de datasets `lab04`
  - revalidacion del runtime local y validacion base de `lab04`
- Resultado verificado:
  - imagenes publicadas descargadas y stack base levantado localmente
  - `status.ps1`, `smoke-test.ps1` y `smoke-test.ps1 -IncludeRealJobs` completados
  - `lab04` validado para:
    - `prepare-lab04.ps1`
    - `run-lab04.ps1 -Utility WordCountTask`
    - `run-lab04.ps1 -Utility AverageSeriesRating` con dataset corto y full
- Resultado no verificado:
  - flujo vivo completo de `lab05` sobre overlay `ir`
  - completitud funcional del codigo fuente de `lab05`
- Evidencia principal:
  - `evidencia/smoke-test-20260731-202220.log`
  - `evidencia/smoke-test-20260731-202424.log`
- Observaciones:
  - `run-lab04.ps1` tuvo que compilar en `/tmp` del contenedor por un `Operation not permitted` al escribir el jar en el bind mount
  - persisten warnings de `illegal reflective access` y el mensaje cosmetico `text: Unable to write to output stream.`

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell + Podman
- Accion:
  - correccion funcional de `lab05`
  - revalidacion completa del overlay `ir`
  - implementacion de wrappers y smoke real de `lab06`
  - cierre documental de continuidad
- Resultado verificado:
  - `lab05` validado para:
    - `prepare-lab05.ps1`
    - `up-ir.ps1`
    - `status-ir.ps1`
    - `run-lab05-index.ps1`
    - `run-lab05-search.ps1`
  - el indice `wiki-lab05-v2` quedo con `1000` documentos y consultas reales devolviendo resultados
  - `lab06` validado para:
    - `prepare-lab06.ps1`
    - `run-lab06-pagerank.ps1`
  - `Giraph` y `SortByRank` completaron sobre YARN con salida PageRank no trivial
- Resultado no verificado:
  - ejecucion de `lab06` con el dataset real `es-wiki-links.tsv.gz`
  - validacion de wrappers `bash` de `lab06` en host Linux real
- Observaciones:
  - en `lab05`, el fallo del `TransportClient` no era de red sino de empaquetado del proyecto; hubo que ejecutar el laboratorio como `jar` completo con `META-INF`
  - en `lab06`, el problema ya no era de infraestructura sino de los `@TODO` del enunciado en `PageRank.java`
  - el runtime local sigue mostrando warnings de `illegal reflective access`, sin bloquear las ejecuciones verificadas en esta sesion

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - formalizacion del pendiente de reproducibilidad de `Pig 0.18.0-SNAPSHOT`
  - endurecimiento del baseline reusable para `v0.2.0`
- Resultado verificado:
  - el artefacto local `.artifacts/pig-0.18.0-SNAPSHOT-course.tgz` existe en este checkout
  - su `SHA256` local verificado es `CAE27FD40AF1DE9C1FE45B920B6B5EA4A6D9351B50DB3290FCB95D10B21466AF`
  - los scripts de build y el `Containerfile` base quedaron configurados para rechazar artefactos de Pig distintos
- Resultado no verificado:
  - build real local de `v0.2.0`
  - validacion en `orcl01-chg`
  - publicacion de `xbash/*:v0.2.0`
- Observaciones:
  - este cambio resuelve la reproducibilidad del insumo exacto usado por el baseline, pero no prueba una fuente publica alterna del snapshot

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - revision estatica del pendiente de wrappers `bash` para Linux real
  - endurecimiento preventivo antes de la validacion final en `orcl01-chg`
- Resultado verificado:
  - `prepare-lab05.sh` ya no usa `tar` sobre un `.zip`; extrae con `python3`
  - los wrappers de jobs revisados ya no dependen de `/usr/bin/podman`
  - `run-lab05-search.sh` deja de inyectar la consulta en claro y la pasa codificada en `base64`
- Resultado no verificado:
  - parseo `bash -n` local
  - ejecucion real de wrappers `bash` en Linux
- Observaciones:
  - `bash -n` sigue bloqueado en este laptop porque `WSL` no tiene distribuciones instaladas
  - por solicitud del usuario, la validacion Linux real y la aplicacion final en `ServidorQA` quedan movidas al backlog de cierre

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - cierre documental del flujo `pull + tag + up --no-build` desde Docker Hub
- Resultado verificado:
  - existe evidencia previa de pull y rehidratacion local para `v0.1.0`
  - el proyecto ahora tiene un documento operativo dedicado:
    - `docs/FLUJO_PULL_DOCKER_HUB.md`
- Resultado no verificado:
  - disponibilidad publica del tag `v0.2.0` en Docker Hub
  - revalidacion publica del flujo para `v0.2.0`
- Observaciones:
  - se distinguio explicitamente entre evidencia pasada de `v0.1.0` y flujo previsto para `v0.2.0`

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - analisis del pendiente de `lab05` sobre shards y replicas del indice local
  - correccion del payload de creacion del indice
- Resultado verificado:
  - la causa estaba en `BuildWikiIndexBulk.java`
  - el indice se creaba con `mappings` solamente
  - `Elasticsearch 6.8.10` completaba por defecto `5` shards y `1` replica
- Cambio aplicado:
  - el indice ahora se crea con:
    - `number_of_shards = 1`
    - `number_of_replicas = 0`
- Resultado no verificado:
  - reindexacion real posterior a la correccion

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - consolidacion funcional de pendientes de `lab06`
- Resultado verificado:
  - el usuario confirmo que para el avance actual basta el dataset pequeno ya validado
  - el dataset real fue copiado al proyecto
  - el PDF de `lab06` indica que `PageRank` se usa para mejorar el ranking de resultados de la clase anterior
- Implicancia aceptada:
  - la prueba con dataset real queda diferida como pendiente final
  - `lab06` requiere como insumo los resultados de `lab05`

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - limpieza del mensaje residual `Unable to write to output stream` en previews HDFS
- Resultado verificado:
  - los scripts ya no usan `head` en las vistas previas HDFS ajustadas
  - las variantes `PowerShell` editadas mantienen parseo correcto
- Cambio aplicado:
  - reemplazo de `head` por `awk` en los previews de:
    - `lab02`
    - `lab03`
    - `lab04`
    - `lab06`
- Resultado no verificado:
  - rerun vivo posterior del smoke para confirmar ausencia del mensaje en nueva evidencia

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell + Podman
- Accion:
  - validacion funcional del flujo real de `lab02` asociado al wrapper Linux `run-lab02-wordcount.sh`
- Resultado verificado:
  - el stack local estaba operativo
  - el flujo de WordCount completo termino correctamente
  - salida HDFS observada:
    - `/outputs/lab02/wordcount-20260801-010019`
  - contadores relevantes:
    - `Map input records = 1000`
    - `Reduce output records = 19483`
- Resultado no verificado:
  - ejecucion directa del archivo `.sh` en un host Linux real
- Observaciones:
  - la validacion funcional reduce el riesgo de logica del wrapper
  - el cierre especifico del wrapper Linux sigue diferido a `ServidorQA`

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - cierre documental del pendiente sobre `lab02/docs/hadooppass.txt`
- Resultado verificado:
  - el usuario indico que el archivo ya fue eliminado del proyecto
- Observaciones:
  - se marco el pendiente como resuelto en la continuidad del checkout

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - verificacion y cierre del pendiente sobre el dataset full de `lab05`
- Resultado verificado:
  - el archivo `data/shared/lab05/datasets/es-wiki-articles.tsv.gz` existe en el checkout
  - tamano observado:
    - `200465618` bytes
- Observaciones:
  - queda disponible para la corrida funcional completa de `lab05`

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - consolidacion de pendientes trabajados para continuidad de otra sesion
- Resultado verificado:
  - se creo `docs/pendientes_lista.md`
- Observaciones:
  - el archivo resume estados `RESUELTO`, `RESUELTO-PARCIAL`, `PENDIENTE`, `PENDIENTE-DIFERIDO` y `ACLARADO`

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - incorporacion del componente `sql-ui` al baseline reusable
  - resolucion del pendiente sobre `compose.hive.yml`
- Resultado verificado:
  - la ultima version local vigente paso de `v0.2.0` a `v0.3.0`
  - `compose.hive.yml` ya no queda como placeholder neutro
  - el componente visual elegido para el overlay `sql-hive` es `Hue`
- Cambio aplicado:
  - se agrego `containers/sql-ui/Containerfile`
  - se actualizaron manifests, scripts de build y documentacion de continuidad
- Resultado no verificado:
  - build real del nuevo componente
  - validacion funcional completa del overlay `sql-hive`

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - preparacion de wrappers operativos para el overlay `sql-hive`
- Resultado verificado:
  - parseo local `OK` de:
    - `up-hive.ps1`
    - `status-hive.ps1`
    - `down-hive.ps1`
    - `shell-hive.ps1`
    - `shell-sql-ui.ps1`
- Resultado no verificado:
  - `podman compose ... config` del overlay en este sandbox
  - build y runtime real de `sql-hive`
- Observaciones:
  - `podman` quedo bloqueado por acceso denegado a `containers.conf`
  - la validacion funcional sigue reservada para `ServidorQA`

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + `ServidorQA` Oracle Linux
- Accion:
  - validacion Linux real de wrappers `bash` sobre `orcl01-chg`
- Resultado verificado:
  - `bash -n` paso para todos los `containers/scripts/*.sh`
  - `status.sh`, `status-ir.sh`, `status-hive.sh` ejecutaron en Linux real
  - `down.sh`, `down-ir.sh`, `down-hive.sh` ejecutaron en Linux real
  - `compose.yml + compose.hive.yml` expanden correctamente bajo `podman-compose`
  - el checkout remoto quedo actualizado con:
    - `.artifacts`
    - baseline reusable
    - `lab05`
    - `lab06`
    - `docs`
- Hallazgo corregido:
  - `status-hive.sh`, `up-hive.sh` y `down-hive.sh` no debian usar `--profile`
  - causa: `podman-compose 1.0.6` del host no soporta ese flujo
- Resultado no verificado:
  - `up.sh`, `up-ir.sh`, `up-hive.sh`
  - `build.sh`, `build-clean.sh`
  - `run-lab02-wordcount.sh` en ejecucion real
- Observaciones:
  - el host muestra errores de lock huérfano en Podman rootless
  - `down.sh` removio los contenedores antiguos `v0.1.0`
## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + `ServidorQA` Oracle Linux
- Accion:
  - resincronizacion del checkout remoto con una ronda 1 sin datasets de `lab01..lab08`
  - correccion del build `v0.3.0`
  - levantamiento del stack base en `ServidorQA`
- Resultado verificado:
  - `/home/opc/bigdata-lab` quedo reconstruido con todo el proyecto salvo `data/shared/lab01..lab08/datasets`
  - `build.sh` ejecuto realmente en Linux real y construyo:
    - `bigdata-core-base:v0.3.0`
    - `bigdata-master:v0.3.0`
    - `bigdata-worker:v0.3.0`
    - `bigdata-sql-ui:v0.3.0`
  - el build quedo limpio tras retirar el warning de `PIG_ARCHIVE_SHA256` no consumido
  - `up.sh` ejecuto realmente en Linux real
  - quedaron `healthy`:
    - `bigdata-master`
    - `bigdata-worker1`
    - `bigdata-worker2`
    - `bigdata-worker3`
- Observaciones:
  - el siguiente paso operativo es copiar manualmente los datasets al remoto
  - los overlays `ir` y `sql-hive` siguen pendientes de arranque y validacion funcional

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + `ServidorQA` Oracle Linux
- Accion:
  - validacion real de overlays `ir` y `sql-hive` en el remoto
- Resultado verificado:
  - `up-ir.sh` y `status-ir.sh` ejecutaron realmente
  - `bigdata-elasticsearch` quedo arriba con:
    - `9200/tcp`
    - `9300/tcp`
    - `_cat/health = green`
  - `up-hive.sh` y `status-hive.sh` ejecutaron realmente
  - quedaron arriba:
    - `bigdata-sql-ui`
    - `bigdata-hive-metastore`
    - `bigdata-hive-server`
  - endpoints verificados:
    - `Hue` responde `HTTP/1.1 302 Found` en `8888`
    - `HiveServer2` web responde `HTTP/1.1 200 OK` en `10002`
    - `9083` y `10000` quedan abiertos
- Observaciones:
  - la primera corrida de `status-ir.sh` consulto antes de tiempo y devolvio `Connection refused`; una segunda validacion confirmo arranque correcto de Elasticsearch
  - `up-hive.sh` demoro por descarga y bootstrap inicial
  - `bigdata-hive-metastore` registra `NoClassDefFoundError: org/apache/hadoop/yarn/util/SystemClock` en tareas internas de housekeeping; no impidio el arranque, pero queda como riesgo abierto antes del cierre final

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local
- Accion:
  - reorganizacion de wrappers por laboratorio
- Resultado verificado:
  - la ubicacion canonica de scripts de laboratorio queda bajo `data/shared/lab0X/scripts`
  - `containers/scripts` conserva wrappers delegadores de compatibilidad
  - quedaron reubicados wrappers de `lab02`, `lab03`, `lab04`, `lab05` y `lab06`
- Observaciones:
  - el cambio preserva el uso historico desde `containers/scripts`, pero ordena el contenido funcional junto al material de cada laboratorio

## 2026-08-01

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local
- Accion:
  - alineacion de `lab01` a la estructura `data/shared/lab01/*`
  - validacion controlada del pipeline externo con `n=51`
- Resultado verificado:
  - `run_lab01_experiments.ps1`, `run_lab01_experiments_macos.sh` y `abrir-powershell-lab01.cmd` quedaron ajustados a:
    - `datasets/`
    - `work/gdd_lab01/gdd-wiki`
    - `logs/lab01`
    - `results/`
  - los resultados historicos en `work/work_lab01` quedaron preservados
  - corrida real ejecutada:
    - `-UseSample -SkipInMemory -RunExternalPipeline -ExternalN 51 -Heap 1024M -BatchSize 10000 -TopK 20`
  - etapas del pipeline:
    - `extract`: `OK`
    - `sort`: `OK`
    - `count`: `OK`
    - `rank`: `OK`
    - `head`: `OK`
  - artefacto final verificado:
    - `data/shared/lab01/results/es-wiki-abstracts-n51-grams-c-s-top20.txt`
- Observaciones:
  - la escritura a `results/` fallo dentro del sandbox del agente con `Access denied`
  - la validacion real debio correrse fuera del sandbox

## 2026-08-02

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local
- Accion:
  - revision de permisos efectivos y normalizacion final de destinos de `lab01`
- Resultado verificado:
  - los scripts de `lab01` quedaron ajustados para usar solo:
    - `data/shared/lab01/results/`
    - `data/shared/lab01/logs/`
  - se elimino el fallback de resultados a `work/work_lab01`
  - se elimino la subruta operativa `logs/lab01`
  - el arbol actual de `work/` conserva solo `gdd_lab01/`
  - el arbol actual de `logs/` contiene directamente la evidencia operativa
  - `run_lab01_experiments.ps1` parsea correctamente luego del cambio
- Observaciones:
  - en esta sesion siguio observandose `Access denied` para pruebas simples de escritura desde el entorno gestionado del agente
  - la correccion de rutas quedo validada por inspeccion de scripts, no por una nueva corrida completa de `lab01`

## 2026-08-02

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell + Podman
- Accion:
  - cierre adicional de `lab01`
  - implementacion y compilacion de `lab02`
  - carga de contexto de `lab03`
- Resultado verificado:
  - `lab01` queda cerrado operativamente segun evidencia local existente y confirmacion del usuario de ejecucion `OK`
  - `lab02` queda con proyecto completo en `data/shared/lab02/work/gdd-hadoop`
  - `LetterCount.java` queda implementado
  - el `jar` local queda compilado y empaquetado
  - existen evidencias locales:
    - `data/shared/lab02/logs/20260802-wordcount-run.log`
    - `data/shared/lab02/logs/20260802-wordcount-top20.txt`
    - `data/shared/lab02/logs/20260802-lettercount-run.log`
    - `data/shared/lab02/logs/20260802-lettercount-results.txt`
    - `data/shared/lab02/results/20260802-lettercount-a-z.txt`
  - `lab03` queda releido y listo para avanzar desde `star-count` hacia `costar-count`
- Observaciones:
  - la ejecucion de `WordCount` quedo observada con `completed successfully`
  - la ejecucion final de `LetterCount` queda registrada como confirmada por el usuario y respaldada por artefactos locales presentes
  - la siguiente fase tecnica ya no es infraestructura: es adaptar y validar `costar-count` en `lab03`

## 2026-08-02

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local
- Accion:
  - modularizacion adicional de runners `PowerShell` y `bash` de `lab01`
  - analisis de conveniencia entre wrappers separados vs. un solo script principal con `-Mode`
- Resultado verificado:
  - `PowerShell` queda modularizado con:
    - `lab01-common.ps1`
    - `run_lab01_inmemory.ps1`
    - `run_lab01_external.ps1`
    - `run_lab01_experiments.ps1`
  - `bash` queda modularizado con:
    - `run_lab01_common.sh`
    - `run_lab01_inmemory.sh`
    - `run_lab01_external.sh`
    - `run_lab01_experiments.sh`
  - `run_lab01_experiments_macos.sh` queda como alias de compatibilidad
  - parseo `PowerShell` verificado `OK`
- Observaciones:
  - el host no permitio validar `bash -n` por `Access denied`
  - recomendacion actual pendiente de confirmacion del usuario:
    - dejar un solo script principal para UX
    - y mantener la modularizacion interna con wrappers como alias

## 2026-08-02

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell + Podman
- Accion:
  - consolidacion final de `lab01` con documentacion operativa
  - separacion explicita de `lab02` en `WordCount` y `LetterCount`
  - implementacion inicial y depuracion runtime de `costar-count` en `lab03`
- Resultado verificado:
  - `lab01` queda con referencia operativa en:
    - `docs/COMANDOS_OPERATIVOS_LAB01.md`
  - `lab02` queda con wrappers nuevos:
    - `run-lab02-wordcount.ps1`
    - `run-lab02-lettercount.ps1`
    - `run-lab02-wordcount.sh`
    - `run-lab02-lettercount.sh`
  - `lab03` queda con:
    - `costar-count.template.pig`
    - `run-lab03-costarcount.ps1`
  - los wrappers de `lab03` ahora dejan:
    - log local en `data/shared/lab03/logs/`
    - preview local en `data/shared/lab03/results/`
  - se observo ejecucion real fallida de `costar-count` con:
    - error de parseo Pig
    - luego error de plan fisico invalido
  - el script Pig fue simplificado a un self-join por `movie_id`
  - los errores del wrapper ahora reportan causa resumida y ruta del log local
- Observaciones:
  - el avance de `lab03` ya esta respaldado por errores reales observados, no solo por implementacion estatica
  - aun falta una corrida exitosa posterior al ultimo ajuste de `costar-count.template.pig`

## 2026-08-02

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell + Podman
- Accion:
  - cierre formal parcial de `lab03` tras corrida exitosa de `costar-count`
  - correccion del wrapper para preservar `UTF-8` en la muestra y limpiar `WARNING:` del preview
  - preparacion de artefacto formal con top-10 observado y par adicional
- Resultado verificado:
  - `lab03` ejecuto `costar-count` con `SUCCEEDED` y `Success!`
  - evidencia local presente:
    - `data/shared/lab03/logs/20260802-034543-costarcount-run.log`
    - `data/shared/lab03/results/20260802-034543-costarcount-top20.txt`
    - `data/shared/lab03/results/20260802-034543-costarcount-entrega.md`
  - el wrapper `run-lab03-costarcount.ps1` ahora:
    - fuerza lectura `UTF-8` al regenerar `imdb-stars-test.tsv`
    - excluye `WARNING:` del preview local
- Observaciones:
  - la corrida verificada corresponde a la muestra `imdb-stars-test.tsv`
  - para cierre completo segun PDF aun conviene una corrida equivalente sobre `imdb-stars.tsv` full

## 2026-08-03

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell + Podman + WSL
- Accion:
  - diagnostico runtime de la corrida full de `lab06`
  - aumento gradual de memoria efectiva de la VM de Podman hasta ~`24 GB`
  - rehidratacion del stack base tras reinicios y validacion de HDFS
- Resultado verificado:
  - `lab06` siguio fallando sobre `es-wiki-links.tsv.gz`
  - se confirmo que el ajuste de memoria en `WSL` si aplica dentro de la VM aunque `podman machine list` siga mostrando `8GiB`
  - evidencia observada:
    - `MemTotal: 24610416 kB`
  - se registro un reintento fallido por `Name node is in safe mode`
  - luego se verifico:
    - `Safe mode is OFF`
    - `hdfs dfsadmin -report` sin bloques faltantes ni corruptos
- Observaciones:
  - `bigdata-elasticsearch` no se necesita para calcular `PageRank` y conviene mantenerlo abajo durante la fase pesada de `lab06`
  - el siguiente ajuste prudente del job seria aumentar tambien:
    - `MapMemoryMb`
    - `MapJavaOpts`

## 2026-08-03

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell + Podman + SSH de solo lectura al servidor docente
- Accion:
  - carga del enunciado `lab07.pdf`
  - inspeccion remota de version y despliegue Cassandra docente sin registrar credenciales
  - implementacion del overlay `nosql-cassandra` sobre los cuatro contenedores existentes
  - desarrollo del runner reproducible de Lab07
  - documentacion de alternativas por Cassandra `2.0.7`
- Resultado verificado:
  - servidor docente observado:
    - Cassandra `2.0.7`
    - `cqlsh 4.1.1`
    - CQL `3.1.1`
    - Thrift `19.39.0`
    - 5 nodos `UN`
  - overlay local validado:
    - solo servicios `master`, `worker1`, `worker2`, `worker3`
    - 4 nodos Cassandra `UN`
    - `SHOW VERSION` coincide con Cassandra `2.0.7`, `cqlsh 4.1.1`, CQL `3.1.1`, Thrift `19.39.0`
  - Lab07 genero evidencia final:
    - `data/shared/lab07/results/20260803-215924-lab07-cassandra-comandos-entrega.cql`
    - `data/shared/lab07/results/20260803-215924-lab07-cassandra-resumen.txt`
    - `data/shared/lab07/logs/20260803-215924-lab07-cassandra-run.log`
- Observaciones:
  - los scripts de habilitacion Cassandra quedaron concentrados en `containers/scripts/`
  - no se mantiene `containers/common/`
  - las consultas por indice secundario en Cassandra `2.0.7` via Thrift no fueron confiables y se reemplazaron por tablas orientadas a consulta en el flujo validado

## 2026-08-04

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell + Podman
- Accion:
  - cierre de conclusion operativa del ambiente reusable tras la revalidacion viva en orden:
    - `core`
    - `lab04 / Spark`
    - `lab05 / IR`
    - `lab06 / graph`
    - `lab07 / Cassandra`
  - ajuste documental del `README` para reflejar la progresion efectiva del ambiente
  - implementacion y validacion del flujo de integracion `lab06 -> lab05`
- Resultado verificado:
  - el diseno queda alineado, en grado alto, con la progresion objetivo de laboratorios:
    - `core`: `Hadoop` + `HDFS` + `YARN` + `Pig`
    - `lab04`: overlay `Spark`
    - `lab05`: overlay `IR`
    - `lab06`: perfil `graph` con `Giraph`
    - `lab07`: overlay `Cassandra`
    - `lab08`: `MongoDB` aun pendiente de implementacion local
  - `lab06` completo con dataset real ya no depende de `Elasticsearch`; la integracion con `lab05` queda como fase posterior y opcional
  - se valido la corrida full de `PageRank` + `SortByRank` sobre:
    - `data/shared/lab06/datasets/es-wiki-links.tsv.gz`
  - evidencia principal de esa corrida:
    - log: `data/shared/lab06/logs/20260804-000726-lab06-pagerank-run.log`
    - preview PageRank: `data/shared/lab06/results/20260804-000726-lab06-pagerank-top10.txt`
    - preview ordenado: `data/shared/lab06/results/20260804-000726-lab06-pagerank-sorted-top10.txt`
    - salida HDFS PageRank: `/outputs/lab06/pagerank-20260804-000726`
    - salida HDFS ordenada: `/outputs/lab06/pagerank-sorted-20260804-000726`
  - se valido la integracion `lab06 -> lab05` mediante export de ranks y reindexacion comparativa:
    - wrapper: `data/shared/lab06/scripts/run-lab06-lab05-integration.ps1`
    - ranks exportados: `data/shared/lab06/results/lab05-rank-integration/ranks.s.tsv`
    - comparacion: `data/shared/lab06/results/lab05-rank-integration/20260804-001746-lab05-rank-compare-estados-unidos.md`
  - la indexacion enriquecida de `lab05` quedo soportada por:
    - `data/shared/lab05/scripts/run-lab05-index.ps1` con `-RanksLocalPath` y `-RanksHostPath`
    - `data/shared/lab05/scripts/run-lab05-search.ps1` con `-UseRank`, `-RankFactor`, `-ShowRank` y `-ShowScore`
- Observaciones:
  - la recomendacion operativa se mantiene en `Elasticsearch single-node` para el laptop; distribuirlo en mas nodos encarece RAM sin necesidad demostrada para estos labs
  - la conclusion ya permite tratar el ambiente como:
    - una base `core` estable
    - overlays optativos por laboratorio, sin recrear el cluster desde cero
  - la refactorizacion de wrappers `bash` sigue como cierre pendiente posterior a esta fase `PowerShell`

## 2026-08-04

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell
- Accion:
  - simplificacion estructural de scripts y rutas operativas
  - separacion entre wrappers `bash`, scripts privados y runtime reusable
  - redefinicion de `reset-data.ps1` como `factory reset`
  - evaluacion metodologica de `MongoDB` para `lab08`
  - consolidacion documental de cierre de sesion
- Resultado verificado:
  - los wrappers `bash` del ambiente reusable quedaron bajo:
    - `containers/scripts/bash/`
  - `build-clean.ps1` fue absorbido por:
    - `containers/scripts/build.ps1 -NoCache`
  - los scripts privados `PowerShell` quedaron movidos a:
    - `docs/private/pull-images-and-up.ps1`
    - `docs/private/sync-servidorqa.ps1`
  - `sync-servidorqa-rsync.ps1` fue retirado del arbol operativo
  - `reset-data.ps1` ahora:
    - ejecuta `down-all.ps1`
    - elimina solo volumenes persistentes del cluster
    - no borra contenido del repositorio
  - parseo `PowerShell` validado para:
    - `containers/scripts/build.ps1`
    - `containers/scripts/reset-data.ps1`
- Resultado no verificado:
  - ejecucion real de:
    - `build.ps1 -NoCache`
    - `reset-data.ps1`
    - `test-operational.ps1`
    - wrappers `bash` luego del movimiento a `containers/scripts/bash/`
  - implementacion de `MongoDB` local alineada al ambiente docente
- Observaciones:
  - no se implemento `MongoDB` porque la evidencia local solo confirma el `shell` `v4.4.14`; la version real del daemon `mongod` sigue pendiente de revalidacion
  - el proyecto queda mas simple, con menor duplicacion y separacion mas clara entre baseline reusable y utilitarios privados
## 2026-08-05

- Agente: Codex
- Modelo/version: pendiente-de-verificacion
- Entorno: Windows local + PowerShell + SSH de solo lectura al servidor docente
- Accion:
  - ajuste del `README.md` principal para dejar mas clara la finalidad del proyecto
  - alineacion de `README.md` de perfiles y laboratorios con el estado funcional ya validado
  - creacion de `profiles/spark/README.md`
  - inspeccion remota de solo lectura para verificar si los esquemas cargados en el ambiente docente pueden exportarse
- Resultado verificado:
  - el proyecto queda descrito de forma mas precisa como ambiente base reusable para replicar laboratorios
  - se deja explicito que no busca reemplazar el ambiente docente
  - se confirma acceso remoto de solo lectura al host docente observado como:
    - `cluster-01`
  - en `MongoDB` remoto se observaron las bases:
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
  - en `Cassandra` remoto se verifico exportabilidad de esquema con:
    - `DESCRIBE KEYSPACES;`
    - `DESCRIBE KEYSPACE cc66i;`
- Resultado no verificado:
  - export completo de todos los esquemas del servidor docente a archivos locales
  - inspeccion equivalente de `Hive` o `Elasticsearch` orientada a exportacion
- Observaciones:
  - la sesion no persistio credenciales en la documentacion
  - `containers/scripts/common.ps1` presentaba una modificacion previa no intervenida
