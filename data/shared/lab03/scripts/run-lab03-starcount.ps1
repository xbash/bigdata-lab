<#
Prepara muestra y ejecuta el script Pig star-count de lab03.
#>
param(
    [string]$FullDatasetLocalPath = "data\shared\lab03\datasets\imdb-stars.tsv",
    [string]$SampleDatasetLocalPath = "data\shared\lab03\datasets\imdb-stars-test.tsv",
    [int]$SampleLines = 50000,
    [string]$InputHdfsPath = "/inputs/lab03/imdb-stars-test.tsv",
    [string]$OutputHdfsRoot = "/outputs/lab03",
    [switch]$SkipSampleRefresh
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
$basePigScriptPath = Join-Path $scriptDir "star-count.template.pig"
$runtimePigScriptPath = Join-Path $scriptDir "star-count.runtime.pig"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outputHdfsPath = ($OutputHdfsRoot.TrimEnd("/") + "/star-count-" + $timestamp)
$runLogPath = Join-Path $logsDir ($timestamp + "-starcount-run.log")
$previewPath = Join-Path $resultsDir ($timestamp + "-starcount-top20.txt")

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

if (-not (Test-Path $basePigScriptPath)) {
    $pigSource = tar -xOf $zipPath gdd-lab3/star-count.pig
    [System.IO.File]::WriteAllText($basePigScriptPath, ($pigSource -join [Environment]::NewLine), [System.Text.UTF8Encoding]::new($false))
}

if (-not $SkipSampleRefresh) {
    Get-Content $fullDatasetPath -TotalCount $SampleLines | Out-File -FilePath $sampleDatasetPath -Encoding utf8
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

$pigScript = Get-Content $basePigScriptPath -Raw
$pigScript = $pigScript.Replace("hdfs://cm:9000/uhadoop/shared/imdb/imdb-stars-test.tsv", "hdfs://master:9000$InputHdfsPath")
$pigScript = $pigScript.Replace("hdfs://cm:9000/uhadoop2026/cc66i/<suCarpeta>/imdb-stars-test/", "hdfs://master:9000$outputHdfsPath")
[System.IO.File]::WriteAllText($runtimePigScriptPath, $pigScript, [System.Text.UTF8Encoding]::new($false))

$pigCommand = @'
set -euo pipefail
hdfs dfs -mkdir -p /inputs/lab03
hdfs dfs -put -f /opt/bigdata/data/shared/lab03/datasets/imdb-stars-test.tsv "__INPUT_HDFS__"
hdfs dfs -rm -r -f "__OUTPUT_HDFS__" >/dev/null 2>&1 || true
pig -f /opt/bigdata/data/shared/lab03/scripts/star-count.runtime.pig
echo ---STARCOUNT-TOP20-BEGIN---
hdfs dfs -text "__OUTPUT_HDFS__/part-r-00000" | awk 'NR <= 20 { print }'
echo ---STARCOUNT-TOP20-END---
'@

$pigCommand = $pigCommand.Replace("__INPUT_HDFS__", $InputHdfsPath)
$pigCommand = $pigCommand.Replace("__OUTPUT_HDFS__", $outputHdfsPath)

$tempScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) ("run-lab03-starcount-" + $timestamp + ".sh")
[System.IO.File]::WriteAllText($tempScriptPath, $pigCommand, [System.Text.UTF8Encoding]::new($false))

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$global:LASTEXITCODE = 0
podman cp $tempScriptPath bigdata-master:/tmp/run-lab03-starcount.sh | Out-Null
$rawOutput = podman exec bigdata-master /bin/bash /tmp/run-lab03-starcount.sh 2>&1
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
$output | ForEach-Object { Write-Host $_ }

$previewLines = New-Object System.Collections.Generic.List[string]
$capturePreview = $false
foreach ($line in $output) {
    if ($line -eq "---STARCOUNT-TOP20-BEGIN---") {
        $capturePreview = $true
        continue
    }
    if ($line -eq "---STARCOUNT-TOP20-END---") {
        $capturePreview = $false
        continue
    }
    if ($capturePreview) {
        $previewLines.Add($line)
    }
}
$previewLines | Set-Content -LiteralPath $previewPath -Encoding UTF8

if ($exitCode -ne 0) {
    $errorSummary = $output |
        Where-Object {
            $_ -match 'ERROR \d+' -or
            $_ -match 'exception during parsing' -or
            $_ -match 'Failed to parse' -or
            $_ -match 'Invalid physical operators' -or
            $_ -match 'mismatched input'
        } |
        Select-Object -Last 3

    if (-not $errorSummary) {
        $errorSummary = $output | Select-Object -Last 10
    }

    $errorText = ($errorSummary -join [Environment]::NewLine)
    throw ("La ejecucion de star-count fallo.`n" +
        "Causa resumida:`n$errorText`n" +
        "Log local: $runLogPath")
}

Write-Host "Resultado HDFS: $outputHdfsPath"
Write-Host "Log local: $runLogPath"
Write-Host "Preview local: $previewPath"
