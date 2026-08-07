<#
Ejecuta el script Pig costar-count de lab03 sobre muestra o dataset completo.
#>
param(
    [ValidateSet("Sample", "Full")]
    [string]$Mode = "Sample",
    [string]$FullDatasetLocalPath = "data\shared\lab03\datasets\imdb-stars.tsv",
    [string]$SampleDatasetLocalPath = "data\shared\lab03\datasets\imdb-stars-test.tsv",
    [int]$SampleLines = 50000,
    [string]$OutputHdfsRoot = "/outputs/lab03",
    [switch]$SkipSampleRefresh,
    [switch]$SkipHdfsUpload,
    [switch]$SkipPreview,
    [switch]$ShowJvmWarnings
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$zipPath = Join-Path $root "data\shared\lab03\docs\gdd_lab03.zip"
$fullDatasetZipPath = Join-Path $root "data\shared\lab03\datasets\imdb-stars.zip"
$sampleDatasetZipPath = Join-Path $root "data\shared\lab03\datasets\imdb-stars-test.zip"
$fullDatasetPath = Join-Path $root $FullDatasetLocalPath
$sampleDatasetPath = Join-Path $root $SampleDatasetLocalPath
$scriptDir = Join-Path $root "data\shared\lab03\scripts"
$logsDir = Join-Path $root "data\shared\lab03\logs"
$resultsDir = Join-Path $root "data\shared\lab03\results"
$basePigScriptPath = Join-Path $scriptDir "costar-count.template.pig"
$runtimePigScriptPath = Join-Path $scriptDir "costar-count.runtime.pig"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$modeSuffix = $Mode.ToLowerInvariant()

New-Item -ItemType Directory -Force -Path $scriptDir, $logsDir, $resultsDir | Out-Null

if (-not (Test-Path -LiteralPath $zipPath)) {
    throw "No se encontro el ZIP requerido del laboratorio: $zipPath"
}

if (-not (Test-Path -LiteralPath $fullDatasetPath)) {
    if (-not (Test-Path -LiteralPath $fullDatasetZipPath)) {
        throw "No se encontro el dataset full esperado ni su ZIP fuente: $fullDatasetPath | $fullDatasetZipPath"
    }

    Write-Host "Extrayendo dataset full desde $fullDatasetZipPath"
    tar -xf $fullDatasetZipPath -C (Split-Path -Parent $fullDatasetPath)

    if (-not (Test-Path -LiteralPath $fullDatasetPath)) {
        throw "La extraccion del dataset full no genero el archivo esperado: $fullDatasetPath"
    }
}

if (-not (Test-Path -LiteralPath $basePigScriptPath)) {
    throw "No se encontro el script base requerido: $basePigScriptPath"
}

if ($Mode -eq "Sample") {
    if (-not $SkipSampleRefresh) {
        $sampleLinesContent = Get-Content -LiteralPath $fullDatasetPath -Encoding UTF8 -TotalCount $SampleLines
        [System.IO.File]::WriteAllLines($sampleDatasetPath, $sampleLinesContent, [System.Text.UTF8Encoding]::new($false))
    }

    if (-not (Test-Path -LiteralPath $sampleDatasetPath)) {
        if (-not (Test-Path -LiteralPath $sampleDatasetZipPath)) {
            throw "No se encontro el dataset de muestra esperado ni su ZIP fuente: $sampleDatasetPath | $sampleDatasetZipPath"
        }

        Write-Host "Extrayendo dataset de muestra desde $sampleDatasetZipPath"
        tar -xf $sampleDatasetZipPath -C (Split-Path -Parent $sampleDatasetPath)

        if (-not (Test-Path -LiteralPath $sampleDatasetPath)) {
            throw "La extraccion del dataset de muestra no genero el archivo esperado: $sampleDatasetPath"
        }
    }

    $inputLocalPath = $sampleDatasetPath
    $inputContainerPath = "/opt/bigdata/data/shared/lab03/datasets/imdb-stars-test.tsv"
    $inputHdfsPath = "/inputs/lab03/imdb-stars-test.tsv"
    $outputHdfsPath = ($OutputHdfsRoot.TrimEnd("/") + "/costar-count-sample-" + $timestamp)
} else {
    $inputLocalPath = $fullDatasetPath
    $inputContainerPath = "/opt/bigdata/data/shared/lab03/datasets/imdb-stars.tsv"
    $inputHdfsPath = "/inputs/lab03/imdb-stars.tsv"
    $outputHdfsPath = ($OutputHdfsRoot.TrimEnd("/") + "/costar-count-full-" + $timestamp)
}

if (-not (Test-Path -LiteralPath $inputLocalPath)) {
    throw "No se encontro el dataset de entrada esperado para modo ${Mode}: $inputLocalPath"
}

$runLogPath = Join-Path $logsDir ($timestamp + "-costarcount-" + $modeSuffix + "-run.log")
$previewPath = Join-Path $resultsDir ($timestamp + "-costarcount-" + $modeSuffix + "-top20.txt")

$pigScript = Get-Content $basePigScriptPath -Raw
$pigScript = $pigScript.Replace("hdfs://cm:9000/uhadoop/shared/imdb/imdb-stars-test.tsv", "hdfs://master:9000$InputHdfsPath")
$pigScript = $pigScript.Replace("hdfs://cm:9000/uhadoop2026/cc66i/<suCarpeta>/imdb-costars-test/", "hdfs://master:9000$outputHdfsPath")
[System.IO.File]::WriteAllText($runtimePigScriptPath, $pigScript, [System.Text.UTF8Encoding]::new($false))

$pigCommandLines = New-Object System.Collections.Generic.List[string]
$pigCommandLines.Add("set -euo pipefail")
$pigCommandLines.Add("hdfs dfs -mkdir -p /inputs/lab03")
if (-not $SkipHdfsUpload) {
    $pigCommandLines.Add('hdfs dfs -put -f "__INPUT_LOCAL__" "__INPUT_HDFS__"')
}
$pigCommandLines.Add('echo "---HDFS-INPUT-CHECK-BEGIN---"')
$pigCommandLines.Add('if ! hdfs dfs -test -e "__INPUT_HDFS__"; then')
$pigCommandLines.Add('  echo "ERROR: no existe el input HDFS requerido: __INPUT_HDFS__"')
$pigCommandLines.Add('  echo "Sugerencia: ejecuta sin -SkipHdfsUpload o verifica la carga previa en HDFS."')
$pigCommandLines.Add('  echo "---HDFS-INPUT-CHECK-END---"')
$pigCommandLines.Add('  exit 20')
$pigCommandLines.Add('fi')
$pigCommandLines.Add('echo "hdfs dfs -ls __INPUT_HDFS__"')
$pigCommandLines.Add('hdfs dfs -ls "__INPUT_HDFS__"')
$pigCommandLines.Add('echo "hdfs dfs -du -h __INPUT_HDFS__"')
$pigCommandLines.Add('hdfs dfs -du -h "__INPUT_HDFS__"')
$pigCommandLines.Add('if hdfs dfs -test -z "__INPUT_HDFS__"; then')
$pigCommandLines.Add('  echo "ERROR: el input HDFS requerido existe pero esta vacio: __INPUT_HDFS__"')
$pigCommandLines.Add('  echo "Sugerencia: vuelve a cargar el archivo sin -SkipHdfsUpload."')
$pigCommandLines.Add('  echo "---HDFS-INPUT-CHECK-END---"')
$pigCommandLines.Add('  exit 21')
$pigCommandLines.Add('fi')
$pigCommandLines.Add('echo "---HDFS-INPUT-CHECK-END---"')
$pigCommandLines.Add('hdfs dfs -rm -r -f "__OUTPUT_HDFS__" >/dev/null 2>&1 || true')
$pigCommandLines.Add("pig -f /opt/bigdata/data/shared/lab03/scripts/costar-count.runtime.pig")
if (-not $SkipPreview) {
    $pigCommandLines.Add("echo ---COSTARCOUNT-TOP20-BEGIN---")
    $pigCommandLines.Add('hdfs dfs -text "__OUTPUT_HDFS__/part-r-00000" | awk ''NR <= 20 { print }''')
    $pigCommandLines.Add("echo ---COSTARCOUNT-TOP20-END---")
}

$pigCommand = ($pigCommandLines -join [Environment]::NewLine)
$pigCommand = $pigCommand -replace "`r`n", "`n"
$pigCommand = $pigCommand.Replace("__INPUT_LOCAL__", $inputContainerPath)
$pigCommand = $pigCommand.Replace("__INPUT_HDFS__", $InputHdfsPath)
$pigCommand = $pigCommand.Replace("__OUTPUT_HDFS__", $outputHdfsPath)

$tempScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) ("run-lab03-costarcount-" + $timestamp + ".sh")
[System.IO.File]::WriteAllText($tempScriptPath, $pigCommand, [System.Text.UTF8Encoding]::new($false))

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$global:LASTEXITCODE = 0
podman cp $tempScriptPath bigdata-master:/tmp/run-lab03-costarcount.sh | Out-Null
$rawOutput = podman exec bigdata-master /bin/bash /tmp/run-lab03-costarcount.sh 2>&1
$exitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
Remove-Item -LiteralPath $tempScriptPath -Force -ErrorAction SilentlyContinue

$output = @($rawOutput | ForEach-Object {
    if ($_ -is [System.Management.Automation.ErrorRecord]) {
        $_.ToString()
    } else {
        [string]$_
    }
})

$output | Set-Content -LiteralPath $runLogPath -Encoding UTF8

$consoleOutput = if ($ShowJvmWarnings) {
    $output
} else {
    $output | Where-Object {
        $_ -notmatch '^WARNING: An illegal reflective access operation has occurred$' -and
        $_ -notmatch '^WARNING: Illegal reflective access by org\.apache\.hadoop\.security\.authentication\.util\.KerberosUtil' -and
        $_ -notmatch '^WARNING: Please consider reporting this to the maintainers of org\.apache\.hadoop\.security\.authentication\.util\.KerberosUtil$' -and
        $_ -notmatch '^WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations$' -and
        $_ -notmatch '^WARNING: All illegal access operations will be denied in a future release$'
    }
}

$consoleOutput | ForEach-Object { Write-Host $_ }

$previewLines = New-Object System.Collections.Generic.List[string]
$capturePreview = $false
foreach ($line in $output) {
    if ($line -eq "---COSTARCOUNT-TOP20-BEGIN---") {
        $capturePreview = $true
        continue
    }
    if ($line -eq "---COSTARCOUNT-TOP20-END---") {
        $capturePreview = $false
        continue
    }
    if ($capturePreview) {
        $normalizedLine = $line.TrimStart([char]0xFEFF)
        if ([string]::IsNullOrWhiteSpace($normalizedLine)) {
            continue
        }
        if ($normalizedLine -match '^WARNING:') {
            continue
        }
        $previewLines.Add($normalizedLine)
    }
}
$previewLines | Set-Content -LiteralPath $previewPath -Encoding UTF8

if ($exitCode -ne 0) {
    $errorSummary = $output |
        Where-Object {
            $_ -match 'ERROR: ' -or
            $_ -match 'ERROR \d+' -or
            $_ -match 'exception during parsing' -or
            $_ -match 'Failed to parse' -or
            $_ -match 'Invalid physical operators' -or
            $_ -match 'mismatched input' -or
            $_ -match 'Failed to read data from'
        } |
        Select-Object -Last 3

    if (-not $errorSummary) {
        $errorSummary = $output | Select-Object -Last 10
    }

    $errorText = ($errorSummary -join [Environment]::NewLine)
    throw ("La ejecucion de costar-count fallo.`n" +
        "Causa resumida:`n$errorText`n" +
        "Log local: $runLogPath")
}

Write-Host "Resultado HDFS: $outputHdfsPath"
Write-Host "Log local: $runLogPath"
if ($SkipPreview) {
    Write-Host "Preview local: omitido por -SkipPreview"
} else {
    Write-Host "Preview local: $previewPath"
}
