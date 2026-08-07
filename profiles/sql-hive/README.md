# sql-hive

## Objetivo

Overlay para habilitar el frente SQL del ambiente reusable mediante `Hive` y `Hue`.

## Estado

Implementado y validado funcionalmente como overlay auxiliar del ambiente
reusable.

## Activacion

Se activa mediante el `compose` dedicado y sus wrappers:

- `containers/scripts/up-hive.ps1`
- `containers/scripts/status-hive.ps1`
- `containers/scripts/down-hive.ps1`
- `containers/scripts/shell-hive.ps1`
- `containers/scripts/shell-sql-ui.ps1`

## Decision actual al `2026-08-01`

- el placeholder deja de ser neutro
- el componente visual seleccionado para este overlay es `Hue`
- `compose.hive.yml` queda reservado para:
  - `sql-ui` basado en `Hue`
  - `Hive Metastore`
  - `HiveServer2`
  - sin depender de `profiles`, porque el overlay ya se activa por archivo `compose` dedicado

## Archivos clave

- `compose.hive.yml`
- `conf/hive/README.md`
- `conf/hue/hue.ini`
- `containers/scripts/up-hive.ps1`
- `containers/scripts/status-hive.ps1`
- `containers/scripts/down-hive.ps1`
- `containers/scripts/shell-hive.ps1`
- `containers/scripts/shell-sql-ui.ps1`

## Limites

- `sql-ui` queda incorporado como componente del baseline `v0.4.1`.
- Este overlay es auxiliar y no reemplaza los flujos especificos de cada
  laboratorio.
