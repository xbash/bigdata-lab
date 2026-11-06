<#
Abre una shell interactiva dentro del contenedor HiveServer2 del overlay sql-hive.
#>
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

Write-Host ""
Write-Host "===== SHELL EN BIGDATA-HIVE-SERVER ====="
Write-Host ""

podman exec -it bigdata-hive-server /bin/bash
