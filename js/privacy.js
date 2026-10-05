(() => {
  'use strict';
  const strings = {
    es: {
      privacy:'Política de privacidad', terms:'Términos y condiciones', cookies:'Política de cookies', refunds:'Política de reembolsos', preferences:'Cambiar consentimiento', legalLinks:'Información legal', googlePolicy:'Privacidad de Google', whatsappPolicy:'Privacidad de WhatsApp', vercelPolicy:'Privacidad de Vercel',
      consent:'Acepto la política de privacidad', reservationUse:'Tus datos se usan para gestionar la reserva. Al continuar, se abre WhatsApp con los datos del formulario; revisa el mensaje antes de enviarlo.',
      chatUse:'Las preguntas se procesan en este navegador y se borran al recargar. No incluyas datos de salud, bancarios ni identificaciones.', consentRequired:'Acepta la política de privacidad para continuar.',
      cookieTitle:'Tu privacidad', cookieText:'Guardamos el tema en tu navegador y tu decisión durante 180 días. El mapa de Google solo se carga si aceptas; puede usar cookies y recibir tu IP. No usamos analítica ni publicidad.',
      accept:'Aceptar mapa de Google', reject:'Rechazar opcionales', mapNotice:'El mapa está desactivado. Al permitir Google Maps se conectará con Google, que puede recibir tu IP y usar cookies.', mapAllow:'Permitir Google Maps',
      tradeName:'Nombre comercial', legalName:'Titular o razón social', taxId:'RFC', address:'Dirección física', privacyContact:'Contacto de privacidad', pending:'Pendiente de confirmar por el titular',
      fullAddressPending:'Calle, número y colonia pendientes de confirmar.', pendingNotice:'La identidad legal y el domicilio completo del responsable están pendientes de confirmación. Este aviso debe completarse con esos datos.',
      updated:'Actualización: 4 de octubre de 2026', back:'Volver al restaurante', skip:'Saltar al contenido', language:'Change language to English', theme:'Cambiar modo claro/oscuro',
      logoAlt:'Logotipo de Restaurante El Playón', g0Alt:'Pescado frito servido con arroz y ensalada', g1Alt:'Mariscos al ajillo con pulpo y camarón', g2Alt:'Camarones gratinados con queso',
      g3Alt:'Filetes empanizados con arroz y ensalada', g4Alt:'Jaibas rellenas con arroz y ensalada', g5Alt:'Aguachile de mariscos servido en copa',
      viewerAlt:'Fotografía de un platillo de El Playón', gallery:'Galería de platillos', close:'Cerrar', previous:'Fotografía anterior', next:'Fotografía siguiente',
      priceNote:'Precios en MXN. Confirma el importe total y la disponibilidad antes de ordenar. Las reservas no requieren anticipo.', whatsapp:'Abrir WhatsApp', menuSearch:'Buscar en el menú'
    },
    en: {
      privacy:'Privacy policy', terms:'Terms and conditions', cookies:'Cookie policy', refunds:'Refund policy', preferences:'Change consent', legalLinks:'Legal information', googlePolicy:'Google privacy', whatsappPolicy:'WhatsApp privacy', vercelPolicy:'Vercel privacy',
      consent:'I accept the privacy policy', reservationUse:'Your details are used to arrange your reservation. Continuing opens WhatsApp with the form details; review the message before sending it.',
      chatUse:'Questions are processed in this browser and cleared on reload. Do not include health, bank or identity document details.', consentRequired:'Accept the privacy policy to continue.',
      cookieTitle:'Your privacy', cookieText:'We store your theme in this browser and your consent choice for 180 days. Google Maps loads only if you accept; it may use cookies and receive your IP address. We use no analytics or advertising.',
      accept:'Accept Google Maps', reject:'Reject optional services', mapNotice:'The map is disabled. Allowing Google Maps connects to Google, which may receive your IP address and use cookies.', mapAllow:'Allow Google Maps',
      tradeName:'Trading name', legalName:'Legal owner or business name', taxId:'Mexican tax ID (RFC)', address:'Physical address', privacyContact:'Privacy contact', pending:'Awaiting confirmation from the owner',
      fullAddressPending:'Street, building number and neighborhood await confirmation.', pendingNotice:'The controller’s legal identity and full address await confirmation. This notice must be completed with those details.',
      updated:'Updated: October 4, 2026', back:'Back to the restaurant', skip:'Skip to content', language:'Cambiar idioma a español', theme:'Switch light/dark mode',
      logoAlt:'El Playón Restaurant logo', g0Alt:'Fried fish served with rice and salad', g1Alt:'Garlic seafood with octopus and shrimp', g2Alt:'Shrimp gratin with cheese',
      g3Alt:'Breaded fillets with rice and salad', g4Alt:'Stuffed crabs with rice and salad', g5Alt:'Seafood aguachile served in a glass',
      viewerAlt:'Photograph of an El Playón dish', gallery:'Dish photo gallery', close:'Close', previous:'Previous photo', next:'Next photo',
      priceNote:'Prices in MXN. Confirm the total amount and availability before ordering. Reservations require no deposit.', whatsapp:'Open WhatsApp', menuSearch:'Search the menu'
    }
  };
  const key = 'playon-consent-v1';
  const maxAge = 180 * 24 * 60 * 60 * 1000;
  let language = document.documentElement.lang === 'en' ? 'en' : 'es';
  let choice = null;
  let returnFocus = null;
  try {
    const saved = JSON.parse(localStorage.getItem(key));
    if (saved && saved.version === 1 && typeof saved.maps === 'boolean' && Number.isFinite(saved.at) && Date.now() >= saved.at && Date.now() - saved.at < maxAge) choice = saved;
  } catch {}
  const text = name => strings[language][name];
  const banner = document.querySelector('#privacyBanner');
  const map = document.querySelector('#locationMap');
  const mapNotice = document.querySelector('#mapConsent');
  function updateMap() {
    if (!map) return;
    const allowed = choice?.maps === true;
    if (allowed && !map.hasAttribute('src')) map.src = map.dataset.src;
    if (!allowed) map.removeAttribute('src');
    map.hidden = !allowed;
    if (mapNotice) mapNotice.hidden = allowed;
  }
  function setBannerVisible(visible) {
    if (banner) banner.hidden = !visible;
    document.body.classList.toggle('consent-pending',visible);
    const toggle = document.querySelector('#aiChatToggle');
    if (toggle) toggle.tabIndex = visible || toggle.classList.contains('is-hidden') ? -1 : 0;
  }
  function saveChoice(maps) {
    const focusWasInBanner = banner?.contains(document.activeElement);
    choice = {version:1,maps,at:Date.now()};
    try { localStorage.setItem(key,JSON.stringify(choice)); } catch {}
    updateMap();
    setBannerVisible(false);
    if (returnFocus?.isConnected) returnFocus.focus({preventScroll:true});
    else if (focusWasInBanner) document.querySelector('[data-consent-settings]')?.focus({preventScroll:true});
    returnFocus = null;
  }
  function validateForm(form) {
    const input = form.querySelector('[data-privacy-consent]');
    if (!input) return true;
    const error = form.querySelector('.privacy-error');
    if (input.checked) {
      input.removeAttribute('aria-invalid');
      error.hidden = true;
      return true;
    }
    input.setAttribute('aria-invalid','true');
    error.textContent = text('consentRequired');
    error.hidden = false;
    input.focus();
    return false;
  }
  function setLanguage(value) {
    language = value === 'en' ? 'en' : 'es';
    document.querySelectorAll('[data-legal-i18n]').forEach(el => { el.textContent = text(el.dataset.legalI18n); });
    document.querySelectorAll('[data-legal-alt]').forEach(el => { el.alt = text(el.dataset.legalAlt); });
    document.querySelectorAll('[data-legal-label]').forEach(el => { el.setAttribute('aria-label',text(el.dataset.legalLabel)); });
    document.querySelectorAll('[data-legal-language]').forEach(el => { el.hidden = el.dataset.legalLanguage !== language; });
    if (document.body.classList.contains('legal-page')) {
      const title = document.querySelector('[data-legal-language]:not([hidden]) h1');
      if (title) document.title = `${title.textContent} · El Playón`;
    }
    document.querySelectorAll('[data-privacy-link]').forEach(el => {
      const href = new URL(el.getAttribute('href'),location.href);
      href.searchParams.set('lang',language);
      el.href = href.href;
    });
    document.querySelectorAll('.privacy-error:not([hidden])').forEach(el => { el.textContent = text('consentRequired'); });
  }
  document.querySelectorAll('[data-consent-action]').forEach(button => {
    button.addEventListener('click',() => saveChoice(button.dataset.consentAction === 'accept'));
  });
  document.querySelectorAll('[data-consent-settings]').forEach(button => {
    button.addEventListener('click',() => {
      returnFocus = button;
      setBannerVisible(true);
      banner?.querySelector('button')?.focus();
    });
  });
  document.querySelectorAll('[data-privacy-consent]').forEach(input => {
    input.addEventListener('change',() => {
      input.removeAttribute('aria-invalid');
      input.closest('form').querySelector('.privacy-error').hidden = true;
    });
  });
  window.PlayonPrivacy = {setLanguage,validateForm};
  updateMap();
  setBannerVisible(!choice);
  setLanguage(language);
  if (document.body.classList.contains('legal-page')) {
    const requestedLanguage = new URLSearchParams(location.search).get('lang');
    if (requestedLanguage === 'en') { document.documentElement.lang = 'en'; setLanguage('en'); }
    document.querySelector('#legalLang').addEventListener('click',() => {
      document.documentElement.lang = language === 'es' ? 'en' : 'es';
      setLanguage(document.documentElement.lang);
      const url = new URL(location.href);
      url.searchParams.set('lang',language);
      history.replaceState(null,'',url);
    });
    const root = document.documentElement;
    try { root.dataset.theme = localStorage.getItem('playon-theme') === 'dark' ? 'dark' : 'light'; } catch {}
    document.querySelector('#legalTheme').addEventListener('click',() => {
      root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
      try { localStorage.setItem('playon-theme',root.dataset.theme); } catch {}
    });
  }
})();
