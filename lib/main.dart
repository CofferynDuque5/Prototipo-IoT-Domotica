import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/service_locator.dart';

/// Punto de entrada de la aplicación.
///
/// Inicializa los bindings de Flutter y las preferencias locales, y monta el
/// árbol de widgets con las dependencias inyectadas. La app se comunica con un
/// backend propio (Node.js + PostgreSQL) mediante REST + WebSocket.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Instancia única de SharedPreferences compartida por preferencias y token.
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: ServiceLocator.buildProviders(prefs),
      child: const SmartHomeApp(),
    ),
  );
}
