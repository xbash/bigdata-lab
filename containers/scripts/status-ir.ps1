<#
Muestra el estado del stack base mas el overlay IR y consulta Elasticsearch.
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
Write-Host "===== ESTADO OVERLAY IR ====="

Write-Host "`n== podman compose ps (core + ir) =="
podman compose @composeEnvArgs -f .\compose.yml -f .\compose.ir.yml ps

Write-Host "`n== podman ps =="
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host "`n== elasticsearch health (localhost:9200) =="
try {
    (Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:9200/_cat/health?v" -TimeoutSec 5).Content
} catch {
    Write-Warning "No fue posible consultar Elasticsearch en http://localhost:9200"
}

Write-Host "`n== elasticsearch nodes (localhost:9200) =="
try {
    (Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:9200/_cat/nodes?v" -TimeoutSec 5).Content
} catch {
    Write-Warning "No fue posible consultar los nodos de Elasticsearch."
}
