<#
Compila y ejecuta una tarea Spark del proyecto lab04 sobre el cluster local.
#>
param(
    [ValidateSet("WordCountTask", "AverageSeriesRating", "InfoSeriesRating")]
    [string]$Utility = "WordCountTask",
    [string]$InputLocalPath = "",
    [string]$InputHdfsPath = "",
    [string]$OutputHdfsRoot = "/outputs/lab04",
    [int]$PreviewLines = 20,
    [switch]$SkipPrepare
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$projectDir = Join-Path $root "data\shared\lab04\work\gdd-spark"
$buildFile = Join-Path $projectDir "build.xml"
$logsDir = Join-Path $root "data\shared\lab04\logs"
$resultsDir = Join-Path $root "data\shared\lab04\results"
$defaultWordCountInput = "/opt/bigdata/data/shared/lab01/datasets/es-wiki-abstracts-1k.txt"
$defaultWordCountHostInput = Join-Path $root "data\shared\lab01\datasets\es-wiki-abstracts-1k.txt"
$defaultAverageSeriesRatingInput = "/opt/bigdata/data/shared/lab04/datasets/imdb-ratings.tsv"
$defaultAverageSeriesRatingHostInput = Join-Path $root "data\shared\lab04\datasets\imdb-ratings.tsv"
$defaultInfoSeriesRatingInput = "/opt/bigdata/data/shared/lab04/datasets/imdb-ratings-two.tsv"
$defaultInfoSeriesRatingHostInput = Join-Path $root "data\shared\lab04\datasets\imdb-ratings-two.tsv"
$wordCountZipPath = Join-Path $root "data\shared\lab01\datasets\es-wiki-abstracts-1k.zip"
$averageSeriesRatingZipPath = Join-Path $root "data\shared\lab04\datasets\imdb-ratings.zip"
$infoSeriesRatingZipPath = Join-Path $root "data\shared\lab04\datasets\imdb-ratings-two.zip"

New-Item -ItemType Directory -Force -Path $logsDir, $resultsDir | Out-Null

function Expand-DatasetIfMissing {
    param(
        [string]$TargetPath,
        [string]$ZipPath,
        [string]$Description
    )

    if (Test-Path -LiteralPath $TargetPath) {
        return
    }

    if (-not (Test-Path -LiteralPath $ZipPath)) {
        throw "No se encontro el dataset $Description ni su ZIP fuente: $TargetPath | $ZipPath"
    }

    Write-Host "Extrayendo dataset $Description desde $ZipPath"
    tar -xf $ZipPath -C (Split-Path -Parent $TargetPath)

    if (-not (Test-Path -LiteralPath $TargetPath)) {
        throw "La extraccion del dataset $Description no genero el archivo esperado: $TargetPath"
    }
}

if (-not $SkipPrepare -and -not (Test-Path -LiteralPath $buildFile)) {
    & (Join-Path $PSScriptRoot "prepare-lab04.ps1")
}

if (-not (Test-Path -LiteralPath $buildFile)) {
    throw "No se encontro el proyecto preparado de lab04 en $projectDir"
}

if ([string]::IsNullOrWhiteSpace($InputLocalPath)) {
    if ($Utility -eq "WordCountTask") {
        $InputLocalPath = $defaultWordCountInput
    } elseif ($Utility -eq "AverageSeriesRating") {
        $InputLocalPath = $defaultAverageSeriesRatingInput
    } elseif ($Utility -eq "InfoSeriesRating") {
        $InputLocalPath = $defaultInfoSeriesRatingInput
    } else {
        throw "$Utility requiere un InputLocalPath explicito con un TSV compatible."
    }
}

if ([string]::IsNullOrWhiteSpace($InputHdfsPath)) {
    if ($Utility -eq "WordCountTask") {
        $InputHdfsPath = "/inputs/lab04/wordcount-input.txt"
    } else {
        $InputHdfsPath = "/inputs/lab04/average-series-rating.tsv"
    }
}

if ($InputLocalPath -eq $defaultWordCountInput) {
    Expand-DatasetIfMissing -TargetPath $defaultWordCountHostInput -ZipPath $wordCountZipPath -Description "lab01 sample"
} elseif ($InputLocalPath -eq $defaultAverageSeriesRatingInput) {
    Expand-DatasetIfMissing -TargetPath $defaultAverageSeriesRatingHostInput -ZipPath $averageSeriesRatingZipPath -Description "lab04 ratings"
} elseif ($InputLocalPath -eq $defaultInfoSeriesRatingInput) {
    Expand-DatasetIfMissing -TargetPath $defaultInfoSeriesRatingHostInput -ZipPath $infoSeriesRatingZipPath -Description "lab04 ratings-two"
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runId = $timestamp + "-" + $Utility.ToLowerInvariant()
$outputHdfsPath = ($OutputHdfsRoot.TrimEnd("/") + "/" + $Utility.ToLowerInvariant() + "-" + $timestamp)
$runLogPath = Join-Path $logsDir ($timestamp + "-" + $Utility.ToLowerInvariant() + "-run.log")
$previewPath = Join-Path $resultsDir ($timestamp + "-" + $Utility.ToLowerInvariant() + "-top" + $PreviewLines + ".txt")

$runCommand = @'
set -euo pipefail
workdir="__WORKDIR__"
rm -rf "$workdir"
mkdir -p "$workdir"
cp -R /opt/bigdata/data/shared/lab04/work/gdd-spark "$workdir/"
cd "$workdir/gdd-spark"
rm -rf bin dist
mkdir -p bin dist
javac -cp "lib/*" -d bin $(find src -name '*.java')
jar cfe dist/gdd-spark.jar org.mdp.spark.cli.Main -C bin .
hdfs dfs -mkdir -p "__INPUT_HDFS_DIR__"
hdfs dfs -put -f "__INPUT_LOCAL__" "__INPUT_HDFS__"
hdfs dfs -rm -r -f "__OUTPUT_HDFS__" >/dev/null 2>&1 || true
/opt/bigdata/spark/bin/spark-submit \
  --master spark://master:7077 \
  --class org.mdp.spark.cli.Main \
  dist/gdd-spark.jar \
  "__UTILITY__" \
  "__INPUT_HDFS__" \
  "__OUTPUT_HDFS__"
echo ---LAB04-PREVIEW-BEGIN---
hdfs dfs -text "__OUTPUT_HDFS__/part-*" | awk 'NR <= __PREVIEW_LINES__ { print }'
echo ---LAB04-PREVIEW-END---
'@

$inputHdfsDir = [System.IO.Path]::GetDirectoryName($InputHdfsPath.Replace("/", "\")).Replace("\", "/")
$runCommand = $runCommand.Replace("__INPUT_LOCAL__", $InputLocalPath)
$runCommand = $runCommand.Replace("__INPUT_HDFS__", $InputHdfsPath)
$runCommand = $runCommand.Replace("__INPUT_HDFS_DIR__", $inputHdfsDir)
$runCommand = $runCommand.Replace("__OUTPUT_HDFS__", $outputHdfsPath)
$runCommand = $runCommand.Replace("__WORKDIR__", "/tmp/lab04-work-" + $runId)
$runCommand = $runCommand.Replace("__UTILITY__", $Utility)
$runCommand = $runCommand.Replace("__PREVIEW_LINES__", $PreviewLines.ToString())

$tempScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) ("run-lab04-" + $timestamp + ".sh")
[System.IO.File]::WriteAllText($tempScriptPath, $runCommand, [System.Text.UTF8Encoding]::new($false))

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$global:LASTEXITCODE = 0
podman cp $tempScriptPath bigdata-master:/tmp/run-lab04.sh | Out-Null
$rawOutput = podman exec bigdata-master /bin/bash /tmp/run-lab04.sh 2>&1
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

$previewLinesOutput = New-Object System.Collections.Generic.List[string]
$capturePreview = $false
foreach ($line in $output) {
    if ($line -eq "---LAB04-PREVIEW-BEGIN---") {
        $capturePreview = $true
        continue
    }
    if ($line -eq "---LAB04-PREVIEW-END---") {
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
        $previewLinesOutput.Add($normalizedLine)
    }
}
$previewLinesOutput | Set-Content -LiteralPath $previewPath -Encoding UTF8

if ($exitCode -ne 0) {
    throw ("run-lab04.ps1 termino con codigo de salida $exitCode.`n" +
        "Log local: $runLogPath")
}

Write-Host "Resultado HDFS: $outputHdfsPath"
Write-Host "Log local: $runLogPath"
Write-Host "Preview local: $previewPath"
