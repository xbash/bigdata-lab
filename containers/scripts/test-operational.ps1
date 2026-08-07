<#
Ejecuta un set de pruebas operacionales del runtime, excluyendo jobs de datos.
#>
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host ("[TEST] {0}" -f $Message)
}

function Get-ContainerState {
    param([string]$Name)
    try {
        return (podman inspect -f '{{.State.Status}}|{{if .State.Health}}{{.State.Health.Status}}{{end}}' $Name 2>$null)
    } catch {
        return $null
    }
}

function Assert-ContainerRunning {
    param([string]$Name)

    $state = Get-ContainerState -Name $Name
    if ([string]::IsNullOrWhiteSpace($state)) {
        throw "Contenedor no encontrado: $Name"
    }

    $parts = $state -split '\|', 2
    $status = $parts[0]
    $health = if ($parts.Length -gt 1) { $parts[1] } else { "" }

    if ($status -ne "running") {
        throw "Contenedor no esta running: $Name ($state)"
    }
    if (-not [string]::IsNullOrWhiteSpace($health) -and $health -ne "healthy") {
        throw "Contenedor sin health satisfactoria: $Name ($state)"
    }
}

function Assert-ContainerAbsent {
    param([string]$Name)

    $previousNativeErrorPreference = $PSNativeCommandUseErrorActionPreference
    $script:PSNativeCommandUseErrorActionPreference = $false
    try {
        podman container exists $Name | Out-Null
        if ($LASTEXITCODE -eq 0) {
            throw "Contenedor aun presente: $Name"
        }
    } finally {
        $script:PSNativeCommandUseErrorActionPreference = $previousNativeErrorPreference
    }

    if ($LASTEXITCODE -eq 0) {
        throw "Contenedor aun presente: $Name"
    }
}

function Wait-Running {
    param(
        [int]$TimeoutSec,
        [string[]]$Names
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        $allOk = $true
        foreach ($name in $Names) {
            try {
                Assert-ContainerRunning -Name $name
            } catch {
                $allOk = $false
                break
            }
        }
        if ($allOk) {
            return
        }
        Start-Sleep -Seconds 5
    }

    foreach ($name in $Names) {
        Write-Host ("  - {0} => {1}" -f $name, (Get-ContainerState -Name $name))
    }
    throw ("Timeout esperando contenedores: {0}" -f ($Names -join ", "))
}

function Test-TcpPort {
    param(
        [string]$HostName,
        [int]$Port
    )

    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $iar = $client.BeginConnect($HostName, $Port, $null, $null)
        if (-not $iar.AsyncWaitHandle.WaitOne(2000, $false)) {
            return $false
        }
        $client.EndConnect($iar)
        return $true
    } catch {
        return $false
    } finally {
        $client.Dispose()
    }
}

function Wait-Http {
    param(
        [string]$Url,
        [int]$TimeoutSec
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        try {
            Invoke-WebRequest -UseBasicParsing -Uri $Url -TimeoutSec 5 | Out-Null
            return
        } catch {
            try {
                $uri = [Uri]$Url
                if (Test-TcpPort -HostName $uri.Host -Port $uri.Port) {
                    return
                }
            } catch {
            }
        }
        Start-Sleep -Seconds 5
    }

    throw "Timeout esperando endpoint: $Url"
}

function Wait-TcpPortOpen {
    param(
        [string]$HostName,
        [int]$Port,
        [int]$TimeoutSec
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        if (Test-TcpPort -HostName $HostName -Port $Port) {
            return
        }
        Start-Sleep -Seconds 5
    }

    throw "Timeout esperando puerto TCP: ${HostName}:$Port"
}

function Assert-PodmanExecSuccess {
    param(
        [string]$Name,
        [string]$Command
    )

    podman exec $Name /bin/bash -lc $Command | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw ("Fallo validacion dentro de {0}: {1}" -f $Name, $Command)
    }
}

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $root

Write-Host ""
Write-Host "===== SET DE PRUEBAS OPERACIONALES ====="
Write-Host ""

$baseContainers = @("bigdata-master", "bigdata-worker1", "bigdata-worker2", "bigdata-worker3")
$sparkPorts = @("http://127.0.0.1:8080")
$irContainers = @("bigdata-elasticsearch")
$hiveContainers = @("bigdata-sql-ui", "bigdata-hive-metastore", "bigdata-hive-server")

Write-Step "Limpieza inicial con down-all.ps1"
try {
    & .\containers\scripts\down-all.ps1
} catch {
}

Write-Step "Prueba core: up.ps1"
& .\containers\scripts\up.ps1
Wait-Running -TimeoutSec 180 -Names $baseContainers

Write-Step "Prueba core: status.ps1"
& .\containers\scripts\status.ps1

Write-Step "Prueba core: down.ps1"
& .\containers\scripts\down.ps1
foreach ($name in $baseContainers) {
    Assert-ContainerAbsent -Name $name
}

Write-Step "Prueba Spark: up-spark.ps1"
& .\containers\scripts\up-spark.ps1
Wait-Running -TimeoutSec 180 -Names $baseContainers
foreach ($url in $sparkPorts) {
    Wait-Http -Url $url -TimeoutSec 180
}

Write-Step "Prueba Spark: status-spark.ps1"
& .\containers\scripts\status-spark.ps1

Write-Step "Prueba Spark: down-spark.ps1"
& .\containers\scripts\down-spark.ps1
foreach ($name in $baseContainers) {
    Assert-ContainerAbsent -Name $name
}

Write-Step "Prueba IR: up-ir.ps1"
& .\containers\scripts\up-ir.ps1
Wait-Running -TimeoutSec 180 -Names ($baseContainers + $irContainers)
Wait-Http -Url "http://127.0.0.1:9200/_cat/health?v" -TimeoutSec 180

Write-Step "Prueba IR: status-ir.ps1"
& .\containers\scripts\status-ir.ps1

Write-Step "Prueba IR: down-ir.ps1"
& .\containers\scripts\down-ir.ps1
foreach ($name in ($baseContainers + $irContainers)) {
    Assert-ContainerAbsent -Name $name
}

Write-Step "Prueba sql-hive: up-hive.ps1"
& .\containers\scripts\up-hive.ps1
Wait-Running -TimeoutSec 300 -Names ($baseContainers + $hiveContainers)
Wait-Http -Url "http://127.0.0.1:8888" -TimeoutSec 300
Wait-Http -Url "http://127.0.0.1:10002" -TimeoutSec 300

Write-Step "Prueba sql-hive: status-hive.ps1"
& .\containers\scripts\status-hive.ps1

Write-Step "Prueba sql-hive: down-hive.ps1"
& .\containers\scripts\down-hive.ps1
foreach ($name in ($baseContainers + $hiveContainers)) {
    Assert-ContainerAbsent -Name $name
}

Write-Step "Prueba nosql-cassandra: up-cassandra.ps1"
& .\containers\scripts\up-cassandra.ps1
Wait-Running -TimeoutSec 240 -Names $baseContainers
Wait-TcpPortOpen -HostName "127.0.0.1" -Port 9042 -TimeoutSec 240
Assert-PodmanExecSuccess -Name "bigdata-master" -Command "nodetool status >/tmp/nodetool-status.txt 2>&1 && cat /tmp/nodetool-status.txt"
Assert-PodmanExecSuccess -Name "bigdata-master" -Command "cqlsh --version >/tmp/cqlsh-version.txt 2>&1 && cat /tmp/cqlsh-version.txt"

Write-Step "Prueba nosql-cassandra: status-cassandra.ps1"
& .\containers\scripts\status-cassandra.ps1

Write-Step "Prueba nosql-cassandra: down-cassandra.ps1"
& .\containers\scripts\down-cassandra.ps1
foreach ($name in $baseContainers) {
    Assert-ContainerAbsent -Name $name
}

Write-Step "Prueba combinada: up-spark.ps1 + up-ir.ps1 + up-hive.ps1 + down-all.ps1"
& .\containers\scripts\up-spark.ps1
Wait-Running -TimeoutSec 180 -Names $baseContainers
& .\containers\scripts\up-ir.ps1
Wait-Running -TimeoutSec 180 -Names ($baseContainers + $irContainers)
& .\containers\scripts\up-hive.ps1
Wait-Running -TimeoutSec 300 -Names ($baseContainers + $irContainers + $hiveContainers)
& .\containers\scripts\down-all.ps1
foreach ($name in ($baseContainers + $irContainers + $hiveContainers)) {
    Assert-ContainerAbsent -Name $name
}

Write-Host ""
Write-Host "[MANUAL] Wrappers interactivos a revisar"
Write-Host "- .\containers\scripts\shell-master.ps1"
Write-Host "- .\containers\scripts\shell-elastic.ps1"
Write-Host "- .\containers\scripts\shell-hive.ps1"
Write-Host "- .\containers\scripts\shell-sql-ui.ps1"
Write-Host "- .\containers\scripts\shell-cassandra.ps1"
Write-Host ""
Write-Host "Criterio de aprobacion manual:"
Write-Host "- abre shell dentro del contenedor correcto"
Write-Host "- ejecuta 'hostname'"
Write-Host "- ejecuta 'pwd'"
Write-Host "- salir con 'exit'"

Write-Host ""
Write-Host "[OK] Set de pruebas operacionales completado."
