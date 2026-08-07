<#
Levanta el stack base junto con el overlay nosql-cassandra.
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
Write-Host "===== LEVANTANDO OVERLAY NOSQL-CASSANDRA ====="
Write-Host ""

$dirs = @(
    "profiles\\nosql-cassandra",
    "data\\shared\\lab07\\scripts",
    "data\\shared\\lab07\\results",
    "data\\shared\\lab07\\notes"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path (Join-Path $root $dir) | Out-Null
}

podman compose @composeEnvArgs -f .\compose.yml -f .\compose.cassandra.yml up -d
