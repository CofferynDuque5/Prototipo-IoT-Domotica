# 🔌 Configuración del firmware ESP8266 (Arduino IDE)

Guía para compilar y cargar el firmware del nodo NodeMCU ESP8266, que se
comunica con el **backend propio** (Node.js + PostgreSQL) por su API REST.

## 1. Instalar el soporte para ESP8266

1. Arduino IDE → **Archivo → Preferencias**.
2. En **Gestor de URLs adicionales de tarjetas**, añade:
   ```
   http://arduino.esp8266.com/stable/package_esp8266com_index.json
   ```
3. **Herramientas → Placa → Gestor de tarjetas** → instala **esp8266**.
4. Selecciona **NodeMCU 1.0 (ESP-12E Module)**.

## 2. Instalar la librería ArduinoJson

1. **Herramientas → Gestionar librerías**.
2. Busca **ArduinoJson** (autor Benoit Blanchon) e instala la **v6.x**.

> `ESP8266WiFi` y `ESP8266HTTPClient` ya vienen con el core del ESP8266.

## 3. Abrir el sketch

```
firmware/prototipo_iot_domotica/prototipo_iot_domotica.ino
```

El IDE cargará junto al `.ino` los archivos `Config.h`, `Relays.h` y `Relays.cpp`.

## 4. Configurar `Config.h`

```cpp
#define WIFI_SSID       "CAMBIAR_SSID"
#define WIFI_PASSWORD   "CAMBIAR_PASSWORD"

#define API_HOST        "192.168.1.100"   // IP LAN de la PC con el backend
#define API_PORT        3000
#define DEVICE_API_KEY  "cambia_esta_clave_del_dispositivo"  // = backend
```

- `API_HOST`: la IP de tu computadora en la red local (no `localhost`).
- `DEVICE_API_KEY`: **debe coincidir** con `DEVICE_API_KEY` del backend (`.env`).
- El ESP y el backend deben estar en la **misma red**.

> 💡 Puedes mover las credenciales a un `secrets.h` (ignorado por `.gitignore`).

## 5. Conexión del hardware

| Relé | GPIO | Pin NodeMCU |
|---|---|---|
| IN1 | GPIO5  | D1 |
| IN2 | GPIO4  | D2 |
| IN3 | GPIO14 | D5 |
| IN4 | GPIO12 | D6 |

- **VCC** del módulo → **5V/VIN**; **GND** → **GND** (común con el NodeMCU).
- Si tu módulo enciende con nivel bajo, deja `RELAY_ACTIVE_LOW = true`.

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

1. Conecta el NodeMCU por USB y selecciona el **Puerto**.
2. Pulsa **Subir**.
3. Abre el **Monitor Serie** a **115200 baudios**. Deberías ver:

```
========================================
 Prototipo IoT Domotica - ESP8266
 Firmware v1.0.0
========================================
[WiFi] Conectado. IP: 192.168.1.50
[Relay] dev_luz_sala -> GPIO5 = ON
[Confirm] dev_luz_sala confirmado
[Telemetry] Publicada. RSSI=-55 dBm, heap=41000
```

## 7. Cómo funciona (REST polling)

- Cada **1.5 s** el ESP hace `GET /api/devices/device/list` con la cabecera
  `x-device-key`. Si el estado de un relé cambió, lo acciona y confirma con
  `POST /api/devices/{id}/confirm`.
- Cada **10 s** publica su telemetría con `POST /api/esp/telemetry`, lo que hace
  que la app muestre el ESP **online** (basado en el último *heartbeat*).

## 8. HTTPS (opcional)

El firmware usa HTTP en texto plano, ideal para una red local. Si expones el
backend con TLS, cambia a `WiFiClientSecure` y gestiona el certificado/fingerprint.

## Solución de problemas

| Síntoma | Solución |
|---|---|
| No conecta a Wi-Fi | Usa red **2.4 GHz**; revisa SSID/clave. |
| `GET ... -> 401` | `DEVICE_API_KEY` no coincide con el backend. |
| `GET ... -> -1` / no responde | `API_HOST`/puerto incorrectos o backend caído; verifica misma red. |
| Los relés actúan al revés | Cambia `RELAY_ACTIVE_LOW` en `Config.h`. |
| Error al parsear JSON | Instala **ArduinoJson v6.x**. |
