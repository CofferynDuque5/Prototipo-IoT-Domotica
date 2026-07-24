/// Nombres y rutas centralizados para la navegación con GoRouter.
class RouteNames {
  RouteNames._();

  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String dashboard = 'dashboard';
  static const String deviceDetail = 'device-detail';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String systemInfo = 'system-info';
  static const String about = 'about';

  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String dashboardPath = '/dashboard';
  static const String deviceDetailPath = '/device/:id';
  static const String settingsPath = '/settings';
  static const String profilePath = '/profile';
  static const String systemInfoPath = '/system-info';
  static const String aboutPath = '/about';

  /// Construye la ruta concreta al detalle de un dispositivo.
  static String deviceDetail_(String id) => '/device/$id';
}
