# ⚙️ Backend — API REST + WebSocket (Node.js + PostgreSQL)

Servidor que actúa como bróker del sistema IoT: expone una API REST para la app
y el ESP8266, difunde cambios en **tiempo real** por WebSocket y persiste todo
en **PostgreSQL**.

## 🧱 Stack

- **Node.js + Express** — API REST.
- **PostgreSQL** — base de datos relacional.
- **ws** — servidor WebSocket para tiempo real.
- **jsonwebtoken + bcryptjs** — autenticación (JWT) y hash de contraseñas.

## 🚀 Puesta en marcha

### Opción A — Docker (recomendada)

Levanta PostgreSQL + API con un comando. El esquema y el seed se aplican solos.

```bash
cd backend
cp .env.example .env          # ajusta JWT_SECRET y DEVICE_API_KEY
docker compose up --build
```

- API:       http://localhost:3000
- WebSocket: ws://localhost:3000/ws
- PostgreSQL: localhost:5432 (usuario `iot_user`, BD `iot_domotica`)

### Opción B — Local (sin Docker)

Requiere PostgreSQL instalado y en ejecución.

```bash
cd backend
cp .env.example .env          # ajusta DATABASE_URL, JWT_SECRET, DEVICE_API_KEY
npm install

# Crea la base de datos (una vez):
createdb iot_domotica

npm run migrate               # aplica db/schema.sql
npm run seed                  # inserta db/seed.sql (4 dispositivos + esp)
npm start                     # arranca la API en el puerto configurado
```

## 🔐 Variables de entorno (`.env`)

| Variable | Descripción |
|---|---|
| `PORT` | Puerto HTTP/WebSocket (por defecto 3000). |
| `DATABASE_URL` | Cadena de conexión a PostgreSQL. |
| `JWT_SECRET` | Secreto para firmar los JWT de sesión. |
| `JWT_EXPIRES_IN` | Vigencia del token (p. ej. `7d`). |
| `DEVICE_API_KEY` | Clave que usa el ESP8266 (cabecera `x-device-key`). |
| `ESP_OFFLINE_THRESHOLD_SECONDS` | Segundos sin telemetría para marcar el ESP offline. |

## 📡 API REST

### Autenticación (`/api/auth`)

| Método | Ruta | Auth | Cuerpo | Respuesta |
|---|---|---|---|---|
| POST | `/register` | — | `{nombre, email, password}` | `{token, user}` |
| POST | `/login` | — | `{email, password}` | `{token, user}` |
| POST | `/forgot-password` | — | `{email}` | `{message}` |
| GET | `/me` | JWT | — | `user` |
| PATCH | `/me` | JWT | `{nombre}` | `user` |

### Dispositivos (`/api/devices`)

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| GET | `/` | JWT | Lista de dispositivos. |
| GET | `/:id` | JWT | Un dispositivo. |
| POST | `/:id/state` | JWT | Cambia el estado `{estado: bool}` (app). |
| GET | `/device/list` | `x-device-key` | Lista para el ESP8266. |
| POST | `/:id/confirm` | `x-device-key` | El ESP confirma el estado aplicado. |

### Telemetría del ESP (`/api/esp`)

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| GET | `/` | JWT | Estado actual del ESP8266. |
| POST | `/telemetry` | `x-device-key` | El ESP publica su telemetría. |

### Eventos (`/api/events`)

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| GET | `/` | JWT | Historial de eventos (máx. 100). |

### Estado del relé (`/api/estado`) — puente hacia Proteus

Endpoints simplificados que operan sobre un único dispositivo relé
(`RELAY_DEVICE_ID`, por defecto `dev_luz_sala`), consumidos por el puente serial
(`proteus-bridge/`). Ver [`proteus-bridge/README.md`](../proteus-bridge/README.md).

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| GET | `/` | `x-device-key` | Estado actual del relé `{estado, deviceId, ...}`. |
| POST | `/` | `x-device-key` | Actualiza el relé `{estado: bool}` (registra evento y difunde). |

## 🔌 WebSocket (tiempo real)

Conéctate a `ws://host:3000/ws?token=<JWT>`.

Al conectar recibes una instantánea (`devices`, `esp`, `events`) y luego, ante
cada cambio, un mensaje con la forma:

```json
{ "type": "devices", "payload": [ /* ... */ ] }
```

Tipos: `devices`, `esp`, `events`.

## ✉️ Recuperación de contraseña

El endpoint `/api/auth/forgot-password` responde siempre `200` (para no revelar
si un correo existe). El **envío real del correo** requiere integrar un
proveedor SMTP (p. ej. Nodemailer + un servicio de correo); en este prototipo la
solicitud se registra en el log del servidor como punto de extensión.

## 🧪 Pruebas automatizadas (Jest)

Las pruebas usan **Jest + Supertest** y **pg-mem** (PostgreSQL en memoria), por
lo que corren en cualquier máquina y en CI **sin necesidad de una base de datos
real**. Cubren autenticación, dispositivos, eventos, telemetría del ESP y la
difusión en tiempo real por WebSocket.

```bash
cd backend
npm install
npm test            # ejecuta todas las suites
npm run test:watch  # modo interactivo
```

Cobertura de las suites (`tests/`):

| Suite | Qué valida |
|---|---|
| `auth.test.js` | Registro, login, `/me`, `PATCH /me`, `forgot-password`, validaciones y 401. |
| `devices.test.js` | Listado, cambio de estado, evento asociado, 400/404, seguridad y clave de dispositivo. |
| `esp.test.js` | Telemetría con/sin clave, lectura del estado y detección de offline por heartbeat. |
| `events.test.js` | Historial vacío, creación de eventos y orden (más reciente primero). |
| `ws.test.js` | Rechazo de token inválido, instantánea inicial y difusión en tiempo real. |

En CI se ejecutan automáticamente con el workflow
`.github/workflows/backend-tests.yml`.

## 🗄️ Esquema de datos

Ver `db/schema.sql`. Los timestamps se almacenan como `BIGINT` (epoch en
milisegundos) para coincidir con los modelos de la app Flutter.
