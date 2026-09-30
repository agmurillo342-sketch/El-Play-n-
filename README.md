# Cristal Boreal — Minecraft Bedrock

Resource pack orientado a **Vibrant Visuals**, con iluminación realista y una
dirección artística de cristal. Estado: **fase 1, versión del pack 0.1.0**.
Esta entrega contiene estructura, manifest, icono, validación y empaquetado.
Todavía no incorpora cambios de iluminación, cielo, emisores ni materiales PBR.
El icono es una ilustración geométrica original, no una captura del resultado.

El repositorio Git está en `C:\PROYECTOS\el-playn\El-Play-n`; también contiene un
sitio web preexistente. Las rutas relativas siguientes parten de ese repositorio.

## Compatibilidad y alcance

El objetivo solicitado es **Minecraft Bedrock 1.26.52.3 en Android**.
Mojang publicó [Bedrock 26.52 el 25 de septiembre de 2026][release]; esa nota no
confirma el sufijo Android `.3`. No se ha abierto Minecraft ni se ha probado la
importación en esa compilación. Registrar la versión real en [TESTING.md](TESTING.md).

Se usa [manifest v2][manifest], un módulo `resources`, UUID distintos y estables,
y `capabilities: ["pbr"]`. `min_engine_version: [1,21,120]` es el mínimo documentado
para [packs de Vibrant Visuals][vv-pack]. No es la versión objetivo ni una promesa
de compatibilidad con todas las versiones posteriores. El campo tiene tres
componentes: no se introduce un cuarto número ni se transforma `26.52` en `[26,52,3]`.
Al añadir funciones de esquemas más recientes se revisará el mínimo necesario.

La capacidad `pbr` permite identificar el pack; no activa por sí sola un modo gráfico
en una GPU incompatible. Se requiere un Android compatible con Vibrant Visuals;
Mojang enumera Adreno 640, Mali-G68, Mali-G77 o Xclipse 530 y superiores. Windows
requiere el modo DX12. Consultar los [requisitos oficiales][vv-devices] y comprobar
que el menú permita seleccionar Vibrant Visuals. Esta base usa `pack_scope: "world"`.

## Estructura

```text
pack/
  manifest.json
  pack_icon.png                 # 256 x 256
  materials/                    # Reserva; sin binarios ni contrato de carga
  lighting/                     # Configuración de luz futura
  atmospherics/                 # Atmósfera futura
  color_grading/                # Ajustes de color futuros
  local_lighting/               # Emisores futuros
  pbr/                          # Valores PBR futuros
  textures/
    blocks/ environment/ entity/ items/ particle/
profiles/
  bajo.json medio.json alto.json # Objetos vacíos, sin efecto
  README.md
tools/
  validate.ps1                  # JSON estricto + contrato de fase 1
  build.ps1                     # ZIP .mcpack + SHA-256
  create-icon.ps1               # Regeneración opcional del icono en Windows
README.md
TESTING.md
dist/                           # Generado; excluido de Git
```

Las carpetas reservadas se versionan con `.gitkeep`. Estos marcadores y las carpetas
vacías no se incluyen en el ZIP. Se usarán nombres y campos de los esquemas oficiales
cuando corresponda cada fase; no hay JSON de efectos ficticios para rellenar carpetas.

## Validar y generar el .mcpack

Requisito del script: **PowerShell 7.4 o posterior (`pwsh`)**. La ejecución comprobada
usa 7.6.5; Windows PowerShell 5.1 no es compatible. No se requiere Node, npm, Python,
un compilador de shaders, ni acceso a Internet para generar esta entrega.

Desde la raíz del repositorio:

```powershell
pwsh -NoProfile -File .\tools\validate.ps1
pwsh -NoProfile -File .\tools\build.ps1
```

El build ejecuta primero el validador. Crea:

- `dist/cristal-boreal-0.1.0.mcpack`
- `dist/cristal-boreal-0.1.0.mcpack.sha256`

Se validan los cuatro JSON actuales: sintaxis estricta UTF-8, ausencia de comentarios,
comas finales y claves duplicadas; campos previstos del manifest, versiones y UUID;
perfiles vacíos y cabecera/dimensiones del PNG. Es un **contrato local de fase 1**,
no el validador oficial completo de Bedrock. Hay que ampliarlo junto con cada fase.
Actualmente rechaza recursos adicionales para evitar publicar efectos no implementados.

El ZIP contiene únicamente `manifest.json` y `pack_icon.png` en su raíz. El build
lo reabre y compara SHA-256 del contenido descomprimido con los archivos fuente.
Publica el resultado solo tras esas comprobaciones. Orden y fechas de entradas son
fijos; la repetibilidad se verifica con el mismo runtime. Cambiar .NET/compresión puede
cambiar los bytes del ZIP. Nunca se copia a la instalación de Minecraft automáticamente.

Para regenerar el icono en Windows, ejecutar `pwsh -NoProfile -File .\tools\create-icon.ps1`
y después el build. Los colores/vértices están comentados en el generador. Los UUID no
se regeneran durante el build. Al publicar otra versión, incrementar `header.version`
y `modules[0].version`; Bedrock puede ignorar una importación con igual o menor versión.

## Instalación y activación manual

Estas instrucciones son para el usuario: el agente no abre Minecraft.

### Windows

1. Generar el `.mcpack` y abrirlo manualmente con **Minecraft for Windows (Bedrock)**.
   Esperar la notificación de importación y registrar cualquier error.
2. Crear o editar un mundo de prueba. En **Paquetes de recursos → Mis paquetes**,
   activar **Cristal Boreal**. Por su alcance `world`, se busca en el mundo, no en
   Recursos globales. Para aislar la prueba, dejarlo como único pack adicional.
3. En el menú principal, abrir **Configuración → Vídeo → Modo gráfico → Vibrant Visuals**.
   Si aparece deshabilitado, registrar dispositivo, GPU y versión; un pack no elimina
   ese requisito. No se necesitan experimentos para esta base estable.
4. Entrar al mundo y completar la fase 1 de [TESTING.md](TESTING.md).

Alternativa de desarrollo documentada: copiar el contenido de `pack` a una carpeta
propia dentro de `%appdata%\Minecraft Bedrock\users\shared\games\com.mojang\development_resource_packs`.
No instalar simultáneamente esa copia y el `.mcpack` con el mismo UUID. La ubicación
de Preview puede diferir. Referencias: [instalación][installation], [carpeta de recursos][resource-pack]
y [modo gráfico][vv-devices].

### Android

1. Transferir `dist/cristal-boreal-0.1.0.mcpack` al teléfono, conservando la extensión.
2. Desde el gestor de archivos, abrirlo/compartirlo con Minecraft y comprobar la importación.
   La disponibilidad de esa asociación depende del gestor y Android; no se ha verificado aquí.
3. Activar **Cristal Boreal** en los paquetes del mundo de prueba y seleccionar Vibrant
   Visuals en Vídeo, si está disponible. Seguir el mismo checklist.

En esta fase, el resultado esperado es **pack reconocido y mundo cargable**, con el
aspecto base del motor. Ver reflejos o sombras vanilla no demuestra que el pack añada
efectos propios. Guardar también una captura sin el pack como referencia.

## Herramientas y versiones

Versiones observadas en este entorno el **2026-09-30**:

| Herramienta | Versión exacta | Uso |
| --- | --- | --- |
| PowerShell Core | 7.6.5 | Generador del icono, validación y empaquetado |
| .NET | 10.0.11 | Runtime incluido en PowerShell |
| System.Text.Json | Assembly 10.0.0.0 | Parser JSON estricto |
| System.IO.Compression | Assembly 10.0.0.0 | Lectura/escritura ZIP |
| System.Drawing.Common | Assembly 10.0.0.0 | PNG geométrico en Windows |
| Git for Windows | 2.55.0.windows.5 | Control de versiones y commit de fase |

No se han instalado ni ejecutado Lazurite, MaterialBinTool, shaderc o DXC.
Las versiones de assembly anteriores son distintas del número de parche del runtime.

## Límites conocidos y decisiones para las siguientes fases

- Las sombras solares y puntuales dependen del motor y sus opciones. No se promete
  sombra suave de cada objeto ni igual rendimiento entre GPU.
- [La documentación de luces][lighting] distingue puntos con sombras dinámicas de
  iluminación estática. Recomienda emisión estática/PBR para superficies extensas
  como lava; no se convertirá cada emisor en una luz con sombras por suposición.
- Los reflejos usan IBL/SSR: no reflejan objetos fuera de pantalla y el vidrio
  transparente no recibe SSR. La alternativa será una apariencia pulida en superficies
  compatibles; no se promete refracción física ni espejo perfecto en vidrio.
- [Atmósfera][atmosphere] permite colores por hora. La aproximación propuesta a la
  aurora son gradientes morados/azules; no existe aquí una implementación de cortinas
  volumétricas. El parpadeo configurable de luz tampoco está implementado.
- Los valores globales de luz no sustituyen automáticamente los valores vanilla por
  bioma: la fase 2 deberá resolver asignaciones por bioma según la documentación.
- Bajo, Medio y Alto son reservas. Distancia de sombras/calidad de reflejos podrían
  requerir ajustes manuales del cliente. No hay FPS objetivo ni medidas todavía.
- Importación, aceptación por el motor, calidad visual, temperatura y consumo en
  Android están pendientes. Un build correcto solo demuestra integridad estática.

## .material.bin: estado y flujo manual condicionado

**Esta vía no forma parte del build PBR.** No se ha compilado un `.material.bin`:
faltan originales de la compilación Android objetivo, fuentes compatibles, compilador
y un mecanismo de carga confirmado. `pack/materials` es solo una reserva. No se
asume que colocar binarios en un `.mcpack` los haga cargar en el cliente estándar.

Para una investigación posterior, el procedimiento documentado de Lazurite es:

1. Preparar Python 3.12 y un entorno aislado en `work-materials/.venv`. Instalar una
   versión fija; [Lazurite 0.10.0][lazurite-release] existe y se usa como referencia
   reproducible del ejemplo, no como certificación para 1.26.52.3. Registrar también
   el parche exacto de Python y `pip freeze` en esa investigación.
2. Obtener de la propia instalación los materiales de **esa** compilación, guardarlos
   en `work-materials/vanilla` y consultar `lazurite info`. La [tabla de formatos][lazurite-versions]
   incluye formato 26 desde Preview 1.26.50.25; no confirma por sí sola el hotfix objetivo.
3. Usar `unpack` para inspeccionar estructura y variantes. `pack` solo reempaqueta:
   no compila fuentes. No usar `restore` como decompilador universal: la [guía][lazurite-guide]
   advierte que las versiones Android recientes ya no incluyen fuentes legibles.
4. Preparar **manualmente** `work-materials/shader-project` con fuentes compatibles,
   `project.json`, `merge_source` hacia los originales, y un perfil `android` con las
   plataformas realmente observadas. Seguir el [formato de proyecto][lazurite-project].
   No se han creado esos archivos en fase 1 ni se sustituyen por shaders antiguos.
5. Obtener shaderc para Windows desde los [binarios enlazados por Lazurite][shaderc]
   y glslang desde su [repositorio oficial][glslang]. Registrar sus versiones/commit
   y SHA-256 antes de compilar; no hay un binario seleccionado o verificado aquí.
6. Ejecutar los [comandos documentados][lazurite-commands] de abajo, usando el nombre
   real del material. Volver a inspeccionar el resultado con `info`. Detenerse si el
   formato, plataformas o compilación no coinciden. La carga y prueba en Android son
   pasos separados, todavía sin procedimiento confirmado para esta compilación.

Comandos de referencia; **no ejecutar hasta proporcionar los insumos anteriores**.
`MATERIAL` representa el nombre real encontrado, no un archivo incluido:

```powershell
py -3.12 -m venv .\work-materials\.venv
.\work-materials\.venv\Scripts\python.exe -m pip install lazurite==0.10.0
.\work-materials\.venv\Scripts\python.exe -m lazurite info .\work-materials\vanilla\MATERIAL.material.bin
.\work-materials\.venv\Scripts\python.exe -m lazurite unpack .\work-materials\vanilla\MATERIAL.material.bin -o .\work-materials\unpacked
.\work-materials\.venv\Scripts\python.exe -m lazurite build .\work-materials\shader-project -p android --shaderc .\work-materials\bin\shaderc.exe --glslang .\work-materials\bin\glslang.exe -o .\work-materials\compiled
.\work-materials\.venv\Scripts\python.exe -m lazurite info .\work-materials\compiled\MATERIAL.material.bin
```

Esto documenta las operaciones reales, pero **no es un flujo completo ejecutable
para el objetivo sin sus fuentes y materiales**. La vía utilizable ahora es el pack
Vibrant Visuals. No se distribuyen materiales extraídos ni se incluyen binarios vacíos.

## Fases

1. Estructura base — entrega actual; pruebas en juego pendientes.
2. Día: sombras, sol y atmósfera — pendiente de autorización.
3. Noche: cielo, estrellas, luna y visibilidad — pendiente.
4. Luces locales — pendiente.
5. Apariencia de cristal — pendiente.
6. Perfiles, ajuste de rendimiento y empaquetado final — pendiente.

Cada fase requiere validación, build, actualización de TESTING.md y commit, y termina
sin comenzar la siguiente. El `.mcpack` actual es una base de importación, no la entrega visual final.

## Fuentes consultadas

Consultadas el 2026-09-30. Los enlaces se distribuyen arriba junto a cada decisión.
Los esquemas del juego y la sintaxis de herramientas deben revisarse al avanzar de fase.

[release]: https://feedback.minecraft.net/hc/en-us/articles/49175370527501-Minecraft-Bedrock-Edition-26-52-Hotfix-Changelog
[manifest]: https://learn.microsoft.com/en-us/minecraft/creator/reference/content/addonsreference/packmanifest?view=minecraft-bedrock-stable
[vv-pack]: https://learn.microsoft.com/en-us/minecraft/creator/documents/vibrantvisuals/vvresourcepacks?view=minecraft-bedrock-stable
[vv-devices]: https://www.minecraft.net/en-us/vibrant-visuals-update
[installation]: https://learn.microsoft.com/en-us/minecraft/creator/documents/gettingstarted?view=minecraft-bedrock-stable
[resource-pack]: https://learn.microsoft.com/en-us/minecraft/creator/documents/resourcepack?view=minecraft-bedrock-stable
[lighting]: https://learn.microsoft.com/en-us/minecraft/creator/documents/vibrantvisuals/lightingcustomization?view=minecraft-bedrock-stable
[atmosphere]: https://learn.microsoft.com/en-us/minecraft/creator/documents/vibrantvisuals/atmosphericscustomization?view=minecraft-bedrock-stable
[lazurite-release]: https://pypi.org/project/lazurite/0.10.0/
[lazurite-versions]: https://veka0.github.io/lazurite/supported_versions/
[lazurite-guide]: https://veka0.github.io/lazurite/guide/
[lazurite-project]: https://veka0.github.io/lazurite/project/
[lazurite-commands]: https://veka0.github.io/lazurite/commands/
[shaderc]: https://github.com/veka0/bgfx-mcbe/releases/tag/binaries
[glslang]: https://github.com/KhronosGroup/glslang/releases
