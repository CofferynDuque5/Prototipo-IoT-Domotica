// Convierte filas de PostgreSQL (snake_case) al formato JSON que consume la
// app Flutter y el firmware (camelCase). Centralizar el mapeo evita
// inconsistencias entre endpoints.

export function mapDevice(row) {
  return {
    id: row.id,
    nombre: row.nombre,
    tipo: row.tipo,
    estado: row.estado,
    gpio: row.gpio,
    habitacion: row.habitacion,
    online: row.online,
    ultimaActualizacion: Number(row.ultima_actualizacion),
  };
}

export function mapEvent(row) {
  return {
    id: String(row.id),
    deviceId: row.device_id,
    deviceName: row.device_name,
    action: row.action,
    timestamp: Number(row.timestamp),
  };
}

export function mapEsp(row) {
  return {
    online: row.online,
    ip: row.ip,
    ssid: row.ssid,
    rssi: row.rssi,
    uptime: row.uptime,
    firmware: row.firmware,
    freeHeap: row.free_heap,
    lastSeen: Number(row.last_seen),
  };
}

export function mapUser(row) {
  return {
    uid: row.id,
    nombre: row.nombre,
    email: row.email,
    createdAt: Number(row.created_at),
  };
}
