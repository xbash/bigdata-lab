# graph

## Objetivo

Perfil operativo de `lab06`, con foco en `Giraph` para `PageRank` y `SortByRank`.

## Estado

Perfil implementado y validado funcionalmente mediante los scripts del
laboratorio, sin `compose` propio.

## Activacion

No agrega contenedores nuevos.

Su flujo actual se apoya sobre el `core`:

1. levantar el `core` con `containers/scripts/up.ps1`
2. preparar el material de `lab06` con `data/shared/lab06/scripts/prepare-lab06.ps1`
3. ejecutar `PageRank` con `data/shared/lab06/scripts/run-lab06-pagerank.ps1`

Si luego se quiere integrar el ranking con la busqueda de `lab05`, se reutiliza el overlay `ir`.

## Archivos clave

- `profiles/graph/`
- `data/shared/lab06/`
- `data/shared/lab06/scripts/prepare-lab06.ps1`
- `data/shared/lab06/scripts/run-lab06-pagerank.ps1`
- `data/shared/lab06/results/lab05-rank-integration/README_PREPARACION.md`

## Limites

- No existe un `compose` dedicado para este perfil.
- `Giraph` no forma parte del `core`; vive solo dentro del flujo de `lab06`.
- `Elasticsearch` no es requerido para calcular `PageRank`; solo participa en la integracion posterior con `lab05`.
