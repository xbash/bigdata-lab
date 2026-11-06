# Lab07 - Cassandra

## Objetivo

`lab07` ejecuta un flujo reproducible sobre el overlay `nosql-cassandra` para
generar sentencias CQL de entrega y validar consultas equivalentes al
enunciado.

## Estado funcional

Laboratorio implementado y validado funcionalmente sobre el overlay
`nosql-cassandra`, con generacion de comandos CQL, logs y resumen de resultados.

## Insumos del laboratorio

- `docs/BD2026_07.pdf`
- `docs/lab07.pdf`
- `datasets/alumno.csv`
- `datasets/cc66i.schema.cql`
- `scripts/run-lab07-cassandra.ps1`
- `scripts/load-lab07-base-data.ps1`

## Prerrequisitos

- overlay Cassandra levantado con `containers/scripts/up-cassandra.ps1`
- cluster validado con `containers/scripts/status-cassandra.ps1`

## Flujo recomendado

### 1. Levantar el overlay

```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\up-cassandra.ps1
powershell -ExecutionPolicy Bypass -File .\containers\scripts\status-cassandra.ps1
```

### 2. Cargar solo la base compartida del laboratorio

La carga base debe ejecutarse solo despues de habilitar y validar el
componente `nosql-cassandra`.

Este paso carga unicamente la tabla compartida `cc66i.alumno` desde:

- `data/shared/lab07/datasets/alumno.csv`

Comando:

```powershell
powershell -ExecutionPolicy Bypass -File .\data\shared\lab07\scripts\load-lab07-base-data.ps1
```

### 3. Ejecutar el laboratorio con valores por defecto

```powershell
powershell -ExecutionPolicy Bypass -File .\data\shared\lab07\scripts\run-lab07-cassandra.ps1
```

### 4. Ejecutar con datos propios

```powershell
powershell -ExecutionPolicy Bypass -File .\data\shared\lab07\scripts\run-lab07-cassandra.ps1 `
  -Usuario "jperez" `
  -NombreIniciales "J. Perez" `
  -NombreCompleto "Juan Perez" `
  -Edad 31 `
  -ColorFav "black" `
  -PeliculaFav "Matrix" `
  -Comentario "lab07 prueba"
```

## Criterio de carga de datos

- Primero se habilita el overlay Cassandra.
- Luego se valida el cluster.
- Recién despues se carga la base compartida del lab.
- Solo entonces conviene comenzar los ejercicios en `cqlsh` o ejecutar el
  runner reproducible.

Si el volumen persistente de Cassandra ya conserva `cc66i.alumno`, no hace
falta recargar en cada arranque. La recarga conviene cuando:

- es la primera habilitacion del lab
- se ejecuto una limpieza del runtime o `factory reset`
- se quiere restaurar la tabla base compartida desde el respaldo local

## Respaldo local del lab

El respaldo base de `lab07` debe quedar en `datasets/`.

Para este laboratorio, el respaldo relevante a conservar es:

- `data/shared/lab07/datasets/alumno.csv`
- `data/shared/lab07/datasets/cc66i.schema.cql`

Los demas archivos exportados o auxiliares pueden depurarse manualmente segun
el criterio operativo del checkout.

## Evidencia esperada

El script deja:

- `results/*-comandos-entrega.cql`
- `results/*-resumen.txt`
- `logs/*-run.log`

El archivo principal de entrega es:

- `data/shared/lab07/results/*-comandos-entrega.cql`

## Notas sobre Cassandra 2.0.7

- Los `CREATE INDEX` pueden existir y aun asi devolver `0 rows` en consultas
  por indice bajo este cluster local.
- El script deja registradas alternativas orientadas a consulta para edad,
  `despierto` y consultas finales por `color_fav`.
- La ruta correcta del wrapper en este checkout es
  `data/shared/lab07/scripts/run-lab07-cassandra.ps1`.
- La ruta correcta del cargador base en este checkout es
  `data/shared/lab07/scripts/load-lab07-base-data.ps1`.
