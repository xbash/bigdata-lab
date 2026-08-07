<#
Muestra el estado del stack base mas el overlay sql-hive y consulta endpoints expuestos.
#>
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
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

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $PSScriptRoot "common.ps1")
Set-Location $root
$composeEnvArgs = Get-ComposeEnvArgs -Root $root

Write-Host ""
Write-Host "===== ESTADO OVERLAY SQL-HIVE ====="

Write-Host "`n== podman compose ps (core + sql-hive) =="
podman compose @composeEnvArgs -f .\compose.yml -f .\compose.hive.yml ps

Write-Host "`n== podman ps =="
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host "`n== hue (localhost:8888) =="
try {
    (Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:8888" -TimeoutSec 5).StatusCode
} catch {
    Write-Warning "No fue posible consultar Hue en http://localhost:8888"
}

Write-Host "`n== hiveserver2 web (localhost:10002) =="
try {
    (Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:10002" -TimeoutSec 5).StatusCode
} catch {
    Write-Warning "No fue posible consultar HiveServer2 en http://localhost:10002"
}

Write-Host "`n== puertos TCP =="
foreach ($port in 9083, 10000) {
    $isOpen = Test-TcpPort -HostName "127.0.0.1" -Port $port
    Write-Host ("localhost:{0} -> {1}" -f $port, ($(if ($isOpen) { "OPEN" } else { "CLOSED" })))
}
