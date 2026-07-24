# 🐘 Configuración del Backend + PostgreSQL

Guía para levantar el servidor y la base de datos, y conectar la app Flutter.

## 1. Requisitos

- **Node.js** ≥ 18
- **PostgreSQL** ≥ 14 (o **Docker** para la opción rápida)

## 2. Arranque rápido con Docker

```bash
cd backend
cp .env.example .env
# Edita .env: cambia JWT_SECRET y DEVICE_API_KEY por valores propios.
docker compose up --build
```

Esto crea:
- Un contenedor **PostgreSQL** con la BD `iot_domotica`, el esquema y el seed
  (4 dispositivos) ya aplicados.
- Un contenedor **API** en `http://localhost:3000` (WebSocket en `/ws`).

Verifica que responde:

```bash
curl http://localhost:3000/health
# {"status":"ok","ts":...}
```

## 3. Arranque local (sin Docker)

```bash
cd backend
cp .env.example .env      # ajusta DATABASE_URL, JWT_SECRET, DEVICE_API_KEY
npm install
createdb iot_domotica     # crea la base de datos (una sola vez)
npm run migrate           # crea las tablas
npm run seed              # inserta los 4 dispositivos + fila esp
npm start
```

## 4. Conectar la app Flutter al backend

La app lee el host/puerto del backend mediante `--dart-define` (ver
`lib/core/config/api_config.dart`). Según dónde ejecutes la app:

| Escenario | Comando |
|---|---|
| **Emulador Android** | `flutter run` (usa `10.0.2.2:3000` por defecto) |
| **Dispositivo físico** | `flutter run --dart-define=API_HOST=192.168.1.100` (IP LAN de tu PC) |
| **Web / escritorio** | `flutter run --dart-define=API_HOST=localhost` |
| **Backend con HTTPS** | añade `--dart-define=API_SECURE=true` |

> Para saber la IP LAN de tu computadora: `ipconfig` (Windows) o
> `ip addr` / `ifconfig` (Linux/macOS). El teléfono y la PC deben estar en la
> **misma red Wi-Fi**.

## 5. Probar el flujo completo

```bash
# Registro
curl -X POST http://localhost:3000/api/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"nombre":"Ana","email":"ana@test.com","password":"secret123"}'

# Guarda el token de la respuesta y consulta los dispositivos:
curl http://localhost:3000/api/devices -H "Authorization: Bearer <TOKEN>"
```

En la app: regístrate/inicia sesión y verás los 4 dispositivos. Al alternar uno,
el cambio se guarda en PostgreSQL y se difunde por WebSocket a todos los
clientes conectados en tiempo real.

## 6. Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| App: "No se pudo conectar con el servidor" | Host/puerto incorrectos o backend caído | Revisa `API_HOST`, que la API esté arriba y la red. |
| `permission denied` en la BD | Credenciales de `DATABASE_URL` | Verifica usuario/clave/BD en `.env`. |
| El ESP no actualiza relés | Clave de dispositivo | `DEVICE_API_KEY` del ESP debe igualar la del backend. |
| No hay dispositivos | Falta el seed | Ejecuta `npm run seed` (o recrea con Docker). |
