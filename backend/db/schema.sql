-- ===========================================================================
-- Esquema de la base de datos PostgreSQL — Sistema IoT de Domótica
-- ===========================================================================
-- Ejecuta este script para crear las tablas. Los timestamps se almacenan como
-- BIGINT (epoch en milisegundos) para coincidir con los modelos de la app.
-- ===========================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------------
-- Usuarios (autenticación)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre        TEXT        NOT NULL,
  email         TEXT        NOT NULL UNIQUE,
  password_hash TEXT        NOT NULL,
  created_at    BIGINT      NOT NULL
);

-- ---------------------------------------------------------------------------
-- Dispositivos (relés controlables)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS devices (
  id                    TEXT    PRIMARY KEY,
  nombre                TEXT    NOT NULL,
  tipo                  TEXT    NOT NULL DEFAULT 'generico',
  estado                BOOLEAN NOT NULL DEFAULT FALSE,
  gpio                  INTEGER NOT NULL,
  habitacion            TEXT    NOT NULL DEFAULT 'General',
  online                BOOLEAN NOT NULL DEFAULT FALSE,
  ultima_actualizacion  BIGINT  NOT NULL DEFAULT 0
);

-- ---------------------------------------------------------------------------
-- Historial de eventos
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS events (
  id          BIGSERIAL PRIMARY KEY,
  device_id   TEXT   NOT NULL,
  device_name TEXT   NOT NULL,
  action      TEXT   NOT NULL,
  timestamp   BIGINT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events (timestamp DESC);

-- ---------------------------------------------------------------------------
-- Telemetría del ESP8266 (fila única con id = 1)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS esp_status (
  id         INTEGER PRIMARY KEY DEFAULT 1,
  online     BOOLEAN NOT NULL DEFAULT FALSE,
  ip         TEXT    NOT NULL DEFAULT '0.0.0.0',
  ssid       TEXT    NOT NULL DEFAULT '-',
  rssi       INTEGER NOT NULL DEFAULT -100,
  uptime     INTEGER NOT NULL DEFAULT 0,
  firmware   TEXT    NOT NULL DEFAULT '1.0.0',
  free_heap  INTEGER NOT NULL DEFAULT 0,
  last_seen  BIGINT  NOT NULL DEFAULT 0,
  CONSTRAINT esp_status_singleton CHECK (id = 1)
);
