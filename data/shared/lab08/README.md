# Lab08 - MongoDB

## Objetivo

`lab08` queda asociado al perfil `nosql-mongodb` y a su overlay operativo para
MongoDB.

## Estado funcional

Laboratorio implementado y validado funcionalmente sobre el overlay
`nosql-mongodb`, con ejecucion manual de las instrucciones del enunciado en la
shell de MongoDB y obtencion de resultados.

Al 2026-08-05, este laboratorio tiene:

- enunciado docente en `docs/lab08.pdf`
- overlay reusable `nosql-mongodb` con contenedor dedicado
- respaldo base en `datasets/series.json` y `datasets/crew.json`
- insumos especificos del ejercicio en:
  - `datasets/two-and-a-half-men.series.json`
  - `datasets/two-and-a-half-men.crew.json`
- directorios base para `datasets/`, `scripts/`, `results/` y `notes/`

## Carpetas presentes

- `datasets/`
- `docs/`
- `notes/`
- `results/`
- `scripts/`

## Criterio de uso

El laboratorio puede ejecutarse manualmente desde la shell de MongoDB del
overlay. El flujo conserva la forma del enunciado docente: consultas sobre
`tvdb`, insercion de datos desde TVMaze, carga de `crew` y uso de agregaciones.

## Flujo recomendado

### 1. Levantar el overlay

```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\up-mongodb.ps1
powershell -ExecutionPolicy Bypass -File .\containers\scripts\status-mongodb.ps1
```

### 2. Cargar la base compartida del laboratorio

Este paso importa las colecciones base de `tvdb` requeridas para comenzar el
lab:

- `series`
- `crew`

Comando:

```powershell
powershell -ExecutionPolicy Bypass -File .\data\shared\lab08\scripts\load-lab08-base-data.ps1
```

Si se requiere reconstruir esas colecciones desde cero en el contenedor local:

```powershell
powershell -ExecutionPolicy Bypass -File .\data\shared\lab08\scripts\load-lab08-base-data.ps1 -ReplaceCollections
```

### 3. Ejecutar el ejercicio con la serie elegida

La serie definida para este checkout es:

- `Two and a Half Men`
- `TVMaze id = 130`

Archivos disponibles en `datasets/` para esa serie:

- `two-and-a-half-men.series.json`
- `two-and-a-half-men.crew.json`

Referencias TVMaze usadas para el ejercicio:

- `https://api.tvmaze.com/singlesearch/shows?q=two%20and%20a%20half%20men`
- `https://api.tvmaze.com/shows/130/crew`

### 4. Continuar el laboratorio en la shell de MongoDB

```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\shell-mongodb.ps1
```

## Criterio de carga

- Primero se habilita el overlay `nosql-mongodb`.
- Luego se valida conectividad y estado.
- Recién despues conviene importar la base compartida de `tvdb`.
- La serie del ejercicio y su `crew` deben usarse durante la ejecucion del
  laboratorio, no como reemplazo de la base compartida.
