#requires -Version 7.4
<#
.SYNOPSIS
Regenera el icono geometrico original de 256x256. Solo Windows; no es un render del juego.
.DESCRIPTION
Usa System.Drawing del runtime de PowerShell. El build utiliza el PNG versionado
y no necesita ejecutar este generador. Colores y vertices se editan aqui.
#>
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'La regeneracion del icono requiere Windows.' }
Add-Type -AssemblyName System.Drawing
$size = 256
$outputPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'pack/pack_icon.png'
$bitmap = [Drawing.Bitmap]::new($size, $size)
$canvas = [Drawing.Graphics]::FromImage($bitmap)

function Draw-Facet([string] $Color, [int[]] $Coordinates) {
    $points = [Collections.Generic.List[Drawing.Point]]::new()
    for ($i = 0; $i -lt $Coordinates.Count; $i += 2) {
        $points.Add([Drawing.Point]::new($Coordinates[$i], $Coordinates[$i + 1]))
    }
    $brush = [Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml($Color))
    try { $canvas.FillPolygon($brush, $points.ToArray()) } finally { $brush.Dispose() }
}

try {
    $canvas.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $background = [Drawing.Drawing2D.LinearGradientBrush]::new(
        [Drawing.Point]::new(0, 0), [Drawing.Point]::new(256, 256),
        [Drawing.ColorTranslator]::FromHtml('#0B213C'), [Drawing.ColorTranslator]::FromHtml('#261743'))
    try { $canvas.FillRectangle($background, 0, 0, $size, $size) } finally { $background.Dispose() }
    Draw-Facet '#36476D' @(38,188, 128,160, 218,188, 128,226)
    Draw-Facet '#D2FAF8' @(128,34, 58,89, 119,102)
    Draw-Facet '#88E6F1' @(128,34, 198,89, 119,102)
    Draw-Facet '#44BDD7' @(58,89, 119,102, 128,204, 58,162)
    Draw-Facet '#508FD3' @(119,102, 198,89, 198,162, 128,204)
    Draw-Facet '#A4BAF2' @(119,102, 198,162, 128,204)
    Draw-Facet '#C9FCFC' @(58,89, 66,99, 66,159, 58,162)
    Draw-Facet '#FFFFFF' @(128,48, 132,61, 145,65, 132,69, 128,82, 124,69, 111,65, 124,61)
    $bitmap.Save($outputPath, [Drawing.Imaging.ImageFormat]::Png)
} finally {
    $canvas.Dispose()
    $bitmap.Dispose()
}
Write-Host "Icono creado: $outputPath"
