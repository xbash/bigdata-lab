<#
Extrae el proyecto fuente de lab05 desde el ZIP del curso.
#>
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$zipPath = Join-Path $root "data\shared\lab05\docs\gdd_lab05.zip"
$workDir = Join-Path $root "data\shared\lab05\work"
$projectDir = Join-Path $workDir "gdd-elastic"

if (-not (Test-Path -LiteralPath $zipPath)) {
    throw "No se encontro el ZIP requerido del laboratorio: $zipPath"
}

if ((Test-Path $projectDir) -and (-not $Force)) {
    Write-Host "Proyecto ya extraido en $projectDir"
    Write-Host "Use -Force si quiere recrearlo desde el ZIP."
    exit 0
}

if (Test-Path $workDir) {
    Remove-Item -Recurse -Force $workDir
}

New-Item -ItemType Directory -Force -Path $workDir | Out-Null
tar -xf $zipPath -C $workDir

Write-Host "Proyecto de lab05 extraido en $projectDir"
Write-Host "Dataset de muestra esperado: data/shared/lab05/datasets/es-wiki-articles-1k.tsv.gz"
