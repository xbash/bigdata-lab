<#
Detiene y baja el stack base junto con el overlay nosql-cassandra.
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
Write-Host "===== BAJANDO OVERLAY NOSQL-CASSANDRA ====="
Write-Host ""

podman compose @composeEnvArgs -f .\compose.yml -f .\compose.cassandra.yml down
