/// Acciones registrables en el historial de eventos.
enum EventAction {
  encendido,
  apagado,
  conectado,
  desconectado,
  error;

  static EventAction fromString(String? value) {
    switch (value) {
      case 'encendido':
        return EventAction.encendido;
      case 'apagado':
        return EventAction.apagado;
      case 'conectado':
        return EventAction.conectado;
      case 'desconectado':
        return EventAction.desconectado;
      case 'error':
        return EventAction.error;
      default:
        return EventAction.error;
    }
  }

  String get key => name;
}

/// Registro inmutable de un evento del sistema.
///
/// Mapea el nodo `events/{eventId}`. Ejemplo de mensaje generado:
/// "Luz Sala encendida a las 19:35".
class EventLogModel {
  final String id;
  final String deviceId;
  final String deviceName;
  final EventAction action;
  final int timestamp;

  const EventLogModel({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.action,
    required this.timestamp,
  });

  /// Construye el modelo desde el JSON de la API (incluye el campo `id`).
  factory EventLogModel.fromJson(Map<String, dynamic> json) {
    return EventLogModel.fromMap((json['id'] as String?) ?? '', json);
  }

  factory EventLogModel.fromMap(String id, Map<String, dynamic> map) {
    return EventLogModel(
      id: id,
      deviceId: (map['deviceId'] as String?) ?? '',
      deviceName: (map['deviceName'] as String?) ?? 'Dispositivo',
      action: EventAction.fromString(map['action'] as String?),
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'action': action.key,
      'timestamp': timestamp,
    };
  }

  /// Descripción legible del evento, p. ej. "Luz Sala encendida".
  String get descripcion {
    switch (action) {
      case EventAction.encendido:
        return '$deviceName encendida';
      case EventAction.apagado:
        return '$deviceName apagada';
      case EventAction.conectado:
        return '$deviceName conectado';
      case EventAction.desconectado:
        return '$deviceName desconectado';
      case EventAction.error:
        return 'Error en $deviceName';
    }
  }
}
