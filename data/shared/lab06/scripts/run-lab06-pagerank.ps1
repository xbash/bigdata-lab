<#
Compila y ejecuta el flujo minimo de PageRank de lab06 usando Giraph y luego ordena por rank.
#>
param(
    [string]$InputLocalPath = "/opt/bigdata/data/shared/lab06/datasets/pr-ex-local.tsv",
    [string]$InputHdfsPath = "/inputs/lab06/pr-ex-local.tsv",
    [string]$OutputHdfsRoot = "/outputs/lab06",
    [int]$Workers = 1,
    [int]$PreviewLines = 10,
    [int]$MapMemoryMb = 3072,
    [string]$MapJavaOpts = "-Xmx2457m",
    [switch]$SkipPrepare
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman no esta disponible en PATH."
}

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$projectDir = Join-Path $root "data\shared\lab06\work\gdd-giraph"
$buildFile = Join-Path $projectDir "build.xml"
$defaultHostInput = Join-Path $root "data\shared\lab06\datasets\pr-ex-local.tsv"
$logsDir = Join-Path $root "data\shared\lab06\logs"
$resultsDir = Join-Path $root "data\shared\lab06\results"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runId = $timestamp + "-lab06-pagerank"
$logPath = Join-Path $logsDir ($timestamp + "-lab06-pagerank-run.log")
$prPreviewPath = Join-Path $resultsDir ($timestamp + "-lab06-pagerank-top" + $PreviewLines + ".txt")
$sortPreviewPath = Join-Path $resultsDir ($timestamp + "-lab06-pagerank-sorted-top" + $PreviewLines + ".txt")
$containerPrPreviewPath = "/tmp/" + $runId + "-pagerank-preview.txt"
$containerSortPreviewPath = "/tmp/" + $runId + "-pagerank-sorted-preview.txt"

New-Item -ItemType Directory -Force -Path $logsDir, $resultsDir | Out-Null

if (-not $SkipPrepare -and -not (Test-Path -LiteralPath $buildFile)) {
    & (Join-Path $PSScriptRoot "prepare-lab06.ps1")
}

if (-not (Test-Path -LiteralPath $buildFile)) {
    throw "No se encontro el proyecto preparado de lab06 en $projectDir"
}

if ($InputLocalPath -eq "/opt/bigdata/data/shared/lab06/datasets/pr-ex-local.tsv" -and -not (Test-Path -LiteralPath $defaultHostInput)) {
    throw "No se encontro el dataset local esperado: $defaultHostInput"
}

$outputBase = $OutputHdfsRoot.TrimEnd("/")
$prOutput = "$outputBase/pagerank-$timestamp"
$sortOutput = "$outputBase/pagerank-sorted-$timestamp"
$inputHdfsDir = [System.IO.Path]::GetDirectoryName($InputHdfsPath.Replace("/", "\")).Replace("\", "/")
$inputIsGzip = $InputLocalPath.EndsWith(".gz", [System.StringComparison]::OrdinalIgnoreCase)
$effectiveInputHdfsPath = $InputHdfsPath
if ($inputIsGzip) {
    if ($InputHdfsPath.EndsWith(".gz", [System.StringComparison]::OrdinalIgnoreCase)) {
        $effectiveInputHdfsPath = $InputHdfsPath.Substring(0, $InputHdfsPath.Length - 3)
    } else {
        $effectiveInputHdfsPath = $InputHdfsPath + ".expanded"
    }
}

$runCommand = @'
set -euo pipefail
workdir="__WORKDIR__"
rm -rf "$workdir"
mkdir -p "$workdir"
cp -R /opt/bigdata/data/shared/lab06/work/gdd-giraph "$workdir/"
cd "$workdir/gdd-giraph"
rm -rf bin dist stage
mkdir -p bin dist stage
javac -cp "lib/*" -d bin $(find src -name '*.java')
cp -R bin/* stage/
for dep in lib/*.jar; do
  (
    cd stage
    jar xf "../$dep"
  )
done
jar cfm dist/gdd-giraph.jar /dev/stdin -C stage . <<'EOF_MANIFEST'
Manifest-Version: 1.0
Main-Class: org.mdp.hadoop.cli.Main

EOF_MANIFEST
hdfs dfs -mkdir -p "__INPUT_HDFS_DIR__"
hdfs_ready=0
for attempt in $(seq 1 24); do
  safemode_status="$(hdfs dfsadmin -safemode get 2>&1 || true)"
  if printf '%s\n' "$safemode_status" | grep -qi 'Safe mode is OFF'; then
    hdfs_ready=1
    break
  fi
  sleep 5
done
if [ "$hdfs_ready" -ne 1 ]; then
  printf '%s\n' "$safemode_status"
  echo "ERROR: HDFS NameNode sigue en safe mode y no permite cargar el input."
  exit 31
fi
hdfs dfs -rm -f "__EFFECTIVE_INPUT_HDFS__" >/dev/null 2>&1 || true
if [ "__INPUT_IS_GZIP__" = "true" ]; then
  gzip -dc "__INPUT_LOCAL__" | hdfs dfs -put -f - "__EFFECTIVE_INPUT_HDFS__"
else
  hdfs dfs -put -f "__INPUT_LOCAL__" "__EFFECTIVE_INPUT_HDFS__"
fi
hdfs dfs -rm -r -f "__PR_OUTPUT__" >/dev/null 2>&1 || true
hdfs dfs -rm -r -f "__SORT_OUTPUT__" >/dev/null 2>&1 || true
HADOOP_CP="$(/opt/bigdata/hadoop/bin/hadoop classpath)"
java -cp "dist/gdd-giraph.jar:$HADOOP_CP" org.apache.giraph.GiraphRunner org.mdp.hadoop.cli.PageRank \
  -eif org.mdp.hadoop.io.TextNullTextEdgeInputFormat \
  -eip "__EFFECTIVE_INPUT_HDFS__" \
  -vof org.mdp.hadoop.io.VertexValueTextOutputFormat \
  -op "__PR_OUTPUT__" \
  -w __WORKERS__ \
  -ca giraph.SplitMasterWorker=false \
  -ca mapreduce.job.tracker=yarn \
  -ca mapreduce.framework.name=yarn \
  -ca mapreduce.map.memory.mb=__MAP_MEMORY_MB__ \
  -ca mapreduce.map.java.opts=__MAP_JAVA_OPTS__ \
  -mc org.mdp.hadoop.pr.PageRankAgg
/opt/bigdata/hadoop/bin/hadoop jar dist/gdd-giraph.jar SortByRank -D mapreduce.job.reduces=1 "__PR_OUTPUT__" "__SORT_OUTPUT__"
set +o pipefail
hdfs dfs -cat "__PR_OUTPUT__/part-m-*" 2>/dev/null | awk 'index($0, "\t") > 0 { print; count++; if (count >= __PREVIEW_LINES__) exit }' > "__PR_PREVIEW_FILE__"
hdfs dfs -cat "__SORT_OUTPUT__/part-r-00000" 2>/dev/null | awk 'index($0, "\t") > 0 { print; count++; if (count >= __PREVIEW_LINES__) exit }' > "__SORT_PREVIEW_FILE__"
set -o pipefail
echo "__LAB06_PAGERANK_PREVIEW_BEGIN__"
cat "__PR_PREVIEW_FILE__"
echo "__LAB06_PAGERANK_PREVIEW_END__"
echo "__LAB06_SORTED_PREVIEW_BEGIN__"
cat "__SORT_PREVIEW_FILE__"
echo "__LAB06_SORTED_PREVIEW_END__"
'@

$runCommand = $runCommand.Replace("__WORKDIR__", "/tmp/" + $runId)
$runCommand = $runCommand.Replace("__INPUT_LOCAL__", $InputLocalPath)
$runCommand = $runCommand.Replace("__INPUT_HDFS__", $InputHdfsPath)
$runCommand = $runCommand.Replace("__INPUT_HDFS_DIR__", $inputHdfsDir)
$runCommand = $runCommand.Replace("__EFFECTIVE_INPUT_HDFS__", $effectiveInputHdfsPath)
$runCommand = $runCommand.Replace("__INPUT_IS_GZIP__", $inputIsGzip.ToString().ToLowerInvariant())
$runCommand = $runCommand.Replace("__PR_OUTPUT__", $prOutput)
$runCommand = $runCommand.Replace("__SORT_OUTPUT__", $sortOutput)
$runCommand = $runCommand.Replace("__WORKERS__", $Workers.ToString())
$runCommand = $runCommand.Replace("__MAP_MEMORY_MB__", $MapMemoryMb.ToString())
$runCommand = $runCommand.Replace("__MAP_JAVA_OPTS__", $MapJavaOpts)
$runCommand = $runCommand.Replace("__PREVIEW_LINES__", $PreviewLines.ToString())
$runCommand = $runCommand.Replace("__PR_PREVIEW_FILE__", $containerPrPreviewPath)
$runCommand = $runCommand.Replace("__SORT_PREVIEW_FILE__", $containerSortPreviewPath)

$tempScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) ("run-lab06-pagerank-" + $timestamp + ".sh")
[System.IO.File]::WriteAllText($tempScriptPath, $runCommand, [System.Text.UTF8Encoding]::new($false))

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$global:LASTEXITCODE = 0
podman cp $tempScriptPath bigdata-master:/tmp/run-lab06-pagerank.sh | Out-Null
$rawOutput = podman exec bigdata-master /bin/bash /tmp/run-lab06-pagerank.sh 2>&1
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

[System.IO.File]::WriteAllLines($logPath, $output, [System.Text.UTF8Encoding]::new($true))
$output | ForEach-Object { Write-Host $_ }

if ($exitCode -ne 0) {
    $errorSummary = $output | Where-Object {
        $_ -match '^\*\*\*ERROR:' -or
        $_ -match 'Exception' -or
        $_ -match '^Error' -or
        $_ -match 'FAILED' -or
        $_ -match '^Failure'
    } | Select-Object -Last 10

    if (-not $errorSummary) {
        $errorSummary = $output | Select-Object -Last 15
    }

    throw ("La ejecucion de lab06 PageRank fallo.`n" +
        "Input local: $InputLocalPath`n" +
        "Input HDFS solicitado: $InputHdfsPath`n" +
        "Input HDFS efectivo: $effectiveInputHdfsPath`n" +
        "Map memory mb: $MapMemoryMb`n" +
        "Map java opts: $MapJavaOpts`n" +
        "Resumen:`n" +
        ($errorSummary -join [Environment]::NewLine) + "`n" +
        "Log local: $logPath")
}

podman cp ("bigdata-master:" + $containerPrPreviewPath) $prPreviewPath | Out-Null
podman cp ("bigdata-master:" + $containerSortPreviewPath) $sortPreviewPath | Out-Null
podman exec bigdata-master /bin/bash -lc ("rm -f '{0}' '{1}'" -f $containerPrPreviewPath, $containerSortPreviewPath) | Out-Null

Write-Host "Salida HDFS PageRank: $prOutput"
Write-Host "Salida HDFS ordenada: $sortOutput"
Write-Host "Input HDFS solicitado: $InputHdfsPath"
Write-Host "Input HDFS efectivo: $effectiveInputHdfsPath"
Write-Host "Memoria map task: $MapMemoryMb MB"
Write-Host "Java opts map task: $MapJavaOpts"
Write-Host "Log local: $logPath"
Write-Host "Preview local PageRank: $prPreviewPath"
Write-Host "Preview local ordenado: $sortPreviewPath"
