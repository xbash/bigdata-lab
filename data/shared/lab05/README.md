# Lab05 - Recuperacion de informacion con Elasticsearch

## Objetivo

`lab05` indexa articulos de Wikipedia en Elasticsearch y luego ejecuta
consultas sobre el indice creado.

Los scripts visibles del laboratorio son:

- `prepare-lab05.ps1`
- `run-lab05-index.ps1`
- `run-lab05-search.ps1`

## Estado funcional

Laboratorio implementado y validado funcionalmente sobre el overlay `ir`, con
indexacion y busqueda ejecutadas contra Elasticsearch en el ambiente local.

## Insumos del laboratorio

- `docs/BD2026_05.pdf`
- `docs/lab05.pdf`
- `docs/gdd_lab05.zip`
- `scripts/prepare-lab05.ps1`
- `scripts/run-lab05-index.ps1`
- `scripts/run-lab05-search.ps1`
- `work/gdd-elastic/`

## Prerrequisitos

- overlay IR levantado con `containers/scripts/up-ir.ps1`
- `Elasticsearch` respondiendo en `http://localhost:9200`

## Flujo recomendado

### 1. Levantar y validar el overlay IR

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\containers\scripts\up-ir.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\containers\scripts\status-ir.ps1
```

Validaciones web minimas:

```powershell
Start-Sleep -Seconds 8; (Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:9200/_cat/health?v' -TimeoutSec 10).Content
Start-Sleep -Seconds 8; (Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:9200/_cat/nodes?v' -TimeoutSec 10).Content
```

### 2. Prueba de humo con muestra

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab05\scripts\run-lab05-index.ps1 -IndexName wiki-lab05-sample
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab05\scripts\run-lab05-search.ps1 -IndexName wiki-lab05-sample -Query trump
```

### 3. Corrida final con dataset completo

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab05\scripts\run-lab05-index.ps1 -InputLocalPath /opt/bigdata/data/shared/lab05/datasets/es-wiki-articles.tsv.gz -IndexName wiki-lab05-full
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab05\scripts\run-lab05-search.ps1 -IndexName wiki-lab05-full -Query trump
```

Para cubrir consultas adicionales del PDF, repite solo la busqueda cambiando
`-Query`, por ejemplo `linux`, `chile`, `futbol` o `python`.

## Evidencia esperada

- `logs/*-lab05-index-run.log`
- `logs/*-lab05-search-run.log`
- `results/*-lab05-index-summary.txt`
- `results/*-lab05-search-<query>.txt`

## Notas

- Primero debe existir un indice cargado; recien despues tiene sentido correr
  `run-lab05-search.ps1`.
- `run-lab05-index.ps1` soporta enriquecimiento opcional con ranks si se
  entrega `-RanksLocalPath`.
