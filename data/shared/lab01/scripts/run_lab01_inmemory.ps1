param(
    [string]$JavaHome = "C:\apps-local\05-progra\java\jdk-jre-kit\jdk-21.0.10",
    [string]$Heap = "4096M",
    [string[]]$NValues = @("2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"),
    [int]$TopK = 100,
    [switch]$UseSample,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "run_lab01_experiments.ps1") `
    -JavaHome $JavaHome `
    -Heap $Heap `
    -NValues $NValues `
    -TopK $TopK `
    -Mode InMemory `
    -UseSample:$UseSample `
    -Force:$Force
