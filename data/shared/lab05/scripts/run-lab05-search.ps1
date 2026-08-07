<#
Compila y ejecuta una consulta de busqueda de lab05 sobre el overlay IR.
#>
param(
    [string]$IndexName = "wiki-lab05",
    [string]$Query = "linux",
    [int]$TimeoutSec = 10,
    [switch]$UseRank,
    [double]$RankFactor = 1000,
    [switch]$ShowRank,
    [switch]$ShowScore,
    [switch]$SkipPrepare
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

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$projectDir = Join-Path $root "data\shared\lab05\work\gdd-elastic"
$buildFile = Join-Path $projectDir "build.xml"
$logsDir = Join-Path $root "data\shared\lab05\logs"
$resultsDir = Join-Path $root "data\shared\lab05\results"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$queryBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Query))
$runId = $timestamp + "-lab05-search"
$safeQueryName = (($Query -replace '[^A-Za-z0-9]+', '-').Trim('-')).ToLowerInvariant()
if ([string]::IsNullOrWhiteSpace($safeQueryName)) {
    $safeQueryName = "query"
}
$logPath = Join-Path $logsDir ($timestamp + "-lab05-search-run.log")
$resultPath = Join-Path $resultsDir ($timestamp + "-lab05-search-" + $safeQueryName + ".txt")

New-Item -ItemType Directory -Force -Path $logsDir, $resultsDir | Out-Null

if (-not $SkipPrepare -and -not (Test-Path -LiteralPath $buildFile)) {
    & (Join-Path $PSScriptRoot "prepare-lab05.ps1")
}

if (-not (Test-Path -LiteralPath $buildFile)) {
    throw "No se encontro el proyecto preparado de lab05 en $projectDir"
}

$runCommand = @'
set -euo pipefail
workdir="__WORKDIR__"
rm -rf "$workdir"
mkdir -p "$workdir"
cp -R /opt/bigdata/data/shared/lab05/work/gdd-elastic "$workdir/"
cd "$workdir/gdd-elastic"
rm -rf bin dist stage
mkdir -p bin dist stage/META-INF
javac -cp "lib/*" -d bin $(find src -name '*.java')
cp -R bin/* stage/
cp -R meta/* stage/META-INF/
for dep in lib/*.jar; do
  (
    cd stage
    jar xf "../$dep"
  )
done
jar cfm dist/gdd-elastic.jar meta/MANIFEST.MF -C stage .
set +e
query_text=$(printf '%s' "__QUERY_B64__" | base64 -d)
search_cmd=(java -jar dist/gdd-elastic.jar SearchWikiIndex -i "__INDEX_NAME__")
if [ "__USE_RANK__" = "true" ]; then
  search_cmd+=(-ranked -rf "__RANK_FACTOR__")
fi
if [ "__SHOW_RANK__" = "true" ]; then
  search_cmd+=(-showrank)
fi
if [ "__SHOW_SCORE__" = "true" ]; then
  search_cmd+=(-showscore)
fi
printf '%s\n' "$query_text" | timeout "__TIMEOUT_SEC__"s "${search_cmd[@]}"
status=$?
set -e
if [ "$status" -ne 0 ] && [ "$status" -ne 124 ]; then
  exit "$status"
fi
'@

$runCommand = $runCommand.Replace("__QUERY_B64__", $queryBase64)
$runCommand = $runCommand.Replace("__TIMEOUT_SEC__", $TimeoutSec.ToString())
$runCommand = $runCommand.Replace("__INDEX_NAME__", $IndexName)
$runCommand = $runCommand.Replace("__WORKDIR__", "/tmp/" + $runId)
$runCommand = $runCommand.Replace("__USE_RANK__", $UseRank.ToString().ToLowerInvariant())
$runCommand = $runCommand.Replace("__RANK_FACTOR__", $RankFactor.ToString([System.Globalization.CultureInfo]::InvariantCulture))
$runCommand = $runCommand.Replace("__SHOW_RANK__", $ShowRank.ToString().ToLowerInvariant())
$runCommand = $runCommand.Replace("__SHOW_SCORE__", $ShowScore.ToString().ToLowerInvariant())

$tempScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) ("run-lab05-search-" + $timestamp + ".sh")
[System.IO.File]::WriteAllText($tempScriptPath, $runCommand, [System.Text.UTF8Encoding]::new($false))

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$global:LASTEXITCODE = 0
podman cp $tempScriptPath bigdata-master:/tmp/run-lab05-search.sh | Out-Null
$rawOutput = podman exec bigdata-master /bin/bash /tmp/run-lab05-search.sh 2>&1
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

if ($exitCode -ne 0) {
    $errorSummary = $output | Where-Object {
        $_ -match '^\*\*\*ERROR:' -or $_ -match 'Exception' -or $_ -match '^Error'
    } | Select-Object -Last 5

    if (-not $errorSummary) {
        $errorSummary = $output | Select-Object -Last 10
    }

    throw ("La busqueda de lab05 fallo.`n" +
        "Indice: $IndexName`n" +
        "Consulta: $Query`n" +
        "Resumen:`n" +
        ($errorSummary -join [Environment]::NewLine) + "`n" +
        "Log local: $logPath")
}

$resultLines = $output | Where-Object {
    $_ -and
    $_ -notmatch '^Querying index at' -and
    $_ -notmatch '^Enter a keyword search phrase:' -and
    $_ -notmatch '^Busqueda solicitada en el indice:' -and
    $_ -notmatch '^Busqueda ejecutada con la salida funcional' -and
    $_ -notmatch '^WARNING:' -and
    $_ -notmatch '^ADVERTENCIA:' -and
    $_ -notmatch '^Picked up ' -and
    $_ -notmatch '^\d{4}-\d{2}-\d{2} .* ERROR No Log4j 2 configuration file found' -and
    $_ -notmatch '^time elapsed ' -and
    $_ -notmatch '^\s*$'
}

if (-not $resultLines) {
    $resultLines = @(
        "NO_RESULTS",
        "index_name=$IndexName",
        "query=$Query",
        "log_path=$logPath"
    )
}

[System.IO.File]::WriteAllLines($resultPath, $resultLines, $utf8Bom)

Write-Host "Busqueda solicitada en el indice: $IndexName"
Write-Warning "La busqueda se ejecuta con timeout porque la aplicacion del curso entra en un loop interactivo."
Write-Host "Busqueda ejecutada con la salida funcional de titulo, url y abstract."
Write-Host "Log local: $logPath"
Write-Host "Resultado local: $resultPath"
