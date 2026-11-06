<#
Carga la base compartida de Lab08 en MongoDB.
Importa las colecciones base requeridas para comenzar el laboratorio.
#>
param(
    [string]$ContainerName = "bigdata-mongodb",
    [string]$Database = "tvdb",
    [switch]$ReplaceCollections
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = $utf8NoBom
[Console]::InputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$datasetDir = Join-Path $root "data\shared\lab08\datasets"
$seriesPath = Join-Path $datasetDir "series.json"
$crewPath = Join-Path $datasetDir "crew.json"

foreach ($path in @($seriesPath, $crewPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "No existe el dataset requerido: $path"
    }
}

$containerRunning = podman inspect -f "{{.State.Running}}" $ContainerName 2>$null
if ($LASTEXITCODE -ne 0 -or (@($containerRunning)[0] -ne "true")) {
    throw "El contenedor $ContainerName no esta corriendo. Primero habilita el componente de Lab08."
}

$containerDatasetDir = "/opt/bigdata/data/shared/lab08/datasets"
$seriesContainerPath = "$containerDatasetDir/series.json"
$crewContainerPath = "$containerDatasetDir/crew.json"
$dropFlag = if ($ReplaceCollections) { "--drop" } else { "" }

function Invoke-MongoImport {
    param(
        [string]$Collection,
        [string]$ContainerFile
    )

    $command = "mongoimport --quiet --db $Database --collection $Collection $dropFlag --file $ContainerFile --jsonArray"
    $output = podman exec $ContainerName /bin/bash -lc $command 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Fallo mongoimport para $Database.$Collection.`n$($output -join [Environment]::NewLine)"
    }
}

Invoke-MongoImport -Collection "series" -ContainerFile $seriesContainerPath
Invoke-MongoImport -Collection "crew" -ContainerFile $crewContainerPath

$countScript = @'
var dbx = db.getSiblingDB("__DB__");
print("series=" + dbx.series.countDocuments({}));
print("crew=" + dbx.crew.countDocuments({}));
'@
$countScript = $countScript.Replace("__DB__", $Database)
$countOutput = podman exec $ContainerName mongo --quiet --eval $countScript 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "La validacion posterior a la carga fallo.`n$($countOutput -join [Environment]::NewLine)"
}

Write-Host "Carga base de Lab08 completada."
Write-Host "Base: $Database"
Write-Host "Origen series: $seriesPath"
Write-Host "Origen crew: $crewPath"
Write-Host ""
$countOutput | ForEach-Object { Write-Host $_ }
