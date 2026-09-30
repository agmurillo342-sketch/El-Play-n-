# Funciones puras compartidas por generador y verificaciones de datos diurnos.
# No ejecutan el motor ni aseguran la aceptacion del pack por Minecraft.
function Copy-DayData($Value) {
    ConvertFrom-Json -InputObject (ConvertTo-Json -InputObject $Value -Depth 100) -AsHashtable -Depth 100
}

function Get-CurveValue($Curve, [double] $Time) {
    if ($Curve -isnot [Collections.IDictionary]) { return ,$Curve }
    $points = @($Curve.Keys | ForEach-Object {
        [pscustomobject]@{ Time = [double]::Parse($_, [Globalization.CultureInfo]::InvariantCulture); Value = $Curve[$_] }
    } | Sort-Object Time)
    # Interpolacion ciclica tambien para curvas vanilla que omiten el punto 0 o 1.
    $samples = @([pscustomobject]@{ Time = $points[-1].Time - 1; Value = $points[-1].Value }) + $points +
        @([pscustomobject]@{ Time = $points[0].Time + 1; Value = $points[0].Value })
    for ($i = 1; $i -lt $samples.Count; $i++) {
        if ($Time -ge $samples[$i-1].Time -and $Time -le $samples[$i].Time) {
            $a = $samples[$i-1]; $b = $samples[$i]
            $fraction = if ($a.Time -eq $b.Time) { 0.0 } else { ($Time - $a.Time) / ($b.Time - $a.Time) }
            $values = @(for ($channel = 0; $channel -lt @($a.Value).Count; $channel++) {
                @($a.Value)[$channel] + (@($b.Value)[$channel] - @($a.Value)[$channel]) * $fraction
            })
            if ($values.Count -eq 1) { return $values[0] }
            return ,$values
        }
    }
    throw "Tiempo de curva no resoluble: $Time"
}

function New-DayCurve($Original, $DayWeight, [string] $Mode, $Target, [double] $Strength = 1.0) {
    $times = [Collections.Generic.SortedSet[double]]::new()
    foreach ($curve in @($Original, $DayWeight, $Target)) {
        if ($curve -is [Collections.IDictionary]) {
            foreach ($key in $curve.Keys) { [void]$times.Add([double]::Parse($key, [Globalization.CultureInfo]::InvariantCulture)) }
        }
    }
    [void]$times.Add(0); [void]$times.Add(1)
    $result = [ordered]@{}
    foreach ($time in $times) {
        $weight = (Get-CurveValue $DayWeight $time) * $Strength
        $source = Get-CurveValue $Original $time
        $destination = Get-CurveValue $Target $time
        # No redondear los valores nocturnos: conservar la interpolacion de origen.
        $value = if ($weight -eq 0) { $source } else {
            $channels = @(for ($i = 0; $i -lt @($source).Count; $i++) {
                $v = @($source)[$i]; $targetValue = @($destination)[$i]
                switch ($Mode) {
                    'scale' { $v * (1 + ($targetValue - 1) * $weight) }
                    'add' { $v + $targetValue * $weight }
                    'blend' { $v + ($targetValue - $v) * $weight }
                    default { throw "Operacion de curva desconocida: $Mode" }
                }
            })
            if ($channels.Count -eq 1) { $channels[0] } else { $channels }
        }
        $result[$time.ToString('0.######', [Globalization.CultureInfo]::InvariantCulture)] = $value
    }
    return $result
}

function Get-DayDocuments($Snapshot, $Settings) {
    $documents = [ordered]@{}
    $identifierMap = @{}
    foreach ($sourcePath in $Snapshot.files.Keys | Sort-Object) {
        if ($sourcePath -notmatch '^resource_pack/(lighting|atmospherics)/') { continue }
        $category = $Matches[1]
        $document = Copy-DayData $Snapshot.files[$sourcePath].data
        $rootKey = if ($category -eq 'lighting') { 'minecraft:lighting_settings' } else { 'minecraft:atmosphere_settings' }
        $settingsObject = $document[$rootKey]
        $oldId = $settingsObject.description.identifier
        $newId = $oldId.Replace('minecraft:', 'cristal_boreal:day_')
        $identifierMap[$oldId] = $newId
        $settingsObject.description.identifier = $newId
        $dayWeight = $Settings.DayWeight
        if ($category -eq 'lighting') {
            # Las muestras por bioma usan 1.21.70; convertir su envoltura al
            # esquema orbital documentado de 1.21.80 sin cambiar las curvas lunares.
            if ($document.format_version -eq '1.21.70') {
                $settingsObject.directional_lights = [ordered]@{ orbital = $settingsObject.directional_lights }
                $document.format_version = '1.21.80'
            }
            $settingsObject.directional_lights.orbital['orbital_offset_degrees'] = 0.0
            $sun = $settingsObject.directional_lights.orbital.sun
            $sun.illuminance = New-DayCurve $sun.illuminance $dayWeight 'scale' $Settings.SunIlluminanceGain
            $sun.color = New-DayCurve $sun.color $dayWeight 'blend' $Settings.SunColor $Settings.SunColorBlend
            # Luna, ambiente, emisores y orbita permanecen en sus valores fuente.
        } else {
            $settingsObject.rayleigh_strength = New-DayCurve $settingsObject.rayleigh_strength $dayWeight 'scale' $Settings.RayleighGain
            $settingsObject.sun_mie_strength = New-DayCurve $settingsObject.sun_mie_strength $dayWeight 'add' $Settings.SunMieAddition
            $settingsObject.sun_glare_shape = New-DayCurve $settingsObject.sun_glare_shape $dayWeight 'add' $Settings.SunGlareAddition
            $settingsObject.sky_zenith_color = New-DayCurve $settingsObject.sky_zenith_color $dayWeight 'blend' $Settings.ZenithColor $Settings.ZenithBlend
            $settingsObject.sky_horizon_color = New-DayCurve $settingsObject.sky_horizon_color $dayWeight 'blend' $Settings.HorizonColor $Settings.HorizonBlend
        }
        # Nombres no reservados: no aplicar un fallback diurno a Nether/End/biomas ajenos.
        $name = [IO.Path]::GetFileNameWithoutExtension($sourcePath)
        $documents["$category/day_$name.json"] = $document
    }
    foreach ($sourcePath in $Snapshot.files.Keys | Sort-Object) {
        if ($sourcePath -notmatch '^resource_pack/biomes/') { continue }
        $document = Copy-DayData $Snapshot.files[$sourcePath].data
        $components = $document['minecraft:client_biome'].components
        foreach ($kind in @('lighting', 'atmosphere')) {
            $component = "minecraft:${kind}_identifier"
            $field = "${kind}_identifier"
            if (-not $components.Contains($component)) {
                # Un bioma nuevo sin enlace usa el fallback global vanilla.
                $fallback = if ($kind -eq 'lighting') { 'minecraft:default_lighting' } else { 'minecraft:default_atmospherics' }
                $components[$component] = [ordered]@{ $field = $fallback }
            }
            $originalId = $components[$component][$field]
            if (-not $identifierMap.ContainsKey($originalId)) { throw "Referencia fuente no disponible: $originalId ($sourcePath)" }
            $components[$component][$field] = $identifierMap[$originalId]
        }
        $documents[$sourcePath.Replace('resource_pack/', '')] = $document
    }
    $documents['shadows/global.json'] = [ordered]@{
        format_version = '1.21.80'
        'minecraft:shadow_settings' = [ordered]@{ shadow_style = 'soft_shadows' }
    }
    return $documents
}
