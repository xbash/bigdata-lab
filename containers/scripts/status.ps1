<#
Muestra el estado actual del stack base y de los contenedores Podman.
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
Write-Host "===== ESTADO DEL STACK BASE ====="

Write-Host "`n== podman compose ps =="
podman compose @composeEnvArgs -f .\compose.yml ps

Write-Host "`n== podman ps =="
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
