import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/esp_controller.dart';
import '../../controllers/event_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/wifi_signal.dart';
import '../../models/esp_status_model.dart';
import '../../widgets/event_tile.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/info_row.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/wifi_signal_indicator.dart';

/// Pantalla "Estado del sistema".
///
/// Presenta la telemetría del ESP8266 (conectividad, IP, SSID, señal Wi-Fi,
/// tiempo conectado, firmware), el estado de Firebase y el historial global
/// de eventos.
class SystemInfoScreen extends StatelessWidget {
  const SystemInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EspController esp = context.watch<EspController>();
    final EspStatusModel status = esp.status;
    final bool online = esp.isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado del sistema'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: esp.refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ConnectivityHeader(online: online, status: status),
                const SizedBox(height: 16),
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nodo ESP8266',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      InfoRow(
                        icon: Icons.lan_rounded,
                        label: 'Dirección IP',
                        value: status.ip,
                      ),
                      InfoRow(
                        icon: Icons.wifi_rounded,
                        label: 'Red Wi-Fi (SSID)',
                        value: status.ssid,
                      ),
                      InfoRow(
                        icon: WifiSignal.icon(status.rssi),
                        label: 'Intensidad de señal',
                        value:
                            '${WifiSignal.label(status.rssi)} · ${status.rssi} dBm '
                            '(${WifiSignal.toPercentage(status.rssi)}%)',
                        valueColor: WifiSignal.color(status.rssi),
                        trailing: WifiSignalIndicator(
                          rssi: status.rssi,
                          showLabel: false,
                          iconSize: 22,
                        ),
                      ),
                      InfoRow(
                        icon: Icons.timer_rounded,
                        label: 'Tiempo conectado',
                        value: DateFormatter.uptime(status.uptimeSeconds),
                      ),
                      InfoRow(
                        icon: Icons.memory_rounded,
                        label: 'Memoria libre (heap)',
                        value: status.freeHeap > 0
                            ? '${(status.freeHeap / 1024).toStringAsFixed(1)} KB'
                            : 'N/D',
                      ),
                      InfoRow(
                        icon: Icons.developer_board_rounded,
                        label: 'Versión de firmware',
                        value: 'v${status.firmware}',
                      ),
                      InfoRow(
                        icon: Icons.sync_rounded,
                        label: 'Última señal (heartbeat)',
                        value: DateFormatter.relative(status.lastSeen),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ServicesStatus(online: online),
                const SizedBox(height: 16),
                _EventsHistory(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Encabezado grande con el estado de conectividad.
class _ConnectivityHeader extends StatelessWidget {
  final bool online;
  final EspStatusModel status;

  const _ConnectivityHeader({required this.online, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color = online ? AppColors.online : AppColors.offline;
    return GlassContainer(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              online ? Icons.router_rounded : Icons.wifi_off_rounded,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  online ? 'Sistema en línea' : 'Sistema fuera de línea',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  online
                      ? 'El ESP8266 está enviando datos correctamente'
                      : 'No se recibe señal del microcontrolador',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado de los servicios (Firebase RTDB y nodo ESP).
class _ServicesStatus extends StatelessWidget {
  final bool online;
  const _ServicesStatus({required this.online});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Servicios',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Firebase Realtime Database'),
              StatusBadge(
                label: 'Conectado',
                color: AppColors.online,
                icon: Icons.check_circle_rounded,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nodo ESP8266'),
              StatusBadge.connectivity(online, dense: true),
            ],
          ),
        ],
      ),
    );
  }
}

/// Historial global de eventos del sistema.
class _EventsHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EventController events = context.watch<EventController>();

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 20),
              const SizedBox(width: 8),
              Text('Historial de eventos',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 4),
          if (events.loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Aún no se han registrado eventos.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          else
            ...events.latest(15).map((e) => EventTile(event: e)),
        ],
      ),
    );
  }
}
