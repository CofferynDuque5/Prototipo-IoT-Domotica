// Lógica de negocio de la telemetría del ESP8266.
import { query } from '../db.js';
import { config } from '../config.js';
import { mapEsp } from '../mappers.js';
import { broadcast } from '../ws.js';

/**
 * Devuelve el estado del ESP recalculando "online" según la antigüedad del
 * último heartbeat (no basta con la bandera almacenada).
 */
export async function getEspStatus() {
  const { rows } = await query('SELECT * FROM esp_status WHERE id = 1');
  if (!rows.length) {
    return mapEsp({
      online: false, ip: '0.0.0.0', ssid: '-', rssi: -100,
      uptime: 0, firmware: '1.0.0', free_heap: 0, last_seen: 0,
    });
  }

  const esp = mapEsp(rows[0]);
  const ageSeconds = (Date.now() - esp.lastSeen) / 1000;
  esp.online =
    esp.lastSeen > 0 && ageSeconds <= config.espOfflineThresholdSeconds;
  return esp;
}

// --------------------------------------------------------------------------
// Handlers HTTP
// --------------------------------------------------------------------------

export async function getEsp(req, res) {
  res.json(await getEspStatus());
}

/**
 * El ESP8266 publica su telemetría. Requiere clave de dispositivo.
 * Difunde la actualización a las apps conectadas.
 */
export async function postTelemetry(req, res) {
  const {
    ip = '0.0.0.0',
    ssid = '-',
    rssi = -100,
    uptime = 0,
    firmware = '1.0.0',
    freeHeap = 0,
  } = req.body || {};

  const now = Date.now();

  await query(
    `INSERT INTO esp_status
        (id, online, ip, ssid, rssi, uptime, firmware, free_heap, last_seen)
     VALUES (1, TRUE, $1, $2, $3, $4, $5, $6, $7)
     ON CONFLICT (id) DO UPDATE SET
        online = TRUE,
        ip = EXCLUDED.ip,
        ssid = EXCLUDED.ssid,
        rssi = EXCLUDED.rssi,
        uptime = EXCLUDED.uptime,
        firmware = EXCLUDED.firmware,
        free_heap = EXCLUDED.free_heap,
        last_seen = EXCLUDED.last_seen`,
    [ip, ssid, rssi, uptime, firmware, freeHeap, now],
  );

  const esp = await getEspStatus();
  broadcast('esp', esp);
  res.json(esp);
}
