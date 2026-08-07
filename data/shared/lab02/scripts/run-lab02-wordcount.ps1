<#
Compila y ejecuta el WordCount de lab02 sobre HDFS local.
#>
param(
    [string]$InputLocalPath = "/opt/bigdata/data/shared/lab01/datasets/es-wiki-abstracts.txt.gz",
    [string]$InputHdfsPath = "/inputs/lab02/es-wiki-abstracts.txt.gz",
    [string]$OutputHdfsRoot = "/outputs/lab02"
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$workProjectPath = Join-Path $root "data\shared\lab02\work\gdd-hadoop"
$logsDir = Join-Path $root "data\shared\lab02\logs"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outputHdfsPath = ($OutputHdfsRoot.TrimEnd("/") + "/wordcount-" + $timestamp)
$runLogPath = Join-Path $logsDir ($timestamp + "-wordcount-run.log")
$top20Path = Join-Path $logsDir ($timestamp + "-wordcount-top20.txt")

if (-not (Test-Path -LiteralPath $workProjectPath)) {
    throw "No se encontro el proyecto de trabajo requerido: $workProjectPath"
}

if (-not (Test-Path -LiteralPath (Join-Path $workProjectPath "src\org\mdp\hadoop\cli\WordCount.java"))) {
    throw "No se encontro WordCount.java en el arbol de trabajo: $workProjectPath"
}

if (-not (Test-Path -LiteralPath (Join-Path $workProjectPath "src\org\mdp\hadoop\cli\LetterCount.java"))) {
    throw "No se encontro LetterCount.java en el arbol de trabajo: $workProjectPath"
}

New-Item -ItemType Directory -Force -Path $logsDir | Out-Null

$scriptBody = @'
set -euo pipefail
workdir="__WORKDIR__"
rm -rf "$workdir"
mkdir -p "$workdir"
cp -R /opt/bigdata/data/shared/lab02/work/gdd-hadoop "$workdir/"
cd "$workdir/gdd-hadoop"
test -f src/org/mdp/hadoop/cli/Main.java
test -f src/org/mdp/hadoop/cli/WordCount.java
test -f src/org/mdp/hadoop/cli/LetterCount.java
rm -rf bin dist
mkdir -p bin dist
javac -cp "$(hadoop classpath)" -d bin \
  src/org/mdp/hadoop/cli/Main.java \
  src/org/mdp/hadoop/cli/WordCount.java \
  src/org/mdp/hadoop/cli/LetterCount.java
jar cfe dist/gdd-hadoop.jar org.mdp.hadoop.cli.Main -C bin .
hdfs dfs -mkdir -p /inputs/lab02
hdfs dfs -put -f "__INPUT_LOCAL__" "__INPUT_HDFS__"
hdfs dfs -rm -r -f "__OUTPUT_HDFS__" >/dev/null 2>&1 || true
hadoop jar dist/gdd-hadoop.jar WordCount "__INPUT_HDFS__" "__OUTPUT_HDFS__"
echo ---WORDCOUNT-TOP20-BEGIN---
hdfs dfs -text "__OUTPUT_HDFS__/part-r-00000" | awk 'NR <= 20 { print }'
echo ---WORDCOUNT-TOP20-END---
echo ---WORDCOUNT-OUTPUT---
echo "__OUTPUT_HDFS__"
'@

$scriptBody = $scriptBody.Replace("__WORKDIR__", "/tmp/lab02-wordcount-" + $timestamp)
$scriptBody = $scriptBody.Replace("__INPUT_LOCAL__", $InputLocalPath)
$scriptBody = $scriptBody.Replace("__INPUT_HDFS__", $InputHdfsPath)
$scriptBody = $scriptBody.Replace("__OUTPUT_HDFS__", $outputHdfsPath)

$tempScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) ("run-lab02-wordcount-" + $timestamp + ".sh")
[System.IO.File]::WriteAllText($tempScriptPath, $scriptBody, [System.Text.UTF8Encoding]::new($false))

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$global:LASTEXITCODE = 0
podman cp $tempScriptPath bigdata-master:/tmp/run-lab02-wordcount.sh | Out-Null
$rawOutput = podman exec bigdata-master /bin/bash /tmp/run-lab02-wordcount.sh 2>&1
$exitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
Remove-Item -LiteralPath $tempScriptPath -Force -ErrorAction SilentlyContinue

$outputLines = @($rawOutput | ForEach-Object {
    if ($_ -is [System.Management.Automation.ErrorRecord]) {
        $_.ToString()
    } else {
        [string]$_
    }
})

$outputLines | Set-Content -LiteralPath $runLogPath -Encoding UTF8
$outputLines | ForEach-Object { Write-Host $_ }

$top20Lines = New-Object System.Collections.Generic.List[string]
$captureTop20 = $false
foreach ($line in $outputLines) {
    if ($line -eq "---WORDCOUNT-TOP20-BEGIN---") {
        $captureTop20 = $true
        continue
    }
    if ($line -eq "---WORDCOUNT-TOP20-END---") {
        $captureTop20 = $false
        continue
    }
    if ($captureTop20) {
        $top20Lines.Add($line)
    }
}
$top20Lines | Set-Content -LiteralPath $top20Path -Encoding UTF8

if ($exitCode -ne 0) {
    throw "run-lab02-wordcount.ps1 termino con codigo de salida $exitCode."
}

Write-Host "Resultado HDFS: $outputHdfsPath"
Write-Host "Log local: $runLogPath"
Write-Host "Top20 local: $top20Path"
