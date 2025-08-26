const elements = {
  hudContainer: document.getElementById('hud-container'),
  mapBorder: document.getElementById('map-border'),
  mapHeader: document.getElementById('map-header'),
  locationDisplay: document.getElementById('location-display'),
  statusIcons: document.getElementById('status-icons'),
  healthFill: document.querySelector('.health-fill'),
  armorFill: document.querySelector('.armor-fill'),
  playerId: document.getElementById('player-id'),
  discordInvite: document.getElementById('discord-invite'),
  currentTime: document.getElementById('current-time'),
  micIcon: document.getElementById('mic-icon'),
  healthIcon: document.getElementById('health-icon'),
  armorIcon: document.getElementById('armor-icon'),
  serverInfo: document.getElementById('server-info'),
  headtagValue: document.getElementById('headtag-value'),
  aopValue: document.getElementById('aop-value'),
  peacetimeValue: document.getElementById('peacetime-value'),
  priorityStatuses: document.querySelectorAll('.priority-status'),
  timestamp: document.getElementById('timestamp'),
  newDirection: document.getElementById('new-direction'),
  newStreet: document.getElementById('new-street'),
  newPostal: document.getElementById('new-postal'),
  newPlayerName: document.getElementById('new-player-name'),
};

let hudVisible = true;
let minimapAnchor = null;
let voiceStatus = 0;

function initializeHUD() {
  updateTimestamp();
  setInterval(updateTimestamp, 1000);
  
  elements.mapBorder.style.display = 'none';
  
  if (minimapAnchor) {
    positionElementsAroundMinimap();
  }
}

function resetHUD() {
  elements.mapBorder.style.display = 'none';
  elements.hudContainer.style.display = 'block';
  hudVisible = true;
  minimapAnchor = null;
  
  elements.mapHeader.style.position = '';
  elements.mapHeader.style.left = '';
  elements.mapHeader.style.top = '';
  elements.mapHeader.style.width = '';
  
  if (elements.locationDisplay) {
    elements.locationDisplay.style.position = '';
    elements.locationDisplay.style.left = '';
    elements.locationDisplay.style.top = '';
    elements.locationDisplay.style.width = '';
  }
  elements.serverInfo.style.position = '';
  elements.serverInfo.style.left = '';
  elements.serverInfo.style.top = '';
  elements.statusIcons.style.position = '';
  elements.statusIcons.style.left = '';
  elements.statusIcons.style.top = '';
  
  elements.serverInfo.classList.remove('positioned-element');
}

function updateHUD(data) {
  if (!data) return;
  
  const playerData = data.player || data;
  
  if (playerData.id !== undefined) {
    elements.playerId.textContent = playerData.id;
  }
  
  if (playerData.health !== undefined) {
    const healthPercent = Math.max(0, Math.min(100, playerData.health));
    elements.healthFill.style.width = `${healthPercent}%`;
  }
  
  if (playerData.armor !== undefined) {
    const armorPercent = Math.max(0, Math.min(100, playerData.armor));
    elements.armorFill.style.width = `${armorPercent}%`;
  }
  
  if (playerData.headtag !== undefined) {
    elements.headtagValue.textContent = playerData.headtag;
  }
  
  if (playerData.name !== undefined) {
    elements.newPlayerName.textContent = playerData.name || 'Player';
  }
  
  if (playerData.postal !== undefined) {
    elements.newPostal.textContent = playerData.postal;
  }
  
  if (playerData.street !== undefined) {
    elements.newStreet.textContent = playerData.street || 'Unknown Street';
  }
  
  if (playerData.direction !== undefined) {
    elements.newDirection.textContent = playerData.direction || 'N';
  }
  
  if (playerData.discord !== undefined) {
    elements.discordInvite.textContent = playerData.discord.replace('discord.gg/', '');
  }
  
  if (playerData.aop !== undefined) {
    elements.aopValue.textContent = playerData.aop;
  }
  
  if (playerData.peacetime !== undefined) {
    const peacetimeText = typeof playerData.peacetime === 'boolean' 
      ? (playerData.peacetime ? 'ON' : 'OFF')
      : playerData.peacetime;
    elements.peacetimeValue.textContent = peacetimeText;
    elements.peacetimeValue.className = (playerData.peacetime === true || playerData.peacetime === 'ON' || playerData.peacetime === 'Enabled') 
      ? 'info-value pt-green' 
      : 'info-value pt-red';
  }
  
  if (playerData.priority !== undefined) {
    const parts = playerData.priority.split(' | ');
    parts.forEach(part => {
      const [type, status] = part.split(' ');
      if (type && status) {
        if (type === 'BC') {
          elements.priorityStatuses[0].textContent = status;
        } else if (type === 'LS') {
          elements.priorityStatuses[1].textContent = status;
        }
      }
    });
  }
  
  if (playerData.voiceStatus !== undefined) {
    updateVoiceStatus(playerData.voiceStatus.range || 1);
  }
  if (data.minimap) {
    minimapAnchor = data.minimap;
    positionElementsAroundMinimap();
  }
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
  
  elements.mapBorder.style.display = 'none';
  
  if (elements.mapHeader) {
    const headerPadding = 24;
    elements.mapHeader.style.position = 'absolute';
    elements.mapHeader.style.left = `${mapLeft}px`;
    elements.mapHeader.style.top = `${mapTop - 35}px`;
    elements.mapHeader.style.width = `${mapWidth - headerPadding}px`;
    elements.mapHeader.style.maxWidth = `${mapWidth - headerPadding}px`;
    elements.mapHeader.style.overflow = 'hidden';
    elements.mapHeader.classList.add('positioned-element');
  }
  
  if (elements.locationDisplay) {
    let locationLeft = mapRight + 10;
    const locationWidth = elements.locationDisplay.offsetWidth || 320;
    
    if (locationLeft + locationWidth > window.innerWidth - 10) {
      locationLeft = mapLeft - locationWidth - 10;
    }
    
    const serverInfoHeight = elements.serverInfo ? elements.serverInfo.offsetHeight : 0;
    const locationTop = mapTop + serverInfoHeight + 10;
    
    elements.locationDisplay.style.position = 'absolute';
    elements.locationDisplay.style.left = `${Math.max(10, locationLeft)}px`;
    elements.locationDisplay.style.top = `${locationTop}px`;
    elements.locationDisplay.classList.add('positioned-element');
  }
  
  if (elements.statusIcons) {
    const statusIconsWidth = elements.statusIcons.offsetWidth || 200;
    let centeredLeft = mapLeft + (mapWidth - statusIconsWidth) / 2;
    centeredLeft = Math.max(10, Math.min(centeredLeft, window.innerWidth - statusIconsWidth - 10));
    
    elements.statusIcons.style.position = 'absolute';
    elements.statusIcons.style.left = `${centeredLeft}px`;
    elements.statusIcons.style.top = `${mapBottom - 35}px`;
    elements.statusIcons.classList.add('positioned-element');
  }
  
  let serverInfoLeft = mapRight + 10;
  const serverInfoWidth = elements.serverInfo.offsetWidth || 320;
  
  if (serverInfoLeft + serverInfoWidth > window.innerWidth - 10) {
    serverInfoLeft = mapLeft - serverInfoWidth - 10;
  }
  
  elements.serverInfo.style.position = 'absolute';
  elements.serverInfo.style.left = `${Math.max(10, serverInfoLeft)}px`;
  elements.serverInfo.style.top = `${mapTop}px`;
  elements.serverInfo.classList.add('positioned-element');
}

function updateVoiceStatus(status) {
  voiceStatus = status;
  
  elements.micIcon.className = 'fas fa-microphone';
  
  switch(status) {
    case 0:
      elements.micIcon.style.color = '#e74c3c';
      break;
    case 1:
      elements.micIcon.style.color = '#f39c12';
      break;
    case 2:
      elements.micIcon.style.color = '#2ecc71';
      break;
    case 3:
      elements.micIcon.style.color = '#3498db';
      break;
    default:
      elements.micIcon.style.color = '#95a5a6';
  }
}



function updateTimestamp() {
  const now = new Date();
  const timeString = now.toLocaleTimeString('en-US', {
    hour12: true,
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  });
  const dateString = now.toLocaleDateString('en-US', {
    month: '2-digit',
    day: '2-digit',
    year: '2-digit'
  });
  
  elements.timestamp.textContent = `${dateString} | ${timeString} CET`;
  elements.currentTime.textContent = timeString;
}

function toggleHUD() {
  hudVisible = !hudVisible;
  if (elements.hudContainer) elements.hudContainer.style.display = hudVisible ? 'block' : 'none';
}

function showHUD() {
  hudVisible = true;
  if (elements.hudContainer) elements.hudContainer.style.display = 'block';
}

function hideHUD() {
  hudVisible = false;
  if (elements.hudContainer) elements.hudContainer.style.display = 'none';
}

window.addEventListener('message', function(event) {
  const data = event.data;
  
  switch(data.action) {
    case 'updateHUD':
      updateHUD(data.data);
      break;
 case 'updateVoice':
      updateVoiceStatus(data.status);
      break;
    case 'toggleHUD':
      toggleHUD();
      break;
    case 'showHUD':
      showHUD();
      break;
    case 'hideHUD':
      hideHUD();
      break;
    case 'updateStyle':
      updateStyleAndAccent(data.style, data.accentColor);
      break;
    case 'switchHudStyle':
      switchHudStyle(data.style, data.accentColor);
      break;
    case 'updateAccentColor':
      updateAccentColor(data.accentColor);
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
    case 'resetHUD':
      resetHUD();
      break;
  }
});

function switchHudStyle(style, accentColor) {
  if (style === 'og') {
    window.location.href = 'index.html';
  } else {
    updateStyleAndAccent(style, accentColor);
  }
}

function updateAccentColor(accentColor) {
  document.documentElement.style.setProperty('--accent-color', accentColor);
}

function updateStyleAndAccent(style, accentColor) {
  const root = document.documentElement;
  
  document.body.className = '';
  document.body.classList.add(`style-${style}`);
  
  if (accentColor) {
    root.style.setProperty('--accent-color', accentColor);
  }
  
  const accentElements = document.querySelectorAll('.accent-color');
  accentElements.forEach(element => {
    element.style.color = accentColor || 'var(--accent-color)';
  });
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