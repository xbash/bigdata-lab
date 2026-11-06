<#
Ejecuta un factory reset del runtime local destruyendo solo el estado
persistente del cluster almacenado en volumenes Podman.
#>
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$downAllScript = Join-Path $PSScriptRoot "down-all.ps1"

if (-not (Test-Path -LiteralPath $downAllScript)) {
    throw "No existe el script requerido para bajar el stack: $downAllScript"
}

$volumes = @(
    "bigdata-lab_namenode-data",
    "bigdata-lab_datanode1-data",
    "bigdata-lab_datanode2-data",
    "bigdata-lab_datanode3-data",
    "bigdata-lab_elasticsearch-data",
    "bigdata-lab_cassandra-master-data",
    "bigdata-lab_cassandra-worker1-data",
    "bigdata-lab_cassandra-worker2-data",
    "bigdata-lab_cassandra-worker3-data"
)

function Test-PodmanVolumeExists {
    param([string]$Name)

    $previousNativeErrorPreference = $PSNativeCommandUseErrorActionPreference
    $script:PSNativeCommandUseErrorActionPreference = $false
    try {
        podman volume exists $Name | Out-Null
        return ($LASTEXITCODE -eq 0)
    }
    finally {
        $script:PSNativeCommandUseErrorActionPreference = $previousNativeErrorPreference
    }
}

Write-Host ""
Write-Host "===== FACTORY RESET DEL RUNTIME LOCAL ====="
Write-Host ""
Write-Host "Este script SI borra:"
Write-Host "- estado persistente del cluster almacenado en volumenes Podman"
Write-Host "- HDFS del core (namenode y datanodes)"
Write-Host "- persistencia de overlays que usen volumenes nombrados (Elasticsearch y Cassandra)"
Write-Host ""
Write-Host "Este script NO borra:"
Write-Host "- data/shared/lab0X/datasets/"
Write-Host "- data/shared/lab0X/scripts/"
Write-Host "- data/shared/lab0X/docs/"
Write-Host "- data/shared/lab0X/results/"
Write-Host "- data/shared/lab0X/work/"
Write-Host "- docs/"
Write-Host "- evidencia/"
Write-Host "- ningun archivo o carpeta del repositorio"
Write-Host ""
Write-Host "Este factory reset destruye el estado persistente del cluster."
Write-Host "Antes de borrar volumenes ejecutara down-all.ps1 para bajar el stack."
Write-Host ""

$answer = Read-Host "Escribe FACTORY RESET para continuar"
if ($answer -ne "FACTORY RESET") {
    Write-Host "Operacion cancelada."
    exit 1
}

Set-Location $root
& $downAllScript

Write-Host ""
Write-Host "Eliminando volumenes persistentes del cluster..."

foreach ($volume in $volumes) {
    if (Test-PodmanVolumeExists -Name $volume) {
        podman volume rm -f $volume | Out-Null
        Write-Host ("- eliminado: {0}" -f $volume)
    } else {
        Write-Host ("- no existe: {0}" -f $volume)
    }
}

Write-Host ""
Write-Host "Factory reset completado."
