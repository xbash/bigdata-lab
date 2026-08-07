function Get-ProjectEnvFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    Join-Path $Root "conf\image-tags.conf"
}

function Get-ProjectEnvMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $envFile = Get-ProjectEnvFile -Root $Root
    if (-not (Test-Path -LiteralPath $envFile)) {
        throw "No se encontro el archivo de variables del proyecto: $envFile"
    }

    $values = @{}
    foreach ($rawLine in Get-Content -LiteralPath $envFile) {
        $line = $rawLine.Trim()
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#")) {
            continue
        }

        $parts = $line -split "=", 2
        if ($parts.Count -ne 2) {
            throw "Linea invalida en ${envFile}: $rawLine"
        }

        $values[$parts[0].Trim()] = $parts[1].Trim()
    }

    $values
}

function Get-ProjectEnvValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [string]$DefaultValue = ""
    )

    $envValue = [System.Environment]::GetEnvironmentVariable($Name)
    if (-not [string]::IsNullOrWhiteSpace($envValue)) {
        return $envValue
    }

    $values = Get-ProjectEnvMap -Root $Root
    if ($values.ContainsKey($Name)) {
        return $values[$Name]
    }

    $DefaultValue
}

function Get-RequiredProjectEnvValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $value = Get-ProjectEnvValue -Root $Root -Name $Name
    if ([string]::IsNullOrWhiteSpace($value)) {
        $envFile = Get-ProjectEnvFile -Root $Root
        throw "Falta la variable requerida '$Name' en $envFile o en el entorno actual."
    }

    return $value
}

function Get-ComposeEnvArgs {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $envFile = Get-ProjectEnvFile -Root $Root
    if (-not (Test-Path -LiteralPath $envFile)) {
        throw "No se encontro el archivo de variables del proyecto: $envFile"
    }

    @("--env-file", $envFile)
}
