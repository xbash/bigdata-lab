<#
Abre una shell interactiva dentro del contenedor sql-ui del overlay sql-hive.
#>
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

Write-Host ""
Write-Host "===== SHELL EN BIGDATA-SQL-UI ====="
Write-Host ""

podman exec -it bigdata-sql-ui /bin/bash
