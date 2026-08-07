function Expand-Lab01NValues {
    param([string[]]$NValues)

    $normalized = @(
        foreach ($item in $NValues) {
            foreach ($value in ($item -split ",")) {
                $trimmed = $value.Trim()
                if ($trimmed.Length -eq 0) {
                    continue
                }
                try {
                    [int]$trimmed | Out-Null
                } catch {
                    throw "Valor invalido para -NValues: '$trimmed'. Usa enteros separados por coma o espacio, por ejemplo -NValues 2,3,4."
                }
                $trimmed
            }
        }
    )

    if ($normalized.Count -eq 0) {
        throw "Debes indicar al menos un valor entero en -NValues."
    }

    return $normalized
}

function New-Lab01RunContext {
    param(
        [string]$ScriptPath,
        [string]$JavaHome,
        [string]$Heap,
        [string[]]$NValues = @(),
        [int]$TopK,
        [int]$BatchSize,
        [int]$ExternalN,
        [switch]$UseSample,
        [switch]$Force
    )

    $scriptDir = Split-Path -Parent $ScriptPath
    $rootDir = Resolve-Path (Join-Path $scriptDir "..")
    $dataDir = Join-Path $rootDir "datasets"
    $workRootDir = Join-Path $rootDir "work"
    $projectDir = Join-Path $workRootDir "gdd_lab01\gdd-wiki"
    $resultDir = Join-Path $rootDir "results"
    $logDir = Join-Path $rootDir "logs"
    $summaryCsv = Join-Path $logDir "runs_summary.csv"

    if ($UseSample) {
        $inputPath = Join-Path $dataDir "es-wiki-abstracts-1k.txt"
        $inputIsGzip = $false
        $inputLabel = "sample-1k"
    } else {
        $inputPath = Join-Path $dataDir "es-wiki-abstracts.txt.gz"
        $inputIsGzip = $true
        $inputLabel = "full-gzip"
    }

    $javaExe = Join-Path $JavaHome "bin\java.exe"
    if (-not (Test-Path -LiteralPath $javaExe)) {
        throw "No se encontro java.exe en: $javaExe"
    }
    if (-not (Test-Path -LiteralPath $inputPath)) {
        throw "No se encontro el archivo de entrada: $inputPath"
    }
    if (-not (Test-Path -LiteralPath $projectDir)) {
        throw "No se encontro el proyecto Java: $projectDir"
    }

    New-Item -ItemType Directory -Force -Path $resultDir, $logDir | Out-Null

    $resultWriteProbe = Join-Path $resultDir "codex-write-probe.tmp"
    try {
        "probe" | Set-Content -LiteralPath $resultWriteProbe -Encoding ASCII
        Remove-Item -LiteralPath $resultWriteProbe -Force -ErrorAction Stop
    } catch {
        throw "No se pudo escribir en '$resultDir'. El laboratorio esta configurado para dejar todos los resultados en ese directorio; corrige permisos antes de ejecutar."
    }

    $logWriteProbe = Join-Path $logDir "codex-write-probe.tmp"
    try {
        "probe" | Set-Content -LiteralPath $logWriteProbe -Encoding ASCII
        Remove-Item -LiteralPath $logWriteProbe -Force -ErrorAction Stop
    } catch {
        throw "No se pudo escribir en '$logDir'. El laboratorio esta configurado para dejar todas las trazas y evidencias en ese directorio; corrige permisos antes de ejecutar."
    }

    if (-not (Test-Path -LiteralPath $summaryCsv)) {
        "timestamp,name,input,heap,exit_code,elapsed_seconds,stdout,stderr,args" | Set-Content -LiteralPath $summaryCsv -Encoding UTF8
    }

    [pscustomobject]@{
        JavaExe       = $javaExe
        Heap          = $Heap
        NValues       = $NValues
        TopK          = $TopK
        BatchSize     = $BatchSize
        ExternalN     = $ExternalN
        Force         = [bool]$Force
        RootDir       = $rootDir
        DataDir       = $dataDir
        ProjectDir    = $projectDir
        ResultDir     = $resultDir
        LogDir        = $logDir
        SummaryCsv    = $summaryCsv
        InputPath     = $inputPath
        InputIsGzip   = $inputIsGzip
        InputLabel    = $inputLabel
        ActiveResultDir = $resultDir
        Classpath     = "bin;lib\commons-cli-1.1.jar"
        MainClass     = "org.mdp.cli.Main"
    }
}

function ConvertTo-Lab01CsvField {
    param([string]$Value)
    if ($null -eq $Value) {
        return '""'
    }
    return '"' + ($Value -replace '"', '""') + '"'
}

function Get-Lab01RunPaths {
    param(
        [pscustomobject]$RunContext,
        [string]$RunName
    )

    $stdout = Join-Path $RunContext.LogDir "$RunName.stdout.txt"
    $stderr = Join-Path $RunContext.LogDir "$RunName.stderr.log"
    $meta = Join-Path $RunContext.LogDir "$RunName.meta.txt"
    $done = Join-Path $RunContext.LogDir "$RunName.done"
    return @{
        Stdout = $stdout
        Stderr = $stderr
        Meta   = $meta
        Done   = $done
    }
}

function New-Lab01RunMetadataLines {
    param(
        [pscustomobject]$RunContext,
        [string]$RunName,
        [string[]]$AllArguments,
        [hashtable]$RunPaths,
        [datetime]$StartedAt
    )

    return @(
        "# Lab01 run metadata",
        "timestamp_start=$($StartedAt.ToString("s"))",
        "name=$RunName",
        "java=$($RunContext.JavaExe)",
        "heap=-Xmx$($RunContext.Heap)",
        "input_label=$($RunContext.InputLabel)",
        "input_path=$($RunContext.InputPath)",
        "top_k=$($RunContext.TopK)",
        "batch_size=$($RunContext.BatchSize)",
        "project_dir=$($RunContext.ProjectDir)",
        "result_dir=$($RunContext.ActiveResultDir)",
        "stdout=$($RunPaths.Stdout)",
        "stderr=$($RunPaths.Stderr)",
        "command=$($AllArguments -join " ")",
        ""
    )
}

function Invoke-Lab01Java {
    param(
        [pscustomobject]$RunContext,
        [string]$RunName,
        [string[]]$ProgramArguments
    )

    $runPaths = Get-Lab01RunPaths -RunContext $RunContext -RunName $RunName
    if ((Test-Path -LiteralPath $runPaths.Done) -and -not $RunContext.Force) {
        Write-Host "[SKIP] $RunName ya tiene marcador .done. Usa -Force para repetir."
        return
    }

    Write-Host "[RUN ] $RunName"
    Write-Host "       args: $($ProgramArguments -join ' ')"

    $jvmArguments = @("-Xmx$($RunContext.Heap)", "-cp", $RunContext.Classpath, $RunContext.MainClass)
    $allArguments = @($jvmArguments + $ProgramArguments)
    $startedAt = Get-Date
    $metadataLines = New-Lab01RunMetadataLines -RunContext $RunContext -RunName $RunName -AllArguments $allArguments -RunPaths $runPaths -StartedAt $startedAt
    $metadataLines | Set-Content -LiteralPath $runPaths.Meta -Encoding UTF8
    $rawStderr = Join-Path $RunContext.LogDir "$RunName.stderr.raw.tmp"
    if (Test-Path -LiteralPath $rawStderr) {
        Remove-Item -LiteralPath $rawStderr -Force
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $process = Start-Process `
            -FilePath $RunContext.JavaExe `
            -ArgumentList $allArguments `
            -WorkingDirectory $RunContext.ProjectDir `
            -RedirectStandardOutput $runPaths.Stdout `
            -RedirectStandardError $rawStderr `
            -NoNewWindow `
            -Wait `
            -PassThru
        $exitCode = $process.ExitCode
    } finally {
        $sw.Stop()
    }

    $metadataLines | Set-Content -LiteralPath $runPaths.Stderr -Encoding UTF8
    if (Test-Path -LiteralPath $rawStderr) {
        $stderrText = [System.IO.File]::ReadAllText($rawStderr, [System.Text.Encoding]::Default)
        if ($stderrText.Length -gt 0) {
            Add-Content -LiteralPath $runPaths.Stderr -Encoding UTF8 -Value $stderrText
        }
        Remove-Item -LiteralPath $rawStderr -Force
    }

    $elapsed = [Math]::Round($sw.Elapsed.TotalSeconds, 3)
    $argText = ($allArguments -join " ")
    $fields = @(
        (Get-Date).ToString("s"),
        $RunName,
        $RunContext.InputLabel,
        $RunContext.Heap,
        "$exitCode",
        "$elapsed",
        $runPaths.Stdout,
        $runPaths.Stderr,
        $argText
    )
    $row = (($fields | ForEach-Object { ConvertTo-Lab01CsvField -Value $_ }) -join ",")
    Add-Content -LiteralPath $RunContext.SummaryCsv -Encoding UTF8 -Value $row

    if ($exitCode -eq 0) {
        "completed $(Get-Date -Format s)" | Set-Content -LiteralPath $runPaths.Done -Encoding UTF8
        Write-Host "[ OK ] $RunName en $elapsed segundos"
    } else {
        Write-Host "[FAIL] $RunName termino con codigo $exitCode en $elapsed segundos"
        Write-Host "       Revisa: $($runPaths.Stderr)"
    }
}

function Add-Lab01GzipFlagIfNeeded {
    param(
        [pscustomobject]$RunContext,
        [string[]]$InputArguments
    )
    if ($RunContext.InputIsGzip) {
        return @($InputArguments + @("-igz"))
    }
    return $InputArguments
}

function Add-Lab01OutputGzipFlagIfNeeded {
    param(
        [pscustomobject]$RunContext,
        [string[]]$InputArguments
    )
    if ($RunContext.InputIsGzip) {
        return @($InputArguments + @("-ogz"))
    }
    return $InputArguments
}

function Show-Lab01RunHeader {
    param(
        [pscustomobject]$RunContext,
        [string]$ModeLabel
    )

    Write-Host "== Lab01 $ModeLabel =="
    Write-Host "Java: $($RunContext.JavaExe)"
    Write-Host "Heap: -Xmx$($RunContext.Heap)"
    Write-Host "Data: $($RunContext.DataDir)"
    Write-Host "Project: $($RunContext.ProjectDir)"
    Write-Host "Input: $($RunContext.InputPath)"
    Write-Host "Logs: $($RunContext.LogDir)"
    Write-Host "Results: $($RunContext.ActiveResultDir)"
    Write-Host "Summary: $($RunContext.SummaryCsv)"
}

function Invoke-Lab01InMemory {
    param([pscustomobject]$RunContext)

    Show-Lab01RunHeader -RunContext $RunContext -ModeLabel "in-memory"

    $wordArguments = @("RunWordCountInMemory", "-i", $RunContext.InputPath)
    $wordArguments = Add-Lab01GzipFlagIfNeeded -RunContext $RunContext -InputArguments $wordArguments
    $wordArguments += @("-k", "$($RunContext.TopK)")
    Invoke-Lab01Java -RunContext $RunContext -RunName "wordcount_$($RunContext.InputLabel)_top$($RunContext.TopK)" -ProgramArguments $wordArguments

    foreach ($n in $RunContext.NValues) {
        $ngramArguments = @("RunNGramCountInMemory", "-i", $RunContext.InputPath)
        $ngramArguments = Add-Lab01GzipFlagIfNeeded -RunContext $RunContext -InputArguments $ngramArguments
        $ngramArguments += @("-k", "$($RunContext.TopK)", "-n", "$n")
        Invoke-Lab01Java -RunContext $RunContext -RunName "ngram_inmemory_$($RunContext.InputLabel)_n${n}_top$($RunContext.TopK)" -ProgramArguments $ngramArguments
    }

    Write-Host "== Terminado =="
    Write-Host "Resumen CSV: $($RunContext.SummaryCsv)"
}

function Invoke-Lab01ExternalPipeline {
    param([pscustomobject]$RunContext)

    Show-Lab01RunHeader -RunContext $RunContext -ModeLabel "external"

    $suffix = "n$($RunContext.ExternalN)"
    if ($RunContext.InputIsGzip) {
        $ngrams = Join-Path $RunContext.ActiveResultDir "es-wiki-abstracts-$suffix-grams.txt.gz"
        $sorted = Join-Path $RunContext.ActiveResultDir "es-wiki-abstracts-$suffix-grams-s.txt.gz"
        $counted = Join-Path $RunContext.ActiveResultDir "es-wiki-abstracts-$suffix-grams-c.txt.gz"
        $ranked = Join-Path $RunContext.ActiveResultDir "es-wiki-abstracts-$suffix-grams-c-s.txt.gz"
    } else {
        $ngrams = Join-Path $RunContext.ActiveResultDir "es-wiki-abstracts-$suffix-grams.txt"
        $sorted = Join-Path $RunContext.ActiveResultDir "es-wiki-abstracts-$suffix-grams-s.txt"
        $counted = Join-Path $RunContext.ActiveResultDir "es-wiki-abstracts-$suffix-grams-c.txt"
        $ranked = Join-Path $RunContext.ActiveResultDir "es-wiki-abstracts-$suffix-grams-c-s.txt"
    }
    $topFile = Join-Path $RunContext.ActiveResultDir "es-wiki-abstracts-$suffix-grams-c-s-top$($RunContext.TopK).txt"
    $tmpDir = Join-Path $RunContext.ActiveResultDir "tmp"
    New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null

    $extractArguments = @("ExtractNGrams", "-i", $RunContext.InputPath)
    $extractArguments = Add-Lab01GzipFlagIfNeeded -RunContext $RunContext -InputArguments $extractArguments
    $extractArguments += @("-n", "$($RunContext.ExternalN)", "-o", $ngrams)
    $extractArguments = Add-Lab01OutputGzipFlagIfNeeded -RunContext $RunContext -InputArguments $extractArguments
    Invoke-Lab01Java -RunContext $RunContext -RunName "external_01_extract_$($RunContext.InputLabel)_$suffix" -ProgramArguments $extractArguments

    $sortArguments = @("ExternalMergeSort", "-i", $ngrams)
    $sortArguments = Add-Lab01GzipFlagIfNeeded -RunContext $RunContext -InputArguments $sortArguments
    $sortArguments += @("-o", $sorted)
    $sortArguments = Add-Lab01OutputGzipFlagIfNeeded -RunContext $RunContext -InputArguments $sortArguments
    $sortArguments += @("-tmp", $tmpDir, "-b", "$($RunContext.BatchSize)")
    Invoke-Lab01Java -RunContext $RunContext -RunName "external_02_sort_$($RunContext.InputLabel)_${suffix}_b$($RunContext.BatchSize)" -ProgramArguments $sortArguments

    $countArguments = @("CountDuplicates", "-i", $sorted)
    $countArguments = Add-Lab01GzipFlagIfNeeded -RunContext $RunContext -InputArguments $countArguments
    $countArguments += @("-o", $counted)
    $countArguments = Add-Lab01OutputGzipFlagIfNeeded -RunContext $RunContext -InputArguments $countArguments
    Invoke-Lab01Java -RunContext $RunContext -RunName "external_03_count_$($RunContext.InputLabel)_$suffix" -ProgramArguments $countArguments

    $rankArguments = @("ExternalMergeSort", "-i", $counted)
    $rankArguments = Add-Lab01GzipFlagIfNeeded -RunContext $RunContext -InputArguments $rankArguments
    $rankArguments += @("-o", $ranked)
    $rankArguments = Add-Lab01OutputGzipFlagIfNeeded -RunContext $RunContext -InputArguments $rankArguments
    $rankArguments += @("-tmp", $tmpDir, "-b", "$($RunContext.BatchSize)", "-r")
    Invoke-Lab01Java -RunContext $RunContext -RunName "external_04_rank_$($RunContext.InputLabel)_${suffix}_b$($RunContext.BatchSize)" -ProgramArguments $rankArguments

    $headArguments = @("Head", "-i", $ranked)
    $headArguments = Add-Lab01GzipFlagIfNeeded -RunContext $RunContext -InputArguments $headArguments
    $headArguments += @("-k", "$($RunContext.TopK)", "-o", $topFile)
    Invoke-Lab01Java -RunContext $RunContext -RunName "external_05_head_$($RunContext.InputLabel)_${suffix}_top$($RunContext.TopK)" -ProgramArguments $headArguments

    Write-Host "Top-$($RunContext.TopK) esperado en: $topFile"
    Write-Host "== Terminado =="
    Write-Host "Resumen CSV: $($RunContext.SummaryCsv)"
}
