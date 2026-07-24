import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/snackbar_helper.dart';

/// Menú lateral de navegación de la aplicación.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = context.watch<AuthController>();
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final user = auth.user;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Cabecera con avatar e información del usuario.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: scheme.primary.withOpacity(0.15),
                    child: Text(
                      user?.initials ?? '?',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.nombre ?? 'Usuario',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _DrawerItem(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              onTap: () => _go(context, RouteNames.dashboard),
            ),
            _DrawerItem(
              icon: Icons.person_rounded,
              label: 'Perfil',
              onTap: () => _go(context, RouteNames.profile),
            ),
            _DrawerItem(
              icon: Icons.router_rounded,
              label: 'Estado del sistema',
              onTap: () => _go(context, RouteNames.systemInfo),
            ),
            _DrawerItem(
              icon: Icons.settings_rounded,
              label: 'Configuración',
              onTap: () => _go(context, RouteNames.settings),
            ),
            _DrawerItem(
              icon: Icons.info_rounded,
              label: 'Acerca del sistema',
              onTap: () => _go(context, RouteNames.about),
            ),
            const Spacer(),
            const Divider(),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Cerrar sesión',
              color: scheme.error,
              onTap: () => _confirmLogout(context),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'v${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, String name) {
    Navigator.of(context).pop(); // cierra el drawer
    if (name == RouteNames.dashboard) return;
    context.pushNamed(name);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthController>().signOut();
      if (context.mounted) {
        SnackbarHelper.show(context, 'Sesión finalizada');
      }
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
