const speedometerElements = {
  speedometer: document.getElementById('speedometer'),
  speedValue: document.getElementById('speed-value'),
  licensePlate: document.getElementById('license-plate'),
  rpmFill: document.querySelector('.rpm-fill'),
  fuelFill: document.querySelector('.fuel-fill'),
  fuelIcon: document.querySelector('.fuel-icon'),
  rpmIcon: document.querySelector('.rpm-icon'),
  engineWarning: document.getElementById('engine-warning')
};

let currentVehicleData = {
  inVehicle: false,
  speed: 0,
  gear: 1,
  rpm: 0,
  fuel: 0,
  engine: 100,
  licensePlate: 'UNKNOWN',
  seatbelt: false,
  engineOn: true,
  lights: false,
  needsRepair: false
};

function initSpeedometer() {
  hideSpeedometer();
}

function updateSpeedometer(vehicleData) {
  if (!vehicleData) return;
  
  Object.assign(currentVehicleData, vehicleData);
  
  if (speedometerElements.speedValue) {
    const speed = Math.max(0, Math.floor(currentVehicleData.speed || 0));
    speedometerElements.speedValue.textContent = speed.toString().padStart(3, '0');
  }
  
  if (speedometerElements.licensePlate) {
    speedometerElements.licensePlate.textContent = currentVehicleData.licensePlate || 'UNKNOWN';
  }
  
  updateRPM(currentVehicleData.rpm || 0);
  updateFuel(currentVehicleData.fuel || 0);
  updateIcons();
}

function updateRPM(rpm) {
  if (!speedometerElements.rpmFill) return;
  
  const rpmPercentage = Math.max(0, Math.min(100, rpm * 100));
  
  const fillAngle = (rpmPercentage / 100) * 180;
  const radians = (fillAngle * Math.PI) / 180;
  
  const startAngle = Math.PI * 3/2;
  const currentAngle = startAngle - radians;
  
  const endX = 50 + 50 * Math.cos(currentAngle);
  const endY = 50 + 50 * Math.sin(currentAngle);
  
  speedometerElements.rpmFill.style.clipPath = `polygon(50% 50%, 50% 100%, 100% 100%, 100% 50%, 100% 0%, ${endX}% ${endY}%)`;

  if (rpmPercentage > 80) {
    speedometerElements.rpmFill.classList.add('high');
  } else {
    speedometerElements.rpmFill.classList.remove('high');
  }
}

function updateFuel(fuelLevel) {
  if (!speedometerElements.fuelFill) return;
  
  const fuelPercentage = Math.max(0, Math.min(100, fuelLevel));
  
  const fillAngle = (fuelPercentage / 100) * 180;
  const radians = (fillAngle * Math.PI) / 180;
  
  const startAngle = Math.PI * 3/2;
  const currentAngle = startAngle + radians;
  
  const endX = 50 + 50 * Math.cos(currentAngle);
  const endY = 50 + 50 * Math.sin(currentAngle);
  
  speedometerElements.fuelFill.style.clipPath = `polygon(50% 50%, 0% 100%, 0% 50%, 0% 0%, ${endX}% ${endY}%)`;

  if (fuelPercentage < 20) {
    speedometerElements.fuelFill.style.borderLeftColor = '#ff4444';
  } else {
    speedometerElements.fuelFill.style.borderLeftColor = '#ff8800';
  }
}

function updateIcons() {
  if (speedometerElements.fuelIcon) {
    if (currentVehicleData.fuel < 20) {
      speedometerElements.fuelIcon.classList.add('active');
    } else {
      speedometerElements.fuelIcon.classList.remove('active');
    }
  }

  if (speedometerElements.rpmIcon) {
    if (currentVehicleData.rpm > 0.8) {
      speedometerElements.rpmIcon.classList.add('active');
    } else {
      speedometerElements.rpmIcon.classList.remove('active');
    }
  }

  if (speedometerElements.engineWarning) {
    if (currentVehicleData.engine < 50) {
      speedometerElements.engineWarning.classList.add('warning');
    } else {
      speedometerElements.engineWarning.classList.remove('warning');
    }
  }
}

function showSpeedometer() {
  if (speedometerElements.speedometer) {
    speedometerElements.speedometer.classList.add('visible');
  }
}

function hideSpeedometer() {
  if (speedometerElements.speedometer) {
    speedometerElements.speedometer.classList.remove('visible');
  }
}

function toggleSpeedometer(visible) {
  if (visible) {
    showSpeedometer();
  } else {
    hideSpeedometer();
  }
}

window.addEventListener('message', function(event) {
  const data = event.data;
  
  switch(data.action) {
    case 'updateSpeedometer':
      if (data.data && data.data.inVehicle) {
        updateSpeedometer(data.data);
        showSpeedometer();
      } else {
        hideSpeedometer();
      }
      break;
    case 'toggleSpeedometer':
      toggleSpeedometer(data.visible);
      break;
    case 'showSpeedometer':
      showSpeedometer();
      break;
    case 'hideSpeedometer':
      hideSpeedometer();
      break;
  }
});

document.addEventListener('DOMContentLoaded', function() {
  initSpeedometer();
});