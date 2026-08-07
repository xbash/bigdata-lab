# Lab02 - Hadoop WordCount y LetterCount

## Objetivo

`lab02` ejecuta dos tareas Hadoop sobre HDFS local:

- `WordCount`
- `LetterCount`

La guia de este README se alinea con `docs/leeme_instrucciones.txt` y con los
wrappers reales del checkout.

## Estado funcional

Laboratorio implementado y validado funcionalmente sobre el ambiente `core`,
con resultados obtenidos para los flujos de Hadoop indicados.

## Insumos del laboratorio

- `docs/BD2026_02.pdf`
- `docs/lab02.pdf`
- `docs/gdd_lab02.zip`
- `scripts/run-lab02-wordcount.ps1`
- `scripts/run-lab02-lettercount.ps1`
- `work/gdd-hadoop/`

## Prerrequisitos

- stack base levantado con `containers/scripts/up.ps1`
- `bigdata-master` disponible
- proyecto `work/gdd-hadoop` presente

## Flujo recomendado

### 1. Ejecutar WordCount

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab02\scripts\run-lab02-wordcount.ps1
```

La salida imprime al final:

- `Resultado HDFS: /outputs/lab02/wordcount-YYYYMMDD-HHMMSS`
- `Log local: data/shared/lab02/logs/...`
- `Top20 local: data/shared/lab02/logs/...`

### 2. Ejecutar LetterCount usando la salida de WordCount

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab02\scripts\run-lab02-lettercount.ps1 -WordCountInputHdfsPath "/outputs/lab02/wordcount-YYYYMMDD-HHMMSS"
```

### 3. Flujo encadenado sin copiar la ruta a mano

```powershell
$wordcountOutput = powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab02\scripts\run-lab02-wordcount.ps1
$wordcountOutput | ForEach-Object { $_ }
$wordcountHdfsPath = $wordcountOutput | Select-String '^Resultado HDFS:\s*(.+)$' | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() } | Select-Object -First 1
if (-not $wordcountHdfsPath) { throw "No se pudo capturar la ruta HDFS de WordCount." }
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab02\scripts\run-lab02-lettercount.ps1 -WordCountInputHdfsPath $wordcountHdfsPath
```

## Evidencia esperada

- `logs/*-wordcount-run.log`
- `logs/*-wordcount-top20.txt`
- `logs/*-lettercount-run.log`
- `results/*-lettercount-a-z.txt`

## Notas

- `docs/leeme_instrucciones.txt` tambien documenta la compilacion con `ant` o
  `javac`/`jar` para el proyecto `gdd-hadoop`.
- Para cierre academico fuerte, conviene conservar la salida final `a-z` en
  `results/` y la traza completa en `logs/`.
