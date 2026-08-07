<#
Abre una shell interactiva de MongoDB dentro del contenedor del overlay.
#>
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

Write-Host ""
Write-Host "===== SHELL MONGODB EN BIGDATA-MONGODB ====="
Write-Host ""

podman exec -it bigdata-mongodb mongo
