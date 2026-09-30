# Perfiles de rendimiento

Fase 2: `bajo.json`, `medio.json` y `alto.json` siguen conteniendo exclusivamente `{}`.
Son reservas para herramientas del proyecto, **no formatos de Minecraft**.
No se incluyen en el `.mcpack`, no se aplican y aún no existe un selector.
El validador rechaza perfiles con valores para impedir ajustes silenciosamente ignorados.
El ajuste diurno común está en `tools/day-settings.psd1`; aún no es un perfil de rendimiento.

| Parámetro previsto | Unidad / significado | Implementación pendiente |
| --- | --- | --- |
| Distancia de sombras | Bloques, si hay un control documentado compatible | Verificar controles del motor y ajustes del cliente |
| Calidad de reflejos | Nivel de calidad del cliente | No asumir que un pack pueda forzar SSR |
| Intensidad de aurora | Intensidad artística del gradiente nocturno aproximado | Verificar correspondencia con atmósfera y keyframes |
| Brillo nocturno | Iluminancia ambiental y exposición | Definir límites y conversión a campos oficiales |

En la fase 6 se definirán valores, unidades y límites con los efectos ya probados.
Los ajustes que solo pueda cambiar el jugador se documentarán como recomendaciones
del menú de vídeo. No se añadirán campos ficticios al manifest ni a los JSON del juego.
