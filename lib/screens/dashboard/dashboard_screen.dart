import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/device_controller.dart';
import '../../controllers/esp_controller.dart';
import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../models/room_model.dart';
import '../../widgets/connection_banner.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/stat_tile.dart';
import 'widgets/app_drawer.dart';
import 'widgets/room_section.dart';

/// Pantalla principal: panel de control (dashboard).
///
/// Presenta el resumen del sistema, el banner de conexión del ESP8266 y las
/// tarjetas de dispositivos agrupadas por habitación. Escucha en tiempo real
/// las transiciones de conectividad para notificarlas.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Escucha las transiciones online/offline para mostrar notificaciones.
    context.read<EspController>().addListener(_onEspChanged);
  }

  @override
  void dispose() {
    context.read<EspController>().removeListener(_onEspChanged);
    super.dispose();
  }

  void _onEspChanged() {
    final EspController esp = context.read<EspController>();
    final bool? transition = esp.pendingTransition;
    if (transition == null || !mounted) return;

    SnackbarHelper.show(
      context,
      transition
          ? 'ESP8266 conectado al sistema'
          : 'Se perdió la conexión con el ESP8266',
      type: transition ? SnackType.success : SnackType.warning,
    );
    esp.consumeTransition();
  }

  @override
  Widget build(BuildContext context) {
    final DeviceController devices = context.watch<DeviceController>();
    final AuthController auth = context.watch<AuthController>();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Mi Hogar'),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            icon: CircleAvatar(
              radius: 16,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.15),
              child: Text(
                auth.user?.initials ?? '?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            onPressed: () => context.pushNamed(RouteNames.profile),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: _buildBody(devices),
        ),
      ),
    );
  }

  Widget _buildBody(DeviceController devices) {
    if (devices.loading) {
      return const LoadingIndicator(message: 'Cargando dispositivos...');
    }

    if (devices.devices.isEmpty) {
      return const EmptyState(
        icon: Icons.devices_other_rounded,
        title: 'Sin dispositivos',
        message:
            'Aún no hay dispositivos registrados en el sistema.\n'
            'Ejecuta el seed del backend o enciende el ESP8266.',
      );
    }

    final List<RoomModel> rooms = devices.rooms;

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<EspController>().refresh();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const ConnectionBanner()
              .animate()
              .fadeIn()
              .slideY(begin: -0.2),
          const SizedBox(height: 16),
          _StatsRow(devices: devices),
          const SizedBox(height: 8),
          for (int i = 0; i < rooms.length; i++)
            RoomSection(room: rooms[i])
                .animate()
                .fadeIn(delay: (80 * i).ms)
                .slideY(begin: 0.1),
        ],
      ),
    );
  }
}

/// Fila de estadísticas del sistema.
class _StatsRow extends StatelessWidget {
  final DeviceController devices;
  const _StatsRow({required this.devices});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatTile(
            icon: Icons.devices_rounded,
            value: '${devices.totalDevices}',
            label: 'Dispositivos',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatTile(
            icon: Icons.bolt_rounded,
            value: '${devices.activeDevices}',
            label: 'Encendidos',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatTile(
            icon: Icons.wifi_tethering_rounded,
            value: '${devices.onlineDevices}',
            label: 'En línea',
            color: AppColors.online,
          ),
        ),
      ],
    );
  }
}
