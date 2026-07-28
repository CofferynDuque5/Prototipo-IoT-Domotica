import 'dart:ui';

import 'package:flutter/material.dart';

/// Contenedor con efecto *glassmorphism* ligero.
///
/// Aplica un desenfoque de fondo, una superficie translúcida, borde sutil y
/// esquinas redondeadas. Se reutiliza en tarjetas, encabezados y paneles para
/// dar el aspecto premium solicitado.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? color;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.blur = 14,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;

    final Color surface = color ??
        (isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.55));
    final Color border =
        isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.6);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Ink(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
