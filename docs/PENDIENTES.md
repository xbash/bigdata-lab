# PENDIENTES

## 2026-07-28

### Pendientes tecnicos

- Revalidar en vivo `containers/scripts/smoke-test.ps1 -IncludeRealJobs` con Podman operativo para confirmar:
  - pendiente resuelto el `2026-07-31` en el laptop local
- Revalidar en vivo el runtime definitivo local en Java `11.0.26` para confirmar:
  - `java -version`
  - arranque Hadoop
  - arranque Pig
  - arranque Spark
- Revalidar en vivo la nueva combinacion:
  - pendiente resuelto el `2026-07-31` en Oracle y laptop local para:
    - Hadoop `2.10.0`
    - Spark `3.3.2`
    - acceso HDFS desde Spark
- Proveer y validar un origen reproducible para `Pig 0.18.0-SNAPSHOT`:
  - pendiente local resuelto el `2026-08-01` mediante artefacto congelado + `SHA256` en:
    - `.artifacts/pig-0.18.0-SNAPSHOT-course.tgz`
    - `.artifacts/pig-0.18.0-SNAPSHOT-course.tgz.sha256`
  - pendiente de cierre operativo:
    - validar el flujo `v0.3.0` en `orcl01-chg`
    - construir y publicar imagenes `v0.3.0`
- Revalidar en vivo el overlay `ir` de `lab05` con:
  - `up-ir.ps1`
  - `status-ir.ps1`
  - conectividad Elasticsearch transporte `9300`
- Validar en un host Linux real los wrappers:
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
  - avance estatico realizado el `2026-08-01`:
    - `prepare-lab05.sh` ya no depende de `tar -xf` sobre `.zip`; ahora extrae con `python3` + `zipfile`
    - `run-lab02-wordcount.sh`, `run-lab05-index.sh` y `run-lab05-search.sh` ya no fijan `/usr/bin/podman`; usan `podman` resuelto desde `PATH`
    - `run-lab05-search.sh` codifica la consulta en `base64` antes de pasarla al contenedor
    - `status-ir.sh` reporta ausencia de `curl` de forma explicita
  - avance adicional validado en `ServidorQA` el `2026-08-01`:
    - `bash -n` paso para todos los `.sh` de `containers/scripts/`
    - `status.sh`, `status-ir.sh`, `status-hive.sh` ejecutaron en Linux real
    - `down.sh`, `down-ir.sh`, `down-hive.sh` ejecutaron en Linux real
    - el overlay `sql-hive` requirio retirar `--profile` porque `podman-compose 1.0.6` no lo soporta
  - pendiente vigente:
    - saneamiento final del estado rootless de Podman en `ServidorQA`
    - ejecucion real de `up.sh`, `up-ir.sh`, `up-hive.sh`
    - ejecucion real de `build.sh`, `build-clean.sh`
- Ejecutar una reconstruccion completa desde cero del stack local actualizado para confirmar:
  - arranque del overlay `ir`
- Revisar si conviene mover datasets cargados hoy desde `labXX/docs/` a `labXX/datasets/` para mantener la convencion definida.
- Revisar si `lab02/docs/hadooppass.txt` debe eliminarse, moverse o quedar fuera del proyecto:
  - pendiente resuelto el `2026-08-01`
  - estado final:
    - el archivo ya fue eliminado del proyecto por el usuario
- Evaluar si conviene traer tambien el dataset full de `lab05`:
  - pendiente resuelto el `2026-08-01`
  - dataset full ya disponible en:
    - `data/shared/lab05/datasets/es-wiki-articles.tsv.gz`
  - estado:
    - la muestra `1k` sigue siendo util para smoke
    - el dataset full queda disponible para la corrida funcional completa del laboratorio
- Cargar material en `lab06` a `lab08` cuando exista disponibilidad.
- Pendiente resuelto el `2026-08-01` sobre `compose.hive.yml`:
  - decision tomada:
    - el overlay `sql-hive` deja de quedar como placeholder neutro
    - se incorpora `Hue` como componente visual objetivo para consultas SQL
  - alcance decidido para el overlay:
    - `sql-ui`
    - `Hive Metastore`
    - `HiveServer2`
  - pendiente vigente derivado:
    - implementar y validar funcionalmente el overlay `sql-hive` completo sobre la nueva linea base `v0.3.0`

### Pendientes de verificacion

- pendiente-de-verificacion:
  - version exacta de herramientas del curso usadas originalmente en los laboratorios remotos
- pendiente-de-verificacion:
  - si los proyectos `.zip` del curso se compilan y corren sin ajustes adicionales dentro del stack local
- pendiente-de-verificacion:
  - contenido y accesibilidad de la configuracion real de Elasticsearch del cluster docente
- pendiente-de-verificacion:
  - comportamiento del tag `eclipse-temurin:11.0.26_4-jdk-jammy` durante build real

### Proximos pasos sugeridos

1. Ejecutar un build limpio desde cero en Windows o Linux real.
2. Levantar y revalidar el stack base con `status` y smoke tests.
3. Revalidar el overlay `ir` con Elasticsearch local.
4. Completar y probar el flujo real de `lab05`.
5. Registrar evidencia adicional en `evidencia/`.

## 2026-07-31

### Pendientes tecnicos adicionales

- Backlog diferido para cierre final en `ServidorQA`:
  - Pendiente 1:
    - validar los wrappers `sh` en el servidor Linux `ServidorQA`
  - Pendiente 2:
    - aplicar los cambios finales al servidor Linux `ServidorQA`
    - crear las imagenes con estos cambios
    - construir los contenedores
    - validar el flujo completo
- Ejecutar el plan incremental documentado en:
  - `docs/PLAN_IMPLEMENTACION_LABS_04_06.md`
- Estado validado de `lab04` al `2026-08-01`:
  - `prepare-lab04.ps1` ejecutado correctamente
  - `run-lab04.ps1 -Utility WordCountTask` validado como smoke tecnico
  - `run-lab04.ps1 -Utility AverageSeriesRating` validado con:
    - `imdb-ratings-two.tsv`
    - `imdb-ratings.tsv`
- Mantener versionado incremental del ambiente reusable:
  - toda nueva modificacion del ambiente debe publicarse con una version superior a `v0.1.0`
  - objetivo: distinguir con claridad cada nueva iteracion de mejora del ambiente reusable
  - siguiente version preparada localmente:
    - `v0.3.0`
- Recomendar uso de zona horaria de Santiago:
  - preferir `America/Santiago`
  - referencia operativa esperada: `GMT-4` cuando corresponda
- Estado de revalidacion de `lab05` al `2026-08-01`:
  - `prepare-lab05.ps1`: `OK` tras corregir la posicion de `param(...)`
  - `up-ir.ps1`: `OK` tras quitar settings de indice invalidos de `conf/elasticsearch/elasticsearch.yml`
  - `status-ir.ps1`: `PARCIAL`
  - `run-lab05-index.ps1`: `OK`
  - `run-lab05-search.ps1`: `OK`
- Bloqueos vigentes de `lab05` observados en vivo:
  - `Elasticsearch 6.8.10` rechaza `index.number_of_shards` y `index.number_of_replicas` en `elasticsearch.yml`
  - pendiente resuelto el `2026-08-01`:
    - el cliente Java ya no falla al crear `PreBuiltTransportClient`
    - causa raiz: los wrappers debian empaquetar y ejecutar el proyecto como `jar` con `META-INF` y dependencias, consistente con `build.xml`
  - `status-ir.ps1` no refleja de forma confiable todo el estado cuando `podman compose` usa el proveedor externo `docker-compose.exe`
  - pendiente resuelto el `2026-08-01`:
    - `SearchWikiIndex` ya corta correctamente al recibir `EOF`
- Siguiente foco util para `lab05`:
  - pendiente resuelto el `2026-08-01`:
    - la causa estaba en `BuildWikiIndexBulk.java`, que creaba el indice sin `settings`
    - al no declarar `number_of_shards` ni `number_of_replicas`, `Elasticsearch 6.8.10` aplicaba sus defaults de `5` y `1`
    - se ajusto el payload de creacion del indice al overlay compacto local:
      - `1` shard
      - `0` replicas
  - evaluar si conviene agregar una verificacion posterior al indexado para confirmar automaticamente `count`, mapping y un documento de ejemplo
- Estado de `lab06` al `2026-08-01`:
  - `prepare-lab06.ps1`: `OK`
  - `run-lab06-pagerank.ps1`: `OK` con smoke real sobre `pr-ex-local.tsv`
  - `PageRank.java`: `OK` tras completar los `@TODO` del enunciado
- Siguiente foco util para `lab06`:
  - estado actualizado el `2026-08-01`:
    - para el avance actual basta el dataset pequeno de smoke ya validado
    - el dataset real ya fue copiado al proyecto
  - pendiente diferido para backlog final:
    - ejecutar `run-lab06-pagerank.ps1` con el dataset real `es-wiki-links.tsv.gz`
    - usar esa prueba como pendiente 3 final
  - integracion requerida segun el PDF:
    - `lab06` debe usar PageRank para mejorar el ranking de los resultados de busqueda de `lab05`
    - por lo tanto, `lab06` requiere como insumo los resultados de `lab05`
- Limpiar el mensaje residual `text: Unable to write to output stream.` de las vistas previas HDFS:
  - pendiente resuelto el `2026-08-01`
  - causa:
    - las vistas previas HDFS usaban `head`, cerrando la tuberia antes de tiempo
  - ajuste aplicado:
    - reemplazo por `awk` para imprimir solo las primeras lineas sin cortar prematuramente la salida
  - scripts ajustados:
    - `containers/scripts/run-lab02-wordcount.ps1`
    - `containers/scripts/run-lab02-wordcount.sh`
    - `containers/scripts/run-lab03-starcount.ps1`
    - `containers/scripts/run-lab04.ps1`
    - `containers/scripts/run-lab06-pagerank.ps1`
- Validar en Linux real local o segundo host los wrappers `bash` de jobs:
  - `containers/scripts/run-lab02-wordcount.sh`
  - avance estatico realizado el `2026-08-01`:
    - se elimino la dependencia de `/usr/bin/podman`
  - validacion funcional equivalente realizada el `2026-08-01`:
    - el flujo real de `lab02` completo corrio exitosamente sobre el stack local con:
      - `Map input records = 1000`
      - `Reduce output records = 19483`
      - salida HDFS:
        - `/outputs/lab02/wordcount-20260801-010019`
  - pendiente vigente:
    - ejecutar el `.sh` directamente en un host Linux real `ServidorQA` para cerrar la validacion especifica del wrapper
  - avance adicional en `ServidorQA` el `2026-08-01`:
    - `bash -n containers/scripts/run-lab02-wordcount.sh`: `OK`
- Revalidar y documentar publicamente el flujo de pull desde Docker Hub para:
  - pendiente de documentacion resuelto el `2026-08-01` en:
    - `docs/FLUJO_PULL_DOCKER_HUB.md`
  - evidencia historica verificada:
    - `xbash/bigdata-core-base:v0.1.0`
    - `xbash/bigdata-master:v0.1.0`
    - `xbash/bigdata-worker:v0.1.0`
  - pendiente vigente:
    - revalidar publicamente el mismo flujo para `v0.3.0` cuando esas imagenes sean publicadas

- Nuevo componente agregado a la linea base reusable el `2026-08-01`:
  - overlay `sql-hive`
  - componente visual:
    - `sql-ui` con `Hue`
  - estado:
    - incorporado en manifests y build local
    - pendiente de validacion funcional completa junto con `Hive Metastore` y `HiveServer2`

- Sincronizacion hacia `ServidorQA`:
  - resuelto el `2026-08-01` a nivel de mecanismo de traslado:
    - existe `docs/private/sync-servidorqa.ps1`
    - preserva `data/shared/lab05` y `data/shared/lab06` bajo la raiz correcta
    - el experimento `rsync.exe` local + `plink.exe` fue descartado y retirado del arbol operativo
  - observacion vigente:
    - el flujo `tar` queda como fallback

### Memories durables propuestas

- Memory propuesta:
- Motivo: el proyecto usa una convencion estable `core + overlays futuros` y `lab01..lab08` bajo `data/shared/`
- Alcance: continuidad de este repositorio de semanas o meses
- Riesgo si se guarda: bajo
- Alternativa si debe ir mejor en `AGENTS.md` o `docs/`: ya quedo en `docs/DECISIONES_TECNICAS.md` y `docs/CONTEXTO_PROYECTO.md`
## 2026-08-01

### Actualizacion adicional de `ServidorQA`

- Validado en Linux real:
  - `build.sh`
  - `up.sh`
- Resultado verificado:
  - imagenes construidas:
    - `bigdata-core-base:v0.3.0`
    - `bigdata-master:v0.3.0`
    - `bigdata-worker:v0.3.0`
    - `bigdata-sql-ui:v0.3.0`
  - stack base levantado y saludable:
    - `bigdata-master`
    - `bigdata-worker1`
    - `bigdata-worker2`
    - `bigdata-worker3`
- Estado de sincronizacion remota:
  - `/home/opc/bigdata-lab` fue reconstruido con todo el proyecto excepto:
    - `data/shared/lab01/datasets`
    - `data/shared/lab02/datasets`
    - `data/shared/lab03/datasets`
    - `data/shared/lab04/datasets`
    - `data/shared/lab05/datasets`
    - `data/shared/lab06/datasets`
    - `data/shared/lab07/datasets`
    - `data/shared/lab08/datasets`
- Pendientes vigentes:
  - ejecutar jobs reales del curso en `ServidorQA`

## 2026-08-01

### Pendientes adicionales de `lab01`

- Validacion adicional sugerida:
  - repetir el pipeline externo de `lab01` con `n=52` o superior sobre el dataset pequeno para continuar la curva de experimentacion
- Pendiente de corrida pesada:
  - ejecutar `lab01` con dataset completo para un `n` objetivo mayor a `51`, segun decida el usuario
- Pendiente de verificacion:
  - determinar si la restriccion `Access denied` observada desde el sandbox de Codex aplica solo al entorno del agente o si tambien afecta flujos locales manuales del usuario

## 2026-08-02

### Pendientes vigentes de `lab01` tras la normalizacion de rutas

- Reejecutar una corrida controlada de `lab01` despues del cambio de scripts a rutas planas:
  - resultados en `data/shared/lab01/results/`
  - trazas en `data/shared/lab01/logs/`
- Confirmar en runtime que no quedan escrituras residuales hacia:
  - `data/shared/lab01/work/work_lab01`
  - `data/shared/lab01/logs/lab01`
- Verificar fuera del sandbox del agente si `results/` y `logs/` son escribibles en una ejecucion manual normal del usuario.
- Si la politica nueva queda validada en runtime:
  - actualizar o limpiar referencias documentales antiguas que aun mencionen `work/work_lab01` o `logs/lab01`
- Pendiente de verificacion:
  - confirmar si `es-wiki-abstracts-n51-grams-c-s-top100.txt` en `results/` proviene de una corrida completa real de `n=51` o de una consolidacion manual posterior de artefactos

### Estado actualizado de `lab02` al `2026-08-02`

- `WordCount`: `OK`
  - evidencia local:
    - `data/shared/lab02/logs/20260802-wordcount-run.log`
    - `data/shared/lab02/logs/20260802-wordcount-top20.txt`
- `LetterCount.java`: `OK` a nivel de implementacion y empaquetado
  - codigo fuente:
    - `data/shared/lab02/work/gdd-hadoop/src/org/mdp/hadoop/cli/LetterCount.java`
  - `jar` compilado:
    - `data/shared/lab02/work/gdd-hadoop/dist/gdd-hadoop.jar`
- `LetterCount`: `OK` segun ejecucion confirmada por el usuario
  - evidencia local:
    - `data/shared/lab02/logs/20260802-lettercount-run.log`
    - `data/shared/lab02/logs/20260802-lettercount-results.txt`
    - `data/shared/lab02/results/20260802-lettercount-a-z.txt`
- pendiente-de-verificacion:
  - releer y resumir el contenido exacto de `20260802-lettercount-a-z.txt` dentro del cierre academico si se quiere explicitar el ranking en documentacion

### Estado actualizado de `lab03` al `2026-08-02`

- `costar-count` sobre muestra: `OK`
  - evidencia verificada:
    - `data/shared/lab03/logs/20260802-034543-costarcount-run.log`
    - `data/shared/lab03/results/20260802-034543-costarcount-top20.txt`
    - `data/shared/lab03/results/20260802-034543-costarcount-entrega.md`
  - salida HDFS observada:
    - `/outputs/lab03/costar-count-20260802-034543`
- pendiente real de cierre academico:
  - ejecutar `costar-count` sobre `imdb-stars.tsv` completo si se quiere declarar el laboratorio completamente cerrado segun el PDF
- pendiente real de presentacion:
  - reejecutar la muestra luego de la correccion UTF-8 del wrapper para regenerar:
    - `data/shared/lab03/datasets/imdb-stars-test.tsv`
    - `data/shared/lab03/results/*-costarcount-top20.txt`
  - objetivo:
    - eliminar mojibake en nombres con acentos del bloque de evidencia local

### Estado actualizado de wrappers de `lab02`

- Reejecutar los wrappers nuevos para dejar evidencia posterior a la separacion:
  - `data/shared/lab02/scripts/run-lab02-wordcount.ps1`
  - `data/shared/lab02/scripts/run-lab02-lettercount.ps1`
- Revalidar en Linux real, cuando corresponda:
  - `data/shared/lab02/scripts/run-lab02-wordcount.sh`
  - `data/shared/lab02/scripts/run-lab02-lettercount.sh`

### Decision pendiente sobre interfaz final de `lab01`

- Estado actual:
  - ya existe modularizacion interna y wrappers separados para:
    - `inmemory`
    - `external`
- Estado actual:
  - la interfaz principal ya quedo consolidada en un unico script con `-Mode InMemory|External|Both`
  - los wrappers separados quedan solo como alias operativos de compatibilidad
- pendiente-de-verificacion:
  - reejecutar al menos una corrida corta con `-Mode` para dejar evidencia posterior a la consolidacion final

### Validacion adicional de overlays en `ServidorQA` el `2026-08-01`

- Overlay `ir`:
  - `bash ./containers/scripts/up-ir.sh`: `OK`
  - `bash ./containers/scripts/status-ir.sh`: `OK`
  - evidencia verificada:
    - `bigdata-elasticsearch` levantado
    - `9200/tcp` y `9300/tcp` expuestos
    - `_cat/health` en `green`
  - observacion:
    - la primera consulta HTTP puede fallar si `status-ir.sh` corre antes de que Elasticsearch termine de iniciar
- Overlay `sql-hive`:
  - `bash ./containers/scripts/up-hive.sh`: `OK` con arranque prolongado por pull/startup inicial
  - `bash ./containers/scripts/status-hive.sh`: `OK`
  - evidencia verificada:
    - `bigdata-sql-ui` arriba en `8888/tcp`
    - `bigdata-hive-metastore` arriba en `9083/tcp`
    - `bigdata-hive-server` arriba en `10000/tcp` y `10002/tcp`
    - `Hue` responde `HTTP/1.1 302 Found`
    - `HiveServer2` web responde `HTTP/1.1 200 OK`
  - riesgo vigente:
    - `bigdata-hive-metastore` registra `NoClassDefFoundError: org/apache/hadoop/yarn/util/SystemClock` al iniciar tareas internas de housekeeping
    - el overlay queda operativo a nivel de puertos y endpoints, pero falta decidir si ese warning se acepta o si debe corregirse antes del cierre final

### Resumen principal actualizado el `2026-08-01`

- copiar manualmente los `datasets/` al remoto: `OK`
- levantar y validar `up-ir.sh`: `OK`
- levantar y validar `up-hive.sh`: `OK`
- ejecutar jobs reales del curso en `ServidorQA`: siguiente

## 2026-08-03

### Pendientes vigentes de `lab06`

- Reintentar la corrida full de `lab06` ahora con la VM WSL de Podman en ~`24 GB` efectivos:
  - mantener por ahora:
    - `-Workers 1`
  - siguiente ajuste sugerido del job:
    - `-MapMemoryMb 6144`
    - `-MapJavaOpts "-Xmx4915m"`
- Si la corrida vuelve a fallar:
  - inspeccionar el nuevo log local y los `yarn logs` antes de volver a cambiar memoria o workers
- Si la corrida full finalmente termina `OK`:
  - copiar o materializar el top-10 ordenado en `data/shared/lab06/results/`
  - dejar `ranks.s.tsv` en la ruta prevista por:
    - `data/shared/lab06/results/lab05-rank-integration/`
  - reactivar `bigdata-elasticsearch`
  - reindexar o comparar consultas de `lab05` con y sin PageRank

### Pendiente de capacidad operativa

- Verificar si `run-lab06-pagerank.ps1` conviene endurecer adicionalmente para:
  - distinguir mejor:
    - error de HDFS `safe mode`
    - error de heap Java
    - error `exit code 137`
  - registrar explicitamente en el log el `applicationId` de YARN para acelerar diagnosticos posteriores

### Pendientes vigentes de `lab07` al `2026-08-03`

- Si se requiere entregar con datos personales/reales:
  - reejecutar:
    - `powershell -ExecutionPolicy Bypass -File .\containers\scripts\run-lab07-cassandra.ps1 -Usuario "<usuario>" -NombreCompleto "<nombre>" -Edad <edad> -ColorFav "<color>" -PeliculaFav "<pelicula>" -Comentario "<comentario>"`
  - revisar el archivo generado en:
    - `data/shared/lab07/results/*-comandos-entrega.cql`
- Si se necesita fidelidad total con el servidor docente:
  - evaluar si conviene extender el overlay local de 4 a 5 nodos
  - por ahora se mantiene la restriccion del proyecto: no agregar contenedores nuevos
- Si se va a publicar o sincronizar:
  - reconstruir imagenes despues del movimiento de `start-cassandra.sh` a `containers/scripts/`
  - verificar nuevamente:
    - `cassandra -v`
    - `cqlsh --version`
    - `nodetool status`
    - `SHOW VERSION`
- Pendiente metodologico:
  - decidir si el archivo de entrega debe conservar las alternativas `byage_*`/`bycolor_*` o si se desea una version mas cercana al PDF aunque algunas consultas por indice secundario fallen en Cassandra `2.0.7`

### Memory propuesta pendiente de confirmacion

- Memory propuesta:
  - En `C:\rutinas-local\gen-container\bigdata-lab`, `lab07` usa overlay Cassandra `2.0.7` dentro de `master + worker1..3`; los scripts Cassandra deben vivir en `containers/scripts/`; las consultas por indice secundario via Thrift no fueron confiables y se validan con tablas orientadas a consulta.
- Motivo:
  - Evita reabrir el diagnostico de Cassandra `2.0.7`, la decision de no agregar contenedores y la ubicacion obligatoria de scripts.
- Alcance:
  - Futuras sesiones sobre `bigdata-lab`, `profiles/nosql-cassandra` y `data/shared/lab07`.
- Riesgo si se guarda:
  - Puede quedar obsoleta si se migra a Cassandra moderna, a 5 nodos locales o si se corrige el comportamiento de indices.
- Alternativa si debe ir mejor en `AGENTS.md` o `docs/`:
  - Mantener como decision tecnica en `docs/DECISIONES_TECNICAS.md`; si se vuelve regla permanente del repositorio, crear o actualizar `AGENTS.md`.

## 2026-08-04

### Cierres realizados

- `lab06` full sobre `es-wiki-links.tsv.gz`: `RESUELTO`
  - evidencia:
    - `data/shared/lab06/logs/20260804-000726-lab06-pagerank-run.log`
    - `data/shared/lab06/results/20260804-000726-lab06-pagerank-top10.txt`
    - `data/shared/lab06/results/20260804-000726-lab06-pagerank-sorted-top10.txt`
- Integracion `lab06 -> lab05` con comparacion de busqueda usando PageRank: `RESUELTO`
  - evidencia:
    - `data/shared/lab06/results/lab05-rank-integration/ranks.s.tsv`
    - `data/shared/lab06/results/lab05-rank-integration/20260804-001746-lab05-rank-compare-estados-unidos.md`
- Ajuste documental del ambiente reusable hacia `core + overlays`: `RESUELTO`

### Pendientes vigentes reales

- Refactorizar y revalidar al final los wrappers `bash` pendientes de esta linea `v0.4.0`:
  - prioridad:
    - `containers/scripts/*.sh`
    - wrappers `sh` por laboratorio que dependan de cambios recientes en `lab05` y `lab06`
  - condicion de cierre:
    - no basta revision estatica; se requiere ejecucion real en Linux
- Implementar la siguiente fase `lab08 / MongoDB`:
  - confirmar version y forma de arranque docente antes de fijar overlay local
  - definir si sera overlay dedicado o habilitacion sobre contenedores existentes
- Si se desea cierre operativo completo de `v0.4.0`:
  - construir imagenes `v0.4.0`
  - revalidar `core`
  - revalidar overlays que se quieran dejar publicados
  - decidir si esas imagenes se publicaran o quedaran solo locales

### Pendientes que ya no deben tratarse como abiertos

- No volver a registrar como pendiente principal:
  - la corrida full de `lab06`
  - la integracion `lab06 -> lab05`
- `Elasticsearch` distribuido en mas nodos:
  - no queda como pendiente recomendado
  - la decision vigente del proyecto es mantener `single-node` en el laptop

### Memory propuesta pendiente de confirmacion

- Memory propuesta:
  - En `bigdata-lab`, el ambiente reusable queda alineado como `core` (`Hadoop` + `HDFS` + `YARN` + `Pig`) mas overlays progresivos por laboratorio; `lab06` full e integracion `lab06 -> lab05` ya quedaron resueltos localmente y `Elasticsearch` se mantiene en `single-node`.
- Motivo:
  - Evita reabrir en futuras sesiones la misma discusion de alineacion de arquitectura, dependencia de `lab06` y topologia local de `Elasticsearch`.
- Alcance:
  - Futuras sesiones sobre `bigdata-lab`, especialmente `README`, `compose*.yml`, `lab05`, `lab06` y plan de `lab08`.
- Riesgo si se guarda:
  - Puede quedar obsoleta si se rediseña el `core`, se distribuye `Elasticsearch` o se cambia la estrategia de `MongoDB`.
- Alternativa si debe ir mejor en `AGENTS.md` o `docs/`:
  - Ya quedo asentada en `README.md`, `docs/CONTEXTO_PROYECTO.md` y `docs/DECISIONES_TECNICAS.md`.

## 2026-08-04

### Pendientes adicionales tras la simplificacion estructural

- Revalidar en vivo, cuando corresponda el cierre operativo final de esta linea:
  - `containers/scripts/build.ps1 -NoCache`
  - `containers/scripts/test-operational.ps1`
  - `containers/scripts/reset-data.ps1`
- Validar en Linux real la nueva ubicacion de wrappers `bash`:
  - `containers/scripts/bash/*.sh`
- Revisar si conviene fusionar mas adelante tambien en `bash`:
  - `build-clean.sh` dentro de `build.sh`
- Implementar `lab08 / MongoDB` solo despues de revalidar en vivo:
  - version real de `mongod`
  - forma de arranque
  - puertos y persistencia
  - topologia docente relevante

### Pendientes que ya no deben tratarse como abiertos

- `build-clean.ps1`:
  - ya no existe como wrapper separado
  - su funcionalidad queda absorbida por `build.ps1 -NoCache`
- `sync-servidorqa-rsync.ps1`:
  - ya no debe considerarse backlog operativo
  - fue retirado del arbol operativo por quedar como experimento descartado

### Memory propuesta pendiente de confirmacion

- Memory propuesta:
  - En `bigdata-lab`, los wrappers `bash` del ambiente reusable viven en `containers/scripts/bash/`; los scripts `PowerShell` privados viven en `docs/private/`; `build-clean.ps1` fue absorbido por `build.ps1 -NoCache`; `reset-data.ps1` se redefine como `factory reset` del runtime local y `MongoDB` no debe implementarse sin revalidar el daemon docente.
- Motivo:
  - Evita reabrir en futuras sesiones la misma limpieza estructural del proyecto y fija el estandar actual del arbol operativo.
- Alcance:
  - Futuras sesiones sobre `bigdata-lab`, especialmente mantenimiento de scripts, README y `lab08`.
- Riesgo si se guarda:
  - Medio; puede quedar obsoleta si el proyecto vuelve a cambiar la separacion publico/privado o si `MongoDB` se implementa con evidencia nueva.
- Alternativa si debe ir mejor en `AGENTS.md` o `docs/`:
  - Ya quedo asentada en `docs/DECISIONES_TECNICAS.md`, `docs/CONTEXTO_PROYECTO.md` y `README.md`.
## 2026-08-05

### Pendientes vigentes

- Revisar y cerrar en Git el paquete documental y operativo trabajado en esta etapa:
  - `README.md`
  - `profiles/*/README.md`
  - `data/shared/lab0X/README.md`
  - `profiles/spark/README.md`
  - overlay `MongoDB` (`compose.mongodb.yml` y wrappers asociados)
- Decidir si la exportacion remota de esquemas quedara solo documentada o tambien automatizada con scripts reproducibles y sin credenciales embebidas.
- Si se formaliza la exportacion remota:
  - definir alcance por tecnologia
  - `MongoDB`: bases, colecciones, metadatos y eventual muestra de documentos
  - `Cassandra`: `KEYSPACE`, tablas, indices y estrategia de salida a archivos
- Evaluar si conviene documentar tambien la inspeccion/export potencial de `Hive` y `Elasticsearch`; en esta sesion no quedaron revalidados al mismo nivel que `MongoDB` y `Cassandra`.

### Pendientes que no deben reabrirse como duda conceptual

- Ya quedo claro documentalmente que el proyecto:
  - habilita un ambiente base reusable
  - permite replicar progresivamente los componentes segun el laboratorio
  - no busca reemplazar el ambiente docente
- Tambien quedo asentado que los componentes implementados en los labs trabajados fueron validados funcionalmente y produjeron resultados.
