# Contrato de los campos utilizados en fase 2, basado en documentacion oficial.
# Se carga desde validate.ps1; depende de sus funciones Assert-Valid/Assert-Keys.
. (Join-Path $PSScriptRoot 'lib/day.ps1')

function Assert-SameData($Actual, $Expected, [string] $Label) {
    $a = ConvertTo-Json -InputObject $Actual -Depth 100 -Compress
    $b = ConvertTo-Json -InputObject $Expected -Depth 100 -Compress
    Assert-Valid ($a -ceq $b) "Cambio no previsto en $Label"
}

function Assert-DayCurve($Curve, [int] $Channels, [double] $Minimum, [double] $Maximum, [string] $Label) {
    $values = @($Curve)
    if ($Curve -is [Collections.IDictionary]) {
        Assert-Valid ($Curve.Count -gt 0) "Curva vacia: $Label"
        $times = [Collections.Generic.HashSet[double]]::new()
        $values = @(foreach ($key in $Curve.Keys) {
            $time = 0.0
            $isNumber = [double]::TryParse($key, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$time)
            Assert-Valid ($isNumber -and [double]::IsFinite($time) -and $time -ge 0 -and $time -le 1 -and $times.Add($time)) "Tiempo invalido o duplicado: $Label.$key"
            ,$Curve[$key]
        })
    } else { $values = @(,$Curve) }
    foreach ($value in $values) {
        Assert-Valid (@($value).Count -eq $Channels) "Numero de canales invalido: $Label"
        foreach ($number in @($value)) {
            Assert-Valid ($number -is [ValueType] -and $number -isnot [bool]) "Valor no numerico: $Label"
            Assert-Valid ([double]::IsFinite([double]$number) -and $number -ge $Minimum - 1e-8 -and $number -le $Maximum + 1e-8) "Valor fuera de rango: $Label"
        }
    }
}

function Assert-NightPreserved($Actual, $Original, [string] $Label) {
    # Comprobar todos los nudos interiores y ambas fronteras; entre nudos las
    # curvas son lineales. Se incluyen muestras adicionales entre ellos.
    $times = [Collections.Generic.SortedSet[double]]::new()
    foreach ($time in @(0.32, 0.36, 0.40, 0.44, 0.50, 0.56, 0.60, 0.64, 0.68)) { [void]$times.Add($time) }
    foreach ($curve in @($Actual, $Original)) {
        if ($curve -is [Collections.IDictionary]) {
            foreach ($key in $curve.Keys) {
                $time = [double]::Parse($key, [Globalization.CultureInfo]::InvariantCulture)
                if ($time -ge 0.32 -and $time -le 0.68) { [void]$times.Add($time) }
            }
        }
    }
    foreach ($time in $times) {
        $a = Get-CurveValue $Actual $time; $b = Get-CurveValue $Original $time
        $a = @($a); $b = @($b)
        for ($i = 0; $i -lt $a.Count; $i++) {
            Assert-Valid ([Math]::Abs($a[$i] - $b[$i]) -lt 1e-7) "Regresion nocturna: $Label en $time"
        }
    }
    $start = Get-CurveValue $Actual 0; $end = Get-CurveValue $Actual 1
    $start = @($start); $end = @($end)
    for ($i = 0; $i -lt $start.Count; $i++) {
        Assert-Valid ([Math]::Abs($start[$i] - $end[$i]) -lt 1e-7) "Discontinuidad de ciclo: $Label"
    }
}

function Test-DayAssets($Parsed, [string] $ProjectRoot, [string] $PackRoot) {
    $snapshot = $Parsed[(Join-Path $ProjectRoot 'tools/reference/vanilla-day.json')]
    $index = $Parsed[(Join-Path $ProjectRoot 'tools/reference/source-index.json')]
    Assert-Valid ($null -ne $snapshot -and $null -ne $index) 'Faltan referencias diurnas.'
    Assert-Valid ($snapshot.revision -ceq $index.revision) 'Revision de referencia inconsistente.'
    $expected = [Collections.Generic.List[string]]::new()
    foreach ($path in @('manifest.json', 'pack_icon.png', 'CREDITS.txt', 'textures/environment/sun_vv.png', 'shadows/global.json')) { $expected.Add($path) }
    $ids = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($category in @('lighting', 'atmospherics')) {
        foreach ($name in $index[$category]) {
            $relative = "$category/day_$name.json"
            $expected.Add($relative)
            $filePath = Join-Path $PackRoot $relative
            Assert-Valid ($Parsed.ContainsKey($filePath)) "Falta recurso: $relative"
            $document = $Parsed[$filePath]
            $source = $snapshot.files["resource_pack/$category/$name.json"].data
            $rootKey = if ($category -eq 'lighting') { 'minecraft:lighting_settings' } else { 'minecraft:atmosphere_settings' }
            Assert-Keys $document @('format_version', $rootKey) $relative
            $settings = $document[$rootKey]; $baseline = $source[$rootKey]
            Assert-Keys $settings.description @('identifier') "$relative.description"
            $identifier = $settings.description.identifier
            Assert-Valid ($identifier -ceq $baseline.description.identifier.Replace('minecraft:', 'cristal_boreal:day_') -and $ids.Add($identifier)) "Identificador incorrecto/duplicado: $relative"
            if ($category -eq 'lighting') {
                Assert-Valid ($document.format_version -ceq '1.21.80') "Esquema de luz incorrecto: $relative"
                $orbital = $settings.directional_lights.orbital
                Assert-Keys $orbital @('sun', 'moon', 'orbital_offset_degrees') "$relative.orbital"
                Assert-Valid ($orbital.orbital_offset_degrees -eq 0) 'La orbita debe permanecer coherente en todos los biomas.'
                $originalOrbital = if ($source.format_version -eq '1.21.70') { $baseline.directional_lights } else { $baseline.directional_lights.orbital }
                Assert-Keys $orbital.sun @('illuminance', 'color') "$relative.sun"
                Assert-DayCurve $orbital.sun.illuminance 1 0 1000000 "$relative.sun.illuminance"
                Assert-DayCurve $orbital.sun.color 3 0 255 "$relative.sun.color"
                Assert-NightPreserved $orbital.sun.illuminance $originalOrbital.sun.illuminance "$relative.sun.illuminance"
                Assert-NightPreserved $orbital.sun.color $originalOrbital.sun.color "$relative.sun.color"
                # Retirar exclusivamente los cambios permitidos y comparar el resto.
                $actualRest = Copy-DayData $settings; $sourceRest = Copy-DayData $baseline
                if ($source.format_version -eq '1.21.70') { $sourceRest.directional_lights = [ordered]@{ orbital = $sourceRest.directional_lights } }
                $sourceRest.directional_lights.orbital['orbital_offset_degrees'] = 0.0
                $actualRest.description = $sourceRest.description
                $actualRest.directional_lights.orbital.sun = $sourceRest.directional_lights.orbital.sun
                Assert-SameData $actualRest $sourceRest "$relative (luna, ambiente, emisores y campos ajenos al dia)"
            } else {
                Assert-Valid ($document.format_version -ceq '1.21.40') "Esquema atmosferico incorrecto: $relative"
                Assert-Keys $settings @('description','horizon_blend_stops','rayleigh_strength','sun_mie_strength','moon_mie_strength','sun_glare_shape','sky_zenith_color','sky_horizon_color') $relative
                foreach ($field in @('rayleigh_strength','sun_mie_strength','sun_glare_shape','sky_zenith_color','sky_horizon_color')) {
                    $channels = if ($field -match 'color$') { 3 } else { 1 }
                    $max = if ($channels -eq 3) { 255 } else { 1000 }
                    Assert-DayCurve $settings[$field] $channels 0 $max "$relative.$field"
                    Assert-NightPreserved $settings[$field] $baseline[$field] "$relative.$field"
                }
                Assert-SameData $settings.horizon_blend_stops $baseline.horizon_blend_stops "$relative.horizon_blend_stops"
                Assert-SameData $settings.moon_mie_strength $baseline.moon_mie_strength "$relative.moon_mie_strength"
            }
        }
    }
    foreach ($biome in $index.biomes) {
        $relative = "biomes/$biome.client_biome.json"
        $expected.Add($relative)
        $filePath = Join-Path $PackRoot $relative
        Assert-Valid ($Parsed.ContainsKey($filePath)) "Falta bioma: $biome"
        $document = $Parsed[$filePath]; $source = $snapshot.files["resource_pack/$relative"].data
        Assert-Keys $document @('format_version','minecraft:client_biome') $relative
        Assert-Valid ($document.format_version -ceq $source.format_version) "Version del bioma alterada: $biome"
        $components = $document['minecraft:client_biome'].components
        $originalComponents = $source['minecraft:client_biome'].components
        foreach ($kind in @('lighting','atmosphere')) {
            $component = "minecraft:${kind}_identifier"; $field = "${kind}_identifier"
            Assert-Keys $components[$component] @($field) "$relative.$component"
            $oldId = if ($originalComponents.Contains($component)) { $originalComponents[$component][$field] } elseif ($kind -eq 'lighting') { 'minecraft:default_lighting' } else { 'minecraft:default_atmospherics' }
            $newId = $components[$component][$field]
            Assert-Valid ($ids.Contains($newId) -and $newId -ceq $oldId.Replace('minecraft:', 'cristal_boreal:day_')) "Referencia de bioma no resuelta: $biome/$kind"
        }
        $actualRest = Copy-DayData $document; $sourceRest = Copy-DayData $source
        foreach ($value in @($actualRest, $sourceRest)) {
            [void]$value['minecraft:client_biome'].components.Remove('minecraft:lighting_identifier')
            [void]$value['minecraft:client_biome'].components.Remove('minecraft:atmosphere_identifier')
        }
        Assert-SameData $actualRest $sourceRest "$biome (componentes originales)"
    }
    $shadows = $Parsed[(Join-Path $PackRoot 'shadows/global.json')]
    Assert-Keys $shadows @('format_version','minecraft:shadow_settings') 'shadows/global.json'
    Assert-Keys $shadows['minecraft:shadow_settings'] @('shadow_style') 'minecraft:shadow_settings'
    Assert-Valid ($shadows.format_version -ceq '1.21.80' -and $shadows['minecraft:shadow_settings'].shadow_style -ceq 'soft_shadows') 'Se requiere el estilo oficial soft_shadows.'
    Write-Host "Dia: $($index.biomes.Count) biomas enlazados; $($ids.Count) definiciones; curvas nocturnas y componentes fuente conservados."
    return $expected.ToArray()
}
