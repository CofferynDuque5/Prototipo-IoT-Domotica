import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/device_model.dart';
import 'glass_container.dart';
import 'status_badge.dart';

/// Tarjeta moderna que representa y controla un dispositivo en el dashboard.
///
/// Muestra icono animado, nombre, habitación, estado online/offline, la hora de
/// la última actualización y un interruptor. Usa [AnimatedContainer] y
/// [AnimatedSwitcher] para transiciones fluidas al cambiar de estado.
class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final bool pending;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.pending,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool on = device.estado;
    final Color accent = on ? scheme.primary : scheme.onSurfaceVariant;

    return GlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icono con contenedor animado que reacciona al encendido.
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: on
                      ? scheme.primary.withOpacity(0.18)
                      : scheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: on
                      ? [
                          BoxShadow(
                            color: scheme.primary.withOpacity(0.35),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    on ? device.tipo.activeIcon : device.tipo.inactiveIcon,
                    key: ValueKey<bool>(on),
                    color: accent,
                    size: 26,
                  ),
                ),
              ),
              _OnlineDot(online: device.online),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            device.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            device.habitacion,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  device.estadoLabel,
                  key: ValueKey<bool>(on),
                  style: TextStyle(
                    color: on ? AppColors.online : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              // Interruptor con indicador de acción en curso.
              pending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Switch(
                      value: on,
                      onChanged: onToggle,
                    ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: 13, color: scheme.onSurfaceVariant),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  DateFormatter.relative(device.ultimaActualizacion),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                device.gpioLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Punto luminoso que refleja el estado online/offline del dispositivo.
class _OnlineDot extends StatelessWidget {
  final bool online;
  const _OnlineDot({required this.online});

  @override
  Widget build(BuildContext context) {
    return StatusBadge.connectivity(online, dense: true);
  }
}
