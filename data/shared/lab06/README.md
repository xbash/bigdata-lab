# Lab06 - PageRank con Giraph

## Objetivo

`lab06` ejecuta un flujo reproducible de `PageRank` con Giraph y luego ordena
los resultados por rank.

Los scripts principales son:

- `prepare-lab06.ps1`
- `run-lab06-pagerank.ps1`
- `run-lab06-lab05-integration.ps1`

## Estado funcional

Laboratorio implementado y validado funcionalmente sobre el perfil `graph`, con
calculo de PageRank, ordenamiento de resultados e integracion posterior con
`lab05` cuando corresponde.

## Insumos del laboratorio

- `docs/BD2026_06.pdf`
- `docs/lab06.pdf`
- `docs/gdd_lab06.zip`
- `scripts/prepare-lab06.ps1`
- `scripts/run-lab06-pagerank.ps1`
- `scripts/run-lab06-lab05-integration.ps1`
- `work/gdd-giraph/`

## Recomendacion operativa

Para la corrida pesada de `PageRank`, conviene bajar el overlay IR si esta
activo:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\containers\scripts\down-ir.ps1
```

## Flujo recomendado

### 1. Preparar el laboratorio

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab06\scripts\prepare-lab06.ps1
```

### 2. Prueba de humo con dataset pequeno

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab06\scripts\run-lab06-pagerank.ps1
```

### 3. Corrida full validada de forma conservadora

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab06\scripts\run-lab06-pagerank.ps1 `
  -InputLocalPath /opt/bigdata/data/shared/lab06/datasets/es-wiki-links.tsv.gz `
  -InputHdfsPath /inputs/lab06/es-wiki-links.tsv.gz `
  -Workers 1 `
  -MapMemoryMb 4096 `
  -MapJavaOpts "-Xmx3276m"
```

### 4. Monitoreo en vivo opcional

```powershell
podman exec bigdata-master /bin/bash -lc "yarn application -list -appStates RUNNING,ACCEPTED,SUBMITTED"
podman exec bigdata-master /bin/bash -lc "yarn application -status application_XXXXXXXXXXXX_000X | egrep 'State :|Final-State :|Progress :|Start-Time :|Finish-Time :'"
```

## Evidencia esperada

- `logs/*-lab06-pagerank-run.log`
- `results/*-lab06-pagerank-top10.txt`
- `results/*-lab06-pagerank-sorted-top10.txt`
- salidas HDFS en `/outputs/lab06`

## Notas

- Si la corrida full falla por memoria, el propio laboratorio deja como base
  recomendada `Workers 1`, `MapMemoryMb 4096` y `MapJavaOpts "-Xmx3276m"`.
- La integracion posterior con `lab05` esta documentada en
  `results/lab05-rank-integration/README_PREPARACION.md`.
