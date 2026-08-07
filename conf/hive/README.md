# hive

## Objetivo

Directorio previsto para la configuracion del frente `Hive` del overlay `sql-hive`.

## Estado

Preparado a nivel de definicion base, con implementacion funcional y validacion final pendientes.

## Uso

Este directorio queda asociado a los componentes:

- `Hive Metastore`
- `HiveServer2`
- integracion con `Hue` como visualizador SQL

## Archivos clave

- `conf/hive/`
- `compose.hive.yml`
- `profiles/sql-hive/README.md`
- `containers/scripts/up-hive.ps1`
- `containers/scripts/status-hive.ps1`

## Limites

- El directorio existe como punto de configuracion reservado.
- La operacion completa del overlay `sql-hive` aun requiere validacion funcional en vivo.
