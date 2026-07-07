document.addEventListener('DOMContentLoaded', () => {
  const toggle = document.getElementById('aiChatToggle');
  const windowEl = document.getElementById('aiChatWindow');
  const closeBtn = document.getElementById('aiChatClose');
  const form = document.getElementById('aiChatForm');
  const input = document.getElementById('aiChatInput');
  const messagesEl = document.getElementById('aiChatMessages');

  let history = [];
  let sending = false;

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

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const message = input.value.trim();
    if (!message || sending) return;

    sending = true;
    input.value = '';
    addMessage(message, 'user');
    const typingBubble = addTypingIndicator();

    try {
      const res = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ message, history }),
      });

      const data = await res.json();
      typingBubble.remove();

      if (!res.ok) {
        addMessage(
          data.error || 'El asistente no está disponible en este momento. Llámanos al 315 107 4335.',
          'error'
        );
        return;
      }

      addMessage(data.reply, 'bot');
      history.push({ role: 'user', content: message });
      history.push({ role: 'assistant', content: data.reply });
      history = history.slice(-10);
    } catch (err) {
      typingBubble.remove();
      addMessage(
        'No pudimos conectar con el asistente. Verifica tu conexión o llámanos al 315 107 4335.',
        'error'
      );
    } finally {
      sending = false;
    }
  });
});
