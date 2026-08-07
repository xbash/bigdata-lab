# bigdata-lab

Entorno reusable para habilitar laboratorios con componentes de Big Data
utilizados en el modulo de Big Data del Diplomado en Ciencia e Ingenieria de
Datos de la Universidad de Chile.

## Finalidad

Este proyecto busca ofrecer una base local, reproducible y extensible para
ejecutar practicas y laboratorios del modulo, separando claramente:

- la infraestructura reusable del ambiente;
- los perfiles u overlays por tecnologia;
- los materiales, scripts y resultados de cada laboratorio.

La idea es mantener este `README` enfocado en el repositorio y mover el detalle
de `lab01` a `lab08` a los `README.md` de cada laboratorio.

## Relacion con el ambiente docente

Este proyecto no busca reemplazar el ambiente docente del curso. Su proposito
es entregar una base local reusable para practicar, replicar laboratorios y
obtener resultados de manera controlada cuando se cuenta con los recursos
locales necesarios.

El ambiente conserva la logica de trabajo de los laboratorios, pero adapta la
operacion a una topologia local sobre contenedores. Por eso, cualquier
diferencia de version, escala, recursos o configuracion respecto del servidor
docente debe tratarse como una diferencia operacional documentada.

## Alcance

El checkout esta orientado a ejecucion local con `Podman` y se organiza en
torno a una base `core` y overlays tecnologicos segun el laboratorio.

Componentes contemplados en el repositorio:

- `Hadoop`
- `HDFS`
- `YARN`
- `Pig`
- `Spark`
- `Elasticsearch`
- `Hive`
- `Hue`
- `Giraph`
- `Cassandra`
- `MongoDB`

## Estructura general

```text
compose.yml
compose.spark.yml
compose.ir.yml
compose.hive.yml
compose.cassandra.yml
compose.mongodb.yml
containers/
  scripts/
conf/
data/
  shared/
    lab01/
    lab02/
    lab03/
    lab04/
    lab05/
    lab06/
    lab07/
    lab08/
profiles/
logs/
evidencia/
docs/
```

Criterio general de organizacion:

- `containers/` y `compose*.yml`: infraestructura y operacion;
- `conf/`: configuracion comun del ambiente;
- `profiles/`: perfiles y overlays por tecnologia;
- `data/shared/lab0X/`: materiales y artefactos de cada laboratorio.

## Requisitos

- `podman` disponible en `PATH`;
- PowerShell para los wrappers `.ps1`;
- Bash para los wrappers `.sh` en Linux;
- recursos suficientes en la `podman machine`;
- archivo `conf/image-tags.conf`;
- artefactos locales requeridos por la construccion base:
  - `.artifacts/pig-0.18.0-SNAPSHOT-course.tgz`
  - `.artifacts/pig-0.18.0-SNAPSHOT-course.tgz.sha256`

## Flujo base

### 1. Construir imagenes

```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\build.ps1
```

### 2. Levantar el ambiente base

```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\up.ps1
```

### 3. Verificar estado

```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\status.ps1
```

### 4. Ejecutar prueba de humo

```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\smoke-test.ps1
```

### 5. Detener el ambiente

```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\down.ps1
```

## Overlays disponibles

El repositorio contempla overlays para ampliar el ambiente base segun el
componente requerido.

- `spark`
- `ir`
- `sql-hive`
- `nosql-cassandra`
- `nosql-mongodb`
- `graph`

Documentacion de perfiles:

- [spark](./profiles/spark/README.md)
- [ir](./profiles/ir/README.md)
- [sql-hive](./profiles/sql-hive/README.md)
- [nosql-cassandra](./profiles/nosql-cassandra/README.md)
- [nosql-mongodb](./profiles/nosql-mongodb/README.md)
- [graph](./profiles/graph/README.md)

Wrappers principales:

- `containers/scripts/up-spark.ps1`
- `containers/scripts/up-ir.ps1`
- `containers/scripts/up-hive.ps1`
- `containers/scripts/up-cassandra.ps1`
- `containers/scripts/up-mongodb.ps1`

## Progresion por laboratorio

Los componentes se habilitan de forma progresiva. La base `core` queda como
punto comun, y cada overlay se activa solo cuando el laboratorio lo necesita.

| Laboratorio | Componente principal | Activacion local |
|---|---|---|
| `lab01` | Java local / procesamiento de archivos | flujo propio de `lab01` |
| `lab02` | Hadoop + HDFS + MapReduce | `core` |
| `lab03` | Pig sobre Hadoop/HDFS | `core` |
| `lab04` | Spark | `spark` |
| `lab05` | Elasticsearch / IR | `ir` |
| `lab06` | Giraph / PageRank | `graph` sobre `core` |
| `lab07` | Cassandra | `nosql-cassandra` |
| `lab08` | MongoDB | `nosql-mongodb` |

## Estado funcional

Los componentes principales del proyecto fueron implementados y validados
funcionalmente en el flujo local del repositorio. En cada laboratorio se
obtuvieron resultados y se dejaron rutas separadas para scripts, logs,
resultados, notas y documentos de apoyo.

El detalle de ejecucion, evidencia esperada, comandos y consideraciones de cada
caso se mantiene en el `README.md` del laboratorio correspondiente.

## Laboratorios

Los laboratorios y su documentacion especifica viven en `data/shared/lab0X/`.
El detalle de objetivos, insumos, ejecucion, evidencia y consideraciones
academicas debe mantenerse en su propio `README.md`.

- [lab01](./data/shared/lab01/README.md)
- [lab02](./data/shared/lab02/README.md)
- [lab03](./data/shared/lab03/README.md)
- [lab04](./data/shared/lab04/README.md)
- [lab05](./data/shared/lab05/README.md)
- [lab06](./data/shared/lab06/README.md)
- [lab07](./data/shared/lab07/README.md)
- [lab08](./data/shared/lab08/README.md)

## Validacion y limites

- La existencia de scripts, logs o resultados historicos no reemplaza una
  revalidacion en vivo cuando se cambia de maquina, recursos, imagenes o datos.
- Cada overlay o laboratorio debe validarse contra su propio flujo de uso antes
  de reportar una nueva corrida.
- Algunos laboratorios tienen mayor automatizacion que otros; esa diferencia
  debe quedar documentada en el `README.md` correspondiente.

## Linux

Tambien existen wrappers `bash` equivalentes en `containers/scripts/bash/` para
las operaciones principales del ambiente base y varios overlays.
