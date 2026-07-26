# 🧪 Puesta en marcha completa con Proteus (sin hardware físico)

Guía única de extremo a extremo: **backend + PostgreSQL + app Flutter + puente
serial + simulación en Proteus**. Pensada para cuando no tienes el ESP8266 ni
el módulo de relés físicos y quieres demostrar el sistema completo simulado.

> Si más adelante consigues el hardware real, el firmware para el NodeMCU
> ESP8266 (distinto al usado aquí) está en [ARDUINO_SETUP.md](ARDUINO_SETUP.md).
> Este documento es solo para la ruta 100% simulada con Proteus.

---

## 1. Contexto: cómo encajan las piezas

La app Flutter **nunca habla con Proteus ni con ningún microcontrolador
directamente**. Siempre habla con el backend por REST/WebSocket. Un proceso
aparte (`bridge.js`) es quien traduce el estado guardado en PostgreSQL a
señales seriales que Proteus interpreta:

```
┌──────────┐  REST/WS  ┌───────────────┐   SQL    ┌────────────┐
│ Flutter  │ ────────▶ │ Backend Node  │ ───────▶ │ PostgreSQL │
└──────────┘           │ (/api/estado) │ ◀─────── └────────────┘
                       └───────┬───────┘
                               │ GET /api/estado  (cada 1 s)
                               ▼
                       ┌───────────────┐  escribe '1'/'0'   ┌──────────────┐
                       │  bridge.js    │ ──────────────────▶│ COM2 (com0com)│
                       │ (serialport)  │                    └──────┬───────┘
                       └───────────────┘                           │ par virtual
                                                                    ▼
                                                            ┌──────────────┐
                                                            │ COM1 ↔ COMPIM │  (Proteus)
                                                            └──────┬───────┘
                                                                   ▼
                                          ┌───────────────────────────────────┐
                                          │ Arduino: lee Serial → PIN 2 → R2 → │
                                          │ Q1(2N2222) → RL1 → lámpara 120V AC │
                                          └───────────────────────────────────┘
```

Piezas del repo involucradas:

| Pieza | Ruta | Rol |
|---|---|---|
| Backend + Postgres | [backend/](../backend) | Guarda el estado del relé, expone `/api/estado` (para el puente) y `/api/devices` (para la app). |
| App Flutter | [lib/](../lib) | UI para crear cuenta y encender/apagar el relé. |
| Puente serial | [proteus-bridge/](../proteus-bridge) | Sondea el backend y escribe `'1'`/`'0'` por un puerto COM virtual. |
| Firmware simulado | [proteus-bridge/arduino/relay_control/](../proteus-bridge/arduino/relay_control) | Sketch que Proteus ejecuta en el Arduino virtual. |

El único dispositivo controlado por esta ruta es el relé configurado en
`backend/.env` como `RELAY_DEVICE_ID` (por defecto `dev_luz_sala`).

---

## 2. Requisitos (instálalos en tu propia máquina)

- **Docker Desktop** (o Node.js ≥ 18 + PostgreSQL ≥ 14 si prefieres correr sin Docker).
- **Node.js ≥ 18** para correr el puente (`proteus-bridge/`), aparte del backend.
- **Proteus** (ISIS) con la librería que incluye el componente **COMPIM**.
- **com0com** (gratuito) o **VSPD** de Eltima — para crear un par de puertos
  COM virtuales enlazados en Windows.
- **Flutter SDK** ya instalado (usado en este proyecto).

---

## 3. Paso a paso

### 3.1 Backend + PostgreSQL

```bash
cd backend
cp .env.example .env        # si no existe ya
# Ajusta JWT_SECRET y DEVICE_API_KEY por valores propios (no los de ejemplo).
docker compose up --build
```

Deja esta terminal abierta. Verifica:

```bash
curl http://localhost:3000/health
# {"status":"ok","ts":...}
```

> Anota el `DEVICE_API_KEY` que pongas aquí — lo necesitarás igual en
> `proteus-bridge/.env` en el paso 3.4.

### 3.2 App Flutter

En otra terminal, desde la raíz del proyecto:

```bash
flutter clean
flutter pub get
flutter run --dart-define=API_HOST=localhost      # PC/escritorio
# o: flutter run                                   # emulador Android (10.0.2.2)
# o: flutter run --dart-define=API_HOST=192.168.1.100  # celular físico (IP LAN)
```

Crea una cuenta y confirma que ya no aparece el error de Firebase. Sin el
puente y Proteus corriendo, el switch del relé se guardará en PostgreSQL
igual, pero no moverá nada físico/simulado todavía — eso lo conectan los
pasos 3.3-3.5.

### 3.3 Par de puertos COM virtuales (com0com)

1. Instala **com0com** y crea un par enlazado, por ejemplo **COM1 ↔ COM2**.
2. Regla de asignación (no se puede abrir el mismo puerto dos veces):
   - **COM1** → lo abre **Proteus** (vía COMPIM).
   - **COM2** → lo abre **el puente** (`bridge.js`).

### 3.4 Esquemático de Proteus

1. Coloca el componente **COMPIM** (Library → busca `COMPIM`) junto al Arduino
   (usa **Arduino Uno** como placa).
2. Cablea cruzado con el UART del Arduino:

   | Arduino | COMPIM |
   |---|---|
   | Pin 1 TXD | RXD |
   | Pin 0 RXD | TXD |
   | GND | GND |

3. Doble clic en COMPIM → propiedades:

   | Propiedad | Valor |
   |---|---|
   | Physical port | **COM1** |
   | Physical Baud Rate | 9600 |
   | Virtual Baud Rate | 9600 |
   | Physical Data Bits | 8 |
   | Physical Parity | NONE |
   | Physical Stop Bits | 1 |

4. Compila el firmware simulado:
   - Abre [proteus-bridge/arduino/relay_control/relay_control.ino](../proteus-bridge/arduino/relay_control/relay_control.ino)
     en Arduino IDE, selecciona **Arduino Uno**.
   - **Sketch → Exportar binario compilado** (Arduino IDE 2.x: *Sketch → Export
     Compiled Binary*) para generar el `.hex`.
   - En Proteus, doble clic sobre el Arduino → **Program File** → selecciona el `.hex`.

   Protocolo de ese sketch: lee `'1'`/`'0'` del Serial y mueve el **PIN 2**
   (relé, vía R2/Q1/RL1); el LED del pin 13 refleja el estado para depurar.

### 3.5 Puente serial (`proteus-bridge`)

```bash
cd proteus-bridge
cp .env.example .env
```

Edita `.env`:

```dotenv
API_URL=http://localhost:3000
DEVICE_API_KEY=<la_misma_clave_que_pusiste_en_backend/.env>
SERIAL_PORT=COM2
BAUD_RATE=9600
POLL_INTERVAL_MS=1000
```

```bash
npm install
npm start
```

Salida esperada:

```
==================================================
 Puente Serial  (API REST  <->  Proteus / COMPIM)
==================================================
API:    http://localhost:3000
Serial: COM2 @ 9600 baudios
[serial] Puerto COM2 abierto a 9600 baudios
```

---

## 4. Orden de arranque recomendado (para la defensa/demo)

1. **Backend + PostgreSQL** (`cd backend && docker compose up`).
2. **Proteus**: inicia la simulación (COMPIM toma COM1).
3. **Puente** (`cd proteus-bridge && npm start`) → abre COM2.
4. **App Flutter**: enciende/apaga el relé desde la UI.

Resultado esperado: pulsar el interruptor en Flutter → se guarda en
PostgreSQL → el puente lo lee (polling de 1 s) → envía `'1'`/`'0'` por COM2 →
Proteus lo recibe por COMPIM/COM1 → el Arduino simulado acciona el transistor
→ el relé conmuta → la lámpara de 120 V se enciende/apaga en la simulación.

### Prueba rápida sin la app (para aislar problemas)

```bash
curl -X POST http://localhost:3000/api/estado \
  -H "x-device-key: <TU_DEVICE_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"estado": true}'
```

Si el relé se mueve en Proteus con este `curl` pero no con la app, el
problema está en la app/backend; si tampoco se mueve con el `curl`, el
problema está en el puente, com0com o la configuración de COMPIM.

---

## 5. Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| App: "No se pudo conectar con el servidor" | Backend caído o `API_HOST` incorrecto | Verifica `docker compose up` y el `--dart-define=API_HOST`. |
| `Access denied` al abrir el COM en el puente | Puerto ocupado por Proteus u otra app | El puente debe usar el extremo **contrario** al de COMPIM (COM2 si Proteus usa COM1). |
| El puente no encuentra el puerto (`File not found`) | com0com no instalado o par no creado | Crea el par COM1↔COM2 en com0com antes de iniciar el puente. |
| El Arduino no reacciona en Proteus | Baudios distintos o TX/RX sin cruzar | Iguala 9600 en Arduino, COMPIM y `BAUD_RATE` del puente; cruza TXD↔RXD. |
| El puente responde `401` / no ve cambios | `DEVICE_API_KEY` no coincide | Debe ser **idéntica** en `backend/.env` y `proteus-bridge/.env`. |
| Nada llega a Proteus aunque el puente escribe | `Physical port` de COMPIM mal puesto | Debe ser el extremo del par que **no** usa el puente. |
| El relé no existe / `404` en `/api/estado` | `RELAY_DEVICE_ID` no coincide con la BD | Debe ser un id existente (por defecto `dev_luz_sala`, creado por el seed). |
| Cambié `.env` del backend y no surtió efecto | Contenedor con variables cacheadas | `docker compose down` y `docker compose up --build` de nuevo. |

---

## 6. Referencias

- [proteus-bridge/README.md](../proteus-bridge/README.md) — guía original del puente (más detalle sobre VSPD/com0com y manejo de errores).
- [docs/BACKEND_SETUP.md](BACKEND_SETUP.md) — backend en detalle (arranque sin Docker, pruebas con `curl`).
- [docs/ARDUINO_SETUP.md](ARDUINO_SETUP.md) — firmware para el ESP8266 **físico** (ruta alternativa a Proteus, no la usada aquí).
- [docs/arquitectura.svg](arquitectura.svg) — diagrama general de arquitectura del proyecto.
