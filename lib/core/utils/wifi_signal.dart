import 'package:flutter/material.dart';

/// Utilidades para interpretar la intensidad de señal Wi-Fi (RSSI).
///
/// El RSSI se expresa en dBm y suele oscilar entre -30 (excelente) y
/// -90 (muy débil). Estas funciones lo traducen a niveles, porcentajes,
/// etiquetas e iconos para la interfaz.
class WifiSignal {
  WifiSignal._();

  /// Convierte el RSSI en un porcentaje aproximado 0–100 %.
  static int toPercentage(int? rssi) {
    if (rssi == null) return 0;
    if (rssi >= -50) return 100;
    if (rssi <= -100) return 0;
    return (2 * (rssi + 100)).clamp(0, 100);
  }

  /// Nivel discreto de 0 (sin señal) a 4 (excelente).
  static int toLevel(int? rssi) {
    final int pct = toPercentage(rssi);
    if (pct >= 80) return 4;
    if (pct >= 60) return 3;
    if (pct >= 40) return 2;
    if (pct >= 20) return 1;
    return 0;
  }

  /// Etiqueta legible de la calidad de la señal.
  static String label(int? rssi) {
    switch (toLevel(rssi)) {
      case 4:
        return 'Excelente';
      case 3:
        return 'Buena';
      case 2:
        return 'Regular';
      case 1:
        return 'Débil';
      default:
        return 'Sin señal';
    }
  }

  /// Icono representativo del nivel de señal.
  static IconData icon(int? rssi) {
    switch (toLevel(rssi)) {
      case 4:
        return Icons.signal_wifi_4_bar;
      case 3:
        return Icons.network_wifi;
      case 2:
        return Icons.network_wifi;
      case 1:
        return Icons.signal_wifi_0_bar;
      default:
        return Icons.signal_wifi_off;
    }
  }

  /// Color asociado a la calidad de la señal.
  static Color color(int? rssi) {
    switch (toLevel(rssi)) {
      case 4:
      case 3:
        return const Color(0xFF22C55E);
      case 2:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
  }
}
