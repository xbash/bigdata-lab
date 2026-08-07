<#
Detiene y baja el stack base junto con todos los overlays operativos.
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
Write-Host "===== BAJANDO TODOS LOS CONTENEDORES ====="
Write-Host ""

podman compose @composeEnvArgs -f .\compose.yml -f .\compose.spark.yml -f .\compose.ir.yml -f .\compose.hive.yml -f .\compose.cassandra.yml down
