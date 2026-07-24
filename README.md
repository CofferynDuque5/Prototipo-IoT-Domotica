# 🏠 Prototipo de Sistema IoT para Domótica (Smart Home)

Sistema de domótica de extremo a extremo que permite **controlar cargas
eléctricas en tiempo real** desde una aplicación móvil, usando un
microcontrolador **NodeMCU ESP8266** como nodo físico y **Firebase Realtime
Database** como bróker en la nube.

> Proyecto universitario · Ingeniería de Sistemas
> Autores: **Valeryn Duque** & **Juan Vrasmatas**

---

## ✨ Características

- 🔐 **Autenticación** con Firebase Authentication (registro, login, recuperar contraseña).
- 💡 **Control de dispositivos** (luces, ventilador, puerta, tomacorriente) mediante relés.
- ⚡ **Tiempo real bidireccional**: la app y el ESP8266 se sincronizan por WebSockets.
- 🏘️ **Gestión por habitaciones** (Sala, Cocina, Dormitorio, …).
- 📊 **Estado del sistema**: IP, SSID, intensidad Wi-Fi (RSSI), uptime, firmware, memoria.
- 📡 **Indicador online/offline** del ESP8266 basado en *heartbeat*.
- 🕑 **Historial de eventos** ("Luz Sala encendida a las 19:35").
- 🧩 **Detalle técnico** de cada dispositivo (GPIO, estado, última sincronización).
- 🌗 **Modo claro / oscuro** con Material Design 3.
- 🎬 Animaciones (Hero, Fade, Slide, AnimatedSwitcher, AnimatedContainer) y *glassmorphism*.

---

## 🏗️ Arquitectura (Clean Architecture)

```
┌─────────────────────┐      WebSocket / SDK      ┌────────────────────┐
│   App Flutter        │  ◀────────────────────▶  │  Firebase RTDB      │
│  (Material 3, M-V-C)  │                           │  (bróker en nube)   │
└─────────────────────┘                           └─────────┬──────────┘
                                                             │ stream
                                                             ▼
                                                  ┌────────────────────┐
                                                  │   NodeMCU ESP8266   │
                                                  │   (C++ / relés)     │
                                                  └────────────────────┘
```

La app se organiza por capas siguiendo **Clean Architecture** y **SOLID**:

```
lib/
├── core/
│   ├── config/      → constantes, tipos de dispositivo, inyección de dependencias
│   ├── theme/       → colores y temas Material 3 (claro/oscuro)
│   ├── routes/      → navegación declarativa con GoRouter
│   └── utils/       → validadores, formato de fechas, señal Wi-Fi, snackbars
├── models/          → entidades de dominio inmutables (device, user, room, event, esp)
├── services/        → acceso de bajo nivel (Firebase Auth, RTDB, SharedPreferences)
├── repositories/    → orquestan servicios y exponen datos al dominio
├── controllers/     → estado de la UI (ChangeNotifier + Provider)
├── screens/         → pantallas (splash, auth, dashboard, detalle, ajustes, …)
├── widgets/         → componentes reutilizables (tarjetas, glass, badges, …)
├── app.dart         → widget raíz (MaterialApp.router)
└── main.dart        → punto de entrada + inicialización
```

**Flujo de dependencias:** `screens → controllers → repositories → services → Firebase`.

---

## 🛠️ Tecnologías

| Capa | Tecnología |
|---|---|
| Frontend | Flutter (Dart), Material Design 3, Google Fonts, flutter_animate |
| Estado | Provider (ChangeNotifier) |
| Navegación | GoRouter |
| Backend | Firebase Realtime Database |
| Autenticación | Firebase Authentication |
| Persistencia local | SharedPreferences |
| Hardware | NodeMCU ESP8266 (C++ / Arduino) |
| Librería firmware | Firebase Arduino Client Library (mobizt) |

---

## 📋 Requisitos previos

- **Flutter SDK** ≥ 3.19 (canal estable) y Dart ≥ 3.3
- **Android Studio** o **VS Code** con los plugins de Flutter/Dart
- Una cuenta de **Firebase** (plan Spark gratuito es suficiente)
- **Arduino IDE** 1.8.x / 2.x con el core de **ESP8266**
- Un **NodeMCU ESP8266** y un **módulo de relés** (opcional para la demo física)

---

## 🚀 Instalación y ejecución

### 1) Clonar e instalar dependencias

```bash
git clone <URL-del-repositorio>
cd Prototipo-IoT-Domotica

# Genera las carpetas de plataforma (android/, ios/, web/) sin tocar lib/.
# Es seguro: no sobrescribe el código fuente existente.
flutter create . --project-name prototipo_iot_domotica --platforms=android,ios,web

flutter pub get
```

### 2) Configurar Firebase

1. Crea un proyecto en la [consola de Firebase](https://console.firebase.google.com/).
2. Habilita **Authentication → Sign-in method → Correo electrónico/contraseña**.
3. Crea una **Realtime Database** (modo bloqueado).
4. Genera la configuración de la app con **FlutterFire CLI**:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Esto sobrescribe `lib/firebase_options.dart` con tus credenciales reales.
   (Si prefieres, edita manualmente la plantilla incluida).

5. Importa los datos iniciales y las reglas — ver [`database/README.md`](database/README.md):
   - Importa `database/database_seed.json`.
   - Publica las reglas de `database/database.rules.json`.

### 3) Ejecutar la app

```bash
flutter run
```

> Regístrate con un correo y contraseña; el dashboard mostrará los 4
> dispositivos del *seed*. Podrás encenderlos/apagarlos aunque el ESP no esté
> conectado (aparecerá **offline** hasta que el hardware publique telemetría).

---

## 🔌 Firmware ESP8266 (Arduino IDE)

Consulta la guía detallada en [`docs/ARDUINO_SETUP.md`](docs/ARDUINO_SETUP.md).
Resumen:

1. En Arduino IDE, añade el gestor de placas ESP8266 y selecciona **NodeMCU 1.0**.
2. Instala la librería **"Firebase Arduino Client Library for ESP8266 and ESP32"** (mobizt).
3. Abre `firmware/prototipo_iot_domotica/prototipo_iot_domotica.ino`.
4. Edita `Config.h` con tu SSID, contraseña, URL/API key de Firebase y la
   cuenta de dispositivo (correo/contraseña creada en Authentication).
5. Verifica que el campo `gpio` de cada dispositivo en la base de datos
   coincide con `RELAY_PINS` (`GPIO5, GPIO4, GPIO14, GPIO12`).
6. Compila y sube al ESP8266. Abre el **Monitor Serie** a `115200` baudios.

### Conexión de relés (ejemplo)

| Relé | GPIO | Pin NodeMCU | Dispositivo sugerido |
|---|---|---|---|
| 1 | GPIO5  | D1 | Luz Sala |
| 2 | GPIO4  | D2 | Luz Cocina |
| 3 | GPIO14 | D5 | Ventilador |
| 4 | GPIO12 | D6 | Tomacorriente |

> ⚠️ Muchos módulos de relé son **activos en bajo**. Ajusta `RELAY_ACTIVE_LOW`
> en `Config.h` según tu hardware. Para manipular cargas de 110/220 V toma las
> precauciones eléctricas adecuadas.

---

## 📁 Estructura del repositorio

```
Prototipo-IoT-Domotica/
├── lib/                        → aplicación Flutter (Clean Architecture)
├── firmware/
│   └── prototipo_iot_domotica/ → sketch Arduino para ESP8266
│       ├── prototipo_iot_domotica.ino
│       ├── Config.h
│       ├── Relays.h / Relays.cpp
├── database/                   → seed + reglas + documentación del modelo
├── docs/                       → guías de Firebase y Arduino
├── pubspec.yaml
└── README.md
```

---

## 🧪 Cómo probar el flujo completo

1. Enciende el ESP8266 → publica telemetría en `/esp` → la app muestra **online**.
2. Pulsa el interruptor de "Luz Sala" en la app.
3. Firebase actualiza `devices/dev_luz_sala/estado = true`.
4. El ESP8266 recibe el cambio por *stream*, activa el relé y confirma el estado.
5. Se registra un evento: *"Luz Sala encendida"* en el historial.

---

## 📄 Licencia

Proyecto académico con fines educativos. Uso libre para aprendizaje.

---

<p align="center">Hecho con ❤️ y ⚡ por Valeryn Duque &amp; Juan Vrasmatas</p>
