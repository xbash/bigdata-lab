<#
Abre una shell interactiva dentro del contenedor Elasticsearch del overlay IR.
#>
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

Write-Host ""
Write-Host "===== SHELL EN BIGDATA-ELASTICSEARCH ====="
Write-Host ""

podman exec -it bigdata-elasticsearch /bin/bash
