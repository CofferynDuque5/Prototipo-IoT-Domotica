/*
 * ===========================================================================
 *  Puente Serial: API REST  <->  Puerto serial virtual (COMPIM en Proteus)
 * ===========================================================================
 *  Flujo:
 *    1) Consulta GET /api/estado cada POLL_INTERVAL_MS.
 *    2) Procesa los dispositivos dev_luz_sala y dev_luz_cocina.
 *    3) Si el estado cambió, escribe el carácter correspondiente en el
 *       puerto serial virtual:
 *         - Sala:    '1' (ON) / '0' (OFF)
 *         - Cocina:  '2' (ON) / '3' (OFF)
 * ===========================================================================
 */
'use strict';

require('dotenv').config();
const { SerialPort } = require('serialport');

const CONFIG = {
  apiUrl: process.env.BACKEND_URL || 'http://localhost:3000',
  deviceKey: process.env.DEVICE_API_KEY || 'cambia_esta_clave_del_dispositivo',
  serialPath: process.env.SERIAL_PORT || 'COM2',
  baudRate: parseInt(process.env.BAUD_RATE || '9600', 10),
  pollIntervalMs: parseInt(process.env.POLL_INTERVAL_MS || '1000', 10),
  reconnectMs: 3000,
};

let port = null;          // instancia de SerialPort (o null si está cerrado)
let lastSent = {};        // almacena el último estado enviado por dispositivo { id: estado }
let opening = false;      // evita intentos de apertura solapados

// ---------------------------------------------------------------------------
// Puerto serial
// ---------------------------------------------------------------------------
function openSerial() {
  if (opening || (port && port.isOpen)) return;
  opening = true;

  const sp = new SerialPort({
    path: CONFIG.serialPath,
    baudRate: CONFIG.baudRate,
    autoOpen: false,
  });

  sp.open((err) => {
    opening = false;
    if (err) {
      console.error(`[serial] No se pudo abrir ${CONFIG.serialPath}: ${err.message}`);
      console.error(
        `[serial] Verifica que el puerto virtual exista y NO esté ocupado ` +
        `(Proteus usa el otro extremo del par). Reintentando en ${CONFIG.reconnectMs / 1000}s...`,
      );
      scheduleReopen();
      return;
    }
    port = sp;
    lastSent = {}; // fuerza el reenvío de estados tras (re)conectar
    console.log(`[serial] Puerto ${CONFIG.serialPath} abierto a ${CONFIG.baudRate} baudios`);
  });

  sp.on('error', (err) => {
    console.error(`[serial] Error: ${err.message}`);
  });

  sp.on('close', () => {
    console.warn('[serial] Puerto cerrado. Reintentando...');
    port = null;
    scheduleReopen();
  });
}

function scheduleReopen() {
  port = null;
  setTimeout(openSerial, CONFIG.reconnectMs);
}

function sendState(deviceId, estado, charOn, charOff) {
  if (!port || !port.isOpen) return;
  if (lastSent[deviceId] === estado) return; // solo se escribe cuando hay un cambio real

  const ch = estado ? charOn : charOff;
  port.write(ch, (err) => {
    if (err) {
      console.error(`[serial] Error al escribir '${ch}' para ${deviceId}: ${err.message}`);
      return;
    }
    lastSent[deviceId] = estado;
    console.log(`[bridge] [${deviceId}] Estado=${estado}  ->  enviado '${ch}' por ${CONFIG.serialPath}`);
  });
}

// ---------------------------------------------------------------------------
// Sondeo de la API
// ---------------------------------------------------------------------------
async function pollOnce() {
  try {
    const res = await fetch(`${CONFIG.apiUrl}/api/estado`, {
      headers: { 
        'x-device-api-key': CONFIG.deviceKey, 
        'x-device-key': CONFIG.deviceKey      
      },
    });

    if (!res.ok) {
      console.error(`[api] GET /api/estado -> HTTP ${res.status}`);
      return;
    }

    const data = await res.json();

    // Soporta si la API devuelve un Array de dispositivos o un objeto individual
    const dispositivos = Array.isArray(data) ? data : (data.dispositivos || [data]);

    dispositivos.forEach((dev) => {
      if (dev.id === 'dev_luz_sala') {
        sendState('dev_luz_sala', dev.estado === true, '1', '0');
      } 
      else if (dev.id === 'dev_luz_cocina') {
        sendState('dev_luz_cocina', dev.estado === true, '2', '3');
      }
    });

  } catch (err) {
    console.error(`[api] No se pudo consultar la API (${CONFIG.apiUrl}): ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// Arranque
// ---------------------------------------------------------------------------
function main() {
  console.log('==================================================');
  console.log(' Puente Serial  (API REST  <->  Proteus / COMPIM)');
  console.log('==================================================');
  console.log(`API:    ${CONFIG.apiUrl}`);
  console.log(`Serial: ${CONFIG.serialPath} @ ${CONFIG.baudRate} baudios`);
  console.log(`Sondeo: cada ${CONFIG.pollIntervalMs} ms`);
  console.log('--------------------------------------------------');

  openSerial();
  setInterval(pollOnce, CONFIG.pollIntervalMs);
}

// Cierre ordenado.
process.on('SIGINT', () => {
  console.log('\n[bridge] Cerrando...');
  if (port && port.isOpen) port.close();
  process.exit(0);
});

main();