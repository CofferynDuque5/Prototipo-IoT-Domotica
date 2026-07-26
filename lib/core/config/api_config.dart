/// Configuración de red del backend (API REST + WebSocket).
///
/// Los valores se pueden sobreescribir en tiempo de compilación con
/// `--dart-define`, por ejemplo:
///
///   flutter run --dart-define=API_HOST=192.168.1.100 --dart-define=API_PORT=3000
///
/// Notas sobre el host por defecto:
///  - `10.0.2.2` es el alias del *host* de la máquina desde el emulador de
///    Android (equivale a `localhost` de tu PC).
///  - En un dispositivo físico usa la IP LAN de tu computadora (p. ej.
///    `192.168.1.100`), no `localhost`.
///  - En Flutter Web o escritorio usa `localhost`.
class ApiConfig {
  ApiConfig._();

  static const String host =
      String.fromEnvironment('API_HOST', defaultValue: '127.0.0.1');

  static const int port =
      int.fromEnvironment('API_PORT', defaultValue: 3000);

  /// `true` para usar https/wss (backend detrás de TLS).
  static const bool secure =
      bool.fromEnvironment('API_SECURE', defaultValue: false);

  static String get _httpScheme => secure ? 'https' : 'http';
  static String get _wsScheme => secure ? 'wss' : 'ws';

  /// URL base de la API REST, p. ej. http://10.0.2.2:3000
  static String get baseUrl => '$_httpScheme://$host:$port';

  /// URL del canal WebSocket, p. ej. ws://10.0.2.2:3000/ws
  static String get wsUrl => '$_wsScheme://$host:$port/ws';
}
