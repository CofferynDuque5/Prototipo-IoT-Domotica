/*
 * Config.h
 * ---------------------------------------------------------------------------
 * Configuración centralizada del firmware del nodo IoT (NodeMCU ESP8266).
 *
 * IMPORTANTE: sustituye los valores marcados con "CAMBIAR" por los de tu
 * entorno. Para no versionar credenciales reales puedes mover estas macros a
 * un archivo "secrets.h" (ya ignorado por .gitignore) e incluirlo aquí.
 * ---------------------------------------------------------------------------
 */
#ifndef CONFIG_H
#define CONFIG_H

// ===========================================================================
// Red Wi-Fi
// ===========================================================================
#define WIFI_SSID       "CAMBIAR_SSID"        // Nombre de tu red Wi-Fi
#define WIFI_PASSWORD   "CAMBIAR_PASSWORD"    // Contraseña de tu red Wi-Fi

// ===========================================================================
// Firebase
// ===========================================================================
// URL de tu Realtime Database (sin barra final), p. ej.:
//   https://mi-proyecto-default-rtdb.firebaseio.com
#define FIREBASE_HOST   "https://TU_PROYECTO-default-rtdb.firebaseio.com"

// Clave web de API del proyecto (Configuración del proyecto → General).
#define FIREBASE_API_KEY "CAMBIAR_API_KEY"

// Cuenta de dispositivo creada en Firebase Authentication (correo/contraseña).
// Se recomienda crear un usuario dedicado SOLO para el hardware.
#define DEVICE_EMAIL     "esp8266@tudominio.com"
#define DEVICE_PASSWORD  "CAMBIAR_PASSWORD_DISPOSITIVO"

// ===========================================================================
// Rutas (nodos) de la base de datos
// ===========================================================================
#define PATH_DEVICES    "/devices"   // Colección de dispositivos/relés
#define PATH_ESP        "/esp"       // Telemetría del microcontrolador

// ===========================================================================
// Identidad del firmware
// ===========================================================================
#define FIRMWARE_VERSION "1.0.0"

// ===========================================================================
// Relés (GPIO) — 4 canales de ejemplo
// ---------------------------------------------------------------------------
// Cada relé se asocia a un GPIO. Estos valores deben COINCIDIR con el campo
// "gpio" de cada dispositivo en la base de datos.
//
//   GPIO5  (D1)  -> Relé 1  (p. ej. Luz Sala)
//   GPIO4  (D2)  -> Relé 2  (p. ej. Luz Cocina)
//   GPIO14 (D5)  -> Relé 3  (p. ej. Ventilador)
//   GPIO12 (D6)  -> Relé 4  (p. ej. Tomacorriente)
// ===========================================================================
#define RELAY_COUNT     4
static const uint8_t RELAY_PINS[RELAY_COUNT] = { 5, 4, 14, 12 };

// Muchos módulos de relé son ACTIVOS EN BAJO (LOW = encendido). Ajusta según
// tu hardware: true  -> LOW activa el relé; false -> HIGH activa el relé.
#define RELAY_ACTIVE_LOW  true

// ===========================================================================
// Temporizaciones (milisegundos)
// ===========================================================================
#define TELEMETRY_INTERVAL_MS   10000  // Cada cuánto se publica la telemetría
#define WIFI_RETRY_INTERVAL_MS  500    // Espera entre intentos de Wi-Fi
#define WIFI_MAX_RETRIES        40     // Reintentos antes de reiniciar Wi-Fi

#endif  // CONFIG_H
