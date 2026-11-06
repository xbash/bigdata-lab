<#
Levanta en segundo plano el stack base de contenedores.
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
Write-Host "===== LEVANTANDO STACK BASE ====="
Write-Host ""

$dirs = @(
    "data\\namenode",
    "data\\datanode1",
    "data\\datanode2",
    "data\\datanode3",
    "data\\shared",
    "data\\outputs",
    "data\\hive",
    "data\\hue",
    "conf\\hue",
    "logs",
    "evidencia",
    "profiles\\sql-hive",
    "profiles\\ir",
    "profiles\\nosql-cassandra",
    "profiles\\nosql-mongodb",
    "profiles\\graph"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path (Join-Path $root $dir) | Out-Null
}

podman compose @composeEnvArgs -f .\compose.yml up -d
