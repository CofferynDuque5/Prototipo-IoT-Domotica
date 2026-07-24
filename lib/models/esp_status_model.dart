import '../core/config/app_constants.dart';

/// Estado de telemetría del nodo ESP8266.
///
/// Mapea el nodo `esp` de Firebase Realtime Database, alimentado por el
/// firmware con información de conectividad y salud del microcontrolador.
class EspStatusModel {
  final bool online;
  final String ip;
  final String ssid;
  final int rssi;
  final int uptimeSeconds;
  final String firmware;
  final int lastSeen;
  final int freeHeap;

  const EspStatusModel({
    required this.online,
    required this.ip,
    required this.ssid,
    required this.rssi,
    required this.uptimeSeconds,
    required this.firmware,
    required this.lastSeen,
    required this.freeHeap,
  });

  /// Estado por defecto usado antes de recibir datos del nodo.
  factory EspStatusModel.unknown() => const EspStatusModel(
        online: false,
        ip: '0.0.0.0',
        ssid: '—',
        rssi: -100,
        uptimeSeconds: 0,
        firmware: AppConstants.firmwareVersion,
        lastSeen: 0,
        freeHeap: 0,
      );

  /// Alias para construir desde el JSON de la API.
  factory EspStatusModel.fromJson(Map<String, dynamic> json) =>
      EspStatusModel.fromMap(json);

  factory EspStatusModel.fromMap(Map<String, dynamic> map) {
    return EspStatusModel(
      online: map['online'] as bool? ?? false,
      ip: (map['ip'] as String?) ?? '0.0.0.0',
      ssid: (map['ssid'] as String?) ?? '—',
      rssi: (map['rssi'] as num?)?.toInt() ?? -100,
      uptimeSeconds: (map['uptime'] as num?)?.toInt() ?? 0,
      firmware: (map['firmware'] as String?) ?? AppConstants.firmwareVersion,
      lastSeen: (map['lastSeen'] as num?)?.toInt() ?? 0,
      freeHeap: (map['freeHeap'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'online': online,
      'ip': ip,
      'ssid': ssid,
      'rssi': rssi,
      'uptime': uptimeSeconds,
      'firmware': firmware,
      'lastSeen': lastSeen,
      'freeHeap': freeHeap,
    };
  }

  /// Determina si el nodo debe considerarse conectado, combinando la bandera
  /// `online` con la antigüedad de la última señal (heartbeat).
  bool get isConnected {
    if (!online) return false;
    if (lastSeen == 0) return false;
    final int ageSeconds =
        (DateTime.now().millisecondsSinceEpoch - lastSeen) ~/ 1000;
    return ageSeconds <= AppConstants.espOfflineThresholdSeconds;
  }
}
