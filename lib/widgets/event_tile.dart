import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/event_log_model.dart';

/// Elemento de lista que representa un evento del historial, p. ej.
/// "Luz Sala encendida · hace 3 min".
class EventTile extends StatelessWidget {
  final EventLogModel event;

  const EventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final (IconData icon, Color color) = _visualFor(event.action);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        event.descripcion,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
      ),
      subtitle: Text(
        '${DateFormatter.time(event.timestamp)} · ${DateFormatter.relative(event.timestamp)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
      ),
    );
  }

  (IconData, Color) _visualFor(EventAction action) {
    switch (action) {
      case EventAction.encendido:
        return (Icons.power_settings_new_rounded, AppColors.online);
      case EventAction.apagado:
        return (Icons.power_off_rounded, AppColors.offline);
      case EventAction.conectado:
        return (Icons.cloud_done_rounded, AppColors.online);
      case EventAction.desconectado:
        return (Icons.cloud_off_rounded, AppColors.warning);
      case EventAction.error:
        return (Icons.error_outline_rounded, AppColors.offline);
    }
  }
}
