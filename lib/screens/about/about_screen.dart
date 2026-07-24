import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/esp_controller.dart';
import '../../core/config/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/info_row.dart';

/// Pantalla "Acerca del sistema".
///
/// Muestra la versión de la aplicación y del firmware, los autores, la
/// tecnología empleada y una breve descripción del proyecto.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<(IconData, String, String)> _stack = [
    (Icons.flutter_dash, 'Flutter', 'App multiplataforma (Dart)'),
    (Icons.cloud_rounded, 'Firebase RTDB', 'Base de datos en tiempo real'),
    (Icons.lock_rounded, 'Firebase Auth', 'Autenticación de usuarios'),
    (Icons.developer_board_rounded, 'ESP8266', 'Firmware en C++ (Arduino)'),
    (Icons.hub_rounded, 'WebSockets', 'Sincronización de baja latencia'),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final firmware = context.watch<EspController>().status.firmware;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca del sistema'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.brandGradient,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.home_rounded,
                      size: 52, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Center(
                child: Text(
                  'Prototipo de Sistema IoT para Domótica',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Versiones',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    InfoRow(
                      icon: Icons.smartphone_rounded,
                      label: 'Versión de la aplicación',
                      value:
                          'v${AppConstants.appVersion} (build ${AppConstants.appBuild})',
                    ),
                    InfoRow(
                      icon: Icons.developer_board_rounded,
                      label: 'Versión del firmware',
                      value: 'v$firmware',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tecnologías',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    for (final item in _stack)
                      InfoRow(
                        icon: item.$1,
                        label: item.$2,
                        value: item.$3,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descripción',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Ecosistema IoT que permite el control remoto de cargas '
                      'eléctricas en tiempo real, integrando hardware '
                      '(NodeMCU ESP8266), backend en la nube (Firebase '
                      'Realtime Database) y una aplicación móvil desarrollada '
                      'en Flutter con Material Design 3.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Equipo',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    InfoRow(
                      icon: Icons.people_rounded,
                      label: 'Autores',
                      value: AppConstants.authors,
                    ),
                    InfoRow(
                      icon: Icons.school_rounded,
                      label: 'Programa',
                      value: AppConstants.university,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  '© 2026 · ${AppConstants.authors}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
