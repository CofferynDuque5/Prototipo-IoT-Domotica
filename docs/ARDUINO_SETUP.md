# 🔌 Configuración del firmware ESP8266 (Arduino IDE)

Guía para compilar y cargar el firmware del nodo NodeMCU ESP8266.

## 1. Instalar el soporte para ESP8266

1. Arduino IDE → **Archivo → Preferencias**.
2. En **Gestor de URLs adicionales de tarjetas**, añade:
   ```
   http://arduino.esp8266.com/stable/package_esp8266com_index.json
   ```
3. **Herramientas → Placa → Gestor de tarjetas** → busca **esp8266** e instala
   "ESP8266 by ESP8266 Community".
4. Selecciona la placa **NodeMCU 1.0 (ESP-12E Module)**.

## 2. Instalar la librería de Firebase

1. **Herramientas → Gestionar librerías**.
2. Busca e instala:
   **"Firebase Arduino Client Library for ESP8266 and ESP32"** (autor **mobizt**).
3. Esta librería instala también dependencias necesarias.

## 3. Abrir el sketch

Abre la carpeta:

```
firmware/prototipo_iot_domotica/prototipo_iot_domotica.ino
```

El IDE cargará junto al `.ino` los archivos `Config.h`, `Relays.h` y
`Relays.cpp`.

## 4. Configurar credenciales (`Config.h`)

Edita `Config.h` y reemplaza:

```cpp
#define WIFI_SSID        "CAMBIAR_SSID"
#define WIFI_PASSWORD    "CAMBIAR_PASSWORD"

#define FIREBASE_HOST    "https://TU_PROYECTO-default-rtdb.firebaseio.com"
#define FIREBASE_API_KEY "CAMBIAR_API_KEY"

#define DEVICE_EMAIL     "esp8266@tudominio.com"
#define DEVICE_PASSWORD  "CAMBIAR_PASSWORD_DISPOSITIVO"
```

- `FIREBASE_HOST`: URL de tu Realtime Database.
- `FIREBASE_API_KEY`: **Configuración del proyecto → General → clave de API web**.
- `DEVICE_EMAIL` / `DEVICE_PASSWORD`: la cuenta creada en Authentication para el hardware.

> 💡 Para no versionar credenciales, puedes mover estas macros a un archivo
> `secrets.h` (ya ignorado por `.gitignore`) e incluirlo desde `Config.h`.

## 5. Conexión del hardware

Módulo de relés de 4 canales → NodeMCU:

| Relé | GPIO | Pin NodeMCU |
|---|---|---|
| IN1 | GPIO5  | D1 |
| IN2 | GPIO4  | D2 |
| IN3 | GPIO14 | D5 |
| IN4 | GPIO12 | D6 |

- **VCC** del módulo → **VIN/5V** del NodeMCU (o fuente externa de 5 V).
- **GND** del módulo → **GND** del NodeMCU (GND común).

Si tu módulo enciende con nivel bajo, deja `RELAY_ACTIVE_LOW` en `true`
(valor por defecto). Si enciende con nivel alto, ponlo en `false`.

```
     NodeMCU ESP8266                 Módulo de Relés (4 canales)
   ┌───────────────┐               ┌──────────────────────────┐
   │            D1 ├──────────────▶│ IN1   ┌────┐  Carga 1     │
   │            D2 ├──────────────▶│ IN2   │RELÉ│  Carga 2     │
   │            D5 ├──────────────▶│ IN3   └────┘  Carga 3     │
   │            D6 ├──────────────▶│ IN4          Carga 4      │
   │           GND ├──────────────▶│ GND                       │
   │            5V ├──────────────▶│ VCC                       │
   └───────────────┘               └──────────────────────────┘
```

## 6. Compilar y cargar

1. Conecta el NodeMCU por USB.
2. **Herramientas → Puerto** → selecciona el puerto correspondiente.
3. Pulsa **Subir** (→).
4. Abre el **Monitor Serie** a **115200 baudios**.

Deberías ver:

```
========================================
 Prototipo IoT Domotica - ESP8266
 Firmware v1.0.0
========================================
[WiFi] Conectando a MiRed
[WiFi] Conectado. IP: 192.168.1.50
[Firebase] Autenticando...
[Firebase] Listo.
[Sync] Dispositivos registrados: 4
[Stream] Escuchando cambios en /devices
[Telemetry] Publicada. RSSI=-55 dBm, heap=41000
```

## 7. Probar

- En la app, alterna un dispositivo → en el Monitor Serie verás
  `[Relay] dev_luz_sala -> GPIO5 = ON` y el relé conmutará.
- La telemetría (`/esp`) se publica cada 10 s → la app muestra el ESP **online**.

## Solución de problemas

| Síntoma | Solución |
|---|---|
| No conecta a Wi-Fi | Revisa SSID/clave; usa red **2.4 GHz** (el ESP8266 no soporta 5 GHz). |
| `token error` / no autentica | Verifica API key y la cuenta de dispositivo en Authentication. |
| Los relés actúan al revés | Cambia `RELAY_ACTIVE_LOW` en `Config.h`. |
| `stream` se desconecta | Normal ante cortes de red; reconecta solo. Revisa la señal Wi-Fi. |
| `getJSON error` | Asegúrate de haber importado el *seed* y publicado las reglas. |
