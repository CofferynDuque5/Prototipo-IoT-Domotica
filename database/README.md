# Estructura de Firebase Realtime Database

Este directorio documenta el modelo de datos y las reglas de seguridad del
sistema.

## Archivos

| Archivo | Descripción |
|---|---|
| `database_seed.json` | Datos iniciales (4 dispositivos + nodo `esp`) para importar. |
| `database.rules.json` | Reglas de seguridad (requieren usuario autenticado). |

## Árbol de datos

```
/
├── devices
│   └── {deviceId}
│       ├── nombre               (string)  "Luz Sala"
│       ├── tipo                 (string)  "luz" | "ventilador" | "puerta" | "tomacorriente"
│       ├── estado               (bool)    true = encendido
│       ├── gpio                 (int)     5, 4, 14, 12 ...
│       ├── habitacion           (string)  "Sala", "Cocina", "Dormitorio"
│       ├── online               (bool)    true si el ESP lo reporta activo
│       └── ultimaActualizacion  (int)     epoch en milisegundos
│
├── esp                          (telemetría del microcontrolador)
│   ├── online                   (bool)
│   ├── ip                       (string)  "192.168.1.50"
│   ├── ssid                     (string)  "MiRedWiFi"
│   ├── rssi                     (int)     -55  (dBm)
│   ├── uptime                   (int)     segundos encendido
│   ├── firmware                 (string)  "1.0.0"
│   ├── freeHeap                 (int)     bytes de memoria libre
│   └── lastSeen                 (int)     epoch ms del último heartbeat
│
├── events                       (historial)
│   └── {autoId}
│       ├── deviceId             (string)
│       ├── deviceName           (string)  "Luz Sala"
│       ├── action               (string)  "encendido" | "apagado" | ...
│       └── timestamp            (int)     epoch en milisegundos
│
└── users
    └── {uid}
        ├── nombre               (string)
        ├── email                (string)
        └── createdAt            (int)     epoch en milisegundos
```

## Importar los datos iniciales

1. Consola de Firebase → **Realtime Database**.
2. Menú **⋮** → **Importar JSON**.
3. Selecciona `database_seed.json`.

> El campo `gpio` de cada dispositivo **debe coincidir** con los pines
> definidos en `firmware/prototipo_iot_domotica/Config.h`.

## Aplicar las reglas de seguridad

1. Consola de Firebase → **Realtime Database** → pestaña **Reglas**.
2. Pega el contenido de `database.rules.json` y **publica**.

Las reglas exigen que todo acceso esté autenticado (`auth != null`). Cada
usuario solo puede leer/escribir su propio nodo bajo `/users/{uid}`.
