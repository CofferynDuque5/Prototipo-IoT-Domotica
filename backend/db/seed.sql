-- ===========================================================================
-- Datos iniciales (seed) — 4 dispositivos + fila de telemetría del ESP.
-- Idempotente: puede ejecutarse varias veces sin duplicar.
-- ===========================================================================

INSERT INTO devices (id, nombre, tipo, estado, gpio, habitacion, online, ultima_actualizacion)
VALUES
  ('dev_luz_sala',      'Luz Sala',       'luz',            FALSE, 5,  'Sala',       FALSE, 0),
  ('dev_luz_cocina',    'Luz Cocina',     'luz',            FALSE, 4,  'Cocina',     FALSE, 0),
  ('dev_ventilador',    'Ventilador',     'ventilador',     FALSE, 14, 'Dormitorio', FALSE, 0),
  ('dev_tomacorriente', 'Tomacorriente',  'tomacorriente',  FALSE, 12, 'Sala',       FALSE, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO esp_status (id, online, ip, ssid, rssi, uptime, firmware, free_heap, last_seen)
VALUES (1, FALSE, '0.0.0.0', '-', -100, 0, '1.0.0', 0, 0)
ON CONFLICT (id) DO NOTHING;
