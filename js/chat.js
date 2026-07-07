/* ===========================================================
   Restaurant El Playón — chat.js
   Asistente virtual con respuestas predefinidas (sin IA, sin costo)
   =========================================================== */

document.addEventListener('DOMContentLoaded', () => {
  const toggle = document.getElementById('aiChatToggle');
  const windowEl = document.getElementById('aiChatWindow');
  const closeBtn = document.getElementById('aiChatClose');
  const form = document.getElementById('aiChatForm');
  const input = document.getElementById('aiChatInput');
  const messagesEl = document.getElementById('aiChatMessages');

  function openChat() {
    windowEl.hidden = false;
    toggle.setAttribute('aria-expanded', 'true');
    input.focus();
  }

  function closeChat() {
    windowEl.hidden = true;
    toggle.setAttribute('aria-expanded', 'false');
  }

  toggle.addEventListener('click', () => {
    windowEl.hidden ? openChat() : closeChat();
  });

  closeBtn.addEventListener('click', closeChat);

  function addMessage(text, role) {
    const bubble = document.createElement('div');
    bubble.className = `ai-chat-msg ${role}`;
    bubble.textContent = text;
    messagesEl.appendChild(bubble);
    messagesEl.scrollTop = messagesEl.scrollHeight;
    return bubble;
  }

  function addTypingIndicator() {
    const bubble = document.createElement('div');
    bubble.className = 'ai-chat-msg typing';
    bubble.innerHTML = '<span></span><span></span><span></span>';
    messagesEl.appendChild(bubble);
    messagesEl.scrollTop = messagesEl.scrollHeight;
    return bubble;
  }

  function normalize(text) {
    return text
      .toLowerCase()
      .normalize('NFD')
      .replace(/[̀-ͯ]/g, '');
  }

  function isOpenNow() {
    const now = new Date();
    const minutesNow = now.getHours() * 60 + now.getMinutes();
    return minutesNow >= 9 * 60 && minutesNow < 20 * 60;
  }

  function findMenuMatches(normText) {
    const menu = window.__menuFlat || [];
    const words = normText.split(/\s+/).filter(w => w.length >= 4);
    if (words.length === 0) return [];
    return menu
      .filter(item => {
        const name = normalize(item.name);
        return words.some(w => name.includes(w));
      })
      .slice(0, 5);
  }

  function buildReply(rawText) {
    const text = normalize(rawText);

    if (/\b(hola|buenas|buenos dias|buenas tardes|buenas noches|hey|que tal|saludos)\b/.test(text)) {
      return '¡Hola! 🐚 ¿En qué puedo ayudarte? Puedo darte información sobre nuestro horario, ubicación, teléfono o precios del menú.';
    }

    if (/\b(horario|hora|abren|cierran|abierto|cerrado)\b/.test(text)) {
      const status = isOpenNow() ? 'Ahora mismo estamos abiertos.' : 'En este momento estamos cerrados.';
      return `Abrimos todos los días de 9:00 a.m. a 8:00 p.m. ${status} La mayor afluencia es alrededor de las 6:00 p.m., pero normalmente no hay espera.`;
    }

    if (/\b(ubicacion|direccion|donde estan|donde queda|como llegar|localizacion|mapa)\b/.test(text)) {
      return 'Estamos en Punta Pérula, La Huerta, Jalisco, C.P. 48869. Puedes ver el mapa completo en la sección "Ubicación" de esta página.';
    }

    if (/\b(telefono|contacto|numero|llamar|whatsapp|correo|email)\b/.test(text)) {
      return 'Puedes llamarnos o escribirnos por WhatsApp al 315 107 4335, o por correo a rayperula@hotmail.com.';
    }

    if (/\b(reserva|reservacion|apartar mesa)\b/.test(text)) {
      return 'No manejamos reservaciones por este chat. Para apartar mesa o preguntar por disponibilidad, llámanos al 315 107 4335.';
    }

    const menuMatches = findMenuMatches(text);
    if (menuMatches.length > 0) {
      const lines = menuMatches.map(item => {
        const price = item.price === null ? 'precio en barra' : `$${item.price} MXN`;
        return `• ${item.name} — ${price}`;
      });
      return `Esto encontré en el menú:\n${lines.join('\n')}`;
    }

    if (/\b(menu|platillos|especialidad|que tienen|recomiendas|recomendacion)\b/.test(text)) {
      return 'Tenemos una gran variedad: ceviches, camarones, pescados, pulpo, cortes a la parrilla, cócteles y más. Usa el buscador en la sección "Menú" arriba para ver nombres y precios exactos.';
    }

    if (/\b(gracias|ok|vale|perfecto)\b/.test(text)) {
      return '¡Con gusto! Si tienes otra pregunta aquí estoy 🐚';
    }

    return 'No estoy seguro de eso. Puedes revisar el menú completo arriba, o llamarnos al 315 107 4335 para más información.';
  }

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    const message = input.value.trim();
    if (!message) return;

    input.value = '';
    addMessage(message, 'user');

    const typingBubble = addTypingIndicator();

    // Pequeño retraso para que la respuesta se sienta natural
    setTimeout(() => {
      typingBubble.remove();
      addMessage(buildReply(message), 'bot');
    }, 450);
  });
});
