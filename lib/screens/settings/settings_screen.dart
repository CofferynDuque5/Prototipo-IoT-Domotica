import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/config/app_constants.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_background.dart';

/// Pantalla de configuración de la aplicación.
///
/// Permite cambiar el tema (claro/oscuro/sistema), acceder al estado del ESP,
/// ver el perfil y cerrar sesión.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController theme = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
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
              _SectionTitle('Apariencia'),
              GlassContainer(
                child: Column(
                  children: [
                    _ThemeOption(
                      icon: Icons.brightness_auto_rounded,
                      label: 'Automático (sistema)',
                      mode: ThemeMode.system,
                      current: theme.themeMode,
                      onSelected: theme.setThemeMode,
                    ),
                    const Divider(height: 1),
                    _ThemeOption(
                      icon: Icons.light_mode_rounded,
                      label: 'Modo claro',
                      mode: ThemeMode.light,
                      current: theme.themeMode,
                      onSelected: theme.setThemeMode,
                    ),
                    const Divider(height: 1),
                    _ThemeOption(
                      icon: Icons.dark_mode_rounded,
                      label: 'Modo oscuro',
                      mode: ThemeMode.dark,
                      current: theme.themeMode,
                      onSelected: theme.setThemeMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle('Sistema'),
              GlassContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _NavItem(
                      icon: Icons.router_rounded,
                      label: 'Estado del ESP8266',
                      subtitle: 'IP, SSID, señal Wi-Fi, tiempo conectado',
                      onTap: () =>
                          context.pushNamed(RouteNames.systemInfo),
                    ),
                    const Divider(height: 1),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Perfil',
                      subtitle: 'Editar tu información personal',
                      onTap: () => context.pushNamed(RouteNames.profile),
                    ),
                    const Divider(height: 1),
                    _NavItem(
                      icon: Icons.info_rounded,
                      label: 'Acerca del sistema',
                      subtitle: 'Versión de la app y del firmware',
                      onTap: () => context.pushNamed(RouteNames.about),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle('Cuenta'),
              GlassContainer(
                padding: EdgeInsets.zero,
                child: _NavItem(
                  icon: Icons.logout_rounded,
                  label: 'Cerrar sesión',
                  color: Theme.of(context).colorScheme.error,
                  onTap: () => _logout(context),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  '${AppConstants.appName} · v${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthController>().signOut();
    if (context.mounted) {
      SnackbarHelper.show(context, 'Sesión finalizada');
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeMode mode;
  final ThemeMode current;
  final ValueChanged<ThemeMode> onSelected;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.mode,
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = mode == current;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary)
          : const Icon(Icons.circle_outlined),
      onTap: () => onSelected(mode),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: color == null
          ? const Icon(Icons.chevron_right_rounded)
          : null,
      onTap: onTap,
    );
  }
}
