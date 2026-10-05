# Auditoría del sitio de Restaurante El Playón

Fecha: 2026-10-04. Región: Punta Pérula, municipio de La Huerta, Jalisco, México.
Alcance: sitio público HTML/CSS/JS, páginas legales, fuentes, imágenes, formularios,
almacenamiento del navegador y configuración de entrega en Vercel. Las carpetas
pack, profiles y tools contienen otro proyecto y no forman parte de la web cargada.
No se auditaron dispositivos, cuentas, contratos, permisos o expedientes del local.

Este informe documenta controles y pendientes; no certifica cumplimiento legal
integral ni conformidad completa con WCAG. Los textos describen el funcionamiento
actual y requieren validación de los datos y procedimientos reales del responsable.

## Cambios aplicados

- Páginas accesibles directamente: privacidad.html, terminos.html, cookies.html y
  reembolsos.html. Contenido completo ES/EN, navegación, tema y enlaces visibles.
- Reservas sin anticipo, confirmado por el usuario. Sin pago, carrito ni tarjeta en
  la web. No se inventaron ventanas de devolución ni cláusulas de "sin reembolsos".
- Dos formularios auditados: reserva y asistente local. Ambos requieren una casilla
  no premarcada y validación antes de procesar la solicitud; no es permiso comercial.
- Reserva: nombre de referencia, un teléfono, personas, fecha y hora. No se pide
  domicilio particular, apellidos, RFC, cuenta bancaria ni información sensible.
- Datos del formulario en memoria, no en almacenamiento persistente del sitio.
  WhatsApp recibe el mensaje incluido en la URL al abrirse; el restaurante lo recibe
  al enviarlo. El mensaje incluye la versión del aviso aceptado, sin base de datos
  propia para registrar consentimientos o solicitudes.
- Chat con respuestas programadas locales: sin IA externa, llamadas API ni historial
  persistente. Su texto se inserta con textContent. Se advierte no incluir datos
  sensibles y su botón accesible identifica el asistente, no un chat externo.
- Banner de aceptación/rechazo con igual estilo y sin aceptación por navegación.
  Solo Google Maps es opcional. La elección vence en 180 días; puede cambiarse desde
  todas las páginas. El tema se conserva hasta eliminarlo desde el navegador.
- El iframe no tiene src antes del consentimiento ni después de rechazar. Retirar
  el permiso elimina su URL y bloquea nuevas cargas. No elimina cookies de Google
  previamente creadas en otro dominio; se explica cómo gestionarlas en el navegador.
- Poppins y Quicksand alojadas localmente con licencias OFL y trazabilidad. Quitados
  los preconnect y la hoja externa de Google Fonts. Sin CDN o bibliotecas nuevas.
- Eliminadas tres reseñas sin enlaces de origen y el promedio 4.2 sin muestra,
  fecha o fuente verificables. No se afirma que fueran fraudulentas: no había
  evidencia suficiente para presentarlas como testimonios verificables.
- Sustituidas afirmaciones de frescura diaria/recién salido del mar y espera
  habitual sin evidencia. El indicador de abierto/cierra pronto sigue derivándose
  del reloj y el horario publicado; no es un contador de venta o urgencia ficticia.
- Nombre comercial, dirección disponible y contacto visibles junto a campos
  pendientes de razón social/RFC/domicilio completo. No se usó el nombre de la
  cuenta de Google ni datos deducidos como identidad legal del negocio.
- Todas las imágenes tienen alt; los platillos y el logo se traducen a ES/EN.
  El visor usa el alt del platillo activo, mantiene el foco dentro del diálogo y
  permite pausar/reanudar. Con movimiento reducido empieza pausado.
- Contraste ajustado en el rótulo de galería y el botón de llamada en modo oscuro.
  Casillas, enlaces, opciones, mensajes de error y envío operables por teclado;
  foco visible y errores asociados por aria-describedby/aria-invalid.
- Cabeceras en Vercel: CSP, nosniff, no-referrer, DENY de enmarcado y bloqueo de
  permisos de cámara/micrófono/geolocalización. El formulario no puede enviarse
  directamente a otro destino por form-action 'none'. Los flujos JS de WhatsApp
  conservan su navegación explícita. Se evita el envío GET accidental de formularios.
- Sitemap ampliado para incluir las cuatro páginas legales; verificación de Google
  Search Console conservada. No modifica encabezado visual ni navegación principal.

## Inventario de conexiones y almacenamiento

| Recurso | Activación | Datos o almacenamiento | Estado |
| --- | --- | --- | --- |
| Vercel | Navegación | IP/metadatos de entrega, registros del proveedor | Necesario; revisar contrato y retención del alojamiento |
| Imágenes, CSS, JS y fuentes locales | Navegación | Solicitudes al mismo sitio | Sin terceros adicionales |
| Google Maps iframe | Aceptación explícita | IP, navegador y posibles cookies del proveedor | Bloqueado por defecto y revocable |
| Enlace externo Google Maps | Clic del visitante | Navegación a Google | No carga automática |
| WhatsApp | Clic o envío con consentimiento | Datos de reserva en la URL y conversación posterior | Revisión del mensaje disponible; explicar recepción de URL |
| Chat local | Envío con consentimiento | Texto en memoria del documento | Sin red ni almacenamiento persistente |
| playon-theme | Cambio de tema | Valor light/dark en localStorage | Hasta eliminación del almacenamiento |
| playon-consent-v1 | Aceptar/rechazar | Versión, maps booleano y fecha en localStorage | 180 días |
| Etiqueta Search Console | Lectura del HTML por Google | Token público de propiedad | No ejecuta JS ni rastrea visitantes |
| Google Analytics / Meta Pixel / GTM | No existen en el sitio cargado | Ninguno detectado | No instalados; CSP connect-src self limita nuevas integraciones |

No se encontraron píxeles, balizas, fetch, XHR, scripts de analítica ni cookies
propias de seguimiento en el código activo. Esto no sustituye revisar configuraciones
de Vercel o servicios que el titular habilite después, ni las cookies de Google
tras el consentimiento. CSS/style.css y js/script.js/chat.js son archivos históricos
sin referencia en el HTML actual y no se ejecutan.

## Verificación técnica

Pruebas de navegador automatizadas: 390 y 1440 px; claro/oscuro; ES/EN. Se verificó:

- Cero solicitudes externas antes de aceptar y tras rechazar/reload.
- Carga de la URL del mapa solo al aceptar y retirada de src al revocar.
- Conservación de la elección de consentimiento y aislamiento frente a los datos
  introducidos. Ningún nombre o teléfono de prueba guardado en localStorage.
- Ninguna apertura de WhatsApp ni procesamiento de chat sin casilla marcada.
- Secuencia Space/Tab/Enter para consentimiento, vínculo y botón de reserva;
  selección de hora y mensajes de error asociados al campo correspondiente.
- Nombre, teléfono, personas, fecha, hora y versión del aviso en el mensaje preparado.
- Categorías seleccionables/deseleccionables, búsqueda, cambio ES/EN y visor por
  teclado con cierre y foco retenido dentro del diálogo.
- Páginas legales con un solo h1 visible en el idioma elegido y sin desbordamiento.
- Contraste de texto de al menos 4.5:1 en las muestras de formulario, ayuda,
  footer legal, datos pendientes, buscador, títulos de menú y aviso del mapa,
  tomando sus fondos sólidos computados. No se certificaron todos los píxeles de
  fotografía, transparencias, cada estado de foco o una conformidad WCAG completa.
- Sin errores de consola en las combinaciones comprobadas; XML y JSON válidos.

El iframe externo se sustituyó por una respuesta de prueba al comprobar los flujos,
para no enviar datos de prueba a proveedores ni depender de su UI. La funcionalidad
interna de Google Maps depende de Google y de la configuración del navegador.

## Pendientes del titular

| Prioridad | Dato o evidencia pendiente | Efecto |
| --- | --- | --- |
| Alta | Nombre legal/razón social, RFC y calle/número/colonia | Impide finalizar identificación comercial y aviso integral de privacidad |
| Alta | Confirmar rayperula@hotmail.com como canal ARCO efectivo y asignar quien atienda | La existencia del enlace no demuestra atención de solicitudes |
| Alta | Plazos reales, bloqueo/borrado de conversaciones, acceso del personal y seguridad de WhatsApp | El código frontend no puede implantar controles en los dispositivos del restaurante |
| Media | Comprobar importes totales e impuestos del menú físico y disponibilidad | No se presume que cada precio listado ya incluya todos los cargos |
| Media | Conservar autorización escrita del logo/fotos e identificar autor y alcance | El usuario declaró autorización; no se recibió contrato que permita verificación documental independiente |
| Media | Revisar contratos/retención/transferencias con Vercel, Google y WhatsApp | No se deducen condiciones privadas de una política pública |
| Media | Verificar horario, dirección exacta y precisión de la ficha de Google Maps | El mapa usa una búsqueda por nombre/localidad, no coordenadas confirmadas |
| Media | Revisión legal final de avisos y procedimientos reales del local | Los documentos son una implementación inicial, no un dictamen jurídico |

No se añadieron reglas de retención ficticias ni se publicaron un RFC o razón social
inventados. Los campos pendientes y la advertencia de aviso incompleto son visibles.
Cuando el titular aporte los datos deben sustituirse en las cinco páginas, actualizar
el aviso y confirmar el proceso ARCO antes de considerarlo finalizado.

## Marco local contrastado y límites

- LFPDPPP vigente: principios de finalidad/proporcionalidad, contenido del aviso y
  ejercicio ARCO. Fuente oficial:
  https://www.diputados.gob.mx/LeyesBiblio/pdf/LFPDPPP.pdf
- LFPC: publicidad comprobable, importe total y derechos por incidencias. Sin
  cláusulas que eliminen derechos obligatorios. Fuente oficial:
  https://www.diputados.gob.mx/LeyesBiblio/pdf/LFPC.pdf
- Ley Federal del Derecho de Autor: revisar autorización para las fotos/logo y
  conservar licencias de fuentes. Fuente oficial:
  https://www.diputados.gob.mx/LeyesBiblio/pdf/LFDA.pdf
- Accesibilidad, referencia técnica WCAG 2.2 de W3C:
  https://www.w3.org/TR/WCAG22/
- Jalisco: COPRISJAL explica avisos de funcionamiento y autorizaciones sanitarias:
  https://coprisjal.jalisco.gob.mx/regulacion/autorizaciones-sanitarias-y-avisos

Una web no acredita licencias municipales, autorización para venta de alcohol,
protección civil, higiene, aviso sanitario ni uso/ocupación de zona federal marítima.
El menú incluye alcohol y el local se describe frente a la playa: el titular debe
revisar con La Huerta y las autoridades competentes los permisos que correspondan
a su operación y ubicación. No se comprobó un expediente ni la vigencia de una
licencia municipal, y no se presenta el sitio como certificado por esas autoridades.

## Riesgos técnicos residuales

- La CSP permite unsafe-inline para conservar los scripts y estilos vanilla
  existentes. No representa una protección completa contra XSS. Los textos de
  usuario del chat usan textContent y los nombres de menú se escapan; una futura
  integración no debe convertir entradas de usuario en HTML ni código ejecutable.
- Los datos preparados para WhatsApp quedan en una URL y pueden aparecer en el
  historial de ese destino. No hay servidor propio que intermedie; se informa del
  flujo y se conserva la elección de abrirlo por parte del visitante.
- Cambiar o retirar permiso del mapa evita nuevas cargas, pero no deshace información
  enviada previamente a Google. Los cambios en otras pestañas requieren recarga.
- Las políticas legales públicas son archivos estáticos y el resto del repositorio
  incluye materiales de otro proyecto. No deben guardarse contratos, documentos
  fiscales privados o copias de identificaciones en la carpeta desplegada.
- No se implementó un sistema de cobros ni se garantizaron reembolsos automáticos,
  tiempos de respuesta internos, seguridad de cuentas ajenas o posiciones en Google.
