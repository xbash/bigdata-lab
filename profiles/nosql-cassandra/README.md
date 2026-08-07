# nosql-cassandra

## Objetivo

Overlay previsto para incorporar un escenario NoSQL basado en `Cassandra`.

## Estado

Overlay implementado y validado funcionalmente para habilitar `Apache Cassandra
2.0.7` dentro de los cuatro contenedores existentes del stack base:
`bigdata-master` y `bigdata-worker1..3`.

## Activacion

```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\build.ps1
powershell -ExecutionPolicy Bypass -File .\containers\scripts\up-cassandra.ps1
powershell -ExecutionPolicy Bypass -File .\containers\scripts\status-cassandra.ps1
```

En Linux:

```bash
bash ./containers/scripts/bash/build.sh
bash ./containers/scripts/bash/up-cassandra.sh
bash ./containers/scripts/bash/status-cassandra.sh
```

## Archivos clave

- `profiles/nosql-cassandra/`
- `compose.yml`
- `compose.cassandra.yml`
- `containers/scripts/`

## Limites

- Replica la topologia reusable local `1 master + 3 workers`, no los 5 nodos del servidor docente.
- El servidor docente observado usa `Cassandra 2.0.7`, `cqlsh 4.1.1`, CQL `3.1.1`, Thrift `19.39.0`, puertos `9042` y `9160`.
- En `v0.4.1`, Cassandra deja de pertenecer al `core` y pasa a una familia de imagenes separada para este overlay.
- Ante cambios de imagenes, recursos o maquina anfitriona, conviene revalidar
  el overlay con Podman antes de reportar una nueva corrida.
