# Registro y pruebas por fase

**Minecraft no se ha abierto desde este entorno.** Las casillas de pruebas manuales
solo deben marcarse después de ejecutarlas en el dispositivo indicado. Una validación
estática no demuestra que Bedrock acepte el pack ni que su aspecto sea correcto.

## Datos de cada sesión manual

| Dato | Resultado |
| --- | --- |
| Fecha y probador | Pendiente |
| Dispositivo / GPU / RAM | Pendiente |
| Android o Windows, versión del SO | Pendiente |
| Versión completa de Minecraft | Pendiente; objetivo declarado 1.26.52.3 Android |
| Versión del pack / commit / SHA-256 del mcpack | Pendiente; pack actual 0.2.0 |
| Modo gráfico, resolución y distancia de render | Pendiente |
| Opciones de Vibrant Visuals | Pendiente |
| Mundo / semilla / bioma / coordenadas | Pendiente |
| Otros packs y prioridad | Pendiente; probar primero solo Cristal Boreal |
| FPS / tirones / temperatura tras 10 minutos | Pendiente |
| Capturas y mensajes del registro de contenido | Pendiente |

## Fase 1 — estructura e importación

**Aceptada por el usuario el 2026-09-30:** informó «todo funciona correctamente»
y autorizó iniciar la fase 2. No se recibieron detalles por dispositivo ni capturas;
las casillas individuales siguientes conservan el checklist original, sin atribuir
al agente pruebas en el juego ni inferir mediciones no proporcionadas.

### Verificación estática

Registro histórico del commit `f227d79`, ejecutando `tools/validate.ps1` y
`tools/build.ps1`. Los scripts actuales validan la fase 2.

- [x] Parser estricto acepta los cuatro JSON actuales; perfiles Bajo/Medio/Alto vacíos.
- [x] Manifest v2: UUID distintos, versiones coincidentes, capacidad pbr y módulo resources.
- [x] Icono PNG decodificable y de 256×256.
- [x] Build termina con código 0 y genera `.mcpack` más archivo SHA-256.
- [x] ZIP contiene exactamente `manifest.json` y `pack_icon.png` en raíz, sin carpeta `pack/`, scripts, perfiles ni `.gitkeep`.
- [x] Contenido descomprimido coincide con los originales; repetir el build da el mismo SHA-256 en este runtime.
- [x] Un JSON inválido, un UUID repetido o un perfil no vacío impiden publicar un nuevo artefacto.

Resultado local del **2026-09-30**: comprobaciones anteriores realizadas con
PowerShell 7.6.5 / .NET 10.0.11. Icono abierto y revisado como imagen; Minecraft no se
ejecutó. Artefacto de 8 669 bytes, dos entradas, SHA-256:

`50ac029f99853ce93c1d5d632b9ab64c614387b35e68ab46512be375cc3446c9`

En copias temporales aisladas se comprobaron ocho rechazos: coma final, comentario
JSON, clave duplicada, UUID compartido, versión de cuatro componentes, perfil con
valores, PNG truncado y recurso adicional fuera de fase. Cada caso devolvió código 1
y conservó intacto el `.mcpack` anterior. Las copias de prueba se eliminaron.

### Pruebas manuales en Android objetivo

- [ ] Anotar la versión completa que muestra el juego y el modelo/GPU.
- [ ] Importar `cristal-boreal-0.1.0.mcpack`: obtener confirmación sin errores del manifest.
- [ ] En los recursos del mundo aparece **Cristal Boreal**, versión 0.1.0, descripción de fase 1 e icono de cristal.
- [ ] Activarlo en un mundo de prueba; comprobar que quede en la lista de activos.
- [ ] Seleccionar Vibrant Visuals en Vídeo; si no está disponible, registrar la limitación del dispositivo.
- [ ] Entrar al mundo, recorrerlo y revisar el registro de contenido si está habilitado: sin errores atribuibles a este pack.
- [ ] Comparar con la misma escena sin pack y con idéntico modo gráfico: no se esperan efectos personalizados en esta fase.
- [ ] Salir y volver a entrar: el pack sigue activo y el mundo carga.
- [ ] Desactivarlo: el mundo vuelve a cargar sin incidencias.

### Pruebas manuales en Windows

- [ ] Abrir el `.mcpack` con Minecraft for Windows y comprobar importación, nombre e icono.
- [ ] Activarlo desde los recursos de un mundo; verificar Vibrant Visuals en hardware compatible/DX12.
- [ ] Cargar, salir, volver a entrar y desactivar; registrar errores o diferencias frente a Android.

Aceptación de fase 1 en juego: importación y carga satisfactorias en el Android objetivo.
Windows es una comprobación adicional; no sustituye a Android. Ninguna de estas pruebas
evalúa aún la dirección artística ni el rendimiento del shader final.

## Fase 2 — día (0.2.0; implementada, pendiente de pruebas en juego)

### Verificación estática local

- [x] Los 114 JSON pasan el parser estricto y el contrato de los campos utilizados.
- [x] Las 83 asignaciones de bioma resuelven a 13 luces y 11 atmósferas del pack.
- [x] Las curvas modificadas conservan valores nocturnos entre 0.32 y 0.68 y cierran el ciclo sin salto en 0/1.
- [x] Se conservan los otros componentes de los biomas y los parámetros lunares/ambiente/emisores fuente.
- [x] `shadows/global.json` usa `soft_shadows` del esquema 1.21.80; no hay campos inventados de distancia/calidad.
- [x] Sol PNG de 256×256 decodificado y revisado como imagen local; no es una captura del juego.
- [x] Generación y dos builds repetibles; 112 entradas ZIP con hashes de contenido coincidentes.
- [x] Rechazo de enlaces rotos, cambios nocturnos, pérdida de componentes, tiempos inválidos y ajustes de sombra desconocidos.

Comandos: `pwsh -NoProfile -File .\tools\generate-day.ps1` (Windows, solo al cambiar
constantes), `pwsh -NoProfile -File .\tools\validate.ps1` y
`pwsh -NoProfile -File .\tools\build.ps1`.

Evidencia local del **2026-09-30** (PowerShell 7.6.5 / .NET 10.0.11): regeneración
idéntica de todos los recursos, dos builds con el mismo hash, **112 entradas / 95 597 bytes**.
SHA-256: `c66e4cfa52aff1f79cda1c65de62d43466b8f5623e7830fb3a15e026f5666762`.
Los JSON generados usan finales LF, iguales a los almacenados en Git.
El PNG solar tiene esquinas y bordes examinados RGBA 0,0,0,0 y centro 255,237,172,255.

En copias temporales se comprobaron ocho rechazos con código de error y conservación
del `.mcpack` previo: enlace de bioma roto, cambio de luz solar a medianoche, pérdida
de niebla de bioma, tiempo fuera de [0,1], color no numérico, campo ficticio de distancia
de sombras, perfil prematuro y mínimo de motor inferior al esquema de bioma usado.
Las copias se retiraron. No se ejecutó Minecraft.

### Preparación manual

- [ ] Importar `cristal-boreal-0.2.0.mcpack` y confirmar que actualiza el pack a 0.2.0 con los mismos UUID.
- [ ] Registrar teléfono/GPU, versión exacta de Minecraft y opciones de Vibrant Visuals. Probar solo con este pack adicional.
- [ ] En un mundo de prueba con permisos de comandos, fijar clima despejado y detener el ciclo: `/weather clear`, `/gamerule doDaylightCycle false`.
- [ ] Preparar una llanura con un árbol, hojas, un muro, escalones, un objeto soltado, un soporte para armaduras, un mob y el jugador en tercera persona.

### Luz, sol y sombras

| Hora de prueba | Comando | Qué observar |
| --- | --- | --- |
| Amanecer | `/time set 0` | Sol cálido, halo moderado y sombras largas |
| Mañana | `/time set 3000` | Transición de color/intensidad sin saltos |
| Mediodía | `/time set 6000` | Disco circular amarillo, halo sin cuadro ni manchas; sombras más cortas |
| Tarde | `/time set 9000` | Sombras en dirección coherente con el sol |
| Ocaso | `/time set 12000` | Luz cálida y sombras largas sin inversión |

- [ ] Comparar las horas anteriores desde la misma cámara, con y sin pack y con idénticas opciones; guardar capturas.
- [ ] Caminar alrededor del muro y mover jugador/mob: sombras actualizadas, bordes suaves, sin flotación ni fugas evidentes.
- [ ] Revisar árboles, hojas, bloques, objetos, mobs y jugadores por separado. Registrar explícitamente los que no proyecten sombra; el motor puede omitir categorías.
- [ ] Observar el sol junto a nubes y horizonte; descartar borde cuadrado, halo excesivo y saturación que lo vuelva completamente blanco.
- [ ] Alejarse de las sombras y anotar a qué distancia desaparecen. Cambiar las opciones disponibles del cliente y comparar; el pack no fija esa distancia.

### Biomas, clima y regresión

- [ ] Recorrer llanura → bosque → desierto, costa/océano, nieve, pantano y Pale Garden. Comprobar que aplica la luz y que las transiciones no producen cortes.
- [ ] Probar Dappled Forest si está disponible: conservar su vegetación/color de agua y comprobar su enlace de iluminación.
- [ ] Verificar que siguen presentes niebla, colores de agua/vegetación y sonidos/música propios de los biomas.
- [ ] Probar lluvia con `/weather rain`, entrar/salir de interiores y cuevas; comprobar ausencia de fugas o exposición cegadora.
- [ ] Comprobar medianoche con `/time set 18000` frente a vanilla: no se espera aurora ni nueva iluminación nocturna. La conservación numérica de referencia no sustituye esta prueba.
- [ ] Entrar a Nether y End: no deben recibir cielo/iluminación diurna del Overworld. El estilo global de sombras puede aplicar donde el motor lo use.
- [ ] Recorrer el mismo lugar durante 10 minutos; registrar FPS si se dispone de un contador y calentamiento/tirones observados, sin inventar cifras.
- [ ] Volver a clima despejado y restaurar `/gamerule doDaylightCycle true`; comprobar un ciclo diurno continuo y revisar errores del registro de contenido.

Aceptación manual: actualización/importación correcta, sol circular sin artefactos,
atmósfera diurna visible, sombras coherentes donde el motor las soporte y ausencia
de regresiones relevantes. Anotar cualquier límite del dispositivo antes de fase 3.

## Fase 3 — noche (plan; no implementada)

- [ ] Repetir validación JSON y build.
- [ ] Observar una noche completa: gradientes morados/azules y transiciones temporales sin saltos.
- [ ] Confirmar estrellas legibles y luna cuadrada gris en distintas fases lunares.
- [ ] Evaluar visibilidad caminando, en bosque y en cuevas sin luz; evitar tanto pantalla negra como noche equivalente a día.
- [ ] Registrar explícitamente qué parte de la aurora es una aproximación y cualquier limitación del motor.

## Fase 4 — luces locales (plan; no implementada)

- [ ] Repetir validación JSON y build.
- [ ] Probar antorcha, linterna, lava, glowstone y otros emisores por separado, a varias distancias.
- [ ] Evaluar color cálido, transición espacial, brillos especulares y sombras con un bloque/mob entre luz y superficie.
- [ ] Identificar qué emisores producen sombras reales y cuáles usan luz estática; no confundir brillo emisivo con iluminación proyectada.
- [ ] Revisar parpadeo, si se implementa por una vía verificada, con cámara quieta y en movimiento.
- [ ] Probar muchos emisores cercanos y registrar FPS/temperatura; comprobar luces vanilla de alma y redstone.

## Fase 5 — cristal (plan; no implementada)

- [ ] Repetir validación JSON y build.
- [ ] Comparar materiales designados bajo sol, luna y luces locales; brillo dependiente de ángulo e intensidad.
- [ ] Mover cámara y objetos para evaluar estabilidad de reflejos.
- [ ] Revisar límites de pantalla, geometría transparente, lluvia y zonas subterráneas; documentar límites IBL/SSR.
- [ ] Comprobar legibilidad de bloques y ausencia de saturación, ruido o superficies accidentalmente metálicas.

## Fase 6 — perfiles y entrega final (plan; no implementada)

- [ ] Repetir validación JSON y build para cada perfil implementado.
- [ ] Comprobar que cada ajuste modifique un efecto real o esté identificado como ajuste manual del cliente.
- [ ] Medir Bajo/Medio/Alto en la misma ruta, mundo y resolución, durante al menos 10 minutos por perfil.
- [ ] Registrar FPS, tirones, calentamiento y memoria cuando las herramientas del dispositivo lo permitan.
- [ ] Importar cada artefacto final, revisar actualizaciones de versión/UUID y ausencia de archivos de desarrollo.
- [ ] Repetir día, noche, emisores y reflejos; registrar hardware, límites y configuración recomendada.
