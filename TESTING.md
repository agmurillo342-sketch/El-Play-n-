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
| Versión del pack / commit / SHA-256 del mcpack | Pendiente; pack actual 0.1.0 |
| Modo gráfico, resolución y distancia de render | Pendiente |
| Opciones de Vibrant Visuals | Pendiente |
| Mundo / semilla / bioma / coordenadas | Pendiente |
| Otros packs y prioridad | Pendiente; probar primero solo Cristal Boreal |
| FPS / tirones / temperatura tras 10 minutos | Pendiente |
| Capturas y mensajes del registro de contenido | Pendiente |

## Fase 1 — estructura e importación

### Verificación estática

Ejecutar `pwsh -NoProfile -File .\tools\validate.ps1` y
`pwsh -NoProfile -File .\tools\build.ps1` desde la raíz del repositorio.

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

## Fase 2 — día (plan; no implementada)

- [ ] Repetir validación JSON y build; registrar versión/commit.
- [ ] Comparar amanecer, mediodía y atardecer con clima despejado; sol redondo amarillo y aura sin recorte excesivo.
- [ ] Árboles, bloques, objetos, mobs y jugador: revisar presencia, suavidad, continuidad y dirección de sombras durante el movimiento.
- [ ] Verificar atmósfera en varios biomas y sus transiciones; registrar cualquier efecto que no aplique.
- [ ] Revisar lluvia, interiores y distancia de sombras para detectar fugas, parpadeo o cambios bruscos.

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
