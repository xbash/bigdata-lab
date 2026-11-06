<#
Carga solo los datos base de Lab07 en Cassandra.
Excluye tablas personalizadas de alumnos y tablas derivadas del ejercicio.
#>
param(
    [string]$ContainerName = "bigdata-master",
    [string]$Keyspace = "cc66i",
    [string]$Table = "alumno",
    [int]$ReplicationFactor = 3
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
$datasetDir = Join-Path $root "data\shared\lab07\datasets"
$csvPath = Join-Path $datasetDir "alumno.csv"
$schemaPath = Join-Path $datasetDir "cc66i.schema.cql"

if (-not (Test-Path -LiteralPath $csvPath)) {
    throw "No existe el dataset base requerido: $csvPath"
}

if (-not (Test-Path -LiteralPath $schemaPath)) {
    throw "No existe el esquema exportado esperado: $schemaPath"
}

$containerRunning = podman inspect -f "{{.State.Running}}" $ContainerName 2>$null
if ($LASTEXITCODE -ne 0 -or (@($containerRunning)[0] -ne "true")) {
    throw "El contenedor $ContainerName no esta corriendo. Primero habilita el componente de Lab07."
}

$tableDefinition = @"
CREATE KEYSPACE IF NOT EXISTS $Keyspace WITH replication = {'class': 'SimpleStrategy', 'replication_factor': $ReplicationFactor};
USE $Keyspace;
CREATE TABLE IF NOT EXISTS $Table (
  usuario text PRIMARY KEY,
  color_fav text,
  comentario text,
  despierto boolean,
  edad int,
  nombre text,
  pelicula_fav text
);
"@

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$tempCqlPath = Join-Path ([System.IO.Path]::GetTempPath()) ("load-lab07-base-data-" + $timestamp + ".cql")
[System.IO.File]::WriteAllText($tempCqlPath, $tableDefinition, $utf8NoBom)

$containerCql = "/tmp/load-lab07-base-data.cql"
$containerCsv = "/tmp/alumno.csv"

try {
    podman cp $tempCqlPath ($ContainerName + ":" + $containerCql) | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "No fue posible copiar el archivo CQL al contenedor $ContainerName."
    }

    podman cp $csvPath ($ContainerName + ":" + $containerCsv) | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "No fue posible copiar el CSV base al contenedor $ContainerName."
    }

    $createOutput = podman exec $ContainerName /bin/bash -lc "cqlsh master -f $containerCql" 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Fallo la creacion/validacion de $Keyspace.$Table.`n$($createOutput -join [Environment]::NewLine)"
    }

    $copyCommand = "COPY $Keyspace.$Table (usuario, color_fav, comentario, despierto, edad, nombre, pelicula_fav) FROM '$containerCsv' WITH HEADER=TRUE;"
    $copyOutput = podman exec $ContainerName /bin/bash -lc "printf ""$copyCommand`n"" | cqlsh master" 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Fallo la carga de datos base en $Keyspace.$Table.`n$($copyOutput -join [Environment]::NewLine)"
    }

    $countCommand = "SELECT COUNT(*) FROM $Keyspace.$Table;"
    $countOutput = podman exec $ContainerName /bin/bash -lc "printf ""$countCommand`n"" | cqlsh master" 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "La validacion posterior a la carga fallo.`n$($countOutput -join [Environment]::NewLine)"
    }

    Write-Host "Carga base de Lab07 completada."
    Write-Host "Tabla cargada: $Keyspace.$Table"
    Write-Host "Origen: $csvPath"
    Write-Host ""
    $countOutput | ForEach-Object { Write-Host $_ }
} finally {
    Remove-Item -LiteralPath $tempCqlPath -Force -ErrorAction SilentlyContinue
}
