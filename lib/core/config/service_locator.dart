import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/device_controller.dart';
import '../../controllers/esp_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/device_repository.dart';
import '../../repositories/esp_repository.dart';
import '../../repositories/event_repository.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/preferences_service.dart';

/// Composición de dependencias (inyección de dependencias manual).
///
/// Construye el árbol de `Provider`s siguiendo el flujo de Clean Architecture:
/// servicios → repositorios → controladores. Mantener este cableado en un solo
/// lugar facilita las pruebas y el reemplazo de implementaciones.
class ServiceLocator {
  ServiceLocator._();

  static List<SingleChildWidget> buildProviders(
    PreferencesService preferences,
  ) {
    // --- Servicios (capa de infraestructura) ---
    final AuthService authService = AuthService(FirebaseAuth.instance);
    final DatabaseService databaseService =
        DatabaseService(FirebaseDatabase.instance);

    // --- Repositorios (capa de datos) ---
    final EventRepository eventRepository =
        EventRepository(databaseService: databaseService);
    final DeviceRepository deviceRepository = DeviceRepository(
      databaseService: databaseService,
      eventRepository: eventRepository,
    );
    final EspRepository espRepository =
        EspRepository(databaseService: databaseService);
    final AuthRepository authRepository = AuthRepository(
      authService: authService,
      databaseService: databaseService,
    );

    // --- Controladores (capa de presentación) ---
    return [
      ChangeNotifierProvider<ThemeController>(
        create: (_) => ThemeController(preferences),
      ),
      ChangeNotifierProvider<AuthController>(
        create: (_) => AuthController(
          authRepository: authRepository,
          preferencesService: preferences,
        ),
      ),
      ChangeNotifierProvider<DeviceController>(
        create: (_) =>
            DeviceController(deviceRepository: deviceRepository),
      ),
      ChangeNotifierProvider<EspController>(
        create: (_) => EspController(espRepository: espRepository),
      ),
      ChangeNotifierProvider<EventController>(
        create: (_) => EventController(eventRepository: eventRepository),
      ),
    ];
  }
}
