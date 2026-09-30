#requires -Version 7.4
<#
.SYNOPSIS
Descarga de forma opcional las referencias publicas de Mojang fijadas por revision.
.DESCRIPTION
No se ejecuta durante el build. Conserva las fuentes en un snapshot JSON interno,
fuera del pack, para comparar noches/componentes vanilla sin necesitar Internet.
#>
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$index = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'reference/source-index.json') -Raw | ConvertFrom-Json -AsHashtable
$revision = $index.revision
$requests = @(
    foreach ($name in $index.biomes) { "resource_pack/biomes/$name.client_biome.json" }
    foreach ($name in $index.lighting) { "resource_pack/lighting/$name.json" }
    foreach ($name in $index.atmospherics) { "resource_pack/atmospherics/$name.json" }
)
$records = @($requests | ForEach-Object -Parallel {
    $ErrorActionPreference = 'Stop'
    $path = $_
    $url = "https://raw.githubusercontent.com/Mojang/bedrock-samples/$using:revision/$path"
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            $source = (Invoke-WebRequest -Uri $url -TimeoutSec 15).Content
            $data = ConvertFrom-Json -InputObject $source -AsHashtable -Depth 100
            $digest = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($source))).ToLowerInvariant()
            Write-Host "Referencia: $path"
            [pscustomobject]@{ Path = $path; Sha256 = $digest; Data = $data }
            break
        } catch {
            if ($attempt -eq 3) { throw "No se pudo obtener ${path}: $($_.Exception.Message)" }
        }
    }
} -ThrottleLimit 6)
if ($records.Count -ne $requests.Count) { throw 'Descarga incompleta; no se modifica el snapshot.' }
$files = [ordered]@{}
foreach ($record in $records | Sort-Object Path) {
    $files[$record.Path] = [ordered]@{ sha256 = $record.Sha256; data = $record.Data }
}
$snapshot = [ordered]@{ revision = $revision; files = $files }
$destination = Join-Path $PSScriptRoot 'reference/vanilla-day.json'
$jsonText = ($snapshot | ConvertTo-Json -Depth 100).Replace("`r`n", "`n")
[IO.File]::WriteAllText($destination, $jsonText + "`n", [Text.UTF8Encoding]::new($false))
Write-Host "Snapshot completo: $($records.Count) archivos en $destination"
