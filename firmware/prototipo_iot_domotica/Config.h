/*
 * Config.h
 * ---------------------------------------------------------------------------
 * Configuración centralizada del firmware del nodo IoT (NodeMCU ESP8266).
 *
 * El firmware se comunica con el BACKEND PROPIO (Node.js + PostgreSQL) a través
 * de su API REST, usando una clave de dispositivo (x-device-key).
 *
 * IMPORTANTE: sustituye los valores marcados con "CAMBIAR" por los de tu
 * entorno. Para no versionar credenciales puedes moverlas a un "secrets.h"
 * (ya ignorado por .gitignore) e incluirlo aquí.
 * ---------------------------------------------------------------------------
 */
#ifndef CONFIG_H
#define CONFIG_H

// ===========================================================================
// Red Wi-Fi (usa una red de 2.4 GHz; el ESP8266 no soporta 5 GHz)
// ===========================================================================
#define WIFI_SSID       "CAMBIAR_SSID"
#define WIFI_PASSWORD   "CAMBIAR_PASSWORD"

// ===========================================================================
// Backend (API REST)
// ---------------------------------------------------------------------------
// IP o host de la máquina que ejecuta el backend y su puerto. Usa la IP LAN
// de tu computadora (p. ej. 192.168.1.100), NO "localhost".
// ===========================================================================
#define API_HOST        "192.168.1.100"
#define API_PORT        3000

// Clave de dispositivo (debe coincidir con DEVICE_API_KEY del backend).
#define DEVICE_API_KEY  "cambia_esta_clave_del_dispositivo"

// ===========================================================================
// Rutas de la API
// ===========================================================================
#define PATH_DEVICE_LIST  "/api/devices/device/list"   // GET  (lista para el ESP)
#define PATH_ESP_TELEMETRY "/api/esp/telemetry"        // POST (telemetría)
// La confirmación se construye como: /api/devices/{id}/confirm

// ===========================================================================
// Identidad del firmware
// ===========================================================================
#define FIRMWARE_VERSION "1.0.0"

// ===========================================================================
// Relés (GPIO) — 4 canales de ejemplo
// ---------------------------------------------------------------------------
//   GPIO5  (D1)  -> Relé 1  (Luz Sala)
//   GPIO4  (D2)  -> Relé 2  (Luz Cocina)
//   GPIO14 (D5)  -> Relé 3  (Ventilador)
//   GPIO12 (D6)  -> Relé 4  (Tomacorriente)
// Estos GPIO deben COINCIDIR con el campo "gpio" de cada dispositivo en la BD.
// ===========================================================================
#define RELAY_COUNT     4
static const uint8_t RELAY_PINS[RELAY_COUNT] = { 5, 4, 14, 12 };

// Muchos módulos de relé son ACTIVOS EN BAJO (LOW = encendido). Ajusta según
// tu hardware: true -> LOW activa el relé; false -> HIGH activa el relé.
#define RELAY_ACTIVE_LOW  true

// ===========================================================================
// Temporizaciones (milisegundos)
// ===========================================================================
#define POLL_INTERVAL_MS        1500   // Cada cuánto se consultan los estados
#define TELEMETRY_INTERVAL_MS   10000  // Cada cuánto se publica la telemetría
#define WIFI_RETRY_INTERVAL_MS  500
#define WIFI_MAX_RETRIES        40

#endif  // CONFIG_H
