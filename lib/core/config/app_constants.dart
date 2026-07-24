/// Constantes globales de la aplicación.
///
/// Centraliza cadenas, rutas de nodos de Firebase y valores de configuración
/// para evitar el uso de "strings mágicos" repartidos por el código.
class AppConstants {
  AppConstants._();

  // ------------------------------------------------------------------
  // Información de la aplicación
  // ------------------------------------------------------------------
  static const String appName = 'Smart Home IoT';
  static const String appVersion = '1.0.0';
  static const String appBuild = '1';
  static const String firmwareVersion = '1.0.0';
  static const String authors = 'Valeryn Duque & Juan Vrasmatas';
  static const String university = 'Ingeniería de Sistemas';

  // ------------------------------------------------------------------
  // Claves de SharedPreferences
  // ------------------------------------------------------------------
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefRememberEmail = 'pref_remember_email';

  // ------------------------------------------------------------------
  // Parámetros de comportamiento
  // ------------------------------------------------------------------
  /// Segundos sin señal del ESP antes de considerarlo desconectado.
  static const int espOfflineThresholdSeconds = 30;

  /// Máximo de eventos que se solicitan al historial.
  static const int maxEventHistory = 100;

  /// Duración estándar de las animaciones de la interfaz.
  static const Duration animationDuration = Duration(milliseconds: 350);
}
