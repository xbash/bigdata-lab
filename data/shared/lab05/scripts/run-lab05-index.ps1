<#
Compila y ejecuta la indexacion de lab05 sobre el overlay IR.
#>
param(
    [string]$InputLocalPath = "/opt/bigdata/data/shared/lab05/datasets/es-wiki-articles-1k.tsv.gz",
    [string]$IndexName = "wiki-lab05",
    [string]$RanksLocalPath = "",
    [string]$RanksHostPath = "",
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
$hostDatasetPath = Join-Path $root "data\shared\lab05\datasets\es-wiki-articles-1k.tsv.gz"
$hostFullDatasetPath = Join-Path $root "data\shared\lab05\datasets\es-wiki-articles.tsv.gz"
$logsDir = Join-Path $root "data\shared\lab05\logs"
$resultsDir = Join-Path $root "data\shared\lab05\results"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runId = $timestamp + "-lab05-index"
$logPath = Join-Path $logsDir ($timestamp + "-lab05-index-run.log")
$resultPath = Join-Path $resultsDir ($timestamp + "-lab05-index-summary.txt")

New-Item -ItemType Directory -Force -Path $logsDir, $resultsDir | Out-Null

function Resolve-HostPathFromContainerPath {
    param([string]$ContainerPath)

    $prefix = "/opt/bigdata/"
    if ([string]::IsNullOrWhiteSpace($ContainerPath) -or -not $ContainerPath.StartsWith($prefix, [System.StringComparison]::Ordinal)) {
        return $null
    }

    $relativePath = $ContainerPath.Substring($prefix.Length).Replace("/", "\")
    return Join-Path $root $relativePath
}

if (-not $SkipPrepare -and -not (Test-Path -LiteralPath $buildFile)) {
    & (Join-Path $PSScriptRoot "prepare-lab05.ps1")
}

if (-not (Test-Path -LiteralPath $buildFile)) {
    throw "No se encontro el proyecto preparado de lab05 en $projectDir"
}

if ($InputLocalPath -eq "/opt/bigdata/data/shared/lab05/datasets/es-wiki-articles-1k.tsv.gz" -and -not (Test-Path -LiteralPath $hostDatasetPath)) {
    if (-not (Test-Path -LiteralPath $hostFullDatasetPath)) {
        throw "No se encontro la muestra 1k ni el dataset completo esperado en data/shared/lab05/datasets."
    }

    Write-Host "No existe la muestra 1k. Se generara desde el dataset completo: $hostDatasetPath"

    $buffer = New-Object byte[] 8192

    $inputFileStream = [System.IO.File]::OpenRead($hostFullDatasetPath)
    try {
        $gzipInput = New-Object System.IO.Compression.GzipStream($inputFileStream, [System.IO.Compression.CompressionMode]::Decompress)
        try {
            $streamReader = New-Object System.IO.StreamReader($gzipInput, [System.Text.Encoding]::UTF8)
            try {
                $outputFileStream = [System.IO.File]::Create($hostDatasetPath)
                try {
                    $gzipOutput = New-Object System.IO.Compression.GzipStream($outputFileStream, [System.IO.Compression.CompressionLevel]::Optimal)
                    try {
                        $streamWriter = New-Object System.IO.StreamWriter($gzipOutput, $utf8NoBom)
                        try {
                            for ($i = 0; $i -lt 1000; $i++) {
                                $line = $streamReader.ReadLine()
                                if ($null -eq $line) {
                                    break
                                }
                                $streamWriter.WriteLine($line)
                            }
                        } finally {
                            $streamWriter.Dispose()
                        }
                    } finally {
                        $gzipOutput.Dispose()
                    }
                } finally {
                    $outputFileStream.Dispose()
                }
            } finally {
                $streamReader.Dispose()
            }
        } finally {
            $gzipInput.Dispose()
        }
    } finally {
        $inputFileStream.Dispose()
    }

    Write-Host "Muestra 1k generada en: $hostDatasetPath"
}

if (-not [string]::IsNullOrWhiteSpace($RanksLocalPath)) {
    if ([string]::IsNullOrWhiteSpace($RanksHostPath)) {
        $RanksHostPath = Resolve-HostPathFromContainerPath -ContainerPath $RanksLocalPath
    }

    if ([string]::IsNullOrWhiteSpace($RanksHostPath) -or -not (Test-Path -LiteralPath $RanksHostPath)) {
        throw "No se encontro el archivo local de ranks esperado: $RanksHostPath"
    }
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
java -jar dist/gdd-elastic.jar BuildWikiIndexBulk -i "__INPUT_LOCAL__" -igz __RANK_ARGS__ -o "__INDEX_NAME__"
'@

$runCommand = $runCommand.Replace("__INPUT_LOCAL__", $InputLocalPath)
$runCommand = $runCommand.Replace("__INDEX_NAME__", $IndexName)
$runCommand = $runCommand.Replace("__WORKDIR__", "/tmp/" + $runId)
if ([string]::IsNullOrWhiteSpace($RanksLocalPath)) {
    $runCommand = $runCommand.Replace("__RANK_ARGS__", "")
} else {
    $runCommand = $runCommand.Replace("__RANK_ARGS__", ('-r "' + $RanksLocalPath + '"'))
}

$tempScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) ("run-lab05-index-" + $timestamp + ".sh")
[System.IO.File]::WriteAllText($tempScriptPath, $runCommand, [System.Text.UTF8Encoding]::new($false))

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$global:LASTEXITCODE = 0
podman cp $tempScriptPath bigdata-master:/tmp/run-lab05-index.sh | Out-Null
$rawOutput = podman exec bigdata-master /bin/bash /tmp/run-lab05-index.sh 2>&1
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

    throw ("La indexacion de lab05 fallo.`n" +
        "Indice: $IndexName`n" +
        "Input: $InputLocalPath`n" +
        "Resumen:`n" +
        ($errorSummary -join [Environment]::NewLine) + "`n" +
        "Log local: $logPath")
}

[System.IO.File]::WriteAllLines($resultPath, @(
    "LAB05_INDEX_OK",
    "timestamp=$timestamp",
    "index_name=$IndexName",
    "input_local_path=$InputLocalPath",
    "ranks_local_path=$RanksLocalPath",
    "log_path=$logPath"
), $utf8Bom)

Write-Host "Indexacion solicitada para el indice: $IndexName"
Write-Host "Indexacion completada con el empaquetado jar requerido por el proyecto de lab05."
if (-not [string]::IsNullOrWhiteSpace($RanksLocalPath)) {
    Write-Host "Indexacion enriquecida con ranks desde: $RanksLocalPath"
}
Write-Host "Log local: $logPath"
Write-Host "Resumen local: $resultPath"
