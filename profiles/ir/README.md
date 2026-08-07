# ir

## Objetivo

Overlay local de recuperacion de informacion para `lab05`.

## Estado

Implementado y validado funcionalmente para el flujo local de `lab05`.

## Activacion

Se activa mediante el `compose` dedicado y sus wrappers:

- `containers/scripts/prepare-lab05.ps1`
- `containers/scripts/up-ir.ps1`
- `containers/scripts/status-ir.ps1`
- `containers/scripts/down-ir.ps1`
- `containers/scripts/shell-elastic.ps1`

## Decision local

- Se conserva la semantica remota relevante para el cliente Java del laboratorio:
  - `cluster.name = es-pmd`
  - alias de red `cm`
  - puerto de transporte `9300`
- Se adapta la topologia al laptop:
  - `1` nodo Elasticsearch
  - `1` shard primario por defecto
  - `0` replicas por defecto
- En `v0.4.1`, este overlay se mantiene separado del `core` y no debe distribuirse por defecto sobre varios nodos del cluster local.

## Archivos clave

- `compose.ir.yml`
- `conf/elasticsearch/elasticsearch.yml`
- `containers/scripts/prepare-lab05.ps1`
- `containers/scripts/up-ir.ps1`
- `containers/scripts/status-ir.ps1`
- `containers/scripts/down-ir.ps1`
- `containers/scripts/shell-elastic.ps1`

## Limites

- Este overlay deja lista la infraestructura local para `lab05`.
- No reemplaza la implementacion ni la validacion final del codigo Java del laboratorio.
- Durante la fase pesada de `lab06`, puede convenir dejar `bigdata-elasticsearch` detenido para liberar RAM.
