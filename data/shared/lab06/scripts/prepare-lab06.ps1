<#
Extrae el proyecto fuente de lab06, prepara datasets locales y deja lista la integracion con lab05.
#>
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$zipPath = Join-Path $root "data\shared\lab06\docs\gdd_lab06.zip"
$workDir = Join-Path $root "data\shared\lab06\work"
$projectDir = Join-Path $workDir "gdd-giraph"
$sampleDir = Join-Path $root "data\shared\lab06\datasets"
$samplePath = Join-Path $sampleDir "pr-ex-local.tsv"
$realDatasetPath = Join-Path $sampleDir "es-wiki-links.tsv.gz"
$lab06ResultsDir = Join-Path $root "data\shared\lab06\results"
$lab06NotesDir = Join-Path $root "data\shared\lab06\notes"
$lab06IntegrationDir = Join-Path $lab06ResultsDir "lab05-rank-integration"
$ranksSortedLocalPath = Join-Path $lab06IntegrationDir "ranks.s.tsv"
$rankIntegrationReadmePath = Join-Path $lab06IntegrationDir "README_PREPARACION.md"
$lab05ProjectDir = Join-Path $root "data\shared\lab05\work\gdd-elastic"
$lab05BuildFile = Join-Path $lab05ProjectDir "build.xml"
$lab05DatasetSamplePath = Join-Path $root "data\shared\lab05\datasets\es-wiki-articles-1k.tsv.gz"

if (-not (Test-Path -LiteralPath $zipPath)) {
    throw "No se encontro el ZIP requerido del laboratorio: $zipPath"
}

if (-not (Test-Path -LiteralPath $lab05BuildFile)) {
    & (Join-Path $root "data\shared\lab05\scripts\prepare-lab05.ps1")
}

if (-not (Test-Path -LiteralPath $lab05BuildFile)) {
    throw "No se encontro el proyecto preparado de lab05 en $lab05ProjectDir"
}

if ((Test-Path $projectDir) -and (-not $Force)) {
    Write-Host "Proyecto ya extraido en $projectDir"
} else {
    if (Test-Path $workDir) {
        Remove-Item -Recurse -Force $workDir
    }

    New-Item -ItemType Directory -Force -Path $workDir | Out-Null
    tar -xf $zipPath -C $workDir
}

if (-not (Test-Path -LiteralPath $sampleDir)) {
    New-Item -ItemType Directory -Force -Path $sampleDir | Out-Null
}

foreach ($dir in @($lab06ResultsDir, $lab06NotesDir, $lab06IntegrationDir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

$sampleContent = @(
    "a`tb"
    "a`tc"
    "b`tc"
    "c`ta"
    "d`tc"
) -join "`n"

[System.IO.File]::WriteAllText($samplePath, $sampleContent + "`n", [System.Text.UTF8Encoding]::new($false))

$integrationReadme = @"
# Preparacion local de integracion lab06 -> lab05

- Proyecto de PageRank preparado en:
  - $projectDir
- Proyecto de busqueda/indexacion de lab05 preparado en:
  - $lab05ProjectDir
- Dataset pequeno de smoke de lab06:
  - $samplePath
- Dataset real detectado:
  - $realDatasetPath
- Dataset de muestra de lab05 detectado:
  - $lab05DatasetSamplePath
- Archivo local esperado para ranks ordenados:
  - $ranksSortedLocalPath

Flujo previsto segun el PDF:
1. Ejecutar PageRank y SortByRank.
2. Copiar el resultado ordenado a `ranks.s.tsv`.
3. Reindexar los documentos de lab05 usando esos ranks.
4. Comparar busquedas con y sin rank.
"@

[System.IO.File]::WriteAllText($rankIntegrationReadmePath, $integrationReadme.TrimStart() + "`n", [System.Text.UTF8Encoding]::new($false))

Write-Host "Proyecto de lab06 extraido en $projectDir"
Write-Host "Dataset local de smoke preparado en $samplePath"
if (Test-Path -LiteralPath $realDatasetPath) {
    Write-Host "Dataset real detectado en $realDatasetPath"
} else {
    Write-Warning "No se encontro el dataset real esperado de lab06: $realDatasetPath"
}
if (Test-Path -LiteralPath $lab05DatasetSamplePath) {
    Write-Host "Dataset de muestra de lab05 detectado en $lab05DatasetSamplePath"
} else {
    Write-Warning "No se encontro el dataset de muestra esperado de lab05: $lab05DatasetSamplePath"
}
Write-Host "Integracion local con lab05 preparada en $lab06IntegrationDir"
Write-Host "Ruta prevista para ranks ordenados: $ranksSortedLocalPath"
