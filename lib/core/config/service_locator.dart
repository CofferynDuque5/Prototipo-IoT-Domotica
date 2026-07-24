import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/device_controller.dart';
import '../../controllers/esp_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/device_repository.dart';
import '../../repositories/esp_repository.dart';
import '../../repositories/event_repository.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/preferences_service.dart';
import '../../services/realtime_client.dart';
import '../../services/token_storage.dart';

/// Composición de dependencias (inyección de dependencias manual).
///
/// Cablea el árbol siguiendo Clean Architecture:
/// infraestructura (ApiClient/RealtimeClient/TokenStorage) → servicios →
/// repositorios → controladores.
class ServiceLocator {
  ServiceLocator._();

  static List<SingleChildWidget> buildProviders(SharedPreferences prefs) {
    // --- Infraestructura ---
    final PreferencesService preferences = PreferencesService(prefs);
    final TokenStorage tokenStorage = TokenStorage(prefs);
    final ApiClient apiClient = ApiClient(tokenStorage: tokenStorage);
    final RealtimeClient realtimeClient = RealtimeClient();

    // --- Servicios ---
    final AuthService authService = AuthService(apiClient);

    // --- Repositorios ---
    final AuthRepository authRepository = AuthRepository(
      authService: authService,
      tokenStorage: tokenStorage,
      realtimeClient: realtimeClient,
    );
    final DeviceRepository deviceRepository = DeviceRepository(
      apiClient: apiClient,
      realtimeClient: realtimeClient,
    );
    final EventRepository eventRepository = EventRepository(
      apiClient: apiClient,
      realtimeClient: realtimeClient,
    );
    final EspRepository espRepository = EspRepository(
      apiClient: apiClient,
      realtimeClient: realtimeClient,
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
