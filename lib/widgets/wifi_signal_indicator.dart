import 'package:flutter/material.dart';

import '../core/utils/wifi_signal.dart';

/// Indicador de intensidad de señal Wi-Fi (RSSI).
///
/// Muestra el icono correspondiente al nivel y, opcionalmente, la etiqueta de
/// calidad y el valor en dBm.
class WifiSignalIndicator extends StatelessWidget {
  final int rssi;
  final bool showLabel;
  final bool showDbm;
  final double iconSize;

  const WifiSignalIndicator({
    super.key,
    required this.rssi,
    this.showLabel = true,
    this.showDbm = false,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = WifiSignal.color(rssi);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(WifiSignal.icon(rssi), size: iconSize, color: color),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            WifiSignal.label(rssi),
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
        if (showDbm) ...[
          const SizedBox(width: 6),
          Text(
            '($rssi dBm)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
