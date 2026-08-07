<#
Muestra el estado del stack base mas el overlay nosql-cassandra.
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
Write-Host "===== ESTADO OVERLAY NOSQL-CASSANDRA ====="

Write-Host "`n== podman compose ps (core + cassandra) =="
podman compose @composeEnvArgs -f .\compose.yml -f .\compose.cassandra.yml ps

Write-Host "`n== podman ps =="
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host "`n== nodetool status (master) =="
try {
    podman exec bigdata-master /bin/bash -lc "nodetool status"
} catch {
    Write-Warning "No fue posible ejecutar nodetool status en bigdata-master."
}

Write-Host "`n== cqlsh version (master) =="
try {
    podman exec bigdata-master /bin/bash -lc "cqlsh --version"
} catch {
    Write-Warning "No fue posible ejecutar cqlsh --version en bigdata-master."
}

Write-Host "`n== cassandra version (SHOW VERSION) =="
try {
    podman exec bigdata-master /bin/bash -lc "echo 'SHOW VERSION;' | cqlsh master"
} catch {
    Write-Warning "No fue posible consultar SHOW VERSION en bigdata-master."
}
