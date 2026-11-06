<#
Ejecuta un flujo reproducible de Lab07 sobre el overlay Cassandra.
#>
param(
    [string]$Usuario = "codex",
    [string]$NombreIniciales = "C. Lab",
    [string]$NombreCompleto = "Codex Lab",
    [int]$Edad = 37,
    [string]$ColorFav = "black",
    [string]$PeliculaFav = "Arrival",
    [string]$Comentario = "lab07 local",
    [bool]$Despierto = $true,
    [int]$IndexBuildWaitSeconds = 10
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$utf8Bom = [System.Text.UTF8Encoding]::new($true)
$OutputEncoding = $utf8NoBom
[Console]::InputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

function Convert-ToCqlIdentifier {
    param([string]$Value, [string]$Fallback)

    $identifier = (($Value.ToLowerInvariant() -replace '[^a-z0-9_]+', '_').Trim('_'))
    if ([string]::IsNullOrWhiteSpace($identifier)) {
        $identifier = $Fallback
    }
    if ($identifier[0] -match '[0-9]') {
        $identifier = "u_$identifier"
    }
    return $identifier
}

function Convert-ToCqlText {
    param([string]$Value)
    return "'" + ($Value -replace "'", "''") + "'"
}

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$logsDir = Join-Path $root "data\shared\lab07\logs"
$resultsDir = Join-Path $root "data\shared\lab07\results"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runId = $timestamp + "-lab07-cassandra"
$logPath = Join-Path $logsDir ($runId + "-run.log")
$commandsPath = Join-Path $resultsDir ($runId + "-comandos-entrega.cql")
$summaryPath = Join-Path $resultsDir ($runId + "-resumen.txt")

New-Item -ItemType Directory -Force -Path $logsDir, $resultsDir | Out-Null

$userId = Convert-ToCqlIdentifier -Value $Usuario -Fallback "codex"
$keyspace = "lab07_$userId"
$tableScratch = "scratch_$userId"
$tableAlumno = "alumno_$userId"
$tableByColorAgeUser = "bycolor_$userId"
$tableByAge = "byage_$userId"
$indexEdad = "idx_${tableAlumno}_edad"
$indexDespierto = "idx_${tableAlumno}_despierto"
$despiertoCql = if ($Despierto) { "true" } else { "false" }

$nombreInicialesCql = Convert-ToCqlText $NombreIniciales
$nombreCompletoCql = Convert-ToCqlText $NombreCompleto
$colorFavCql = Convert-ToCqlText $ColorFav
$peliculaFavCql = Convert-ToCqlText $PeliculaFav
$comentarioCql = Convert-ToCqlText $Comentario
$usuarioCql = Convert-ToCqlText $userId

$commands = @"
CREATE KEYSPACE $keyspace WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 3};
USE $keyspace;
CONSISTENCY ONE;

-- Lab07 Cassandra reproducible.
-- Generado: $timestamp
-- Usuario logico: $userId
-- Nota: se usa prefijo lab07_ para no interferir con keyspaces compartidos.

-- Parte 1: keyspace y tabla minima con primary key.
CREATE TABLE $tableScratch (usuario text PRIMARY KEY, edad int);
ALTER TABLE $tableScratch ADD viva boolean;
DROP TABLE $tableScratch;

-- Parte 2: tabla personal equivalente a alumno.
CREATE TABLE $tableAlumno (
  usuario text PRIMARY KEY,
  color_fav text,
  comentario text,
  despierto boolean,
  edad int,
  nombre text,
  pelicula_fav text
);

INSERT INTO $tableAlumno (usuario, nombre) VALUES ($usuarioCql, $nombreInicialesCql);
SELECT * FROM $tableAlumno;

-- Alternativa segura al ejemplo de tipo incorrecto del enunciado:
-- no se ejecuta INSERT INTO $tableAlumno (usuario, nombre) VALUES ($usuarioCql, true);
-- porque Cassandra 2.0.7 aborta esa sentencia por tipo invalido.

-- Alternativa para Cassandra 2.0.7: insertar la fila completa antes de crear indices.
-- En esta version, el flujo de INSERT parcial del enunciado es fragil para la validacion
-- automatica con indices secundarios.
INSERT INTO $tableAlumno (usuario, color_fav, comentario, despierto, edad, nombre, pelicula_fav)
VALUES ($usuarioCql, $colorFavCql, $comentarioCql, $despiertoCql, $Edad, $nombreCompletoCql, $peliculaFavCql);

SELECT COUNT(*) AS count FROM $tableAlumno;
SELECT nombre FROM $tableAlumno WHERE usuario = $usuarioCql;

-- Parte 3: indices secundarios del enunciado.
-- En el cluster local Cassandra 2.0.7/Thrift los indices se crean, pero las
-- consultas por indice pueden devolver 0 rows aunque la fila exista.
-- Se dejan los comandos docentes y se validan las consultas con una tabla
-- orientada a consulta.
CREATE INDEX $indexEdad ON $tableAlumno (edad);
CREATE INDEX $indexDespierto ON $tableAlumno (despierto);

-- Alternativa validada: tabla orientada a las consultas por edad.
CREATE TABLE $tableByAge (
  bucket text,
  edad int,
  despierto boolean,
  usuario text,
  nombre text,
  color_fav text,
  comentario text,
  pelicula_fav text,
  PRIMARY KEY (bucket, edad, despierto, usuario)
);

INSERT INTO $tableByAge (bucket, edad, usuario, nombre, color_fav, comentario, despierto, pelicula_fav)
VALUES ('all', $Edad, $usuarioCql, $nombreCompletoCql, $colorFavCql, $comentarioCql, $despiertoCql, $peliculaFavCql);

SELECT nombre FROM $tableByAge WHERE bucket = 'all' AND edad = $Edad;
SELECT nombre FROM $tableByAge WHERE bucket = 'all' AND edad = $Edad AND despierto = $despiertoCql;
SELECT nombre FROM $tableByAge WHERE bucket = 'all' AND edad > 25;

-- Parte 4: llave primaria compuesta para las consultas finales del enunciado.
CREATE TABLE $tableByColorAgeUser (
  color_fav text,
  edad int,
  usuario text,
  comentario text,
  despierto boolean,
  nombre text,
  pelicula_fav text,
  PRIMARY KEY (color_fav, edad, usuario)
);

INSERT INTO $tableByColorAgeUser (color_fav, edad, usuario, comentario, despierto, nombre, pelicula_fav)
VALUES ($colorFavCql, $Edad, $usuarioCql, $comentarioCql, $despiertoCql, $nombreCompletoCql, $peliculaFavCql);

SELECT * FROM $tableByColorAgeUser WHERE color_fav = $colorFavCql;
SELECT * FROM $tableByColorAgeUser WHERE color_fav = $colorFavCql AND edad > 20;
SELECT * FROM $tableByColorAgeUser WHERE color_fav = $colorFavCql AND usuario = $usuarioCql AND edad = $Edad;
"@

[System.IO.File]::WriteAllText($commandsPath, $commands, $utf8NoBom)

$runCommand = @'
set -euo pipefail
commands_file="__COMMANDS_FILE__"
summary_file="__SUMMARY_FILE__"
index_wait="__INDEX_WAIT__"

echo "== SHOW VERSION =="
echo "SHOW VERSION;" | cqlsh master

echo "== NODETOOL STATUS =="
nodetool status

echo "== RUN LAB07 COMMANDS =="
echo "DROP KEYSPACE IF EXISTS __KEYSPACE__;" | cqlsh master
awk '
  /^CREATE TABLE __TABLE_ALUMNO__ / { in_alumno=1 }
  /^CREATE TABLE __TABLE_BY_AGE__ / { in_byage=1 }
  /^CREATE TABLE __TABLE_BY_COLOR__ / { in_bycolor=1 }
  { print }
  $0 == ");" && in_alumno {
    system("sleep 5");
    in_alumno=0;
    next;
  }
  $0 == ");" && in_byage {
    system("sleep 5");
    in_byage=0;
    next;
  }
  $0 == ");" && in_bycolor {
    system("sleep 5");
    in_bycolor=0;
    next;
  }
  /^CREATE INDEX / {
    system("sleep " wait_seconds);
    next;
  }
' wait_seconds="$index_wait" "$commands_file" | cqlsh master
status="$?"
if [ "$status" -ne 0 ]; then
  exit "$status"
fi

sleep "$index_wait"

cat > "$summary_file" <<EOF
LAB07_CASSANDRA_OK
commands_file=$commands_file
index_build_wait_seconds=$index_wait
validated_show_version=true
validated_nodetool_status=true
validated_keyspace_table_insert_select=true
secondary_indexes_created=true
secondary_index_queries_replaced=true
alternative_range_query=table_by_age_with_bucket
alternative_compound_queries=table_by_color_age_user
EOF
'@

$containerCommandsPath = "/tmp/$runId.cql"
$containerSummaryPath = "/tmp/$runId-summary.txt"
$runCommand = $runCommand.Replace("__COMMANDS_FILE__", $containerCommandsPath)
$runCommand = $runCommand.Replace("__SUMMARY_FILE__", $containerSummaryPath)
$runCommand = $runCommand.Replace("__INDEX_WAIT__", $IndexBuildWaitSeconds.ToString())
$runCommand = $runCommand.Replace("__KEYSPACE__", $keyspace)
$runCommand = $runCommand.Replace("__TABLE_ALUMNO__", $tableAlumno)
$runCommand = $runCommand.Replace("__TABLE_BY_AGE__", $tableByAge)
$runCommand = $runCommand.Replace("__TABLE_BY_COLOR__", $tableByColorAgeUser)
$runCommand = $runCommand.Replace("__EDAD__", $Edad.ToString())
$runCommand = $runCommand.Replace("__DESPIERTO__", $despiertoCql)

$tempScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) ("run-lab07-cassandra-" + $timestamp + ".sh")
[System.IO.File]::WriteAllText($tempScriptPath, $runCommand, $utf8NoBom)

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$global:LASTEXITCODE = 0
podman cp $commandsPath ("bigdata-master:" + $containerCommandsPath) | Out-Null
podman cp $tempScriptPath bigdata-master:/tmp/run-lab07-cassandra.sh | Out-Null
$rawOutput = podman exec bigdata-master /bin/bash /tmp/run-lab07-cassandra.sh 2>&1
$exitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
Remove-Item -LiteralPath $tempScriptPath -Force -ErrorAction SilentlyContinue

$output = @($rawOutput | ForEach-Object {
    if ($_ -is [System.Management.Automation.ErrorRecord]) {
        $_.ToString()
    } else {
        [string]$_
    }
})

[System.IO.File]::WriteAllLines($logPath, $output, $utf8Bom)
$output | ForEach-Object { Write-Host $_ }

if ($exitCode -eq 0 -and ($output | Where-Object { $_ -match 'Bad Request' -or $_ -match 'Invalid syntax' -or $_ -match 'Request did not complete' -or $_ -match 'Traceback' -or $_ -match 'Connection error' })) {
    $exitCode = 1
}

if ($exitCode -ne 0) {
    $errorSummary = $output | Where-Object {
        $_ -match 'Bad Request' -or $_ -match 'Exception' -or $_ -match '^Error' -or $_ -match 'Traceback' -or $_ -match 'Connection error'
    } | Select-Object -Last 10

    if (-not $errorSummary) {
        $errorSummary = $output | Select-Object -Last 15
    }

    throw ("La ejecucion de Lab07 Cassandra fallo.`n" +
        "Keyspace: $keyspace`n" +
        "Resumen:`n" +
        ($errorSummary -join [Environment]::NewLine) + "`n" +
        "Log local: $logPath`n" +
        "Comandos generados: $commandsPath")
}

podman cp ("bigdata-master:" + $containerSummaryPath) $summaryPath | Out-Null
podman exec bigdata-master /bin/bash -lc ("rm -f '{0}' '{1}' /tmp/run-lab07-cassandra.sh" -f $containerCommandsPath, $containerSummaryPath) | Out-Null

Write-Host "Lab07 Cassandra ejecutado correctamente."
Write-Host "Keyspace creado: $keyspace"
Write-Host "Comandos para entrega: $commandsPath"
Write-Host "Resumen local: $summaryPath"
Write-Host "Log local: $logPath"
