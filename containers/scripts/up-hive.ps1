<#
Levanta el stack base junto con el overlay sql-hive.
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
Write-Host "===== LEVANTANDO OVERLAY SQL-HIVE ====="
Write-Host ""

$dirs = @(
    "conf\\hive",
    "conf\\hue",
    "data\\hive\\warehouse",
    "data\\hue",
    "profiles\\sql-hive"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path (Join-Path $root $dir) | Out-Null
}

podman compose @composeEnvArgs -f .\compose.yml -f .\compose.hive.yml up -d
