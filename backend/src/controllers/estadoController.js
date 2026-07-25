// Endpoints simplificados /api/estado para el puente serial hacia Proteus.
//
// Operan sobre un único dispositivo "relé" (config.relayDeviceId), el mismo que
// controla la app Flutter. Así el flujo queda unificado:
//   App Flutter → /api/devices/:id/state ─┐
//                                          ├─▶ PostgreSQL ─▶ /api/estado ─▶ puente serial ─▶ Proteus
//   Puente/otros → /api/estado ───────────┘
import { config } from '../config.js';
import { query } from '../db.js';
import { mapDevice } from '../mappers.js';
import { broadcast } from '../ws.js';
import { logEvent, getRecentEvents } from './eventController.js';
import { getAllDevices } from './deviceController.js';

/** GET /api/estado → estado actual del relé. */
export async function getEstado(req, res) {
  const { rows } = await query('SELECT * FROM devices WHERE id = $1', [
    config.relayDeviceId,
  ]);
  if (!rows.length) {
    return res
      .status(404)
      .json({ error: `Dispositivo de relé "${config.relayDeviceId}" no encontrado` });
  }
  const device = mapDevice(rows[0]);
  res.json({
    estado: device.estado,
    deviceId: device.id,
    nombre: device.nombre,
    gpio: device.gpio,
    ultimaActualizacion: device.ultimaActualizacion,
  });
}

/** POST /api/estado { estado: bool } → actualiza el relé y difunde el cambio. */
export async function setEstado(req, res) {
  const { estado } = req.body || {};
  if (typeof estado !== 'boolean') {
    return res.status(400).json({ error: 'El campo "estado" debe ser boolean' });
  }

  const now = Date.now();
  const { rows } = await query(
    `UPDATE devices
       SET estado = $1, ultima_actualizacion = $2
     WHERE id = $3
     RETURNING *`,
    [estado, now, config.relayDeviceId],
  );
  if (!rows.length) {
    return res
      .status(404)
      .json({ error: `Dispositivo de relé "${config.relayDeviceId}" no encontrado` });
  }

  const device = mapDevice(rows[0]);
  await logEvent(device.id, device.nombre, estado ? 'encendido' : 'apagado');
  broadcast('devices', await getAllDevices());
  broadcast('events', await getRecentEvents());

  res.json({ estado: device.estado, deviceId: device.id, nombre: device.nombre });
}
