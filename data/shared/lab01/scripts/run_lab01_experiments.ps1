param(
    [string]$JavaHome = "C:\apps-local\05-progra\java\jdk-jre-kit\jdk-21.0.10",
    [string]$Heap = "4096M",
    [string[]]$NValues = @("2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"),
    [int]$TopK = 100,
    [int]$BatchSize = 500000,
    [int]$ExternalN = 12,
    [ValidateSet("InMemory", "External", "Both")]
    [string]$Mode = "Both",
    [switch]$RunExternalPipeline,
    [switch]$SkipInMemory,
    [switch]$UseSample,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lab01-common.ps1")

$normalizedNValues = Expand-Lab01NValues -NValues $NValues
$runContext = New-Lab01RunContext `
    -ScriptPath $MyInvocation.MyCommand.Path `
    -JavaHome $JavaHome `
    -Heap $Heap `
    -NValues $normalizedNValues `
    -TopK $TopK `
    -BatchSize $BatchSize `
    -ExternalN $ExternalN `
    -UseSample:$UseSample `
    -Force:$Force

Show-Lab01RunHeader -RunContext $runContext -ModeLabel "experiments"

if ($PSBoundParameters.ContainsKey("RunExternalPipeline") -or $PSBoundParameters.ContainsKey("SkipInMemory")) {
    Write-Host "[WARN] -RunExternalPipeline y -SkipInMemory quedan solo por compatibilidad. Prefiere -Mode InMemory|External|Both."
    if (-not $SkipInMemory -and $RunExternalPipeline) {
        $Mode = "Both"
    } elseif ($SkipInMemory -and $RunExternalPipeline) {
        $Mode = "External"
    } elseif (-not $SkipInMemory -and -not $RunExternalPipeline) {
        $Mode = "InMemory"
    } else {
        throw "La combinacion -SkipInMemory sin -RunExternalPipeline ya no es valida. Usa -Mode InMemory, -Mode External o -Mode Both."
    }
}

if ($Mode -in @("InMemory", "Both")) {
    Invoke-Lab01InMemory -RunContext $runContext
}

if ($Mode -in @("External", "Both")) {
    Invoke-Lab01ExternalPipeline -RunContext $runContext
}
