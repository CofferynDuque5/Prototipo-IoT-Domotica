import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Fondo degradado adaptativo (claro/oscuro) usado como lienzo de las
/// pantallas para reforzar la estética glassmorphism.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> colors = isDark
        ? AppColors.darkBackgroundGradient
        : AppColors.lightBackgroundGradient;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          // Halos de color difuminados para dar profundidad.
          Positioned(
            top: -80,
            right: -60,
            child: _Blob(color: AppColors.accentViolet.withOpacity(0.25)),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _Blob(color: AppColors.accentCyan.withOpacity(0.20)),
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  const _Blob({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}
