const MENU_CONTEXT = require('./menu-context');

const SYSTEM_PROMPT = `Eres el asistente virtual de "Restaurant El Playón", un restaurante familiar de mariscos ubicado en la playa de Punta Pérula, La Huerta, Jalisco, C.P. 48869, México.

DATOS DEL NEGOCIO:
- Teléfono: 315 107 4335
- Correo: rayperula@hotmail.com
- Horario: todos los días de 11:00 a.m. a 8:00 p.m.
- La mayor afluencia es alrededor de las 6:00 p.m., pero normalmente no hay espera.
- Calificación de clientes: 4.2/5 estrellas.
- No se aceptan reservaciones por este chat; para reservar o confirmar disponibilidad, indica al cliente que llame al 315 107 4335.

${MENU_CONTEXT}

INSTRUCCIONES:
- Responde siempre en español, de forma breve, cálida y amable, como alguien de un restaurante de playa.
- Usa la información del menú de arriba para responder sobre platillos y precios exactos.
- Si preguntan por algo que no está en el menú, dilo honestamente y sugiere alternativas similares del menú.
- Si preguntan por reservaciones, pedidos, disponibilidad de temporada (langosta, chacales, pulpo zarandeado) o algo que no puedas confirmar con certeza, indica que llamen al 315 107 4335.
- No inventes platillos, precios, promociones ni datos que no estén arriba.
- Mantén las respuestas cortas (máximo un par de párrafos breves o una lista corta).`;

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Método no permitido' });
    return;
  }

  const { message, history } = req.body || {};

  if (typeof message !== 'string' || !message.trim() || message.length > 500) {
    res.status(400).json({ error: 'Mensaje inválido' });
    return;
  }

  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    res.status(500).json({ error: 'El asistente no está configurado todavía' });
    return;
  }

  const safeHistory = Array.isArray(history)
    ? history
        .filter(m => m && (m.role === 'user' || m.role === 'assistant') && typeof m.content === 'string')
        .slice(-10)
    : [];

  const messages = [...safeHistory, { role: 'user', content: message.trim() }];

  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 500,
        system: SYSTEM_PROMPT,
        messages,
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error('Anthropic API error:', response.status, errText);
      res.status(502).json({ error: 'No se pudo contactar al asistente en este momento' });
      return;
    }

    const data = await response.json();
    const reply = data.content?.find(block => block.type === 'text')?.text
      || 'Lo siento, no pude generar una respuesta. Intenta de nuevo.';

    res.status(200).json({ reply });
  } catch (err) {
    console.error('Chat function error:', err);
    res.status(500).json({ error: 'Error interno del asistente' });
  }
};
