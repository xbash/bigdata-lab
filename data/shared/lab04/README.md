# Lab04 - Spark InfoSeriesRating

## Objetivo

`lab04` ejecuta tareas Spark del proyecto `gdd-spark`. El flujo mas relevante
 para cierre del laboratorio es `InfoSeriesRating`, aunque el wrapper tambien
soporta:

- `WordCountTask`
- `AverageSeriesRating`
- `InfoSeriesRating`

## Estado funcional

Laboratorio implementado y validado funcionalmente sobre el overlay `spark`,
con resultados obtenidos para las utilidades del proyecto `gdd-spark`.

## Insumos del laboratorio

- `docs/BD2026_04.pdf`
- `docs/lab04.pdf`
- `docs/gdd_lab04.zip`
- `scripts/prepare-lab04.ps1`
- `scripts/run-lab04.ps1`
- `work/gdd-spark/`

## Prerrequisitos

- overlay Spark levantado con `containers/scripts/up-spark.ps1`
- proyecto preparado en `work/gdd-spark`

## Flujo recomendado

### 1. Preparar el laboratorio

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab04\scripts\prepare-lab04.ps1
```

### 2. Corrida pequena con el dataset de ejemplo

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab04\scripts\run-lab04.ps1 -Utility InfoSeriesRating -InputLocalPath /opt/bigdata/data/shared/lab04/datasets/imdb-ratings-two.tsv
```

### 3. Corrida final con el dataset completo

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab04\scripts\run-lab04.ps1 -Utility InfoSeriesRating -InputLocalPath /opt/bigdata/data/shared/lab04/datasets/imdb-ratings.tsv
```

## Evidencia esperada

- `logs/*-infoseriesrating-run.log`
- `results/*-infoseriesrating-top20.txt`
- salida HDFS en `/outputs/lab04/infoseriesrating-YYYYMMDD-HHMMSS`

## Verificacion rapida

Ultimo preview:

```powershell
Get-Content (Get-ChildItem .\data\shared\lab04\results\*infoseriesrating-top20.txt | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
```

Ultimo log:

```powershell
Get-Content (Get-ChildItem .\data\shared\lab04\logs\*infoseriesrating-run.log | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
```

## Notas

- El uso academico recomendado es correr primero `imdb-ratings-two.tsv` y
  luego `imdb-ratings.tsv`.
- Para cierre de entrega conviene conservar log, top20, ruta HDFS y las tuplas
  pedidas por el enunciado.
