<#
Levanta el stack base junto con el overlay IR de lab05.
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
Write-Host "===== LEVANTANDO OVERLAY IR ====="
Write-Host ""

$dirs = @(
    "conf\\elasticsearch",
    "data\\shared\\lab05\\work",
    "data\\shared\\lab05\\results",
    "data\\shared\\lab05\\notes"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path (Join-Path $root $dir) | Out-Null
}

podman compose @composeEnvArgs -f .\compose.yml -f .\compose.ir.yml up -d
