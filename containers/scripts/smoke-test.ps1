<#
Ejecuta chequeos operativos del stack y opcionalmente jobs reales.
#>
param(
    [switch]$IncludeRealJobs
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$evidenceDir = Join-Path $root "evidencia"
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outFile = Join-Path $evidenceDir ("smoke-test-" + $timestamp + ".log")

function Invoke-And-Log {
    param(
        [string]$Title,
        [scriptblock]$Command
    )

    Add-Content -Path $outFile -Value ("`n== " + $Title + " ==")
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $global:LASTEXITCODE = 0
    $rawOutput = & $Command 2>&1
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorActionPreference
    $output = @($rawOutput | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            $_.ToString()
        } else {
            [string]$_
        }
    })
    $output | Out-File -FilePath $outFile -Append -Encoding utf8
    if ($exitCode -ne 0) {
        throw "El comando '$Title' termino con codigo de salida $exitCode."
    }
    $output | ForEach-Object { Write-Host $_ }
}

Invoke-And-Log -Title "podman ps" -Command { podman ps --format "table {{.Names}}\t{{.Status}}" }
Invoke-And-Log -Title "master jps" -Command { podman exec bigdata-master jps }
Invoke-And-Log -Title "worker1 jps" -Command { podman exec bigdata-worker1 jps }
Invoke-And-Log -Title "hdfs report" -Command { podman exec bigdata-master hdfs dfsadmin -report }
Invoke-And-Log -Title "mkdir smoke" -Command { podman exec bigdata-master hdfs dfs -mkdir -p /smoke-test }
Invoke-And-Log -Title "ls root" -Command { podman exec bigdata-master hdfs dfs -ls / }
Invoke-And-Log -Title "spark version" -Command { podman exec bigdata-master /bin/bash -lc "spark-submit --version > /tmp/spark-version.txt 2>&1 || true; cat /tmp/spark-version.txt" }
Invoke-And-Log -Title "pig version" -Command { podman exec bigdata-master /bin/bash -lc "pig -version > /tmp/pig-version.txt 2>&1 || true; cat /tmp/pig-version.txt" }

if ($IncludeRealJobs) {
    $sparkSubmitRaw = podman exec bigdata-master /bin/bash -lc 'command -v spark-submit 2>/dev/null || true'
    $sparkSubmit = [string]($sparkSubmitRaw | Select-Object -First 1)
    if ($sparkSubmit) {
        $sparkSubmit = $sparkSubmit.Trim()
    }
    if ($sparkSubmit) {
        Invoke-And-Log -Title "spark pi" -Command { & (Join-Path $PSScriptRoot "run-spark-smoke.ps1") }
    } else {
        Add-Content -Path $outFile -Value "`n== spark pi ==`nSKIPPED: Spark overlay no activo."
        Write-Warning "Se omite SparkPi porque el overlay Spark no esta activo."
    }
    Invoke-And-Log -Title "lab02 wordcount" -Command { & (Join-Path $root "data\shared\lab02\scripts\run-lab02-wordcount.ps1") }
    Invoke-And-Log -Title "lab03 star-count" -Command { & (Join-Path $root "data\shared\lab03\scripts\run-lab03-starcount.ps1") }
}

Write-Host "Smoke test registrado en $outFile"
