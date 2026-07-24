// PLANTILLA — Reemplaza estos valores con los de TU proyecto Firebase.
//
// La forma recomendada de generar este archivo es ejecutar:
//
//     dart pub global activate flutterfire_cli
//     flutterfire configure
//
// Ese comando sobrescribe este archivo con las credenciales reales de tu
// proyecto para cada plataforma. Mientras tanto, esta plantilla permite que el
// proyecto compile: sustituye los marcadores 'TU_...' por los valores que
// aparecen en la consola de Firebase → Configuración del proyecto.
//
// IMPORTANTE: databaseURL debe apuntar a tu Realtime Database, p. ej.
//   https://<project-id>-default-rtdb.firebaseio.com
// o la región correspondiente (…-rtdb.<region>.firebasedatabase.app).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opciones de Firebase por plataforma, consumidas en `main.dart`.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TU_ANDROID_API_KEY',
    appId: 'TU_ANDROID_APP_ID',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
    databaseURL: 'https://TU_PROJECT_ID-default-rtdb.firebaseio.com',
    storageBucket: 'TU_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TU_IOS_API_KEY',
    appId: 'TU_IOS_APP_ID',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
    databaseURL: 'https://TU_PROJECT_ID-default-rtdb.firebaseio.com',
    storageBucket: 'TU_PROJECT_ID.appspot.com',
    iosBundleId: 'com.tuempresa.prototipoIotDomotica',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TU_WEB_API_KEY',
    appId: 'TU_WEB_APP_ID',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
    authDomain: 'TU_PROJECT_ID.firebaseapp.com',
    databaseURL: 'https://TU_PROJECT_ID-default-rtdb.firebaseio.com',
    storageBucket: 'TU_PROJECT_ID.appspot.com',
  );
}
