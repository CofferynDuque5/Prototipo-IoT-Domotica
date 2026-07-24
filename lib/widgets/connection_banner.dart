import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/esp_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';

/// Banner de conexión que resume el estado del nodo ESP8266 y de Firebase.
///
/// Se coloca en la parte superior del dashboard. Cambia de color y contenido
/// según la conectividad y muestra la última sincronización.
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final EspController esp = context.watch<EspController>();
    final bool online = esp.isOnline;
    final Color color = online ? AppColors.online : AppColors.offline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          // Punto pulsante de estado.
          _PulseDot(color: color, active: online),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  online ? 'ESP8266 conectado' : 'ESP8266 desconectado',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  online
                      ? 'Sincronizado ${DateFormatter.relative(esp.status.lastSeen)}'
                      : 'Última señal ${DateFormatter.relative(esp.status.lastSeen)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: color,
          ),
        ],
      ),
    );
  }
}

/// Punto que "late" cuando la conexión está activa.
class _PulseDot extends StatefulWidget {
  final Color color;
  final bool active;
  const _PulseDot({required this.color, required this.active});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double scale =
            widget.active ? 1 + (_controller.value * 0.6) : 1;
        return SizedBox(
          width: 18,
          height: 18,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.active)
                Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withOpacity(
                        (1 - _controller.value) * 0.4,
                      ),
                    ),
                  ),
                ),
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
