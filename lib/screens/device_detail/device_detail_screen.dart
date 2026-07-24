import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/device_controller.dart';
import '../../controllers/event_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/device_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/event_tile.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/info_row.dart';
import '../../widgets/status_badge.dart';

/// Pantalla de detalle de un dispositivo.
///
/// Muestra información técnica (GPIO, estado, habitación, tipo, última
/// sincronización), un control principal de encendido/apagado y el historial
/// de eventos filtrado para este dispositivo.
class DeviceDetailScreen extends StatelessWidget {
  final String deviceId;

  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final DeviceController controller = context.watch<DeviceController>();
    final DeviceModel? device = controller.byId(deviceId);

    return Scaffold(
      appBar: AppBar(
        title: Text(device?.nombre ?? 'Dispositivo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: device == null
              ? const EmptyState(
                  icon: Icons.help_outline_rounded,
                  title: 'Dispositivo no encontrado',
                  message: 'Es posible que haya sido eliminado de la base de '
                      'datos.',
                )
              : _DeviceDetailBody(
                  device: device,
                  pending: controller.isPending(device.id),
                  onToggle: (v) => controller.setState(device, v),
                ),
        ),
      ),
    );
  }
}

class _DeviceDetailBody extends StatelessWidget {
  final DeviceModel device;
  final bool pending;
  final ValueChanged<bool> onToggle;

  const _DeviceDetailBody({
    required this.device,
    required this.pending,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool on = device.estado;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tarjeta principal con el icono y el control.
        Hero(
          tag: 'device-${device.id}',
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: on
                        ? scheme.primary.withOpacity(0.18)
                        : scheme.surfaceContainerHighest.withOpacity(0.5),
                    shape: BoxShape.circle,
                    boxShadow: on
                        ? [
                            BoxShadow(
                              color: scheme.primary.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    on ? device.tipo.activeIcon : device.tipo.inactiveIcon,
                    size: 54,
                    color: on ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  device.nombre,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${device.tipo.label} · ${device.habitacion}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusBadge.connectivity(device.online),
                    const SizedBox(width: 10),
                    StatusBadge(
                      label: device.estadoLabel,
                      color: on ? AppColors.online : scheme.onSurfaceVariant,
                      icon: on
                          ? Icons.power_settings_new_rounded
                          : Icons.power_off_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Control principal grande.
                pending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      )
                    : _PowerButton(on: on, onToggle: onToggle),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Ficha técnica.
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información técnica',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InfoRow(
                icon: Icons.memory_rounded,
                label: 'Pin GPIO (relé)',
                value: device.gpioLabel,
              ),
              InfoRow(
                icon: Icons.category_rounded,
                label: 'Tipo de dispositivo',
                value: device.tipo.label,
              ),
              InfoRow(
                icon: Icons.meeting_room_rounded,
                label: 'Habitación',
                value: device.habitacion,
              ),
              InfoRow(
                icon: Icons.sync_rounded,
                label: 'Última sincronización',
                value: DateFormatter.full(device.ultimaActualizacion),
              ),
              InfoRow(
                icon: Icons.fingerprint_rounded,
                label: 'ID del dispositivo',
                value: device.id,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _DeviceHistory(deviceId: device.id),
      ],
    );
  }
}

/// Botón principal de encendido/apagado.
class _PowerButton extends StatelessWidget {
  final bool on;
  final ValueChanged<bool> onToggle;

  const _PowerButton({required this.on, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => onToggle(!on),
      icon: Icon(on ? Icons.power_off_rounded : Icons.power_settings_new_rounded),
      label: Text(on ? 'Apagar' : 'Encender'),
      style: FilledButton.styleFrom(
        backgroundColor: on ? AppColors.offline : AppColors.online,
        minimumSize: const Size(200, 52),
      ),
    );
  }
}

/// Historial de eventos filtrado para el dispositivo actual.
class _DeviceHistory extends StatelessWidget {
  final String deviceId;
  const _DeviceHistory({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final EventController events = context.watch<EventController>();
    final filtered =
        events.events.where((e) => e.deviceId == deviceId).take(8).toList();

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad reciente',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Todavía no hay eventos para este dispositivo.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          else
            ...filtered.map((e) => EventTile(event: e)),
        ],
      ),
    );
  }
}
