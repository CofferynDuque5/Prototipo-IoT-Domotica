/*
 * ===========================================================================
 *  Puente Serial: API REST  <->  Puerto serial virtual (COMPIM en Proteus)
 * ===========================================================================
 *  Flujo:
 *    1) Consulta GET /api/estado cada POLL_INTERVAL_MS.
 *    2) Si el estado cambió, escribe '1' (encendido) o '0' (apagado) en el
 *       puerto serial virtual, que Proteus recibe a través de COMPIM.
 *
 *  Toda la comunicación es por puerto serial VIRTUAL (VSPD / com0com). No se
 *  asume ningún hardware físico. Incluye manejo de errores y reconexión tanto
 *  del puerto serial (p. ej. si está ocupado) como de la API.
 * ===========================================================================
 */
'use strict';

require('dotenv').config();
const { SerialPort } = require('serialport');

const CONFIG = {
  apiUrl: process.env.API_URL || 'http://localhost:3000',
  deviceKey: process.env.DEVICE_API_KEY || 'cambia_esta_clave_del_dispositivo',
  serialPath: process.env.SERIAL_PORT || 'COM2',
  baudRate: parseInt(process.env.BAUD_RATE || '9600', 10),
  pollIntervalMs: parseInt(process.env.POLL_INTERVAL_MS || '1000', 10),
  reconnectMs: 3000,
};

let port = null;          // instancia de SerialPort (o null si está cerrado)
let lastSent = null;      // último estado enviado (para escribir solo en cambios)
let opening = false;      // evita intentos de apertura solapados

// ---------------------------------------------------------------------------
// Puerto serial
// ---------------------------------------------------------------------------
function openSerial() {
  if (opening || (port && port.isOpen)) return;
  opening = true;

  const sp = new SerialPort(
    { path: CONFIG.serialPath, baudRate: CONFIG.baudRate, autoOpen: false },
  );

  sp.open((err) => {
    opening = false;
    if (err) {
      // Errores típicos: "Access denied" / "Resource busy" (COM ocupado),
      // "File not found" (el puerto virtual no existe todavía).
      console.error(`[serial] No se pudo abrir ${CONFIG.serialPath}: ${err.message}`);
      console.error(
        `[serial] Verifica que el puerto virtual exista y NO esté ocupado ` +
        `(Proteus usa el otro extremo del par). Reintentando en ${CONFIG.reconnectMs / 1000}s...`,
      );
      scheduleReopen();
      return;
    }
    port = sp;
    lastSent = null; // fuerza el reenvío del estado tras (re)conectar
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

function sendState(estado) {
  if (!port || !port.isOpen) return;
  if (estado === lastSent) return; // solo se escribe cuando hay un cambio real

  const ch = estado ? '1' : '0';
  port.write(ch, (err) => {
    if (err) {
      console.error(`[serial] Error al escribir '${ch}': ${err.message}`);
      return;
    }
    lastSent = estado;
    console.log(`[bridge] Estado=${estado}  ->  enviado '${ch}' por ${CONFIG.serialPath}`);
  });
}

// ---------------------------------------------------------------------------
// Sondeo de la API
// ---------------------------------------------------------------------------
async function pollOnce() {
  try {
    const res = await fetch(`${CONFIG.apiUrl}/api/estado`, {
      headers: { 'x-device-key': CONFIG.deviceKey },
    });
    if (!res.ok) {
      console.error(`[api] GET /api/estado -> HTTP ${res.status}`);
      return;
    }
    const data = await res.json();
    sendState(data.estado === true);
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
