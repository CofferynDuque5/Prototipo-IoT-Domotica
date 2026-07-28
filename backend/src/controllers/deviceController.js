// Lógica de negocio de dispositivos.
import { query } from '../db.js';
import { mapDevice } from '../mappers.js';
import { broadcast } from '../ws.js';
import { logEvent, getRecentEvents } from './eventController.js';

/** Devuelve todos los dispositivos ordenados por nombre. */
export async function getAllDevices() {
  const { rows } = await query(
    'SELECT * FROM devices ORDER BY nombre ASC',
  );
  return rows.map(mapDevice);
}

/** Devuelve un dispositivo por id (o null). */
export async function getDeviceById(id) {
  const { rows } = await query('SELECT * FROM devices WHERE id = $1', [id]);
  return rows.length ? mapDevice(rows[0]) : null;
}

// --------------------------------------------------------------------------
// Handlers HTTP
// --------------------------------------------------------------------------

export async function listDevices(req, res) {
  res.json(await getAllDevices());
}

export async function getDevice(req, res) {
  const device = await getDeviceById(req.params.id);
  if (!device) return res.status(404).json({ error: 'Dispositivo no encontrado' });
  res.json(device);
}

/**
 * Cambia el estado (encendido/apagado) de un dispositivo desde la app.
 * Registra un evento y difunde el cambio por WebSocket.
 */
export async function setDeviceState(req, res) {
  const { id } = req.params;
  const { estado } = req.body;

  if (typeof estado !== 'boolean') {
    return res.status(400).json({ error: 'El campo "estado" debe ser boolean' });
  }

  const now = Date.now();
  const { rows } = await query(
    `UPDATE devices
       SET estado = $1, ultima_actualizacion = $2
     WHERE id = $3
     RETURNING *`,
    [estado, now, id],
  );

  if (!rows.length) {
    return res.status(404).json({ error: 'Dispositivo no encontrado' });
  }

  const device = mapDevice(rows[0]);

  // Historial + difusión en tiempo real.
  await logEvent(device.id, device.nombre, estado ? 'encendido' : 'apagado');
  broadcast('devices', await getAllDevices());
  broadcast('events', await getRecentEvents());

  res.json(device);
}

/**
 * El ESP8266 confirma que aplicó el estado físico y se marca "online".
 * Requiere clave de dispositivo.
 */
export async function confirmDeviceState(req, res) {
  const { id } = req.params;
  const { estado } = req.body;
  const now = Date.now();

  const { rows } = await query(
    `UPDATE devices
       SET online = TRUE,
           estado = COALESCE($1, estado),
           ultima_actualizacion = $2
     WHERE id = $3
     RETURNING *`,
    [typeof estado === 'boolean' ? estado : null, now, id],
  );

  if (!rows.length) {
    return res.status(404).json({ error: 'Dispositivo no encontrado' });
  }

  broadcast('devices', await getAllDevices());
  res.json(mapDevice(rows[0]));
}
