# Parametros internos del generador; NO es un formato de Minecraft.
# Tiempo VV: 0/1 = mediodia, 0.25 = ocaso, 0.5 = medianoche, 0.75 = amanecer.
@{
    # Entre 0.32 y 0.68 se conserva la curva de referencia sin modificarla.
    DayWeight = @{ '0'=1.0; '0.20'=1.0; '0.28'=0.3; '0.32'=0.0; '0.68'=0.0; '0.72'=0.3; '0.80'=1.0; '1'=1.0 }
    SunIlluminanceGain = 1.10
    SunColorBlend = 0.60
    SunColor = @{ '0'=@(255,240,199); '0.18'=@(255,222,164); '0.25'=@(255,172,100); '0.75'=@(255,182,112); '0.82'=@(255,226,172); '1'=@(255,240,199) }
    RayleighGain = 1.04
    SunMieAddition = 0.06
    SunGlareAddition = 0.025
    ZenithColor = @(94,144,200)
    ZenithBlend = 0.20
    HorizonColor = @(184,206,224)
    HorizonBlend = 0.15
    # Textura analitica circular, con bordes transparentes negros para evitar un cuadro.
    SunTextureSize = 256
    SunDiscRadius = 0.30
    SunHaloRadius = 0.48
    SunHaloStrength = 0.12
    SunDiscColor = @(255,237,172)
    SunEdgeColor = @(255,203,107)
}
