<#
Muestra el estado del stack base mas el overlay nosql-mongodb.
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
Write-Host "===== ESTADO OVERLAY NOSQL-MONGODB ====="

Write-Host "`n== podman compose ps (core + mongodb) =="
podman compose @composeEnvArgs -f .\compose.yml -f .\compose.mongodb.yml ps

Write-Host "`n== podman ps =="
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host "`n== mongo ping (bigdata-mongodb) =="
try {
    podman exec bigdata-mongodb mongo --quiet --eval "db.adminCommand({ ping: 1 })"
} catch {
    Write-Warning "No fue posible ejecutar el ping de MongoDB en bigdata-mongodb."
}

Write-Host "`n== show dbs (bigdata-mongodb) =="
try {
    podman exec bigdata-mongodb mongo --quiet --eval "show dbs"
} catch {
    Write-Warning "No fue posible listar las bases de datos en bigdata-mongodb."
}
