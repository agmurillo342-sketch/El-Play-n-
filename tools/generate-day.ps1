#requires -Version 7.4
<#
.SYNOPSIS
Genera los JSON de dia y el sol circular a partir de referencias locales y constantes.
.DESCRIPTION
Windows por System.Drawing. No descarga, compila materiales ni abre Minecraft.
Los JSON/PNG generados se versionan; el build solo valida y empaqueta esos archivos.
#>
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib/day.ps1')
$settings = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot 'day-settings.psd1')
$snapshot = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'reference/vanilla-day.json') -Raw | ConvertFrom-Json -AsHashtable -Depth 100
$packRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'pack'
$documents = Get-DayDocuments $snapshot $settings
foreach ($relative in $documents.Keys) {
    $destination = Join-Path $packRoot $relative
    [void][IO.Directory]::CreateDirectory((Split-Path -Parent $destination))
    $jsonText = ($documents[$relative] | ConvertTo-Json -Depth 100).Replace("`r`n", "`n")
    [IO.File]::WriteAllText($destination, $jsonText + "`n", [Text.UTF8Encoding]::new($false))
}
if (-not $IsWindows) { throw 'Regenerar el PNG requiere Windows; los JSON ya fueron escritos.' }
Add-Type -AssemblyName System.Drawing
$size = $settings.SunTextureSize
$bitmap = [Drawing.Bitmap]::new($size, $size, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
try {
    for ($y = 0; $y -lt $size; $y++) {
        for ($x = 0; $x -lt $size; $x++) {
            $radius = [Math]::Sqrt([Math]::Pow(($x + 0.5) / $size - 0.5, 2) + [Math]::Pow(($y + 0.5) / $size - 0.5, 2))
            $disc = [Math]::Clamp(($settings.SunDiscRadius - $radius) * $size + 0.5, 0.0, 1.0)
            $halo = 0.0
            if ($radius -lt $settings.SunHaloRadius) {
                $haloT = [Math]::Clamp(($radius - $settings.SunDiscRadius) / ($settings.SunHaloRadius - $settings.SunDiscRadius), 0.0, 1.0)
                $halo = $settings.SunHaloStrength * [Math]::Pow(1 - $haloT, 3)
            }
            $alpha = [Math]::Max($disc, $halo)
            $limb = [Math]::Pow([Math]::Min(1.0, $radius / $settings.SunDiscRadius), 3)
            $rgb = @(for ($channel = 0; $channel -lt 3; $channel++) {
                # RGB tambien cae a negro: el borde es seguro incluso con mezcla aditiva.
                [int][Math]::Round(($settings.SunDiscColor[$channel] * (1 - $limb) + $settings.SunEdgeColor[$channel] * $limb) * $alpha)
            })
            $bitmap.SetPixel($x, $y, [Drawing.Color]::FromArgb([int][Math]::Round(255 * $alpha), $rgb[0], $rgb[1], $rgb[2]))
        }
    }
    $bitmap.Save((Join-Path $packRoot 'textures/environment/sun_vv.png'), [Drawing.Imaging.ImageFormat]::Png)
} finally { $bitmap.Dispose() }
Write-Host "Generacion de dia: $($documents.Count) JSON y sun_vv.png $size x $size."
