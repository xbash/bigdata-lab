<#
Abre una shell interactiva dentro del contenedor master.
#>
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

Write-Host ""
Write-Host "===== SHELL EN BIGDATA-MASTER ====="
Write-Host ""

podman exec -it bigdata-master /bin/bash
