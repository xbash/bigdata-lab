<#
Muestra el estado del stack base mas el overlay Spark.
#>
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $PSScriptRoot "common.ps1")
Set-Location $root
$composeEnvArgs = Get-ComposeEnvArgs -Root $root

Write-Host ""
Write-Host "===== ESTADO OVERLAY SPARK ====="

Write-Host "`n== podman compose ps (core + spark) =="
podman compose @composeEnvArgs -f .\compose.yml -f .\compose.spark.yml ps

Write-Host "`n== podman ps =="
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host "`n== spark processes (master) =="
try {
    podman exec bigdata-master /bin/bash -lc "jps | grep -E 'Master|Worker' || true"
} catch {
    Write-Warning "No fue posible consultar los procesos Spark en bigdata-master."
}

Write-Host "`n== spark master web (localhost:8080) =="
try {
    (Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:8080" -TimeoutSec 5).StatusCode
} catch {
    Write-Warning "No fue posible consultar Spark Master en http://localhost:8080"
}
