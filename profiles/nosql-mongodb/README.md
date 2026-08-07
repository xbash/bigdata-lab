# nosql-mongodb

## Objetivo

Overlay previsto para incorporar un escenario NoSQL basado en `MongoDB`.

## Estado

Overlay implementado y validado funcionalmente para el flujo local de `lab08`.

## Activacion

Flujo disponible en este checkout:

- `powershell -ExecutionPolicy Bypass -File .\containers\scripts\up-mongodb.ps1`
- `powershell -ExecutionPolicy Bypass -File .\containers\scripts\status-mongodb.ps1`
- `powershell -ExecutionPolicy Bypass -File .\containers\scripts\shell-mongodb.ps1`
- `powershell -ExecutionPolicy Bypass -File .\containers\scripts\down-mongodb.ps1`

## Archivos clave

- `profiles/nosql-mongodb/`
- `docs/accesos_servidores.csv`
- `data/shared/lab08/`

## Limites

- El overlay usa `compose.mongodb.yml` y el contenedor `bigdata-mongodb`.
- La primera ejecucion puede requerir descargar `docker.io/library/mongo:4.4.14` si la imagen no existe localmente.
- El trabajo del laboratorio se realiza desde la shell de MongoDB, siguiendo el
  enunciado docente y los comandos documentados para `lab08`.
- Referencia observada el `2026-08-04` en el laboratorio docente:
  - `MongoDB shell version v4.4.14`
  - el chequeo `mongod --version` termino con `Illegal instruction`, por lo que la version del daemon no queda confirmada con el mismo nivel de certeza.
