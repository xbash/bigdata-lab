<#
Construye las imagenes base del stack reusable.
#>
param(
    [switch]$NoCache
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $PSScriptRoot "common.ps1")
Set-Location $root

Write-Host ""
if ($NoCache) {
    Write-Host "===== CONSTRUCCION LIMPIA DE IMAGENES ====="
} else {
    Write-Host "===== CONSTRUCCION DE IMAGENES ====="
}
Write-Host ""

$imageTag = Get-RequiredProjectEnvValue -Root $root -Name "BIGDATA_IMAGE_TAG"
$pigArchiveDirName = if ($env:PIG_ARCHIVE_DIRNAME) { $env:PIG_ARCHIVE_DIRNAME } else { "pig-0.18.0" }
$sparkVersion = if ($env:SPARK_VERSION) { $env:SPARK_VERSION } else { "3.3.2" }
$cassandraVersion = if ($env:CASSANDRA_VERSION) { $env:CASSANDRA_VERSION } else { "2.0.7" }
$pigArchivePath = Join-Path $root ".artifacts\\pig-0.18.0-SNAPSHOT-course.tgz"
$pigArchiveSha256Path = Join-Path $root ".artifacts\\pig-0.18.0-SNAPSHOT-course.tgz.sha256"

if (-not (Test-Path -LiteralPath $pigArchivePath)) {
    throw "Missing required course Pig artifact: $pigArchivePath"
}

if (-not (Test-Path -LiteralPath $pigArchiveSha256Path)) {
    throw "Missing required course Pig SHA256 file: $pigArchiveSha256Path"
}

$pigArchiveSha256 = ([System.IO.File]::ReadAllText($pigArchiveSha256Path)).Trim().ToUpperInvariant()

if ([string]::IsNullOrWhiteSpace($pigArchiveSha256)) {
    throw "Course Pig SHA256 file is empty: $pigArchiveSha256Path"
}

$actualPigArchiveSha256 = (Get-FileHash -LiteralPath $pigArchivePath -Algorithm SHA256).Hash.ToUpperInvariant()

if ($actualPigArchiveSha256 -ne $pigArchiveSha256) {
    throw "Course Pig artifact SHA256 mismatch. Expected=$pigArchiveSha256 Actual=$actualPigArchiveSha256"
}

$dirs = @(
    "data\\namenode",
    "data\\datanode1",
    "data\\datanode2",
    "data\\datanode3",
    "data\\shared",
    "data\\outputs",
    "data\\hive",
    "data\\hue",
    "conf\\hue",
    "logs",
    "evidencia",
    "profiles\\sql-hive",
    "profiles\\ir",
    "profiles\\nosql-cassandra",
    "profiles\\nosql-mongodb",
    "profiles\\graph",
    "data\\shared\\lab05\\work",
    "conf\\elasticsearch"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path (Join-Path $root $dir) | Out-Null
}

$cacheArgs = @()
if ($NoCache) {
    $cacheArgs += "--no-cache"
}

podman build @cacheArgs --build-arg "PIG_ARCHIVE_DIRNAME=$pigArchiveDirName" --build-arg "PIG_ARCHIVE_SHA256=$pigArchiveSha256" -f .\containers\base\Containerfile -t "bigdata-core-base:$imageTag" .
podman build @cacheArgs --build-arg "BASE_IMAGE=bigdata-core-base:$imageTag" --build-arg "SPARK_VERSION=$sparkVersion" -f .\containers\spark-base\Containerfile -t "bigdata-spark-base:$imageTag" .
podman build @cacheArgs --build-arg "BASE_IMAGE=bigdata-core-base:$imageTag" --build-arg "CASSANDRA_VERSION=$cassandraVersion" -f .\containers\cassandra-base\Containerfile -t "bigdata-cassandra-base:$imageTag" .

podman build @cacheArgs --build-arg "BASE_IMAGE=bigdata-core-base:$imageTag" -f .\containers\master\Containerfile -t "bigdata-master-core:$imageTag" .
podman build @cacheArgs --build-arg "BASE_IMAGE=bigdata-core-base:$imageTag" -f .\containers\worker\Containerfile -t "bigdata-worker-core:$imageTag" .

podman build @cacheArgs --build-arg "BASE_IMAGE=bigdata-spark-base:$imageTag" -f .\containers\master\Containerfile -t "bigdata-master-spark:$imageTag" .
podman build @cacheArgs --build-arg "BASE_IMAGE=bigdata-spark-base:$imageTag" -f .\containers\worker\Containerfile -t "bigdata-worker-spark:$imageTag" .

podman build @cacheArgs --build-arg "BASE_IMAGE=bigdata-cassandra-base:$imageTag" -f .\containers\master\Containerfile -t "bigdata-master-cassandra:$imageTag" .
podman build @cacheArgs --build-arg "BASE_IMAGE=bigdata-cassandra-base:$imageTag" -f .\containers\worker\Containerfile -t "bigdata-worker-cassandra:$imageTag" .

podman build @cacheArgs -f .\containers\sql-ui\Containerfile -t "bigdata-sql-ui:$imageTag" .
