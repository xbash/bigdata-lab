<#
Levanta el stack base junto con el overlay nosql-mongodb de lab08.
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
Write-Host "===== LEVANTANDO OVERLAY NOSQL-MONGODB ====="
Write-Host ""

$dirs = @(
    "profiles\\nosql-mongodb",
    "data\\shared\\lab08\\scripts",
    "data\\shared\\lab08\\results",
    "data\\shared\\lab08\\notes",
    "data\\shared\\lab08\\datasets"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path (Join-Path $root $dir) | Out-Null
}

podman compose @composeEnvArgs -f .\compose.yml -f .\compose.mongodb.yml up -d
