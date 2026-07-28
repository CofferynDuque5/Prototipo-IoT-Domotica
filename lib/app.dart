import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'core/config/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

/// Widget raíz de la aplicación.
///
/// Conecta el [ThemeController] con `MaterialApp.router` para aplicar el tema
/// seleccionado y construye el enrutador a partir del [AuthController].
class SmartHomeApp extends StatefulWidget {
  const SmartHomeApp({super.key});

  @override
  State<SmartHomeApp> createState() => _SmartHomeAppState();
}

class _SmartHomeAppState extends State<SmartHomeApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(context.read<AuthController>());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController theme = context.watch<ThemeController>();

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: theme.themeMode,
      routerConfig: _appRouter.router,
    );
  }
}
