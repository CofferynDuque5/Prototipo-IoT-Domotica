/*
 * ===========================================================================
 *  Prototipo de Sistema IoT para Domótica  —  Firmware NodeMCU ESP8266
 * ===========================================================================
 *  Autores : Valeryn Duque & Juan Vrasmatas
 *  Placa   : NodeMCU 1.0 (ESP-12E) / ESP8266
 *  IDE     : Arduino IDE 1.8.x / 2.x
 *
 *  Descripción
 *  -----------
 *  Nodo físico que actúa sobre relés (cargas eléctricas) consultando el
 *  BACKEND PROPIO (Node.js + PostgreSQL) mediante su API REST, y publicando su
 *  telemetría (IP, SSID, RSSI, uptime, firmware, memoria libre).
 *
 *  Flujo:
 *    1) Conecta a la red Wi-Fi (con reconexión automática).
 *    2) Cada POLL_INTERVAL_MS consulta GET /api/devices/device/list.
 *    3) Aplica el estado a cada relé; si cambió, confirma con POST .../confirm.
 *    4) Cada TELEMETRY_INTERVAL_MS publica su telemetría en POST /api/esp/telemetry.
 *
 *  Librerías necesarias (Gestor de librerías de Arduino):
 *    - "ArduinoJson" (autor Benoit Blanchon) — v6.x recomendado.
 *    - ESP8266 Core (Boards Manager). Incluye ESP8266WiFi y ESP8266HTTPClient.
 * ===========================================================================
 */

#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <ArduinoJson.h>

#include "Config.h"
#include "Relays.h"

// ---------------------------------------------------------------------------
// Estado interno
// ---------------------------------------------------------------------------
unsigned long lastPoll = 0;
unsigned long lastTelemetry = 0;

// URL base del backend (http://host:puerto).
String baseUrl;

// ===========================================================================
// Declaraciones adelantadas
// ===========================================================================
void connectWiFi();
void ensureWiFi();
bool httpGet(const String &path, String &responseBody);
bool httpPost(const String &path, const String &body, String &responseBody);
void pollDevices();
void confirmDevice(const String &id, bool estado);
void publishTelemetry();

// ===========================================================================
// setup()
// ===========================================================================
void setup() {
  Serial.begin(115200);
  delay(200);
  Serial.println();
  Serial.println(F("========================================"));
  Serial.println(F(" Prototipo IoT Domotica - ESP8266"));
  Serial.print(F(" Firmware v"));
  Serial.println(FIRMWARE_VERSION);
  Serial.println(F("========================================"));

  baseUrl = String("http://") + API_HOST + ":" + String(API_PORT);

  relaysInit();
  connectWiFi();
}

// ===========================================================================
// loop()
// ===========================================================================
void loop() {
  ensureWiFi();

  if (WiFi.status() != WL_CONNECTED) {
    delay(100);
    return;
  }

  const unsigned long now = millis();

  // 1) Sincronizar estados de los dispositivos.
  if (now - lastPoll >= POLL_INTERVAL_MS) {
    lastPoll = now;
    pollDevices();
  }

  // 2) Publicar telemetría periódica.
  if (now - lastTelemetry >= TELEMETRY_INTERVAL_MS) {
    lastTelemetry = now;
    publishTelemetry();
  }
}

// ===========================================================================
// Wi-Fi
// ===========================================================================
void connectWiFi() {
  Serial.print(F("[WiFi] Conectando a "));
  Serial.println(WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int retries = 0;
  while (WiFi.status() != WL_CONNECTED && retries < WIFI_MAX_RETRIES) {
    delay(WIFI_RETRY_INTERVAL_MS);
    Serial.print('.');
    retries++;
  }
  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {
    Serial.print(F("[WiFi] Conectado. IP: "));
    Serial.println(WiFi.localIP());
  } else {
    Serial.println(F("[WiFi] Sin conexión. Se reintentará en el loop."));
  }
}

void ensureWiFi() {
  static unsigned long lastAttempt = 0;
  if (WiFi.status() == WL_CONNECTED) return;

  if (millis() - lastAttempt > 5000) {
    lastAttempt = millis();
    Serial.println(F("[WiFi] Reconectando..."));
    WiFi.disconnect();
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  }
}

// ===========================================================================
// HTTP
// ===========================================================================
bool httpGet(const String &path, String &responseBody) {
  WiFiClient client;
  HTTPClient http;
  const String url = baseUrl + path;

  if (!http.begin(client, url)) {
    Serial.println(F("[HTTP] No se pudo iniciar la conexión (GET)."));
    return false;
  }
  http.addHeader("x-device-key", DEVICE_API_KEY);

  const int code = http.GET();
  const bool ok = (code == HTTP_CODE_OK);
  if (ok) {
    responseBody = http.getString();
  } else {
    Serial.printf("[HTTP] GET %s -> %d\n", path.c_str(), code);
  }
  http.end();
  return ok;
}

bool httpPost(const String &path, const String &body, String &responseBody) {
  WiFiClient client;
  HTTPClient http;
  const String url = baseUrl + path;

  if (!http.begin(client, url)) {
    Serial.println(F("[HTTP] No se pudo iniciar la conexión (POST)."));
    return false;
  }
  http.addHeader("Content-Type", "application/json");
  http.addHeader("x-device-key", DEVICE_API_KEY);

  const int code = http.POST(body);
  const bool ok = (code >= 200 && code < 300);
  if (ok) {
    responseBody = http.getString();
  } else {
    Serial.printf("[HTTP] POST %s -> %d\n", path.c_str(), code);
  }
  http.end();
  return ok;
}

// ===========================================================================
// Sincronización de dispositivos
// ===========================================================================
void pollDevices() {
  String payload;
  if (!httpGet(PATH_DEVICE_LIST, payload)) return;

  // La respuesta es un arreglo JSON de dispositivos.
  DynamicJsonDocument doc(4096);
  const DeserializationError err = deserializeJson(doc, payload);
  if (err) {
    Serial.print(F("[Poll] Error al parsear JSON: "));
    Serial.println(err.c_str());
    return;
  }

  JsonArray devices = doc.as<JsonArray>();
  for (JsonObject d : devices) {
    const char *id = d["id"] | "";
    const int gpio = d["gpio"] | -1;
    const bool estado = d["estado"] | false;

    if (strlen(id) == 0 || gpio < 0) continue;

    // Aplica el estado; si cambió, acciona el relé y confirma al backend.
    const bool changed = relayUpsert(String(id), gpio, estado);
    if (changed) {
      Serial.printf("[Relay] %s -> GPIO%d = %s\n",
                    id, gpio, estado ? "ON" : "OFF");
      confirmDevice(String(id), estado);
    }
  }
}

// Confirma al backend que el estado físico fue aplicado (marca "online").
void confirmDevice(const String &id, bool estado) {
  DynamicJsonDocument doc(128);
  doc["estado"] = estado;
  String body;
  serializeJson(doc, body);

  const String path = String("/api/devices/") + id + "/confirm";
  String response;
  if (httpPost(path, body, response)) {
    Serial.printf("[Confirm] %s confirmado\n", id.c_str());
  }
}

// ===========================================================================
// Telemetría
// ===========================================================================
void publishTelemetry() {
  DynamicJsonDocument doc(512);
  doc["ip"] = WiFi.localIP().toString();
  doc["ssid"] = WiFi.SSID();
  doc["rssi"] = WiFi.RSSI();
  doc["uptime"] = (unsigned long)(millis() / 1000);
  doc["firmware"] = FIRMWARE_VERSION;
  doc["freeHeap"] = ESP.getFreeHeap();

  String body;
  serializeJson(doc, body);

  String response;
  if (httpPost(PATH_ESP_TELEMETRY, body, response)) {
    Serial.printf("[Telemetry] Publicada. RSSI=%d dBm, heap=%u\n",
                  WiFi.RSSI(), ESP.getFreeHeap());
  }
}
