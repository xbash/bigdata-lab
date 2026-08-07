# spark

## Objetivo

Overlay para habilitar `Spark` sobre el ambiente reusable y ejecutar los flujos
del `lab04`.

## Estado

Overlay implementado y validado funcionalmente para el flujo local de `lab04`.

## Activacion

```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\build.ps1
powershell -ExecutionPolicy Bypass -File .\containers\scripts\up-spark.ps1
powershell -ExecutionPolicy Bypass -File .\containers\scripts\status-spark.ps1
```

En Linux:

```bash
bash ./containers/scripts/bash/build.sh
bash ./containers/scripts/bash/up-spark.sh
bash ./containers/scripts/bash/status-spark.sh
```

## Archivos clave

- `compose.spark.yml`
- `containers/spark-base/Containerfile`
- `containers/scripts/up-spark.ps1`
- `containers/scripts/status-spark.ps1`
- `containers/scripts/down-spark.ps1`
- `data/shared/lab04/`

## Limites

- Este overlay habilita Spark sobre la topologia local del proyecto.
- No reemplaza el ambiente docente; adapta la ejecucion al stack local sobre
  contenedores.
- Ante cambios de imagenes, recursos o maquina anfitriona, conviene revalidar
  el overlay antes de reportar una nueva corrida.
