#requires -Version 7.4
<#
.SYNOPSIS
Valida y genera dist/cristal-boreal-<version>.mcpack sin abrir Minecraft.
.DESCRIPTION
ZIP estandar mediante .NET. Orden y fechas fijos para repetibilidad con el mismo
runtime. El manifest queda en la raiz. No compila shaders ni aplica perfiles.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$result = & (Join-Path $PSScriptRoot 'validate.ps1') -PassThru

# Constantes del empaquetado; la version se edita unicamente en el manifest.
$artifactPrefix = 'cristal-boreal'
$zipTimestamp = [DateTimeOffset]::new(2000, 1, 1, 0, 0, 0, [TimeSpan]::Zero)
$compression = [IO.Compression.CompressionLevel]::Optimal
$version = $result.Manifest.header.version -join '.'
$outputDirectory = Join-Path $projectRoot 'dist'
if (Test-Path -LiteralPath $outputDirectory) {
    $outputItem = Get-Item -LiteralPath $outputDirectory -Force
    if (-not $outputItem.PSIsContainer -or ($outputItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw 'dist debe ser una carpeta local, no un enlace.'
    }
}
[void][IO.Directory]::CreateDirectory($outputDirectory)
$outputPath = Join-Path $outputDirectory "$artifactPrefix-$version.mcpack"
$temporaryPath = Join-Path $outputDirectory ('.build-' + [guid]::NewGuid().ToString('N') + '.tmp')
$hashPath = "$outputPath.sha256"

try {
    $zip = [IO.Compression.ZipFile]::Open($temporaryPath, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($file in $result.Files | Sort-Object FullName) {
            $entryName = [IO.Path]::GetRelativePath($result.PackPath, $file.FullName).Replace('\', '/')
            $entry = $zip.CreateEntry($entryName, $compression)
            $entry.LastWriteTime = $zipTimestamp
            $inputStream = [IO.File]::OpenRead($file.FullName)
            try {
                $entryStream = $entry.Open()
                try { $inputStream.CopyTo($entryStream) } finally { $entryStream.Dispose() }
            } finally { $inputStream.Dispose() }
        }
    } finally { $zip.Dispose() }

    # Reabrir y comparar hashes del contenido descomprimido con los originales.
    $zip = [IO.Compression.ZipFile]::OpenRead($temporaryPath)
    try {
        if ($zip.Entries.Count -ne $result.Files.Count -or $null -eq $zip.GetEntry('manifest.json')) {
            throw 'ZIP invalido: manifest en raiz o numero de archivos incorrecto.'
        }
        foreach ($file in $result.Files) {
            $entryName = [IO.Path]::GetRelativePath($result.PackPath, $file.FullName).Replace('\', '/')
            $entry = $zip.GetEntry($entryName)
            if ($null -eq $entry) { throw "Falta entrada ZIP: $entryName" }
            $stream = $entry.Open()
            try { $packedHash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($stream)) }
            finally { $stream.Dispose() }
            if ($packedHash -ne (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash) {
                throw "Contenido ZIP distinto del original: $entryName"
            }
        }
    } finally { $zip.Dispose() }

    # Solo sustituir nuestro artefacto tras validar. No borrar carpetas de salida.
    foreach ($destination in @($outputPath, $hashPath)) {
        if ((Test-Path -LiteralPath $destination) -and ((Get-Item -LiteralPath $destination -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw "Destino enlazado no permitido: $destination"
        }
    }
    [IO.File]::Move($temporaryPath, $outputPath, $true)
    $hash = (Get-FileHash -LiteralPath $outputPath -Algorithm SHA256).Hash.ToLowerInvariant()
    [IO.File]::WriteAllText($hashPath, "$hash  $([IO.Path]::GetFileName($outputPath))`n", [Text.UTF8Encoding]::new($false))
    Write-Host "Build OK: $outputPath ($((Get-Item -LiteralPath $outputPath).Length) bytes)"
    Write-Host "SHA-256: $hash"
    Write-Host 'Comprobado: contenedor ZIP y contenido. Pendiente: importacion y renderizado en Minecraft.'
} finally {
    if ([IO.File]::Exists($temporaryPath)) { [IO.File]::Delete($temporaryPath) }
}
