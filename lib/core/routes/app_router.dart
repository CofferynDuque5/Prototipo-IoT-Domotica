import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../screens/about/about_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/device_detail/device_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/system_info/system_info_screen.dart';
import 'route_names.dart';

/// Configuración de navegación de la aplicación basada en GoRouter.
///
/// Incluye redirección declarativa según el estado de autenticación: las rutas
/// privadas requieren sesión y las de auth redirigen al dashboard si ya hay
/// una sesión activa.
class AppRouter {
  AppRouter(this._authController);

  final AuthController _authController;

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splashPath,
    debugLogDiagnostics: false,
    // Rehace la evaluación de `redirect` cuando cambia el estado de sesión.
    refreshListenable: _authController,
    redirect: _guard,
    routes: [
      GoRoute(
        path: RouteNames.splashPath,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.loginPath,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.registerPath,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPasswordPath,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.dashboardPath,
        name: RouteNames.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.deviceDetailPath,
        name: RouteNames.deviceDetail,
        builder: (context, state) {
          final String id = state.pathParameters['id'] ?? '';
          return DeviceDetailScreen(deviceId: id);
        },
      ),
      GoRoute(
        path: RouteNames.settingsPath,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.profilePath,
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.systemInfoPath,
        name: RouteNames.systemInfo,
        builder: (context, state) => const SystemInfoScreen(),
      ),
      GoRoute(
        path: RouteNames.aboutPath,
        name: RouteNames.about,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada: ${state.uri}'),
      ),
    ),
  );

  /// Lógica de protección de rutas.
  String? _guard(BuildContext context, GoRouterState state) {
    final AuthStatus status = _authController.status;
    final String location = state.matchedLocation;

    // Mientras se resuelve la sesión, permanecemos en el splash.
    if (status == AuthStatus.unknown) {
      return location == RouteNames.splashPath ? null : RouteNames.splashPath;
    }

    final bool loggedIn = status == AuthStatus.authenticated;
    final bool onSplash = location == RouteNames.splashPath;
    final bool onAuthPage = location == RouteNames.loginPath ||
        location == RouteNames.registerPath ||
        location == RouteNames.forgotPasswordPath;

    if (!loggedIn) {
      // Sin sesión: solo se permiten las páginas de autenticación. Desde el
      // splash o una ruta privada, redirigir al login.
      return onAuthPage ? null : RouteNames.loginPath;
    }

    // Con sesión: si está en el splash o en una página de auth, ir al panel.
    if (onSplash || onAuthPage) {
      return RouteNames.dashboardPath;
    }

    return null;
  }
}
