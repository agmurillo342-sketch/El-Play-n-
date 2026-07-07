/* ===========================================================
   Restaurant El Playón — script.js
   Menú dinámico, buscador, horario y animaciones
   =========================================================== */

document.addEventListener('DOMContentLoaded', () => {

  /* ================= DATOS DEL MENÚ ================= */
  const menuData = [
    {
      id: 'entradas',
      label: 'Entradas y Ceviches',
      items: [
        { name: 'Mega Hot Dog', price: 60 },
        { name: 'Hamburguesa Res', price: 100 },
        { name: 'Hamburguesa Res c/Papas', price: 150 },
        { name: 'Hamburguesa Camarón', price: 100 },
        { name: 'Hamburguesa Camarón c/Papas', price: 150 },
        { name: 'Hamburguesa Pollo', price: 150 },
        { name: 'Hamburguesa Pollo c/Papas', price: 150 },
        { name: 'Guacamole', price: 150 },
        { name: 'Papas a la Francesa', price: 85 },
        { name: 'Ceviche El Playón (pescado y camarón)', price: 250 },
        { name: 'Ceviche de Pescado', price: 180 },
        { name: 'Ceviche de Camarón', price: 200 },
        { name: 'Ceviche de Atún con Mango', price: 250 },
        { name: 'Ceviche Acapulqueño', price: 190 },
        { name: 'Queso Fundido', price: 130 },
        { name: 'Queso Fundido con Arrachera', price: 230 },
        { name: 'Queso Fundido con Camarón', price: 230 },
        { name: 'Nachos con Arrachera', price: 210 },
        { name: 'Nachos con Camarón', price: 230 },
        { name: 'Tiritas de Pescado', price: 200 },
        { name: 'Atún Aguachile', price: 190 },
      ],
    },
    {
      id: 'ensaladas',
      label: 'Ensaladas',
      items: [
        { name: 'Ensalada de Camarón c/Mayonesa', price: 230 },
        { name: 'Ensalada de Camarón', price: 220 },
        { name: 'Ensalada de Pulpo', price: 230 },
        { name: 'Ensalada de Callo', price: 200 },
        { name: 'Ensalada de Caracol', price: 200 },
        { name: 'Ensalada Mixta', price: 230 },
        { name: 'Ensalada de Marlín Ahumado', price: 190 },
      ],
    },
    {
      id: 'especialidades',
      label: 'Especialidades',
      items: [
        { name: 'Camarón Zarandeado', price: 230 },
        { name: 'Sopa de Mariscos', price: 280 },
        { name: 'Camarón 4x4', price: 280 },
        { name: 'Mariscos al Playón', price: 230 },
        { name: 'Sashimi de Atún', price: 200 },
        { name: 'Langosta al Gusto (temporada)', price: 390 },
        { name: 'Pescado Frito', price: 390 },
        { name: 'Pescado Zarandeado (Huachinango)', price: 280 },
        { name: 'Filete Relleno de Mariscos', price: 280 },
        { name: 'Rollo de Mar', price: 280 },
        { name: 'Chacales 1 Kg (temporada)', price: 250 },
      ],
    },
    {
      id: 'filetes',
      label: 'Filetes',
      items: [
        { name: 'Filete Zarandeado', price: 220 },
        { name: 'Filete Empanizado', price: 200 },
        { name: 'Filete al Chipotle', price: 190 },
        { name: 'Filete a la Mantequilla', price: 190 },
        { name: 'Filete a la Diabla', price: 190 },
        { name: 'Filete al Ajo', price: 190 },
        { name: 'Filete al Ajillo', price: 190 },
        { name: 'Filete a la Plancha', price: 190 },
        { name: 'Filete a la Veracruzana', price: 190 },
        { name: 'Filete Relleno de Marisco', price: 280 },
      ],
    },
    {
      id: 'camaron',
      label: 'Camarón',
      items: [
        { name: 'Camarón a la Diabla', price: 200 },
        { name: 'Camarón Empanizado', price: 220 },
        { name: 'Camarón al Aguachile', price: 200 },
        { name: 'Camarón a la Plancha', price: 200 },
        { name: 'Camarón al Ajo', price: 200 },
        { name: 'Camarón al Ajillo', price: 200 },
        { name: 'Camarón al Tamarindo', price: 220 },
        { name: 'Camarón a la Mantequilla', price: 200 },
        { name: 'Camarón Momia', price: 250 },
        { name: 'Camarón Cucaracha', price: 200 },
        { name: 'Camarón al Coco', price: 250 },
        { name: 'Camarones Mixtos (camarón y pulpo)', price: 250 },
        { name: 'Camarones Combinados', price: 240 },
      ],
    },
    {
      id: 'pulpo',
      label: 'Pulpo',
      items: [
        { name: 'Pulpo al Ajillo', price: 230 },
        { name: 'Pulpo a la Diabla', price: 230 },
        { name: 'Pulpo al Ajo', price: 230 },
        { name: 'Pulpo a la Mantequilla', price: 230 },
        { name: 'Pulpo Zarandeado (temporada)', price: 270 },
        { name: 'Pulpo Mixto', price: 270 },
      ],
    },
    {
      id: 'carnes',
      label: 'Carnes a la Parrilla',
      items: [
        { name: 'Arrachera Suprema', price: 280 },
        { name: 'Brochetas', price: 210 },
        { name: 'Fajitas de Arrachera', price: 200 },
        { name: 'Fajitas Mixtas', price: 220 },
        { name: 'Fajitas de Pollo', price: 180 },
        { name: 'Fajitas de Camarón', price: 210 },
        { name: 'Milanesa de Pollo', price: 170 },
      ],
    },
    {
      id: 'cocteles',
      label: 'Cócteles',
      items: [
        { name: 'Cóctel de Camarón Grande', price: 200 },
        { name: 'Cóctel de Camarón Mediano', price: 160 },
        { name: 'Cóctel de Pulpo Grande', price: 250 },
        { name: 'Cóctel de Pulpo Mediano', price: 200 },
        { name: 'Campechano Grande', price: 250 },
        { name: 'Campechano Mediano', price: 200 },
      ],
    },
    {
      id: 'bebidas',
      label: 'Bebidas',
      items: [
        { name: 'Coco con Ginebra', price: null },
        { name: 'Coco Loco', price: null },
        { name: 'Michelada', price: null },
        { name: 'Cielo Rojo', price: null },
        { name: 'Clamato', price: null },
        { name: 'Café', price: null },
        { name: 'Rusa Refresco', price: null },
        { name: 'Rusa Cerveza', price: null },
        { name: 'Naranjada / Limonada', price: null },
        { name: 'Mineral Preparado', price: null },
        { name: 'Piñada / Piña Colada', price: null },
        { name: 'Kahlúa / Margarita / Pantera Rosa / Coco', price: null },
        { name: 'Smoothie Fresandía', price: null },
        { name: 'Smoothie Maracuyá-Kiwi con Pepino', price: null },
        { name: 'Smoothie Mango, Piña, Frutos Rojos y Coco', price: null },
      ],
    },
    {
      id: 'refrescos',
      label: 'Refrescos',
      items: [
        { name: 'Coca Cola', price: null },
        { name: 'Coca Light', price: null },
        { name: 'Manzana / Manzanita Sol', price: null },
        { name: 'Fresca', price: null },
        { name: 'Fanta', price: null },
        { name: 'Sprite', price: null },
        { name: 'Peñafiel', price: null },
        { name: 'Pepsi', price: null },
        { name: '7up', price: null },
        { name: 'Mirinda', price: null },
      ],
    },
    {
      id: 'mojitos',
      label: 'Mojitos',
      items: [
        { name: 'Mojito Limón', price: null },
        { name: 'Mojito Frutos Rojos', price: null },
        { name: 'Mojito Mora Azul', price: null },
        { name: 'Mojito Maracuyá', price: null },
      ],
    },
    {
      id: 'cervezas',
      label: 'Cervezas',
      items: [
        { name: 'Corona', price: null },
        { name: 'Estrella', price: null },
        { name: 'Victoria', price: null },
        { name: 'Pacífico', price: null },
        { name: 'Corona Light', price: null },
        { name: 'Modelo Especial', price: null },
        { name: 'Negra Modelo', price: null },
      ],
    },
    {
      id: 'licores',
      label: 'Licores',
      groups: [
        {
          title: 'Tequila',
          items: [
            { name: 'Pueblo Viejo Azul', price: null },
            { name: 'Centenario (Reposado / Añejo)', price: null },
            { name: 'Herradura (Añejo / Reposado / Ultra / Antiguo)', price: null },
            { name: '1800 (Añejo / Cristalino)', price: null },
            { name: 'Don Julio (Añejo / 70)', price: null },
            { name: '7 Leguas', price: null },
          ],
        },
        {
          title: 'Brandys',
          items: [
            { name: 'Bacardí (Blanco / Normal)', price: null },
            { name: 'Azteca de Oro', price: null },
            { name: 'Torres 10', price: null },
          ],
        },
        {
          title: 'Whisky',
          items: [
            { name: 'Black Label', price: null },
            { name: 'Red Label', price: null },
            { name: "Buchanan's 12 / 18", price: null },
            { name: 'Chivas 12', price: null },
          ],
        },
        {
          title: 'Cognac',
          items: [
            { name: 'Hennessy', price: null },
            { name: 'Martell', price: null },
            { name: 'Rémy Martin', price: null },
          ],
        },
        {
          title: 'Vodka',
          items: [
            { name: 'Absolut', price: null },
          ],
        },
      ],
    },
    {
      id: 'postres',
      label: 'Postres',
      items: [
        { name: 'Helados Le Cascarie', price: null },
      ],
    },
  ];

  /* ================= RENDER DE TABS Y PANELES ================= */
  const tabsContainer = document.getElementById('menuTabs');
  const panelsContainer = document.getElementById('menuPanels');

  function formatPrice(price) {
    return price === null
      ? '<span class="menu-item-price no-price">Precio en barra</span>'
      : `<span class="menu-item-price">$${price} MXN</span>`;
  }

  function renderItemsGrid(items) {
    return `<div class="menu-grid">${items.map(item => `
      <div class="menu-item">
        <span class="menu-item-name">${item.name}</span>
        ${formatPrice(item.price)}
      </div>`).join('')}</div>`;
  }

  menuData.forEach((category, index) => {
    // Tab button
    const tabBtn = document.createElement('button');
    tabBtn.className = 'menu-tab-btn' + (index === 0 ? ' active' : '');
    tabBtn.type = 'button';
    tabBtn.textContent = category.label;
    tabBtn.dataset.target = category.id;
    tabBtn.addEventListener('click', () => activateTab(category.id));
    tabsContainer.appendChild(tabBtn);

    // Panel
    const panel = document.createElement('div');
    panel.className = 'menu-panel' + (index === 0 ? ' active' : '');
    panel.id = `panel-${category.id}`;

    if (category.groups) {
      panel.innerHTML = category.groups.map(group => `
        <h3 class="menu-group-title">${group.title}</h3>
        ${renderItemsGrid(group.items)}
      `).join('');
    } else {
      panel.innerHTML = renderItemsGrid(category.items);
    }

    panelsContainer.appendChild(panel);
  });

  function activateTab(targetId) {
    document.querySelectorAll('.menu-tab-btn').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.target === targetId);
    });
    document.querySelectorAll('.menu-panel').forEach(panel => {
      panel.classList.toggle('active', panel.id === `panel-${targetId}`);
    });
  }

  /* ================= BUSCADOR DE PLATILLOS ================= */
  const searchInput = document.getElementById('menuSearch');
  const searchResults = document.getElementById('menuSearchResults');
  const noResults = document.getElementById('noResults');

  // Lista plana de todos los platillos para la búsqueda
  const flatMenu = [];
  menuData.forEach(category => {
    if (category.groups) {
      category.groups.forEach(group => {
        group.items.forEach(item => {
          flatMenu.push({ ...item, category: `${category.label} — ${group.title}` });
        });
      });
    } else {
      category.items.forEach(item => {
        flatMenu.push({ ...item, category: category.label });
      });
    }
  });

  // Se expone para que el asistente virtual (chat.js) pueda buscar platillos
  window.__menuFlat = flatMenu;

  searchInput.addEventListener('input', () => {
    const query = searchInput.value.trim().toLowerCase();

    if (query === '') {
      tabsContainer.hidden = false;
      panelsContainer.hidden = false;
      searchResults.hidden = true;
      noResults.hidden = true;
      return;
    }

    const matches = flatMenu.filter(item => item.name.toLowerCase().includes(query));

    tabsContainer.hidden = true;
    panelsContainer.hidden = true;

    if (matches.length === 0) {
      searchResults.hidden = true;
      noResults.hidden = false;
      return;
    }

    noResults.hidden = true;
    searchResults.hidden = false;

    // Agrupar resultados por categoría
    const grouped = {};
    matches.forEach(item => {
      if (!grouped[item.category]) grouped[item.category] = [];
      grouped[item.category].push(item);
    });

    searchResults.innerHTML = Object.keys(grouped).map(categoryLabel => `
      <h3 class="menu-group-title">${categoryLabel}</h3>
      ${renderItemsGrid(grouped[categoryLabel])}
    `).join('');
  });

  /* ================= ESTADO ABIERTO / CERRADO ================= */
  function updateOpenStatus() {
    const badge = document.getElementById('statusBadge');
    const text = document.getElementById('statusText');
    const now = new Date();
    const minutesNow = now.getHours() * 60 + now.getMinutes();
    const openTime = 11 * 60;       // 11:00 a.m.
    const closeTime = 20 * 60;      // 8:00 p.m.

    const isOpen = minutesNow >= openTime && minutesNow < closeTime;

    badge.classList.remove('open', 'closed');
    if (isOpen) {
      badge.classList.add('open');
      text.textContent = 'Abierto ahora';
    } else {
      badge.classList.add('closed');
      text.textContent = 'Cerrado en este momento';
    }
  }

  updateOpenStatus();
  setInterval(updateOpenStatus, 60000);

  /* ================= MENÚ HAMBURGUESA ================= */
  const hamburger = document.getElementById('hamburger');
  const mainNav = document.getElementById('mainNav');

  hamburger.addEventListener('click', () => {
    const isOpen = mainNav.classList.toggle('open');
    hamburger.classList.toggle('open', isOpen);
    hamburger.setAttribute('aria-expanded', String(isOpen));
  });

  mainNav.querySelectorAll('.nav-link').forEach(link => {
    link.addEventListener('click', () => {
      mainNav.classList.remove('open');
      hamburger.classList.remove('open');
      hamburger.setAttribute('aria-expanded', 'false');
    });
  });

  /* ================= ANIMACIÓN FADE-IN AL HACER SCROLL ================= */
  const fadeEls = document.querySelectorAll('.fade-in');
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.15 });

  fadeEls.forEach(el => observer.observe(el));

});
