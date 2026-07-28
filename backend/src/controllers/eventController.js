// Lógica de negocio del historial de eventos.
import { query } from '../db.js';
import { mapEvent } from '../mappers.js';

const MAX_EVENTS = 100;

/** Inserta un evento en el historial. */
export async function logEvent(deviceId, deviceName, action) {
  const now = Date.now();
  await query(
    `INSERT INTO events (device_id, device_name, action, timestamp)
     VALUES ($1, $2, $3, $4)`,
    [deviceId, deviceName, action, now],
  );
}

/** Devuelve los eventos más recientes (máx. MAX_EVENTS). */
export async function getRecentEvents() {
  const { rows } = await query(
    'SELECT * FROM events ORDER BY timestamp DESC LIMIT $1',
    [MAX_EVENTS],
  );
  return rows.map(mapEvent);
}

// --------------------------------------------------------------------------
// Handler HTTP
// --------------------------------------------------------------------------
export async function listEvents(req, res) {
  res.json(await getRecentEvents());
}
