<#
Ejecuta un SparkPi minimo para validar Spark sobre el cluster local.
#>
param(
    [int]$Slices = 10
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

$sparkSubmit = (podman exec bigdata-master /bin/bash -lc 'command -v spark-submit 2>/dev/null || true').Trim()
if (-not $sparkSubmit) {
    throw "Spark no esta disponible en bigdata-master. Levante primero el overlay con .\\containers\\scripts\\up-spark.ps1."
}

$examplesJar = (podman exec bigdata-master /bin/bash -lc 'ls "$SPARK_HOME"/examples/jars/spark-examples_*.jar | head -n 1').Trim()

if (-not $examplesJar) {
    throw "No se encontro el jar de ejemplos de Spark dentro del contenedor bigdata-master."
}

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$global:LASTEXITCODE = 0
$rawOutput = podman exec bigdata-master /opt/bigdata/spark/bin/spark-submit `
    --master spark://master:7077 `
    --class org.apache.spark.examples.SparkPi `
    $examplesJar `
    $Slices.ToString() 2>&1
$exitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference

$output = @($rawOutput | ForEach-Object {
    if ($_ -is [System.Management.Automation.ErrorRecord]) {
        $_.ToString()
    } else {
        [string]$_
    }
})

$output | ForEach-Object { Write-Host $_ }

if ($exitCode -ne 0) {
    throw "run-spark-smoke.ps1 termino con codigo de salida $exitCode."
}
