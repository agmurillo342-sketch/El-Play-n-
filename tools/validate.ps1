#requires -Version 7.4
<#
.SYNOPSIS
Valida JSON estricto y el contrato local de la fase 1. No ejecuta Minecraft.
.DESCRIPTION
El contrato es deliberadamente limitado al contenido implementado. No sustituye
al cargador ni valida esquemas futuros de iluminacion, atmosfera o texturas PBR.
#>
[CmdletBinding()]
param(
    [string] $Root = (Split-Path -Parent $PSScriptRoot),
    [switch] $PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = [IO.Path]::GetFullPath($Root)

function Assert-Valid([bool] $Condition, [string] $Message) {
    if (-not $Condition) { throw $Message }
}

function Assert-UniqueKeys([System.Text.Json.JsonElement] $Element) {
    if ($Element.ValueKind -eq [System.Text.Json.JsonValueKind]::Object) {
        $names = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach ($property in $Element.EnumerateObject()) {
            Assert-Valid ($names.Add($property.Name)) "Clave JSON duplicada: $($property.Name)"
            Assert-UniqueKeys $property.Value
        }
    } elseif ($Element.ValueKind -eq [System.Text.Json.JsonValueKind]::Array) {
        foreach ($elementItem in $Element.EnumerateArray()) { Assert-UniqueKeys $elementItem }
    }
}

function Read-StrictJson([string] $Path) {
    # ConvertFrom-Json admite comentarios; JsonDocument los rechaza primero.
    $utf8 = [Text.UTF8Encoding]::new($false, $true)
    $source = $utf8.GetString([IO.File]::ReadAllBytes($Path))
    $document = $null
    try {
        $document = [System.Text.Json.JsonDocument]::Parse($source)
        Assert-UniqueKeys $document.RootElement
        return ConvertFrom-Json -InputObject $source -AsHashtable -Depth 100
    } catch {
        throw "JSON invalido en ${Path}: $($_.Exception.Message)"
    } finally {
        if ($null -ne $document) { $document.Dispose() }
    }
}

function Get-SourceFiles([string] $Directory) {
    # No seguir enlaces/junctions ni empaquetar archivos externos al proyecto.
    $item = Get-Item -LiteralPath $Directory -Force
    Assert-Valid (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0) "Enlace no permitido: $Directory"
    foreach ($child in Get-ChildItem -LiteralPath $Directory -Force | Sort-Object Name) {
        Assert-Valid (($child.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0) "Enlace no permitido: $($child.FullName)"
        if ($child.PSIsContainer) { Get-SourceFiles $child.FullName } else { $child }
    }
}

function Assert-Version($Value, [string] $Label) {
    Assert-Valid ($Value -is [array] -and $Value.Count -eq 3) "$Label requiere tres enteros."
    foreach ($part in $Value) {
        Assert-Valid (($part -is [long] -or $part -is [int]) -and $part -ge 0 -and $part -le [int]::MaxValue) "$Label contiene una version invalida."
    }
}

function Assert-Keys($Value, [string[]] $Expected, [string] $Label) {
    Assert-Valid ($Value -is [Collections.IDictionary]) "$Label debe ser un objeto."
    Assert-Valid ($Value.Count -eq $Expected.Count) "$Label contiene claves faltantes o no implementadas."
    foreach ($key in $Expected) { Assert-Valid ($Value.Contains($key)) "Falta $Label.$key" }
}

$packPath = Join-Path $Root 'pack'
$requiredDirectories = @(
    'pack/materials', 'pack/lighting', 'pack/atmospherics', 'pack/color_grading',
    'pack/local_lighting', 'pack/pbr', 'pack/textures/blocks',
    'pack/textures/environment', 'pack/textures/entity', 'pack/textures/items',
    'pack/textures/particle', 'profiles', 'tools'
)
foreach ($directory in $requiredDirectories) {
    Assert-Valid (Test-Path -LiteralPath (Join-Path $Root $directory) -PathType Container) "Falta carpeta: $directory"
}

$packFiles = @(Get-SourceFiles $packPath)
$profileFiles = @(Get-SourceFiles (Join-Path $Root 'profiles'))
$toolFiles = @(Get-SourceFiles (Join-Path $Root 'tools'))
$rootJson = @(Get-ChildItem -LiteralPath $Root -File -Filter '*.json')
$jsonFiles = @(@($packFiles + $profileFiles + $toolFiles + $rootJson) | Where-Object Extension -EQ '.json')
$parsed = @{}
foreach ($file in $jsonFiles) { $parsed[$file.FullName] = Read-StrictJson $file.FullName }

$manifestPath = Join-Path $packPath 'manifest.json'
Assert-Valid ($parsed.ContainsKey($manifestPath)) 'Falta pack/manifest.json.'
$manifest = $parsed[$manifestPath]
Assert-Keys $manifest @('format_version', 'header', 'modules', 'capabilities') 'manifest'
Assert-Valid ($manifest.format_version -eq 2) 'Se requiere manifest format_version 2.'
Assert-Keys $manifest.header @('name', 'description', 'uuid', 'version', 'min_engine_version', 'pack_scope') 'header'
foreach ($key in @('name', 'description')) {
    Assert-Valid ($manifest.header[$key] -is [string] -and -not [string]::IsNullOrWhiteSpace($manifest.header[$key])) "header.$key debe ser texto no vacio."
}
Assert-Version $manifest.header.version 'header.version'
Assert-Version $manifest.header.min_engine_version 'header.min_engine_version'
# Minimo documentado para la capacidad pbr; no es una certificacion de versiones.
Assert-Valid ([version]($manifest.header.min_engine_version -join '.') -ge [version]'1.21.120') 'pbr requiere min_engine_version >= 1.21.120.'
Assert-Valid ($manifest.header.pack_scope -eq 'world') 'El pack de prueba se activa por mundo.'
Assert-Valid ($manifest.capabilities -is [array] -and $manifest.capabilities.Count -eq 1 -and $manifest.capabilities[0] -ceq 'pbr') 'Se requiere capabilities: ["pbr"].'
Assert-Valid ($manifest.modules -is [array] -and $manifest.modules.Count -eq 1) 'Se requiere un modulo de recursos.'
$module = $manifest.modules[0]
Assert-Keys $module @('description', 'type', 'uuid', 'version') 'modules[0]'
Assert-Valid ($module.type -ceq 'resources') 'El modulo debe ser resources.'
Assert-Version $module.version 'modules[0].version'
Assert-Valid (($module.version -join '.') -eq ($manifest.header.version -join '.')) 'Las versiones del header y modulo deben coincidir.'
$uuidPattern = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
foreach ($uuid in @($manifest.header.uuid, $module.uuid)) {
    Assert-Valid ($uuid -is [string] -and $uuid -match $uuidPattern -and [guid]$uuid -ne [guid]::Empty) "UUID invalido: $uuid"
}
Assert-Valid ($manifest.header.uuid -ne $module.uuid) 'Los UUID del header y modulo deben ser distintos.'

$profileNames = @('bajo', 'medio', 'alto')
Assert-Valid (@($profileFiles | Where-Object Extension -EQ '.json').Count -eq 3) 'Se requieren exactamente tres perfiles JSON.'
foreach ($profile in $profileNames) {
    $profilePath = Join-Path $Root "profiles/$profile.json"
    Assert-Valid ($parsed.ContainsKey($profilePath)) "Falta perfil: $profile"
    Assert-Valid ($parsed[$profilePath] -is [Collections.IDictionary] -and $parsed[$profilePath].Count -eq 0) "El perfil $profile debe estar vacio en fase 1."
}

# La fase 1 solo publica estos dos archivos; las reservas .gitkeep no se envian.
$packageFiles = @($packFiles | Where-Object Name -NE '.gitkeep')
$expectedEntries = @('manifest.json', 'pack_icon.png')
Assert-Valid ($packageFiles.Count -eq $expectedEntries.Count) 'La fase 1 solo empaqueta manifest.json y pack_icon.png.'
foreach ($entryName in $expectedEntries) {
    Assert-Valid (Test-Path -LiteralPath (Join-Path $packPath $entryName) -PathType Leaf) "Falta $entryName"
}
$icon = [IO.File]::ReadAllBytes((Join-Path $packPath 'pack_icon.png'))
Assert-Valid ($icon.Length -ge 33) 'El icono PNG esta incompleto.'
Assert-Valid ([Convert]::ToHexString($icon[0..7]) -eq '89504E470D0A1A0A') 'Firma PNG invalida.'
Assert-Valid ([Text.Encoding]::ASCII.GetString($icon, 12, 4) -eq 'IHDR') 'Cabecera PNG invalida.'
# 256 x 256, big-endian. Es una decision del proyecto, no un requisito del motor.
Assert-Valid ([Convert]::ToHexString($icon[16..23]) -eq '0000010000000100') 'El icono debe medir 256 x 256.'
Write-Host "Validacion estatica OK: $($jsonFiles.Count) JSON; manifest v2; 3 perfiles vacios; cabecera PNG 256x256."
if ($PassThru) {
    [pscustomobject]@{ Manifest = $manifest; PackPath = $packPath; Files = $packageFiles; JsonCount = $jsonFiles.Count }
}
