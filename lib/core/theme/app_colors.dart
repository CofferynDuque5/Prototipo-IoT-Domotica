import 'package:flutter/material.dart';

/// Paleta de colores del sistema de diseño.
///
/// Define las semillas de color y tonos utilizados para construir los
/// esquemas Material 3 en modo claro y oscuro.
class AppColors {
  AppColors._();

  // Color semilla principal (índigo/violeta tecnológico).
  static const Color seed = Color(0xFF5B5BF5);

  // Acentos.
  static const Color accentCyan = Color(0xFF22D3EE);
  static const Color accentViolet = Color(0xFF8B5CF6);

  // Estados semánticos.
  static const Color online = Color(0xFF22C55E);
  static const Color offline = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Superficies para el efecto glassmorphism en modo claro.
  static const Color glassLight = Color(0x66FFFFFF);
  static const Color glassLightBorder = Color(0x33FFFFFF);

  // Superficies para el efecto glassmorphism en modo oscuro.
  static const Color glassDark = Color(0x1AFFFFFF);
  static const Color glassDarkBorder = Color(0x33FFFFFF);

  // Fondos degradados del splash y encabezados.
  static const List<Color> brandGradient = [
    Color(0xFF5B5BF5),
    Color(0xFF8B5CF6),
    Color(0xFF22D3EE),
  ];

  // Fondos suaves del dashboard.
  static const List<Color> lightBackgroundGradient = [
    Color(0xFFF4F5FF),
    Color(0xFFEAF6FF),
  ];

  static const List<Color> darkBackgroundGradient = [
    Color(0xFF0B1020),
    Color(0xFF121A2E),
  ];
}
