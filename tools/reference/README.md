# Referencias de día

`source-index.json` y `vanilla-day.json` son datos internos de herramientas, **no
formatos de resource pack**. El build funciona sin red; no copia estos archivos al pack.

- Origen: [Mojang/bedrock-samples v1.26.50.4](https://github.com/Mojang/bedrock-samples/releases/tag/v1.26.50.4).
- Revisión fijada: `46ba6ea985fb5a92d79a9419198f10dda14c199d`.
- Consultado/descargado: 2026-09-30 mediante PowerShell 7.6.5.
- Cobertura: 83 biomas del Overworld, 13 luces y 11 atmósferas, 107 archivos fuente.
- Excluidos del índice: basalt_deltas, crimson_forest, hell, soulsand_valley, warped_forest y the_end.
- La revisión 26.50.4 es una referencia estable publicada; no demuestra identidad de todos los recursos con el hotfix Android 1.26.52.3.

Cada registro conserva la ruta original, SHA-256 del texto HTTP original codificado
en UTF-8 y su JSON parseado. La serialización del snapshot cambia espacios y orden
visual; su hash no debe confundirse con el hash del archivo HTTP original.
`fetch-day-reference.ps1` puede reconstruir el snapshot desde esa revisión; es una
operación opcional con red, independiente del build.

Las configuraciones de `pack/biomes` son adaptaciones que sustituyen solo los enlaces
de luz y atmósfera. Las fuentes de luz antiguas 1.21.70 se envuelven en `orbital`
del esquema 1.21.80. Las curvas solares/atmosféricas se modifican de día; se conservan
los valores nocturnos protegidos y los demás componentes. Ver `tools/day-settings.psd1`.

Los archivos fuente están sujetos al [LICENSE.md original](https://github.com/Mojang/bedrock-samples/blob/v1.26.50.4/LICENSE.md),
que remite al EULA de Minecraft. La atribución también se distribuye en `pack/CREDITS.txt`.
