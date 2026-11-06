function Get-ProjectEnvFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    Join-Path $Root "VERSION"
}

function Get-ProjectEnvMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $envFile = Get-ProjectEnvFile -Root $Root
    if (-not (Test-Path -LiteralPath $envFile)) {
        throw "No se encontro el archivo de version del proyecto: $envFile"
    }

    $version = (Get-Content -LiteralPath $envFile -Raw).Trim()
    if ([string]::IsNullOrWhiteSpace($version)) {
        throw "El archivo de version del proyecto esta vacio: $envFile"
    }

    @{ BIGDATA_IMAGE_TAG = $version }
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
        throw "Falta la variable requerida '$Name' en el entorno actual ni en $envFile."
    }

    return $value
}

function Get-ComposeEnvArgs {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    # Compose toma BIGDATA_IMAGE_TAG del entorno; no hay --env-file que pasar.
    $env:BIGDATA_IMAGE_TAG = Get-RequiredProjectEnvValue -Root $Root -Name "BIGDATA_IMAGE_TAG"
    , @() # array vacio: si devolviera $null, el splat pasaria un argumento vacio a podman
}
