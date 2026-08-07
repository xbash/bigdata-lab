# Lab01 - N-grams y conteo sobre Wikipedia

## Objetivo

`lab01` concentra las corridas locales del proyecto `gdd-wiki` para:

- `RunWordCountInMemory`
- `RunNGramCountInMemory`
- pipeline externo con archivos para `n` altos, incluido `n=51`

La referencia docente de este laboratorio esta en `docs/` y el detalle
operativo base esta alineado con `docs/leeme_instrucciones.txt`.

## Estado funcional

Laboratorio implementado y validado funcionalmente en el ambiente local del
proyecto, con generacion de resultados y logs en las carpetas del laboratorio.

## Insumos del laboratorio

- `docs/BD2026_01.pdf`
- `docs/lab01.pdf`
- `docs/gdd_lab01.zip`
- `scripts/run_lab01_experiments.ps1`
- `scripts/run_lab01_inmemory.ps1`
- `scripts/run_lab01_external.ps1`
- `work/gdd_lab01/gdd-wiki/`

## Flujo recomendado

### 1. Corrida de muestra del pipeline externo

Desde la raiz del repo:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab01\scripts\run_lab01_experiments.ps1 -UseSample -SkipInMemory -RunExternalPipeline -ExternalN 51 -Heap 1024M -BatchSize 10000 -TopK 20
```

### 2. Corridas cortas en memoria sobre muestra

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab01\scripts\run_lab01_experiments.ps1 -Mode InMemory -UseSample -NValues 2,3,4,5,6,7,8,9,10 -TopK 20 -Heap 4096M
```

Si necesitas ejecutar las utilidades Java de forma directa, revisa
`docs/leeme_instrucciones.txt`, donde estan las variantes con `java.exe` y
captura de evidencia explicita a `logs/`.

### 3. Corrida completa del pipeline externo

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab01\scripts\run_lab01_experiments.ps1 -SkipInMemory -RunExternalPipeline -ExternalN 51 -Heap 28G -BatchSize 500000 -TopK 100
```

## Evidencia esperada

- `results/es-wiki-abstracts-n51-grams*.txt.gz`
- `results/*-top*.txt`
- `logs/external_*.stdout.txt`
- `logs/external_*.stderr.log`
- `logs/runs_summary.csv`

## Notas

- La secuencia recomendada es muestra externa, luego memoria, y recien despues
  full externa.
- Si el objetivo es cierre academico reproducible, conserva tanto los
  artefactos finales como los logs intermedios.
