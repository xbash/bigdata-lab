<#
Compila y ejecuta el LetterCount de lab02 sobre HDFS local,
usando como entrada la salida previa de WordCount.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$WordCountInputHdfsPath,
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
$resultsDir = Join-Path $root "data\shared\lab02\results"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outputHdfsPath = ($OutputHdfsRoot.TrimEnd("/") + "/lettercount-" + $timestamp)
$runLogPath = Join-Path $logsDir ($timestamp + "-lettercount-run.log")
$azPath = Join-Path $resultsDir ($timestamp + "-lettercount-a-z.txt")

if (-not (Test-Path -LiteralPath $workProjectPath)) {
    throw "No se encontro el proyecto de trabajo requerido: $workProjectPath"
}

if (-not (Test-Path -LiteralPath (Join-Path $workProjectPath "src\org\mdp\hadoop\cli\WordCount.java"))) {
    throw "No se encontro WordCount.java en el arbol de trabajo: $workProjectPath"
}

if (-not (Test-Path -LiteralPath (Join-Path $workProjectPath "src\org\mdp\hadoop\cli\LetterCount.java"))) {
    throw "No se encontro LetterCount.java en el arbol de trabajo: $workProjectPath"
}

New-Item -ItemType Directory -Force -Path $logsDir, $resultsDir | Out-Null

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
hdfs dfs -test -e "__WORDCOUNT_INPUT__"
rm -rf bin dist
mkdir -p bin dist
javac -cp "$(hadoop classpath)" -d bin \
  src/org/mdp/hadoop/cli/Main.java \
  src/org/mdp/hadoop/cli/WordCount.java \
  src/org/mdp/hadoop/cli/LetterCount.java
jar cfe dist/gdd-hadoop.jar org.mdp.hadoop.cli.Main -C bin .
hdfs dfs -rm -r -f "__OUTPUT_HDFS__" >/dev/null 2>&1 || true
hadoop jar dist/gdd-hadoop.jar LetterCount "__WORDCOUNT_INPUT__" "__OUTPUT_HDFS__"
echo ---LETTERCOUNT-AZ-BEGIN---
hdfs dfs -text "__OUTPUT_HDFS__/part-r-00000" | awk -F '\t' '$1 ~ /^[a-z]$/ { print }' | sort | awk 'NR <= 26 { print }'
echo ---LETTERCOUNT-AZ-END---
echo ---LETTERCOUNT-OUTPUT---
echo "__OUTPUT_HDFS__"
'@

$scriptBody = $scriptBody.Replace("__WORKDIR__", "/tmp/lab02-lettercount-" + $timestamp)
$scriptBody = $scriptBody.Replace("__WORDCOUNT_INPUT__", $WordCountInputHdfsPath)
$scriptBody = $scriptBody.Replace("__OUTPUT_HDFS__", $outputHdfsPath)

$tempScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) ("run-lab02-lettercount-" + $timestamp + ".sh")
[System.IO.File]::WriteAllText($tempScriptPath, $scriptBody, [System.Text.UTF8Encoding]::new($false))

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$global:LASTEXITCODE = 0
podman cp $tempScriptPath bigdata-master:/tmp/run-lab02-lettercount.sh | Out-Null
$rawOutput = podman exec bigdata-master /bin/bash /tmp/run-lab02-lettercount.sh 2>&1
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

$azLines = New-Object System.Collections.Generic.List[string]
$captureAz = $false
foreach ($line in $outputLines) {
    if ($line -eq "---LETTERCOUNT-AZ-BEGIN---") {
        $captureAz = $true
        continue
    }
    if ($line -eq "---LETTERCOUNT-AZ-END---") {
        $captureAz = $false
        continue
    }
    if ($captureAz) {
        $azLines.Add($line)
    }
}
$azLines | Set-Content -LiteralPath $azPath -Encoding UTF8

if ($exitCode -ne 0) {
    throw "run-lab02-lettercount.ps1 termino con codigo de salida $exitCode."
}

Write-Host "Resultado HDFS: $outputHdfsPath"
Write-Host "Log local: $runLogPath"
Write-Host "Resultados a-z locales: $azPath"
