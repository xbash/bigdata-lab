<#
Extrae el proyecto fuente de lab04 desde el ZIP del curso.
#>
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$zipPath = Join-Path $root "data\shared\lab04\docs\gdd_lab04.zip"
$workDir = Join-Path $root "data\shared\lab04\work"
$projectDir = Join-Path $workDir "gdd-spark"
$buildFile = Join-Path $projectDir "build.xml"

if (-not (Test-Path -LiteralPath $zipPath)) {
    throw "No se encontro el ZIP requerido del laboratorio: $zipPath"
}

if ((Test-Path -LiteralPath $projectDir) -and (-not $Force)) {
    Write-Host "Proyecto ya extraido en $projectDir"
    Write-Host "Use -Force si quiere recrearlo desde el ZIP."
    exit 0
}

if (Test-Path -LiteralPath $workDir) {
    Remove-Item -LiteralPath $workDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $workDir | Out-Null
tar -xf $zipPath -C $workDir

if (-not (Test-Path -LiteralPath $buildFile)) {
    throw "La extraccion de lab04 no produjo el archivo esperado: $buildFile"
}

Write-Host "Proyecto de lab04 extraido en $projectDir"
