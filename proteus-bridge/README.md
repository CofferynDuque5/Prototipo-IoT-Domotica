# 🔗 Puente Serial: API ↔ Proteus (COMPIM)

Conecta el ecosistema de software (Flutter + API + PostgreSQL) con la
simulación de Proteus (Arduino + relé) a través de un **puerto serial virtual**.

## 🗺️ Flujo completo de extremo a extremo

```
┌──────────┐  REST/WS  ┌───────────────┐   SQL    ┌────────────┐
│ Flutter  │ ────────▶ │ Backend Node  │ ───────▶ │ PostgreSQL │
└──────────┘           │  (/api/estado) │ ◀─────── └────────────┘
                       └───────┬───────┘
                               │ GET /api/estado  (cada 1 s)
                               ▼
                       ┌───────────────┐  escribe '1'/'0'   ┌──────────────┐
                       │  bridge.js     │ ─────────────────▶ │ COM2 (VSPD)   │
                       │ (serialport)   │                    └──────┬───────┘
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

> **Todo es virtual**: el puente y Proteus se comunican por un par de puertos
> COM virtuales enlazados (VSPD/com0com). No hay hardware físico.

---

## 1️⃣ Crear el par de puertos virtuales (VSPD)

Necesitas **dos** puertos COM virtuales **enlazados**: lo que se escribe en uno
sale por el otro. Opciones en Windows:

- **Virtual Serial Port Driver (VSPD)** de Eltima (comercial, con prueba).
- **com0com** (gratuito y de código abierto) — recomendado.

Con cualquiera, crea un **par**, por ejemplo **COM1 ↔ COM2**:

- **COM1** → lo usará **Proteus (COMPIM)**.
- **COM2** → lo usará **el puente `bridge.js`**.

> ⚠️ Un puerto no puede abrirse dos veces. Proteus abre COM1 y el puente abre
> COM2. Si inviertes esto o abres el mismo puerto en ambos, verás el error
> **"Access denied / puerto ocupado"** (el puente lo maneja y reintenta).

### En Linux (alternativa con socat)

```bash
socat -d -d pty,raw,echo=0,link=/tmp/ttyBRIDGE pty,raw,echo=0,link=/tmp/ttyPROTEUS
```

Usa `SERIAL_PORT=/tmp/ttyBRIDGE` en el puente y `/tmp/ttyPROTEUS` en Proteus
(Wine).

---

## 2️⃣ Configurar COMPIM en Proteus

1. Coloca el componente **COMPIM** en el esquemático (Library → busca `COMPIM`).
2. Conéctalo al UART del Arduino (**cruzado**):

   | Arduino | COMPIM |
   |---|---|
   | Pin 1 **TXD** | **RXD** |
   | Pin 0 **RXD** | **TXD** |
   | **GND** | **GND** |

   > El Arduino transmite por TXD → entra a COMPIM por RXD; COMPIM entrega lo
   > recibido del PC por su TXD → entra al Arduino por RXD.

3. Doble clic en COMPIM → **propiedades**:

   | Propiedad | Valor |
   |---|---|
   | **Physical port** | **COM1** (el extremo del par que NO usa el puente) |
   | **Physical Baud Rate** | **9600** |
   | **Virtual Baud Rate** | **9600** |
   | **Physical Data Bits** | 8 |
   | **Physical Parity** | NONE |
   | **Physical Stop Bits** | 1 |

4. Deben coincidir **todos los baudios**: COMPIM (9600) = `Serial.begin(9600)`
   del Arduino = `BAUD_RATE=9600` del puente.

---

## 3️⃣ Cargar el firmware en el Arduino de Proteus

1. Abre `arduino/relay_control/relay_control.ino` en el **Arduino IDE**.
2. Selecciona la placa que uses en Proteus (p. ej. **Arduino Uno**).
3. **Sketch → Exportar binario compilado** para generar el `.hex`
   (en `Arduino IDE 2.x`: menú *Sketch → Export Compiled Binary*).
4. En Proteus, doble clic sobre el Arduino → campo **Program File** → selecciona
   el `.hex` generado.

> El sketch inicia el relé **apagado**, lee `'1'`/`'0'` del Serial y acciona el
> **PIN 2** (que va por R2 a la base de Q1). El LED integrado (pin 13) refleja
> el estado para diagnóstico.

---

## 4️⃣ Ejecutar el puente

Requiere **Node.js ≥ 18** (usa `fetch` nativo).

```bash
cd proteus-bridge
cp .env.example .env       # ajusta SERIAL_PORT, API_URL y DEVICE_API_KEY
npm install                # instala serialport y dotenv
npm start
```

Configuración (`.env`):

| Variable | Descripción |
|---|---|
| `API_URL` | URL del backend (p. ej. `http://localhost:3000`). |
| `DEVICE_API_KEY` | Debe coincidir con la del backend. |
| `SERIAL_PORT` | Extremo del puente (p. ej. `COM2`). |
| `BAUD_RATE` | 9600 (igual que COMPIM y el Arduino). |
| `POLL_INTERVAL_MS` | Intervalo de sondeo (1000 ms). |

Salida esperada:

```
 Puente Serial  (API REST  <->  Proteus / COMPIM)
API:    http://localhost:3000
Serial: COM2 @ 9600 baudios
[serial] Puerto COM2 abierto a 9600 baudios
[bridge] Estado=true  ->  enviado '1' por COM2
```

---

## 5️⃣ Orden de arranque recomendado (para la defensa)

1. **Backend + PostgreSQL** (`cd backend && docker compose up`).
2. **Proteus**: inicia la simulación (COMPIM toma COM1).
3. **Puente** (`cd proteus-bridge && npm start`) → abre COM2.
4. **App Flutter**: enciende/apaga el relé.

Resultado: al pulsar el interruptor en Flutter → se guarda en PostgreSQL → el
puente lo lee y envía `'1'`/`'0'` → el Arduino en Proteus acciona el transistor
→ el relé conmuta → **la lámpara de 120 V se enciende/apaga** en la simulación.
Prueba rápida sin la app:

```bash
curl -X POST http://localhost:3000/api/estado \
  -H "x-device-key: <TU_DEVICE_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"estado": true}'
```

---

## 🛠️ Manejo de errores incluido

- **Puerto COM ocupado / inexistente**: el puente captura el error de apertura,
  lo informa y **reintenta cada 3 s** (no se cae).
- **Cierre del puerto** (p. ej. detienes Proteus): detecta el `close` y reintenta.
- **API caída**: captura el error de red y continúa sondeando.
- **Escritura eficiente**: solo envía por serial cuando el estado **cambia**
  (evita saturar el puerto), reenviando siempre tras una reconexión.

## ❓ Problemas frecuentes

| Síntoma | Causa | Solución |
|---|---|---|
| `Access denied` al abrir el COM | Puerto ocupado por Proteus u otra app | El puente usa el **otro** extremo del par (COM2 si Proteus usa COM1). |
| El Arduino no reacciona | Baudios distintos o TX/RX sin cruzar | Iguala 9600 en todo y cruza TXD↔RXD. |
| El puente no ve cambios | `DEVICE_API_KEY` incorrecta | Debe coincidir con la del backend (401 en el log). |
| Nada llega a Proteus | `Physical port` de COMPIM mal | Debe ser el extremo del par que NO usa el puente. |
