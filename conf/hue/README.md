# hue

## Objetivo

Directorio de configuracion del componente `sql-ui` basado en `Hue` para el overlay `sql-hive`.

## Estado

Preparado a nivel de configuracion base, con validacion funcional pendiente.

## Uso

Este directorio concentra:

- configuracion de `Hue`
- parametros de conexion hacia `HiveServer2`
- ajustes de interfaz y persistencia del componente SQL visual

## Archivos clave

- `conf/hue/hue.ini`
- `compose.hive.yml`
- `profiles/sql-hive/README.md`
- `containers/scripts/up-hive.ps1`
- `containers/scripts/shell-sql-ui.ps1`

## Limites

- La presencia de `hue.ini` no prueba por si sola que el frente SQL este operativo.
- La integracion completa con `HiveServer2` sigue sujeta a validacion real del overlay.
