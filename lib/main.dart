import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config/service_locator.dart';
import 'firebase_options.dart';
import 'services/preferences_service.dart';

/// Punto de entrada de la aplicación.
///
/// Inicializa los bindings de Flutter, Firebase y las preferencias locales
/// antes de montar el árbol de widgets con las dependencias inyectadas.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializa Firebase con la configuración generada por FlutterFire.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Carga las preferencias locales (tema, correo recordado).
  final PreferencesService preferences = await PreferencesService.init();

  runApp(
    MultiProvider(
      providers: ServiceLocator.buildProviders(preferences),
      child: const SmartHomeApp(),
    ),
  );
}
