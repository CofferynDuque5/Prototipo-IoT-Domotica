# 🔥 Configuración de Firebase

Guía paso a paso para conectar la aplicación y el firmware a tu propio
proyecto de Firebase.

## 1. Crear el proyecto

1. Entra a la [consola de Firebase](https://console.firebase.google.com/).
2. **Agregar proyecto** → nombre (p. ej. `smart-home-iot`) → continuar.
3. Puedes deshabilitar Google Analytics (no es necesario).

## 2. Habilitar Authentication

1. Menú lateral → **Compilación → Authentication → Comenzar**.
2. Pestaña **Sign-in method** → habilita **Correo electrónico/contraseña**.
3. (Opcional pero recomendado) Crea manualmente una **cuenta de dispositivo**
   para el ESP8266 en la pestaña **Users → Agregar usuario**:
   - Email: `esp8266@tudominio.com`
   - Contraseña: una segura (la usarás en `Config.h`).

## 3. Crear la Realtime Database

1. Menú lateral → **Compilación → Realtime Database → Crear base de datos**.
2. Elige la ubicación (p. ej. `us-central1`).
3. Inicia en **modo bloqueado** (aplicaremos reglas propias después).
4. Copia la **URL** de la base de datos, tiene esta forma:
   ```
   https://<project-id>-default-rtdb.firebaseio.com
   ```
   La necesitarás en `firebase_options.dart` (`databaseURL`) y en `Config.h`
   (`FIREBASE_HOST`).

## 4. Importar los datos iniciales

1. En **Realtime Database**, botón **⋮** (arriba a la derecha) → **Importar JSON**.
2. Selecciona `database/database_seed.json`.
3. Verás el árbol `devices` y `esp` creado.

## 5. Aplicar las reglas de seguridad

1. Pestaña **Reglas** de la Realtime Database.
2. Reemplaza el contenido por el de `database/database.rules.json`.
3. Pulsa **Publicar**.

> Las reglas exigen usuario autenticado. Si ves `permission denied`, revisa
> que iniciaste sesión en la app y que el ESP usa una cuenta válida.

## 6. Vincular la app Flutter

### Opción A — FlutterFire CLI (recomendada)

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Selecciona tu proyecto y las plataformas (Android/iOS/Web). El comando genera
`lib/firebase_options.dart` con tus credenciales.

> Asegúrate de que `databaseURL` aparezca en las opciones generadas. Si tu
> región no lo incluye por defecto, añádelo manualmente en cada
> `FirebaseOptions`.

### Opción B — Manual

Edita `lib/firebase_options.dart` (plantilla incluida) y reemplaza cada
`TU_...` con los valores de **Configuración del proyecto → General** y
**tus apps**.

Para Android además coloca `google-services.json` en `android/app/` y para
iOS `GoogleService-Info.plist` en `ios/Runner/` (los genera FlutterFire).

## 7. Verificación rápida

1. `flutter run`
2. Regístrate con un correo/contraseña.
3. Deberías ver los 4 dispositivos del *seed* en el dashboard.
4. Al alternar un dispositivo, el valor cambia en la consola de Firebase en
   tiempo real.

## Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| `permission-denied` | Reglas o sesión | Verifica login y reglas publicadas. |
| No aparecen dispositivos | `databaseURL` incorrecta o seed no importado | Revisa la URL y reimporta el JSON. |
| `network-request-failed` | Sin internet | Revisa la conexión del dispositivo/emulador. |
| El ESP no autentica | Cuenta de dispositivo inexistente | Crea el usuario en Authentication. |
