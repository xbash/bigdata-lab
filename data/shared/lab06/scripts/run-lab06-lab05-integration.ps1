<#
Exporta ranks ordenados desde HDFS, reindexa lab05 con y sin PageRank y compara una consulta.
#>
param(
    [string]$Query = "estados unidos",
    [string]$Lab05InputLocalPath = "/opt/bigdata/data/shared/lab05/datasets/es-wiki-articles-1k.tsv.gz",
    [string]$PageRankSortedHdfsPath = "",
    [double]$RankFactor = 5000,
    [int]$TimeoutSec = 10,
    [switch]$SkipPrepare
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$lab06LogsDir = Join-Path $root "data\shared\lab06\logs"
$lab06ResultsDir = Join-Path $root "data\shared\lab06\results"
$integrationDir = Join-Path $lab06ResultsDir "lab05-rank-integration"
$lab05ResultsDir = Join-Path $root "data\shared\lab05\results"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$safeQueryName = (($Query -replace '[^A-Za-z0-9]+', '-').Trim('-')).ToLowerInvariant()
if ([string]::IsNullOrWhiteSpace($safeQueryName)) {
    $safeQueryName = "query"
}

$ranksLocalPath = Join-Path $integrationDir "ranks.s.tsv"
$comparisonPath = Join-Path $integrationDir ($timestamp + "-lab05-rank-compare-" + $safeQueryName + ".md")
$containerRanksExportPath = "/tmp/lab06-ranks-export-" + $timestamp + ".tsv"
$baseIndexName = "wiki-lab05-base-" + $timestamp
$rankedIndexName = "wiki-lab05-ranked-" + $timestamp

New-Item -ItemType Directory -Force -Path $integrationDir, $lab05ResultsDir | Out-Null

if (-not $SkipPrepare) {
    & (Join-Path $PSScriptRoot "prepare-lab06.ps1")
}

$runningContainers = @(podman ps --format "{{.Names}}")
if ($runningContainers -notcontains "bigdata-master") {
    throw "bigdata-master no esta levantado. Inicie primero el core."
}
if ($runningContainers -notcontains "bigdata-elasticsearch") {
    throw "bigdata-elasticsearch no esta levantado. Inicie primero el overlay IR."
}

if ([string]::IsNullOrWhiteSpace($PageRankSortedHdfsPath)) {
    $latestPagerankLog = Get-ChildItem -LiteralPath $lab06LogsDir -Filter "*-lab06-pagerank-run.log" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latestPagerankLog) {
        throw "No se encontro un log de lab06 para inferir la salida ordenada."
    }

    $sortedLine = Get-Content -LiteralPath $latestPagerankLog.FullName |
        Where-Object { $_ -like "Salida HDFS ordenada: *" } |
        Select-Object -Last 1

    if ($sortedLine) {
        $PageRankSortedHdfsPath = $sortedLine.Substring("Salida HDFS ordenada: ".Length).Trim()
    } else {
        $previousErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        $hdfsListingRaw = podman exec bigdata-master hdfs dfs -ls /outputs/lab06 2>&1
        $ErrorActionPreference = $previousErrorActionPreference
        $hdfsListing = @($hdfsListingRaw | ForEach-Object {
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                $_.ToString()
            } else {
                [string]$_
            }
        })
        $hdfsCandidates = $hdfsListing | Where-Object { $_ -match '/outputs/lab06/pagerank-sorted-' }
        $PageRankSortedHdfsPath = [string](($hdfsCandidates | Select-Object -Last 1) -replace '^.*(/outputs/lab06/pagerank-sorted-[^\s]+).*$','$1')
        if ($PageRankSortedHdfsPath) {
            $PageRankSortedHdfsPath = $PageRankSortedHdfsPath.Trim()
        }
    }

    if ([string]::IsNullOrWhiteSpace($PageRankSortedHdfsPath)) {
        throw "No se pudo inferir la salida HDFS ordenada desde $($latestPagerankLog.FullName) ni desde /outputs/lab06"
    }
}

$exportCommand = "set -euo pipefail; hdfs dfs -text '$PageRankSortedHdfsPath/part-r-00000' > '$containerRanksExportPath'"
$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$global:LASTEXITCODE = 0
$exportOutput = podman exec bigdata-master /bin/bash -lc $exportCommand 2>&1
$exportExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference

if ($exportExitCode -ne 0) {
    $errorText = (@($exportOutput | ForEach-Object { [string]$_ }) -join [Environment]::NewLine)
    throw "No se pudo exportar ranks desde HDFS.`n$errorText"
}

podman cp ("bigdata-master:" + $containerRanksExportPath) $ranksLocalPath | Out-Null
podman exec bigdata-master /bin/bash -lc ("rm -f '{0}'" -f $containerRanksExportPath) | Out-Null

$searchFilter = "*-lab05-search-" + $safeQueryName + ".txt"
$beforeBaseIndex = @(Get-ChildItem -LiteralPath $lab05ResultsDir -Filter "*-lab05-index-summary.txt" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
& (Join-Path $root "data\shared\lab05\scripts\run-lab05-index.ps1") -InputLocalPath $Lab05InputLocalPath -IndexName $baseIndexName -SkipPrepare
$afterBaseIndex = @(Get-ChildItem -LiteralPath $lab05ResultsDir -Filter "*-lab05-index-summary.txt" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
$baseIndexSummary = ($afterBaseIndex | Where-Object { $_ -notin $beforeBaseIndex } | Select-Object -Last 1)

$beforeRankedIndex = @(Get-ChildItem -LiteralPath $lab05ResultsDir -Filter "*-lab05-index-summary.txt" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
& (Join-Path $root "data\shared\lab05\scripts\run-lab05-index.ps1") -InputLocalPath $Lab05InputLocalPath -IndexName $rankedIndexName -RanksLocalPath "/opt/bigdata/data/shared/lab06/results/lab05-rank-integration/ranks.s.tsv" -RanksHostPath $ranksLocalPath -SkipPrepare
$afterRankedIndex = @(Get-ChildItem -LiteralPath $lab05ResultsDir -Filter "*-lab05-index-summary.txt" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
$rankedIndexSummary = ($afterRankedIndex | Where-Object { $_ -notin $beforeRankedIndex } | Select-Object -Last 1)

$beforeBaseSearch = @(Get-ChildItem -LiteralPath $lab05ResultsDir -Filter $searchFilter -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
& (Join-Path $root "data\shared\lab05\scripts\run-lab05-search.ps1") -IndexName $baseIndexName -Query $Query -TimeoutSec $TimeoutSec -ShowScore -ShowRank -SkipPrepare
$afterBaseSearch = @(Get-ChildItem -LiteralPath $lab05ResultsDir -Filter $searchFilter -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
$baseSearchResult = ($afterBaseSearch | Where-Object { $_ -notin $beforeBaseSearch } | Select-Object -Last 1)

$beforeRankedSearch = @(Get-ChildItem -LiteralPath $lab05ResultsDir -Filter $searchFilter -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
& (Join-Path $root "data\shared\lab05\scripts\run-lab05-search.ps1") -IndexName $rankedIndexName -Query $Query -TimeoutSec $TimeoutSec -UseRank -RankFactor $RankFactor -ShowScore -ShowRank -SkipPrepare
$afterRankedSearch = @(Get-ChildItem -LiteralPath $lab05ResultsDir -Filter $searchFilter -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
$rankedSearchResult = ($afterRankedSearch | Where-Object { $_ -notin $beforeRankedSearch } | Select-Object -Last 1)

if (-not $baseSearchResult -or -not $rankedSearchResult) {
    throw "No se pudieron ubicar los resultados de busqueda generados para la comparacion."
}

$baseLines = Get-Content -LiteralPath $baseSearchResult | Select-Object -First 10
$rankedLines = Get-Content -LiteralPath $rankedSearchResult | Select-Object -First 10

$comparison = New-Object System.Collections.Generic.List[string]
$comparison.Add("# Comparacion lab06 -> lab05")
$comparison.Add("")
$comparison.Add("- timestamp: $timestamp")
$comparison.Add("- query: $Query")
$comparison.Add("- pagerank_sorted_hdfs: $PageRankSortedHdfsPath")
$comparison.Add("- ranks_local_path: $ranksLocalPath")
$comparison.Add("- base_index: $baseIndexName")
$comparison.Add("- ranked_index: $rankedIndexName")
$comparison.Add("- rank_factor: $RankFactor")
$comparison.Add("- base_index_summary: $baseIndexSummary")
$comparison.Add("- ranked_index_summary: $rankedIndexSummary")
$comparison.Add("- base_search_result: $baseSearchResult")
$comparison.Add("- ranked_search_result: $rankedSearchResult")
$comparison.Add("")
$comparison.Add("## Top 10 sin rank")
$comparison.Add("")
foreach ($line in $baseLines) {
    $comparison.Add($line)
}
$comparison.Add("")
$comparison.Add("## Top 10 con rank")
$comparison.Add("")
foreach ($line in $rankedLines) {
    $comparison.Add($line)
}

[System.IO.File]::WriteAllLines($comparisonPath, $comparison, $utf8NoBom)

Write-Host "Integracion lab06 -> lab05 ejecutada."
Write-Host "Salida HDFS ordenada usada: $PageRankSortedHdfsPath"
Write-Host "Ranks locales exportados en: $ranksLocalPath"
Write-Host "Indice base: $baseIndexName"
Write-Host "Indice con rank: $rankedIndexName"
Write-Host "Comparacion local: $comparisonPath"
