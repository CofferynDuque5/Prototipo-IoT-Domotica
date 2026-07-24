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
 *  Nodo físico que actúa sobre relés (cargas eléctricas) escuchando en tiempo
 *  real los cambios de estado en Firebase Realtime Database y publicando su
 *  propia telemetría (IP, SSID, RSSI, uptime, firmware, memoria libre).
 *
 *  Flujo:
 *    1) Conecta a la red Wi-Fi (con reconexión automática).
 *    2) Autentica contra Firebase con una cuenta de dispositivo.
 *    3) Sincroniza el estado inicial de /devices y configura los GPIO.
 *    4) Abre un "stream" sobre /devices para reaccionar a los cambios.
 *    5) Al cambiar un estado, dispara el relé correspondiente y confirma.
 *    6) Publica telemetría periódica en /esp.
 *
 *  Librerías necesarias (Gestor de librerías de Arduino):
 *    - "Firebase Arduino Client Library for ESP8266 and ESP32" (mobizt)
 *    - ESP8266 Core (Boards Manager)
 * ===========================================================================
 */

#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>

// Helpers oficiales de la librería (impresión de estado de token y RTDB).
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

#include "Config.h"
#include "Relays.h"

// ---------------------------------------------------------------------------
// Objetos globales de Firebase
// ---------------------------------------------------------------------------
FirebaseData fbdo;        // Operaciones puntuales (get/set)
FirebaseData stream;      // Canal de escucha (stream) sobre /devices
FirebaseAuth auth;        // Credenciales del dispositivo
FirebaseConfig config;    // Configuración (API key, URL, callbacks)

// ---------------------------------------------------------------------------
// Variables de control
// ---------------------------------------------------------------------------
unsigned long lastTelemetry = 0;   // Marca de la última telemetría enviada
String pendingConfirmId = "";      // Dispositivo pendiente de confirmar estado
bool   pendingConfirmState = false;

// ===========================================================================
// Declaraciones adelantadas
// ===========================================================================
void connectWiFi();
void ensureWiFi();
void initFirebase();
void syncDevices();
void beginDeviceStream();
void streamCallback(FirebaseStream data);
void streamTimeoutCallback(bool timeout);
void applyDeviceState(const String &deviceId, bool estado);
void confirmDeviceState();
void publishTelemetry();
void registerDeviceFromJson(const String &id, FirebaseJson *json);

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

  relaysInit();
  connectWiFi();
  initFirebase();
}

// ===========================================================================
// loop()
// ===========================================================================
void loop() {
  // 1) Mantener la conexión Wi-Fi activa.
  ensureWiFi();

  // 2) Confirmar un cambio de estado pendiente (escritura fuera del callback).
  if (pendingConfirmId.length() > 0 && Firebase.ready()) {
    confirmDeviceState();
  }

  // 3) Publicar telemetría a intervalos regulares.
  if (Firebase.ready() &&
      (millis() - lastTelemetry > TELEMETRY_INTERVAL_MS)) {
    lastTelemetry = millis();
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
    Serial.print(F("[WiFi] RSSI: "));
    Serial.print(WiFi.RSSI());
    Serial.println(F(" dBm"));
  } else {
    Serial.println(F("[WiFi] No se pudo conectar. Reintentando en loop..."));
  }
}

// Reintenta la conexión si se cae (reconexión automática).
void ensureWiFi() {
  static unsigned long lastAttempt = 0;
  if (WiFi.status() == WL_CONNECTED) return;

  if (millis() - lastAttempt > 5000) {
    lastAttempt = millis();
    Serial.println(F("[WiFi] Conexión perdida. Reconectando..."));
    WiFi.disconnect();
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  }
}

// ===========================================================================
// Firebase
// ===========================================================================
void initFirebase() {
  config.api_key = FIREBASE_API_KEY;
  config.database_url = FIREBASE_HOST;

  auth.user.email = DEVICE_EMAIL;
  auth.user.password = DEVICE_PASSWORD;

  // Callback que informa del estado del token de autenticación.
  config.token_status_callback = tokenStatusCallback;

  // Reintentos y reconexión gestionados por la librería.
  Firebase.reconnectWiFi(true);
  config.timeout.serverResponse = 10 * 1000;

  Firebase.begin(&config, &auth);

  Serial.println(F("[Firebase] Autenticando..."));
  // Espera breve a que el token esté listo antes de la sincronización inicial.
  unsigned long start = millis();
  while (!Firebase.ready() && millis() - start < 10000) {
    delay(200);
  }

  if (Firebase.ready()) {
    Serial.println(F("[Firebase] Listo."));
    syncDevices();
    beginDeviceStream();
    publishTelemetry();
  } else {
    Serial.println(F("[Firebase] No se pudo autenticar todavía."));
  }
}

// Lee /devices una vez y configura los relés con el estado inicial.
void syncDevices() {
  Serial.println(F("[Sync] Leyendo estado inicial de dispositivos..."));

  if (!Firebase.RTDB.getJSON(&fbdo, PATH_DEVICES)) {
    Serial.print(F("[Sync] Error: "));
    Serial.println(fbdo.errorReason());
    return;
  }

  FirebaseJson *json = fbdo.to<FirebaseJson>();
  size_t count = json->iteratorBegin();

  String currentId = "";
  int gpio = -1;
  bool estado = false;
  bool haveGpio = false;

  for (size_t i = 0; i < count; i++) {
    FirebaseJson::IteratorValue v = json->valueAt(i);

    if (v.depth == 0 && v.type == FirebaseJson::JSON_OBJECT) {
      // Nuevo dispositivo: registrar el anterior antes de continuar.
      if (currentId.length() > 0 && haveGpio) {
        relayRegisterDevice(currentId, gpio, estado);
      }
      currentId = v.key;
      gpio = -1;
      estado = false;
      haveGpio = false;
    } else if (v.depth == 1) {
      if (v.key == "gpio") {
        gpio = v.value.toInt();
        haveGpio = true;
      } else if (v.key == "estado") {
        estado = (v.value == "true");
      }
    }
  }
  // Registrar el último dispositivo iterado.
  if (currentId.length() > 0 && haveGpio) {
    relayRegisterDevice(currentId, gpio, estado);
  }
  json->iteratorEnd();

  Serial.print(F("[Sync] Dispositivos registrados: "));
  Serial.println(relayDeviceCount());
}

// Abre el canal de escucha en tiempo real sobre /devices.
void beginDeviceStream() {
  if (!Firebase.RTDB.beginStream(&stream, PATH_DEVICES)) {
    Serial.print(F("[Stream] Error al iniciar: "));
    Serial.println(stream.errorReason());
    return;
  }
  Firebase.RTDB.setStreamCallback(&stream, streamCallback,
                                  streamTimeoutCallback);
  Serial.println(F("[Stream] Escuchando cambios en /devices"));
}

// ===========================================================================
// Callbacks del stream
// ===========================================================================
void streamCallback(FirebaseStream data) {
  const String path = data.dataPath();   // p. ej. "/dev_luz_sala/estado"
  Serial.print(F("[Stream] Cambio en "));
  Serial.println(path);

  if (path == "/") {
    // Instantánea completa del árbol: re-sincronizar todo.
    FirebaseJson *json = data.to<FirebaseJson>();
    size_t count = json->iteratorBegin();
    String currentId = "";
    int gpio = -1;
    bool estado = false;
    bool haveGpio = false;
    for (size_t i = 0; i < count; i++) {
      FirebaseJson::IteratorValue v = json->valueAt(i);
      if (v.depth == 0 && v.type == FirebaseJson::JSON_OBJECT) {
        if (currentId.length() > 0 && haveGpio) {
          relayRegisterDevice(currentId, gpio, estado);
        }
        currentId = v.key;
        gpio = -1; estado = false; haveGpio = false;
      } else if (v.depth == 1) {
        if (v.key == "gpio") { gpio = v.value.toInt(); haveGpio = true; }
        else if (v.key == "estado") { estado = (v.value == "true"); }
      }
    }
    if (currentId.length() > 0 && haveGpio) {
      relayRegisterDevice(currentId, gpio, estado);
    }
    json->iteratorEnd();
    return;
  }

  // Cambio puntual: extraer el id del dispositivo y, si aplica, el campo.
  String trimmed = path.substring(1);          // quita la '/' inicial
  int slash = trimmed.indexOf('/');
  String deviceId = (slash >= 0) ? trimmed.substring(0, slash) : trimmed;
  String field = (slash >= 0) ? trimmed.substring(slash + 1) : "";

  if (field == "estado") {
    applyDeviceState(deviceId, data.to<bool>());
  } else if (field.length() == 0 &&
             data.dataType() == "json") {
    // Se reemplazó el dispositivo completo: registrar de nuevo.
    FirebaseJson *json = data.to<FirebaseJson>();
    registerDeviceFromJson(deviceId, json);
  }
}

void streamTimeoutCallback(bool timeout) {
  if (timeout) {
    Serial.println(F("[Stream] Timeout, reconectando..."));
  }
  if (!stream.httpConnected()) {
    Serial.print(F("[Stream] Error de conexión: "));
    Serial.println(stream.errorReason());
  }
}

// ===========================================================================
// Actuación sobre relés
// ===========================================================================
void applyDeviceState(const String &deviceId, bool estado) {
  int gpio = relaySetById(deviceId, estado);
  if (gpio >= 0) {
    Serial.printf("[Relay] %s -> GPIO%d = %s\n",
                  deviceId.c_str(), gpio, estado ? "ON" : "OFF");
    // Programar la confirmación del estado hacia la base de datos.
    pendingConfirmId = deviceId;
    pendingConfirmState = estado;
  } else {
    Serial.printf("[Relay] Dispositivo desconocido: %s\n", deviceId.c_str());
  }
}

// Registra un dispositivo a partir de su JSON completo (gpio + estado).
void registerDeviceFromJson(const String &id, FirebaseJson *json) {
  FirebaseJsonData result;
  int gpio = -1;
  bool estado = false;

  if (json->get(result, "gpio")) gpio = result.to<int>();
  if (json->get(result, "estado")) estado = result.to<bool>();

  if (gpio >= 0) {
    relayRegisterDevice(id, gpio, estado);
    Serial.printf("[Relay] Registrado %s en GPIO%d\n", id.c_str(), gpio);
  }
}

// Confirma el estado aplicado escribiendo de vuelta en la base de datos
// (campos "online" y "ultimaActualizacion" con marca de tiempo del servidor).
void confirmDeviceState() {
  const String basePath = String(PATH_DEVICES) + "/" + pendingConfirmId;

  FirebaseJson update;
  update.set("online", true);
  update.set("estado", pendingConfirmState);
  update.set("ultimaActualizacion/.sv", "timestamp");

  if (Firebase.RTDB.updateNode(&fbdo, basePath.c_str(), &update)) {
    Serial.printf("[Confirm] Estado confirmado para %s\n",
                  pendingConfirmId.c_str());
  } else {
    Serial.print(F("[Confirm] Error: "));
    Serial.println(fbdo.errorReason());
  }

  pendingConfirmId = "";
}

// ===========================================================================
// Telemetría
// ===========================================================================
void publishTelemetry() {
  FirebaseJson telemetry;
  telemetry.set("online", true);
  telemetry.set("ip", WiFi.localIP().toString());
  telemetry.set("ssid", WiFi.SSID());
  telemetry.set("rssi", (int)WiFi.RSSI());
  telemetry.set("uptime", (int)(millis() / 1000));
  telemetry.set("firmware", FIRMWARE_VERSION);
  telemetry.set("freeHeap", (int)ESP.getFreeHeap());
  // Marca de tiempo del servidor (epoch en milisegundos).
  telemetry.set("lastSeen/.sv", "timestamp");

  if (Firebase.RTDB.updateNode(&fbdo, PATH_ESP, &telemetry)) {
    Serial.printf("[Telemetry] Publicada. RSSI=%d dBm, heap=%u\n",
                  WiFi.RSSI(), ESP.getFreeHeap());
  } else {
    Serial.print(F("[Telemetry] Error: "));
    Serial.println(fbdo.errorReason());
  }

  // Marca cada dispositivo conocido como "online".
  for (int i = 0; i < relayDeviceCount(); i++) {
    DeviceMapping d = relayDeviceAt(i);
    if (d.id.length() > 0) {
      String p = String(PATH_DEVICES) + "/" + d.id + "/online";
      Firebase.RTDB.setBool(&fbdo, p.c_str(), true);
    }
  }
}
