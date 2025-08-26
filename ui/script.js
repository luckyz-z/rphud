const elements = {
  hudContainer: document.getElementById('hud-container'),
  mapBorder: document.getElementById('map-border'),
  healthArmorContainer: document.getElementById('health-armor-container'),
  healthFill: document.querySelector('.health-fill'),
  armorFill: document.querySelector('.armor-fill'),
  playerInfo: document.getElementById('player-info'),
  playerId: document.getElementById('player-id'),
  staminaFill: document.querySelector('.stamina-fill'),
  voiceFill: document.querySelector('.voice-fill'),
  serverInfo: document.getElementById('server-info'),
  headtagValue: document.getElementById('headtag-value'),
  discordValue: document.getElementById('discord-value'),
  aopValue: document.getElementById('aop-value'),
  peacetimeValue: document.getElementById('peacetime-value'),
  priorityStatuses: document.querySelectorAll('.priority-status'),
  timestamp: document.getElementById('timestamp'),
  postalValue: document.getElementById('postal-value'),
  streetValue: document.getElementById('street-value'),
  directionValue: document.getElementById('direction-value'),
  playerName: document.getElementById('player-name'),
  
};

let hudVisible = true;
let minimapAnchor = null;

function initializeHUD() {
  updateTimestamp();
  setInterval(updateTimestamp, 1000);
  
  elements.mapBorder.style.display = 'none';
  
  updateStyleAndAccent('og', '#ffffff');
  
  if (minimapAnchor) {
    positionElementsAroundMinimap();
  }
}

function resetHUD() {
  elements.mapBorder.style.display = 'none';
  elements.hudContainer.style.display = 'block';
  hudVisible = true;
  minimapAnchor = null;
  
  elements.playerInfo.style.position = '';
  elements.serverInfo.style.position = '';
  elements.healthArmorContainer.style.position = '';
}

function updateHUD(data) {
  if (!data) return;
  
  const { player, vehicle, server } = data;
  
  if (player) {
    if (player.postal !== undefined) {
      elements.postalValue.textContent = player.postal;
    }
    if (player.street !== undefined) {
      elements.streetValue.textContent = player.street || 'Unknown Street';
    }
    if (player.direction !== undefined) {
      elements.directionValue.textContent = player.direction || 'N';
    }
    if (player.name !== undefined) {
      elements.playerName.textContent = player.name || 'Player';
    }
  }
  

  if (data.accentColor) {
    updateStyleAndAccent(data.style || 'og', data.accentColor);
  }
  
  if (data.minimap) {
    minimapAnchor = data.minimap;
    positionElementsAroundMinimap();
  }
  
  if (data.player) {
    const player = data.player;
    
    if (player.health !== undefined) {
      const healthPercent = Math.max(0, Math.min(100, player.health));
      elements.healthFill.style.setProperty('--health-width', `${healthPercent}%`);
    }
    
    if (player.armor !== undefined) {
      const armorPercent = Math.max(0, Math.min(100, player.armor));
      elements.armorFill.style.setProperty('--armor-width', `${armorPercent}%`);
    }
    
    if (player.id !== undefined) {
      elements.playerId.textContent = player.id;
    }
    
    if (player.stamina !== undefined) {
      updateStaminaBar(player.stamina);
    }
    
    if (player.voiceStatus) {
      updateVoiceBar(player.voiceStatus);
    }
    
    if (player.headtag !== undefined) {
      elements.headtagValue.textContent = player.headtag;
    }
    
    if (player.aop !== undefined) {
      elements.aopValue.textContent = player.aop;
    }
    
    if (player.peacetime !== undefined) {
      if (typeof player.peacetime === 'boolean') {
        elements.peacetimeValue.textContent = player.peacetime ? 'On' : 'Off';
      } else {
        elements.peacetimeValue.textContent = player.peacetime;
      }
    }
    
    if (player.discord !== undefined) {
      elements.discordValue.textContent = player.discord;
    }
    
    if (player.priority !== undefined) {
      const parts = player.priority.split(' | ');
      parts.forEach(part => {
        const [type, status] = part.split(' ');
        if (type && status) {
          elements.priorityStatuses.forEach(statusElement => {
            const pill = statusElement.closest('.bc-pill, .ls-pill');
            if (pill) {
              if ((type === 'BC' && pill.classList.contains('bc-pill')) ||
                  (type === 'LS' && pill.classList.contains('ls-pill'))) {
                statusElement.textContent = status;
              }
            }
          });
        }
      });
    }
  }
  

  
 updateTimestamp();
}

function positionElementsAroundMinimap() {
  if (!minimapAnchor) return;
  
  const { x, y, width, height, center_x, center_y } = minimapAnchor;
  const mapLeft = x * window.innerWidth;
  const mapTop = y * window.innerHeight;
  const mapWidth = width * window.innerWidth;
  const mapHeight = height * window.innerHeight;
  const mapBottom = mapTop + mapHeight;
  const mapRight = mapLeft + mapWidth;
  
  elements.mapBorder.style.left = `${mapLeft}px`;
  elements.mapBorder.style.top = `${mapTop}px`;
  elements.mapBorder.style.width = `${mapWidth}px`;
  elements.mapBorder.style.height = `${mapHeight}px`;
  elements.mapBorder.style.display = hudVisible ? 'block' : 'none';
  
  const healthArmorWidth = elements.healthArmorContainer.offsetWidth || 200;
  let centeredLeft = mapLeft + (mapWidth - healthArmorWidth) / 2;
  
  centeredLeft = Math.max(10, Math.min(centeredLeft, window.innerWidth - healthArmorWidth - 10));
  
  elements.healthArmorContainer.style.position = 'absolute';
  elements.healthArmorContainer.style.left = `${centeredLeft}px`;
  elements.healthArmorContainer.style.top = `${mapBottom - 25}px`;
  
  let serverInfoLeft = mapRight + 10;
  const serverInfoWidth = elements.serverInfo.offsetWidth || 320;
  
  if (serverInfoLeft + serverInfoWidth > window.innerWidth - 10) {
    serverInfoLeft = mapLeft - serverInfoWidth - 10;
  }
  
  elements.serverInfo.style.position = 'absolute';
  elements.serverInfo.style.left = `${Math.max(10, serverInfoLeft)}px`;
  elements.serverInfo.style.top = `${mapTop}px`;
  elements.serverInfo.classList.add('positioned-element');
  
  const playerInfoTop = window.innerHeight - elements.playerInfo.offsetHeight - 140;
  elements.playerInfo.style.position = 'absolute';
  elements.playerInfo.style.left = `${Math.max(10, serverInfoLeft)}px`;
  elements.playerInfo.style.top = `${Math.max(playerInfoTop, mapTop + 200)}px`;
  elements.playerInfo.style.bottom = 'auto';
  elements.playerInfo.classList.add('positioned-element');
  
  elements.healthArmorContainer.classList.add('positioned-element');
}

function updateStaminaBar(stamina) {
  const staminaPercent = Math.max(0, Math.min(100, stamina));
  const invertedPercent = 100 - staminaPercent;
  
  elements.staminaFill.style.height = `${invertedPercent}%`;
  
  if (stamina < 25) {
    elements.staminaFill.classList.add('low-stamina');
  } else {
    elements.staminaFill.classList.remove('low-stamina');
  }
}

function updateVoiceBar(voiceStatus) {
  if (!voiceStatus) return;
  
  const { talking, micEnabled, range } = voiceStatus;
  
  if (talking) {
    elements.voiceFill.style.height = '100%';
    elements.voiceFill.classList.add('talking');
  } else if (micEnabled) {
    const rangePercent = Math.min(100, (range || 1) * 33);
    elements.voiceFill.style.height = `${rangePercent}%`;
    elements.voiceFill.classList.remove('talking');
  } else {
    elements.voiceFill.style.height = '0%';
    elements.voiceFill.classList.remove('talking');
  }
}



function updateTimestamp() {
  const now = new Date();
  const options = {
    month: '2-digit',
    day: '2-digit',
    year: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: true
  };
  
  const formatted = now.toLocaleString('en-US', options);
  const [date, time] = formatted.split(', ');
  const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
  elements.timestamp.textContent = `${date} | ${time} ${timeZone.split('/').pop()}`;
}

function toggleHUD() {
  hudVisible = !hudVisible;
  if (elements.hudContainer) elements.hudContainer.style.display = hudVisible ? 'block' : 'none';
  if (elements.mapBorder) elements.mapBorder.style.display = hudVisible ? 'block' : 'none';
}

function showHUD() {
  hudVisible = true;
  if (elements.hudContainer) elements.hudContainer.style.display = 'block';
  if (elements.mapBorder) elements.mapBorder.style.display = 'block';
}

function hideHUD() {
  hudVisible = false;
  if (elements.hudContainer) elements.hudContainer.style.display = 'none';
  if (elements.mapBorder) elements.mapBorder.style.display = 'none';
}

window.addEventListener('message', function(event) {
  const { action, data } = event.data;
  
  switch (action) {
    case 'updateHUD':
      updateHUD(data);
      break;
    case 'toggleHUD':
      if (data && data.visible !== undefined) {
        hudVisible = data.visible;
        if (elements.hudContainer) elements.hudContainer.style.display = hudVisible ? 'block' : 'none';
        if (elements.mapBorder) elements.mapBorder.style.display = (hudVisible && minimapAnchor) ? 'block' : 'none';
      } else {
        toggleHUD();
      }
      break;
    case 'showHUD':
      showHUD();
      break;
    case 'hideHUD':
      hideHUD();
      break;
    case 'resetHUD':
      resetHUD();
      break;
    case 'updateStyle':
      updateStyleAndAccent(data.style, data.accentColor);
      break;
    case 'switchHudStyle':
      switchHudStyle(data.style, data && data.accentColor ? data.accentColor : null);
      break;
    case 'updateAccentColor':
      if (data && data.accentColor) {
        updateAccentColor(data.accentColor);
      }
      break;
    case 'updateSpeedometer':
      window.parent.postMessage({
        action: 'updateSpeedometer',
        data: data.data
      }, '*');
      break;
    case 'toggleSpeedometer':
      window.parent.postMessage({
        action: 'toggleSpeedometer'
      }, '*');
      break;
  }
});

function switchHudStyle(style, accentColor) {
  if (style === 'new') {
    window.location.href = 'new.html';
  } else {
    updateStyleAndAccent(style, accentColor);
  }
}

function updateAccentColor(accentColor) {
  if (accentColor) {
    document.documentElement.style.setProperty('--accent-color', accentColor);
  }
}

function updateStyleAndAccent(style, accentColor) {
  if (!accentColor) return;
  
  let color;
  
  if (typeof accentColor === 'string') {
    color = accentColor;
  } else if (Array.isArray(accentColor)) {
    color = `rgb(${accentColor[0]}, ${accentColor[1]}, ${accentColor[2]})`;
  } else {
    color = '#ffffff';
  }
  
  document.documentElement.style.setProperty('--accent-color', color);
  const accentElements = document.querySelectorAll(
    '#headtag-value, #discord-value, #aop-value, #peacetime-value, .priority-status, #player-id, .timestamp'
  );
  
  accentElements.forEach(element => {
    if (element && element.style) {
      element.style.color = color;
    }
  });

  if (style === 'og') {
    
  } else {
    
  }
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeHUD);
} else {
  initializeHUD();
}

window.addEventListener('resize', function() {
  if (minimapAnchor) {
    positionElementsAroundMinimap();
  }
});