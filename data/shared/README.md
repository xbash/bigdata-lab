# shared

## Objetivo

Directorio raiz para datasets, codigo fuente, scripts y artefactos compartidos por laboratorio.

## Estado

En uso como ubicacion canonica de materiales por laboratorio.

## Uso

Cada laboratorio se organiza en su propio subdirectorio, por ejemplo:

- `data/shared/lab01/`
- `data/shared/lab02/`
- `data/shared/lab03/`
- `data/shared/lab04/`
- `data/shared/lab05/`
- `data/shared/lab06/`
- `data/shared/lab07/`
- `data/shared/lab08/`

La convencion observada en este checkout separa, segun el laboratorio:

- `datasets/`
- `scripts/`
- `work/`
- `results/`
- `logs/`
- `docs/`

## Archivos clave

- `data/shared/`
- `README.md`
- scripts delegados desde `containers/scripts/`

## Limites

- No todos los laboratorios tienen exactamente el mismo nivel de madurez o validacion.
- La existencia de `results/` o `logs/` dentro de un laboratorio no equivale por si sola a una validacion actual del entorno.
