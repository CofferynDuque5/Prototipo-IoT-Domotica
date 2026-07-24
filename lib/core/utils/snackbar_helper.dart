import 'package:flutter/material.dart';

/// Tipos de notificación visual mostrados mediante SnackBars.
enum SnackType { success, error, info, warning }

/// Helper centralizado para mostrar SnackBars con estilo Material 3 coherente.
///
/// Evita repetir la construcción de SnackBars en cada pantalla y aplica
/// iconos y colores según el [SnackType].
class SnackbarHelper {
  SnackbarHelper._();

  static void show(
    BuildContext context,
    String message, {
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final (Color bg, IconData icon) = _styleFor(type, scheme);

    final messenger = ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: bg,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (Color, IconData) _styleFor(SnackType type, ColorScheme scheme) {
    switch (type) {
      case SnackType.success:
        return (const Color(0xFF16A34A), Icons.check_circle_rounded);
      case SnackType.error:
        return (const Color(0xFFDC2626), Icons.error_rounded);
      case SnackType.warning:
        return (const Color(0xFFD97706), Icons.warning_amber_rounded);
      case SnackType.info:
        return (scheme.inverseSurface, Icons.info_rounded);
    }
  }
}
