# Lab03 - Pig sobre IMDb

## Objetivo

`lab03` ejecuta consultas Pig del laboratorio usando wrappers PowerShell sobre
el cluster local.

Los dos flujos visibles en el checkout son:

- `costar-count`
- `star-count`

## Estado funcional

Laboratorio implementado y validado funcionalmente sobre el ambiente `core`,
con ejecucion de consultas Pig y resultados generados en el flujo local.

## Insumos del laboratorio

- `docs/BD2026_03.pdf`
- `docs/lab03.pdf`
- `scripts/run-lab03-costarcount.ps1`
- `scripts/run-lab03-starcount.ps1`
- `scripts/*.template.pig`
- `scripts/*.runtime.pig`

## Flujo recomendado

### 1. Corrida de prueba

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab03\scripts\run-lab03-costarcount.ps1 -Mode Sample
```

### 2. Corrida de prueba reutilizando HDFS

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab03\scripts\run-lab03-costarcount.ps1 -Mode Sample -SkipSampleRefresh -SkipHdfsUpload
```

### 3. Corrida completa

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab03\scripts\run-lab03-costarcount.ps1 -Mode Full
```

### 4. Corrida completa minimizando overhead

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab03\scripts\run-lab03-costarcount.ps1 -Mode Full -SkipHdfsUpload -SkipPreview
```

### 5. Ver top 20 desde HDFS

```powershell
podman exec bigdata-master /bin/bash -lc "hdfs dfs -text /outputs/lab03/costar-count-full-YYYYMMDD-HHMMSS/part-r-00000 | awk 'NR <= 20 { print }'"
```

## Evidencia esperada

- logs de corrida en `logs/`
- resultados en `results/`
- salidas HDFS bajo `/outputs/lab03`

## Notas

- El wrapper `run-lab03-costarcount.ps1` ya soporta `-SkipHdfsUpload` y
  `-SkipPreview`.
- La recomendacion metodologica registrada en `docs/leeme_instrucciones.txt`
  es optimizar una variable por vez: primero linea base, luego paralelismo o
  compresion.
