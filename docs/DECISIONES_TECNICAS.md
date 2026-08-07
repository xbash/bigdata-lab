# DECISIONES_TECNICAS

## 2026-07-28

### DT-001: baseline de 4 contenedores

- Decision:
  - usar `1 master + 3 workers`
- Motivo:
  - replica mejor el ambiente academico de `4` maquinas y cabe en la VM recreada de Podman
- Impacto:
  - HDFS queda en `1 NameNode + 3 DataNode`
  - Spark queda en `1 Master + 3 Worker`

### DT-002: base + extensiones futuras

- Decision:
  - mantener un `core` minimo y preparar futuras tecnologias como overlays
- Core:
  - Java
  - Hadoop/HDFS
  - MapReduce/YARN
  - Pig
  - Spark
- Extensiones previstas:
  - Hive
  - Lucene
  - Cassandra
  - MongoDB
  - Giraph

### DT-003: configuracion externa

- Decision:
  - montar `conf/` desde fuera de las imagenes
- Motivo:
  - reducir rebuilds y facilitar ajustes

### DT-004: persistencia HDFS en volumenes de Podman

- Decision:
  - usar volumenes de Podman para `namenode` y `datanode*`
- Motivo verificado:
  - el primer arranque real con bind mounts de Windows fallo al formatear HDFS por permisos POSIX
- Impacto:
  - `conf/`, `data/shared/`, `data/outputs/` y `logs/` siguen como bind mounts visibles en el workspace

### DT-005: replica HDFS por defecto

- Decision:
  - `dfs.replication = 2`
- Motivo:
  - balance entre realismo distribuido y presion de disco

### DT-006: estructura por laboratorio bajo `data/shared/`

- Decision:
  - crear `lab01` a `lab08` con subdirectorios:
    - `docs/`
    - `datasets/`
    - `scripts/`
    - `results/`
    - `notes/`
- Motivo:
  - ordenar insumos, experimentos y resultados por laboratorio

## 2026-07-29

### DT-007: alineamiento de versiones con el ambiente docente usando adaptaciones minimas locales

- Decision:
  - fijar el stack local objetivo en:
    - Java `11.0.26`
    - Hadoop `2.10.2`
    - Spark `3.3.2`
    - Pig `0.18.0`
    - Elasticsearch `6.8.10` para `lab05`
- Motivo:
  - aproximar el entorno del curso con artefactos publicos y mantenibles para laptop o VPS
- Limitacion aceptada:
  - el ambiente docente observado no coincide exactamente en todos los artefactos publicos:
    - Hadoop remoto observado `2.10.0`
    - Pig remoto observado `0.18.0-SNAPSHOT`
  - la compatibilidad final queda sujeta a revalidacion en vivo

### DT-008: paridad operativa PowerShell mas bash

- Decision:
  - mantener wrappers `PowerShell` y `bash` equivalentes en `containers/scripts/`
- Motivo:
  - permitir ejecucion tanto en laptop Windows como en un futuro host Linux o Rocky Linux
- Estado aceptado:
  - `PowerShell` validado por sintaxis en esta sesion
  - `bash` preparado pero pendiente de validacion en un host Linux real

## 2026-07-31

### DT-009: versiones definitivas del baseline reusable

- Decision:
  - fijar el baseline reusable en:
    - Java `11.0.26`
    - Hadoop `2.10.0`
    - Spark `3.3.2`
    - Pig `0.18.0-SNAPSHOT`
- Motivo:
  - consolidar una base reusable alineada con el entorno observado en vivo en el cluster docente
- Impacto:
  - `containers/base/Containerfile` vuelve a `Temurin 11.0.26`
  - `compose.yml` y los `Containerfile` derivados pasan a `Hadoop 2.10.0` y `Pig 0.18.0-SNAPSHOT`
  - el build exacto de Pig requiere un `PIG_DOWNLOAD_URL` verificado para el snapshot
- Limitacion aceptada:
  - falta rebuild y revalidacion en vivo para confirmar compatibilidad operativa del stack alineado al curso

### DT-010: evitar bind mount de `logs/` en el stack base

- Decision:
  - quitar `./logs:/opt/bigdata/logs` del stack base en `compose.yml`
- Motivo verificado:
  - en `orcl01-chg`, `NameNode` y `ResourceManager` fallaban por `Permission denied` al escribir logs sobre el bind mount
- Impacto:
  - el stack base queda mas estable para Hadoop/YARN
  - la evidencia operativa debe capturarse por `evidencia/`, `podman exec`, `podman logs` o copias explicitas, no asumir que todo quedara persistido en `logs/`

### DT-011: scheduler minimo explicito para YARN

- Decision:
  - agregar `conf/hadoop/capacity-scheduler.xml` con `root.default`
- Motivo verificado:
  - `ResourceManager` abortaba con `Queue configuration missing child queue names for root`
- Impacto:
  - YARN queda operativo para `lab02` y `lab03`

### DT-012: wrappers PowerShell de jobs reales desacoplados de `stdin` directo

- Decision:
  - ejecutar scripts Bash temporales copiados al contenedor para `lab02` y `lab03`
- Motivo verificado:
  - `stdin` desde PowerShell introducia problemas de `CRLF`, `BOM` y quoting en Windows
- Impacto:
  - `run-lab02-wordcount.ps1` y `run-lab03-starcount.ps1` quedan estables para smoke tests con jobs reales

## 2026-08-01

### DT-013: pull de imagenes publicadas como flujo operativo valido

- Decision:
  - permitir un flujo de `pull + tag + up --no-build` para rehidratar el ambiente reusable desde Docker Hub
- Motivo verificado:
  - el stack pudo levantarse localmente usando:
    - `xbash/bigdata-core-base:v0.1.0`
    - `xbash/bigdata-master:v0.1.0`
    - `xbash/bigdata-worker:v0.1.0`
- Impacto:
  - `docs/private/pull-images-and-up.ps1`
  - `containers/scripts/bash/pull-images-and-up.sh`
  - el ambiente no depende siempre de rebuild local para recuperar operatividad

### DT-014: compilar `lab04` en almacenamiento temporal del contenedor

- Decision:
  - compilar `gdd-spark` en `/tmp` dentro del contenedor en vez de escribir `dist/` sobre el bind mount del workspace
- Motivo verificado:
  - la escritura de `dist/gdd-spark.jar` en el bind mount produjo `java.nio.file.FileSystemException ... Operation not permitted`
- Impacto:
  - `containers/scripts/run-lab04.ps1` copia temporalmente el proyecto a `/tmp/lab04-work/`
  - el smoke tecnico y `AverageSeriesRating` pudieron ejecutarse sin modificar el `core`

### DT-015: `lab05` debe ejecutarse como jar empaquetado, no como classpath suelto

- Decision:
  - ejecutar el proyecto `gdd-elastic` de `lab05` como `jar` empaquetado con dependencias y `META-INF`, consistente con `build.xml`
- Motivo verificado:
  - el enfoque de `bin + lib/*` provocaba fallo del cliente Java de Elasticsearch:
    - `ExceptionInInitializerError`
    - `NullPointerException` durante inicializacion de `org.elasticsearch.Build`
- Impacto:
  - los wrappers `run-lab05-index` y `run-lab05-search` replican manualmente el empaquetado final dentro del contenedor
  - el bloqueo del `TransportClient` quedo resuelto sin modificar el `core`

### DT-016: `lab06` corre sobre el `core` actual sin overlay `graph`

- Decision:
  - mantener `lab06` sobre el `core` reusable actual y no crear un overlay nuevo en esta etapa
- Motivo verificado:
  - `Giraph` y `SortByRank` ejecutaron correctamente sobre el cluster local ya operativo
  - el problema observado era del codigo del laboratorio y de los flags de lanzamiento, no de falta de servicios adicionales
- Impacto:
  - se agregaron `prepare-lab06.ps1` y `run-lab06-pagerank.ps1`
  - el siguiente paso de `lab06` queda enfocado en dataset real y no en infraestructura

### DT-017: completar solo los `@TODO` del enunciado en `lab05` y `lab06`

- Decision:
  - mantener intervenciones minimas en el codigo fuente de los laboratorios, limitadas a completar los `@TODO` y ajustes operativos estrictamente necesarios
- Motivo:
  - preservar fidelidad con el material docente y evitar convertir wrappers o ejercicios en programas mas complejos de lo requerido
- Impacto:
  - `lab05` queda alineado con la intencion del PDF en indexacion y salida de busqueda
  - `lab06` queda alineado con la implementacion esperada de `PageRank`

### DT-018: congelar y verificar el artefacto exacto de `Pig 0.18.0-SNAPSHOT` para el baseline `v0.2.0`

- Decision:
  - formalizar como insumo obligatorio el artefacto local:
    - `.artifacts/pig-0.18.0-SNAPSHOT-course.tgz`
  - verificar su integridad con:
    - `.artifacts/pig-0.18.0-SNAPSHOT-course.tgz.sha256`
- Motivo verificado:
  - el runtime ya mostro en evidencia `Pig 0.18.0-SNAPSHOT (r1900865)`
  - no existe en este checkout una fuente publica verificada del snapshot exacto del curso
  - el flujo anterior dependia del archivo local, pero sin verificacion formal de integridad
- Impacto:
  - `build.ps1`, `build.ps1 -NoCache`, `build.sh` y `build-clean.sh` fallan si falta el artefacto o su `SHA256`
  - `containers/base/Containerfile` vuelve a verificar el `SHA256` dentro del build
  - la linea base reusable pasa a versionarse como `v0.2.0`
- Limitacion aceptada:
  - este criterio vuelve reproducible el insumo exacto usado por el proyecto, pero no demuestra un origen publico alternativo del snapshot

### DT-019: mantener documentado el flujo `pull + tag + up --no-build` con evidencia y limite de version

- Decision:
  - mantener el flujo de rehidratacion desde Docker Hub como procedimiento documentado, separado del flujo de build
- Motivo verificado:
  - existe evidencia local de rehidratacion correcta para `v0.1.0`
  - la linea base local ya apunta a `v0.2.0`, por lo que la publicacion de ese tag debe diferenciarse explicitamente de la evidencia ya existente
- Impacto:
  - se agrega `docs/FLUJO_PULL_DOCKER_HUB.md`
  - el proyecto distingue entre:
    - flujo historicamente verificado para `v0.1.0`
    - flujo previsto pero aun no revalidado publicamente para `v0.2.0`

### DT-020: desarrollar `compose.hive.yml` como overlay `sql-hive` con `Hue` como visualizador SQL

- Decision:
  - dejar de tratar `compose.hive.yml` como placeholder neutro
  - incorporar el componente `sql-ui` basado en `Hue`
  - mantener en el mismo overlay los futuros servicios:
    - `Hive Metastore`
    - `HiveServer2`
- Motivo:
  - el usuario quiere contar con un visualizador de consultas SQL dentro del ambiente reusable
  - este frente SQL debe convivir con la proyeccion de `lab07` y `lab08` hacia tecnologias `NoSQL`
- Impacto:
  - se agrega `containers/sql-ui/Containerfile`
  - `compose.hive.yml` pasa a declarar `sql-ui`, `hive-metastore` y `hive-server2`
  - la linea base local avanza a `v0.3.0`
- Limitacion aceptada:
  - en esta sesion solo queda incorporado el componente y su trazabilidad
  - la validacion funcional completa del overlay `sql-hive` queda pendiente para `ServidorQA`
### DT-021: sincronizar `ServidorQA` en dos rondas y excluir `datasets/` en la primera

- Decision:
  - reconstruir `/home/opc/bigdata-lab` con una primera ronda que sincroniza todo el proyecto excepto:
    - `data/shared/lab01/datasets`
    - `data/shared/lab02/datasets`
    - `data/shared/lab03/datasets`
    - `data/shared/lab04/datasets`
    - `data/shared/lab05/datasets`
    - `data/shared/lab06/datasets`
    - `data/shared/lab07/datasets`
    - `data/shared/lab08/datasets`
- Motivo:
  - reducir tiempo de transferencia
  - evitar resincronizaciones lentas de archivos pesados
  - separar el baseline reusable y los laboratorios del transporte manual posterior de datasets
- Impacto:
  - `docs/private/sync-servidorqa.ps1` queda orientado a esa ronda 1
  - la ronda 2 de datasets se hace por un mecanismo manual externo al script

### DT-022: mantener `tar + pscp + plink` como ruta estable de sincronizacion hacia `ServidorQA`

- Decision:
  - usar `docs/private/sync-servidorqa.ps1` basado en `tar` temporal + `pscp` + `plink` como ruta estable actual
- Motivo verificado:
  - `rsync.exe` local con `plink.exe` no quedo estable en Windows para este proyecto
  - la ruta `tar + pscp + plink` si permitio reconstruir el checkout remoto y continuar con build y `up`
- Impacto:
  - `sync-servidorqa-rsync.ps1` fue eliminado por quedar como trabajo exploratorio no adoptado para la fase operativa actual

### DT-023: limpiar el build `v0.3.0` retirando args no consumidos en `master` y `worker`

- Decision:
  - retirar el paso de `PIG_ARCHIVE_SHA256` hacia `master` y `worker`
  - simplificar `containers/master/Containerfile` y `containers/worker/Containerfile`
- Motivo verificado:
  - el build real en `ServidorQA` emitia warnings por `PIG_ARCHIVE_SHA256` no consumido
- Impacto:
  - el build final de `v0.3.0` en Linux real queda limpio
  - las imagenes siguen construyendo correctamente sin cambios funcionales en `master` ni `worker`

### DT-024: alinear `lab01` a la estructura `data/shared/lab01/*` preservando resultados historicos

- Decision:
  - ajustar los scripts de `lab01` para trabajar sobre:
    - `data/shared/lab01/datasets/`
    - `data/shared/lab01/work/gdd_lab01/gdd-wiki`
    - `data/shared/lab01/logs/lab01`
    - `data/shared/lab01/results/`
  - conservar los artefactos historicos ya presentes en:
    - `data/shared/lab01/work/work_lab01`
- Motivo verificado:
  - el usuario reorganizo scripts, logs y resultados para que cada laboratorio quede autocontenido bajo `data/shared/lab0X`
  - los scripts heredados de `lab01` aun apuntaban a rutas antiguas `app/` y `data/`
  - no se debe perder el avance historico ni bloquear la continuidad hacia `n > 51`
- Impacto:
  - `run_lab01_experiments.ps1`
  - `run_lab01_experiments_macos.sh`
  - `abrir-powershell-lab01.cmd`
  - quedan alineados a la estructura actual
  - los resultados nuevos del pipeline externo se orientan a `results/`
  - los resultados historicos en `work/work_lab01` se preservan como respaldo y compatibilidad
- Limitacion aceptada:
  - bajo el sandbox de Codex, la escritura en `results/` puede fallar con `Access denied`
  - la validacion real de `lab01` puede requerir ejecucion fuera del sandbox

### DT-025: fijar `results/` como unico destino de resultados de `lab01`

- Decision:
  - eliminar el fallback de resultados hacia `data/shared/lab01/work/work_lab01`
  - dejar `data/shared/lab01/results/` como unico destino valido de artefactos de salida
- Motivo verificado:
  - el usuario consolidó los resultados de `lab01` en `results/`
  - mantener `work_lab01` como ruta operativa mezclaba el arbol de trabajo con el arbol de resultados
  - el fallback ocultaba errores de permisos y hacia ambigua la ubicacion canonica de las metricas
- Impacto:
  - `run_lab01_experiments.ps1` y `run_lab01_experiments_macos.sh` fallan explicitamente si `results/` no es escribible
  - `abrir-powershell-lab01.cmd` ya no anuncia reutilizacion de `work/work_lab01`
- Limitacion aceptada:
  - el cambio queda verificado por inspeccion de scripts
  - no se reejecuto `lab01` luego de aplicar esta politica

### DT-026: fijar `logs/` como unico destino de trazas y evidencia de `lab01`

- Decision:
  - eliminar la subruta operativa `data/shared/lab01/logs/lab01`
  - dejar `data/shared/lab01/logs/` como destino directo de:
    - `runs_summary.csv`
    - `*.meta.txt`
    - `*.stderr.log`
    - `*.stdout.txt`
    - `*.done`
- Motivo verificado:
  - la carpeta `logs/lab01` agregaba un nivel innecesario dentro de un laboratorio ya autocontenido
  - la evidencia operativa debe quedar en una unica ubicacion simple y auditable
- Impacto:
  - ambos runners ahora validan escritura explicita en `logs/`
  - el launcher `.cmd` documenta `results/` y `logs/` como rutas oficiales
- Limitacion aceptada:
  - el cambio queda verificado a nivel estructural
  - la revalidacion runtime posterior a este ajuste queda pendiente

### DT-027: compilar `lab02` con `javac --release 8` en el entorno local actual

- Decision:
  - compilar `data/shared/lab02/work/gdd-hadoop` con:
    - `javac --release 8`
- Motivo verificado:
  - el `javac` local actual ya no acepta:
    - `-source 7 -target 7`
  - `LetterCount.java` implementado en esta sesion usa una construccion basada en `codePoints()` compatible con Java 8
- Impacto:
  - el `jar` local de `lab02` queda compilable y ejecutable en el entorno actual del usuario
  - el `build.xml` original del laboratorio se preserva como referencia historica, pero no representa por si solo la compilacion efectiva usada en esta sesion
- Limitacion aceptada:
  - esto documenta una decision de implementacion local
  - no demuestra por si mismo compatibilidad universal con cualquier JDK antiguo del curso

### DT-028: modularizar `lab01` por tipo de corrida sin duplicar logica

- Decision:
  - mantener un unico script principal por plataforma como interfaz oficial:
    - `run_lab01_experiments.ps1`
    - `run_lab01_experiments.sh`
  - consolidar la seleccion del flujo mediante `-Mode`:
    - `InMemory`
    - `External`
    - `Both`
  - mantener un nucleo comun compartido para evitar duplicacion
  - conservar los wrappers por modo solo como aliases de compatibilidad:
    - `run_lab01_inmemory.*`
    - `run_lab01_external.*`
- Motivo verificado:
  - el laboratorio mezcla dos fases distintas:
    - corridas en memoria
    - pipeline externo por archivos
  - el usuario busca modularizacion, no copia de funcionalidad
- Impacto:
  - `PowerShell`:
    - `lab01-common.ps1`
    - `run_lab01_experiments.ps1` como entrada principal
    - `run_lab01_inmemory.ps1` y `run_lab01_external.ps1` como aliases de compatibilidad
  - `bash`:
    - `run_lab01_common.sh`
    - `run_lab01_experiments.sh` como entrada principal
    - `run_lab01_inmemory.sh` y `run_lab01_external.sh` como aliases de compatibilidad
  - `run_lab01_experiments_macos.sh` queda solo como alias de compatibilidad al nombre generico
- Limitacion aceptada:
  - la modularizacion interna ya quedo aplicada
  - los flags historicos `-RunExternalPipeline` y `-SkipInMemory` se mantienen solo como compatibilidad transitoria

### DT-029: dejar `lab02` separado en wrappers explicitos para `WordCount` y `LetterCount`

- Decision:
  - separar la operacion de `lab02` en:
    - `run-lab02-wordcount.*`
    - `run-lab02-lettercount.*`
  - compilar desde el arbol de trabajo actual:
    - `data/shared/lab02/work/gdd-hadoop`
  - dejar evidencia local en `logs/` y `results/`
- Motivo verificado:
  - el PDF de `lab02` no termina en `WordCount`; tambien exige implementar y ejecutar `LetterCount`
  - compilar desde el ZIP original podia dejar fuera cambios actuales del arbol de trabajo
- Impacto:
  - `run-lab02-wordcount.ps1` y `.sh` dejan log y `top20`
  - `run-lab02-lettercount.ps1` y `.sh` dejan log y artefacto `a-z`
  - `Main.java` queda documentando tambien `LetterCount`
- Limitacion aceptada:
  - la separacion y trazabilidad quedaron implementadas
  - no se reejecutaron aun los wrappers nuevos en esta sesion

### DT-030: implementar `lab03` sobre `costar-count` con self-join en Pig

- Decision:
  - crear `costar-count.template.pig` como entregable real del laboratorio
  - usar una estrategia basada en self-join por `movie_id` para generar pares
  - evitar el bloque `FOREACH ... { ... CROSS ... FLATTEN(...) }` que genero fallas en Pig local
- Motivo verificado:
  - el PDF exige:
    - solo `type == 'movie'`
    - llave unica `title + year`
    - excluir reflexivos
    - excluir simetricos
    - ordenar descendente por conteo
  - una corrida real del usuario mostro:
    - error de parseo Pig
    - luego error `Invalid physical operators in the physical plan`
- Impacto:
  - se agrega:
    - `data/shared/lab03/scripts/costar-count.template.pig`
    - `data/shared/lab03/scripts/run-lab03-costarcount.ps1`
  - el wrapper deja log local y preview local en:
    - `data/shared/lab03/logs/`
    - `data/shared/lab03/results/`
  - los mensajes de error de `lab03` pasan a incluir causa resumida y ruta del log
- Limitacion aceptada:
  - la ultima version del script Pig queda corregida por inspeccion y por errores observados
  - falta confirmar una corrida exitosa posterior al ultimo ajuste

### DT-031: escalar memoria de la VM WSL de Podman antes de seguir elevando el heap de `lab06`

- Decision:
  - tratar el bloqueo de `lab06` full primero como un problema de capacidad del entorno
  - aumentar la memoria efectiva de la VM WSL de Podman antes de seguir subiendo agresivamente:
    - `MapMemoryMb`
    - `mapreduce.map.java.opts`
- Motivo verificado:
  - se observaron fallas reales de:
    - `Java heap space`
    - `exit code 137`
    - `Killed by external signal`
  - en Windows con `podman machine` tipo `wsl`, `podman machine set -m ...` no aplica; la memoria debe ajustarse en:
    - `C:\Users\xbash\.wslconfig`
- Impacto:
  - se verifico memoria efectiva interna de la VM mediante:
    - `podman machine ssh cat /proc/meminfo`
  - al cierre de la sesion la VM quedo con ~`24 GB` efectivos
  - el valor mostrado por `podman machine list` queda tratado como metadato no confiable para este caso
- Limitacion aceptada:
  - el aumento de RAM de la VM no garantiza por si solo el cierre de `lab06`
  - sigue siendo necesario revalidar la corrida full y, si falla, revisar el nuevo log antes de cambiar otra vez los parametros del job

### DT-032: apagar `bigdata-elasticsearch` durante la fase pesada de `lab06`

- Decision:
  - dejar `bigdata-elasticsearch` detenido mientras se ejecuta la corrida full de `PageRank`
- Motivo verificado:
  - `elasticsearch` pertenece a la fase IR de `lab05`
  - no es requisito para:
    - `PageRank`
    - `SortByRank`
  - si consume RAM que puede ser reutilizada por YARN/Giraph durante `lab06`
- Impacto:
  - el stack operativo de `lab06` puede reducirse a:
    - `bigdata-master`
    - `bigdata-worker1`
    - `bigdata-worker2`
    - `bigdata-worker3`
  - `elasticsearch` se vuelve a levantar solo cuando corresponda la integracion con busqueda de `lab05`
- Limitacion aceptada:
  - esto optimiza recursos del host
  - no resuelve por si mismo errores semanticos o de configuracion propios del job de Giraph

### DT-033: implementar Cassandra como overlay sobre contenedores existentes

- Decision:
  - habilitar `Apache Cassandra 2.0.7` dentro de los cuatro contenedores existentes:
    - `bigdata-master`
    - `bigdata-worker1`
    - `bigdata-worker2`
    - `bigdata-worker3`
  - no agregar contenedores Cassandra adicionales
  - dejar `master` como seed Cassandra
  - exponer desde `master` los puertos docentes:
    - `9042`
    - `9160`
    - `7199`
- Motivo verificado:
  - el proyecto usa overlays para extender el stack reusable
  - el usuario explicito que `profiles/nosql-cassandra` existe para habilitar componentes requeridos dentro de los contenedores ya creados
  - la inspeccion del servidor docente mostro Cassandra `2.0.7` con `cqlsh 4.1.1` y Thrift `19.39.0`
- Impacto:
  - se agrega `compose.cassandra.yml`
  - se instala Cassandra en la imagen base, pero solo arranca si `ENABLE_CASSANDRA=true`
  - se agregan wrappers `up/status/down/shell` para Cassandra en `containers/scripts/`
- Limitacion aceptada:
  - la topologia local queda en `1 master + 3 workers`
  - el servidor docente observado usa 5 nodos
  - el objetivo local es reproducir el flujo docente de Lab07, no clonar exactamente la cantidad de nodos del servidor

### DT-034: resolver Lab07 con alternativas orientadas a consulta por limites de Cassandra 2.0.7

- Decision:
  - ejecutar los comandos docentes principales de keyspace, tablas, inserciones, `CREATE INDEX` y consultas
  - cuando las consultas por indice secundario no son confiables, validar el comportamiento con tablas orientadas a consulta:
    - `byage_*`
    - `bycolor_*`
- Motivo verificado:
  - en la validacion local, `CREATE INDEX` se creo correctamente
  - aun asi, consultas por indice en Cassandra `2.0.7` via Thrift devolvieron `0 rows` aunque la fila existia
  - `ALLOW FILTERING` tampoco resolvio de forma confiable ese caso
- Impacto:
  - `data/shared/lab07/scripts/run-lab07-cassandra.ps1` genera un CQL de entrega que comienza con `CREATE KEYSPACE`
  - el script deja evidencia en `results/` y `logs/`
  - `data/shared/lab07/README.md` documenta las alternativas y limites
- Limitacion aceptada:
  - no se reporta como exito una consulta indexada que empiricamente devolvio `0 rows`
  - la solucion documenta la alternativa metodologica propia de Cassandra: modelar tablas segun consulta

### DT-035: redefinir el `core` reusable como base minima sin `Spark`

- Decision:
  - fijar el `core` reusable del ambiente en:
    - `Hadoop`
    - `HDFS`
    - `YARN`
    - `Pig`
  - mover `Spark` fuera del `core` y tratarlo como el primer overlay progresivo de laboratorio
- Motivo verificado:
  - la progresion real de laboratorios observada y documentada ya no usa `Spark` como parte del minimo comun compartido
  - `lab04` es el primer laboratorio que necesita `Spark`
- Impacto:
  - `compose.yml` queda conceptualmente como `core` puro
  - `compose.spark.yml` pasa a ser la habilitacion especifica para `lab04`
  - la arquitectura reusable queda mejor alineada con la secuencia docente

### DT-036: formalizar `lab06` como perfil `graph` sobre el `core`, con integracion opcional hacia `lab05`

- Decision:
  - tratar `lab06` como perfil `graph` sobre el `core`
  - mantener separada la fase de:
    - calculo `PageRank` + `SortByRank`
    - integracion con busqueda de `lab05`
- Motivo verificado:
  - la corrida full de `PageRank` ya fue validada sin requerir `Elasticsearch`
  - la integracion final con ranking sobre `lab05` ya existe como flujo reproducible aparte en:
    - `data/shared/lab06/scripts/run-lab06-lab05-integration.ps1`
- Impacto:
  - `Elasticsearch` deja de verse como prerequisito de ejecucion de `lab06`
  - la dependencia con `lab05` queda acotada a la fase final de comparacion de busqueda

### DT-037: mantener `Elasticsearch` local en `single-node`

- Decision:
  - mantener `Elasticsearch 6.8.10` en `single-node` para el ambiente local del laptop
- Motivo verificado:
  - `lab05` y la integracion `lab06 -> lab05` ya quedaron funcionalmente validados en esa topologia
  - distribuir `Elasticsearch` entre mas nodos del cluster reutilizaria recursos que `lab06` necesita para YARN/Giraph
- Impacto:
  - se conserva la recomendacion local de:
    - `1` nodo
    - `1` shard primario por defecto
    - `0` replicas por defecto
  - el stack local privilegia memoria disponible para los jobs distribuidos del curso

### DT-038: versionar la refactorizacion actual del ambiente como `v0.4.0`

- Decision:
  - fijar la refactorizacion actual del ambiente reusable bajo la referencia `v0.4.0`
- Motivo verificado:
  - los scripts y manifests operativos del ambiente ya apuntan por defecto a `v0.4.0`
  - la sesion consolida cambios estructurales en:
    - `core`
    - overlays por laboratorio
    - `lab06` full
    - integracion `lab06 -> lab05`
- Impacto:
  - `containers/scripts/build.ps1`
  - `docs/private/pull-images-and-up.ps1`
  - `compose.yml`
  - `compose.spark.yml`
  - `compose.cassandra.yml`
  - `compose.hive.yml`
- Limitacion aceptada:
  - esta decision registra la referencia local de version
  - la construccion/publicacion efectiva de imagenes `v0.4.0` sigue siendo una fase operativa aparte

### DT-039: concentrar los wrappers `bash` del ambiente reusable en `containers/scripts/bash/`

- Decision:
  - mover los wrappers `bash` operativos del ambiente reusable a:
    - `containers/scripts/bash/`
- Motivo verificado:
  - reduce ruido en `containers/scripts/`
  - separa con claridad la operacion `PowerShell` principal del soporte `bash`
  - evita mezclar wrappers `bash` del ambiente con scripts auxiliares o historicos
- Impacto:
  - los wrappers `bash` principales pasan a vivir bajo:
    - `build*.sh`
    - `up*.sh`
    - `status*.sh`
    - `down*.sh`
    - `shell*.sh`
    - `test-operational.sh`
  - se agregan los wrappers faltantes de `Spark` en `bash` para mantener coherencia con la documentacion
- Limitacion aceptada:
  - la sesion valida la reorganizacion estructural, no su ejecucion completa en Linux real

### DT-040: fusionar el build limpio en `build.ps1 -NoCache`

- Decision:
  - eliminar `containers/scripts/build-clean.ps1`
  - absorber su funcion en:
    - `containers/scripts/build.ps1 -NoCache`
- Motivo verificado:
  - `build-clean.ps1` duplicaba casi por completo la logica de `build.ps1`
  - la unica diferencia operativa sustantiva era el uso de `--no-cache`
- Impacto:
  - se reduce duplicacion de mantenimiento en `PowerShell`
  - el build limpio sigue disponible sin perder capacidad operativa
- Limitacion aceptada:
  - `build-clean.sh` se conserva por ahora en `bash` y no fue fusionado en esta sesion

### DT-041: mover scripts `PowerShell` privados a `docs/private/`

- Decision:
  - mover fuera del arbol operativo principal:
    - `docs/private/pull-images-and-up.ps1`
    - `docs/private/sync-servidorqa.ps1`
  - eliminar:
    - `containers/scripts/sync-servidorqa-rsync.ps1`
- Motivo verificado:
  - esos flujos no forman parte del baseline reusable comun
  - `sync-servidorqa-rsync.ps1` ya estaba documentado como camino exploratorio no adoptado
  - `pull-images-and-up.ps1` y `sync-servidorqa.ps1` siguen siendo utiles, pero como utilitarios privados u operativos
- Impacto:
  - el arbol operativo principal queda mas limpio para terceros
  - la documentacion privada pasa a referenciar esas rutas nuevas
- Limitacion aceptada:
  - la trazabilidad historica en bitacoras conserva referencias antiguas porque documenta sesiones pasadas, no instrucciones vigentes

### DT-042: redefinir `reset-data.ps1` como `factory reset` del runtime local

- Decision:
  - mantener el script, pero redefinirlo como `factory reset` del runtime local del cluster
- Motivo verificado:
  - el concepto es util para repetir validaciones o volver a replicar datos desde cero
  - el nombre y comportamiento anteriores no explicitaban con suficiente precision que se destruia
- Impacto:
  - `reset-data.ps1` ahora:
    - ejecuta `down-all.ps1`
    - elimina solo volumenes persistentes de Podman del cluster
    - explica explicitamente que no borra contenido del repositorio
  - el `README.md` documenta ese alcance
- Limitacion aceptada:
  - como `hive` y `hue` persisten sobre carpetas del repo, no se borran en este `factory reset`
  - el script queda definido como reset del estado persistente del cluster, no como limpieza total del workspace

### DT-043: no fijar aun un overlay local de `MongoDB` sin revalidar el daemon docente

- Decision:
  - mantener `nosql-mongodb` como perfil reservado y no implementar aun el overlay operativo local
- Motivo verificado:
  - la evidencia local observable del ambiente docente confirma solo:
    - `MongoDB shell version v4.4.14`
  - el chequeo de `mongod --version` no quedo confirmado con el mismo nivel de certeza
- Impacto:
  - `lab08 / MongoDB` sigue como siguiente fase
  - antes de implementar `compose` y wrappers se requiere revalidar:
    - version real de `mongod`
    - forma de arranque
    - puertos
    - topologia docente relevante
- Limitacion aceptada:
  - se evita una implementacion potencialmente desalineada con el ambiente real del curso
## 2026-08-05

### DT-044: mantener el `README.md` principal enfocado en proposito, alcance y progresion

- Decision:
  - mantener el `README.md` principal como documento breve de finalidad del proyecto, alcance reusable, relacion con el ambiente docente y progresion por laboratorio
- Motivo verificado:
  - el detalle extenso de `lab01` a `lab08` vuelve menos legible el punto central del repositorio
  - los laboratorios ya disponen de `README.md` propios donde el detalle tecnico queda mejor localizado
- Impacto:
  - el `README.md` principal explica el proyecto como base reusable para replicar laboratorios
  - los `README.md` de perfiles y laboratorios absorben el detalle especifico
- Limitacion aceptada:
  - el lector debe navegar a los `README.md` secundarios para ver instrucciones o particularidades de cada lab

### DT-045: registrar explicitamente que el proyecto no reemplaza el ambiente docente

- Decision:
  - explicitar en la documentacion principal que este repositorio no busca sustituir el ambiente institucional del curso
- Motivo verificado:
  - el objetivo real es ofrecer una base reusable que permita replicar practicas y resultados de forma local
  - evita una interpretacion incorrecta sobre equivalencia operacional total con la infraestructura docente
- Impacto:
  - la narrativa del proyecto queda metodologicamente mas precisa
  - se refuerza la distincion entre:
    - ambiente base reusable
    - ambiente docente oficial
- Limitacion aceptada:
  - la replica local puede seguir presentando diferencias puntuales de topologia, version o recursos respecto del servidor del curso

### DT-046: tratar la inspeccion remota docente como fuente de verificacion de solo lectura

- Decision:
  - conservar la practica de inspeccionar el ambiente docente solo en modo lectura cuando se necesite confirmar componentes, bases o esquemas
- Motivo verificado:
  - en esta sesion se verifico acceso remoto, procesos activos y estructura observable de `MongoDB` y `Cassandra` sin intervenir el servidor
- Impacto:
  - se pueden derivar procedimientos de replicacion o exportacion con menor riesgo metodologico
  - se evita usar suposiciones no verificadas sobre el estado real del servidor
- Limitacion aceptada:
  - la inspeccion de solo lectura confirma existencia y estructura observable, pero no sustituye una estrategia formal de respaldo o migracion

### DT-047: considerar exportables los esquemas remotos de `MongoDB` y `Cassandra`

- Decision:
  - dejar registrado que la exportacion de esquemas ya cargados en el ambiente docente es viable, al menos para `MongoDB` y `Cassandra`
- Motivo verificado:
  - `MongoDB` expuso bases y colecciones observables
  - `Cassandra` permitio listar keyspaces y describir al menos `cc66i` como DDL
- Impacto:
  - queda abierta la posibilidad de formalizar despues scripts o guias de exportacion reproducible
- Limitacion aceptada:
  - en esta sesion solo se verifico factibilidad y comandos base; no se ejecuto una exportacion completa de todos los esquemas
