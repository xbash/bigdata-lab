param(
    [string]$JavaHome = "C:\apps-local\05-progra\java\jdk-jre-kit\jdk-21.0.10",
    [string]$Heap = "4096M",
    [int]$TopK = 100,
    [int]$BatchSize = 500000,
    [int]$ExternalN = 12,
    [switch]$UseSample,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "run_lab01_experiments.ps1") `
    -JavaHome $JavaHome `
    -Heap $Heap `
    -TopK $TopK `
    -BatchSize $BatchSize `
    -ExternalN $ExternalN `
    -Mode External `
    -UseSample:$UseSample `
    -Force:$Force
