import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Insignia compacta que muestra un estado con color e icono opcional.
/// Reutilizada para online/offline, encendido/apagado y estados del sistema.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool dense;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.dense = false,
  });

  /// Insignia de conectividad online/offline.
  factory StatusBadge.connectivity(bool online, {bool dense = false}) {
    return StatusBadge(
      label: online ? 'Online' : 'Offline',
      color: online ? AppColors.online : AppColors.offline,
      icon: online ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
      dense: dense,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 12,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 15, color: color),
            const SizedBox(width: 5),
          ] else ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: dense ? 11 : 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
