import '../core/config/device_types.dart';

/// Modelo de dominio de un dispositivo controlable (relé).
///
/// Mapea el nodo `devices/{deviceId}` de Firebase Realtime Database.
/// Es inmutable: cualquier cambio de estado produce una nueva instancia
/// mediante [copyWith].
class DeviceModel {
  final String id;
  final String nombre;
  final DeviceType tipo;
  final bool estado;
  final int gpio;
  final String habitacion;
  final bool online;
  final int ultimaActualizacion;

  const DeviceModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.estado,
    required this.gpio,
    required this.habitacion,
    required this.online,
    required this.ultimaActualizacion,
  });

  /// Construye el modelo a partir del mapa devuelto por Firebase.
  factory DeviceModel.fromMap(String id, Map<String, dynamic> map) {
    return DeviceModel(
      id: id,
      nombre: (map['nombre'] as String?)?.trim() ?? 'Dispositivo',
      tipo: DeviceType.fromString(map['tipo'] as String?),
      estado: map['estado'] as bool? ?? false,
      gpio: (map['gpio'] as num?)?.toInt() ?? -1,
      habitacion: (map['habitacion'] as String?)?.trim() ?? 'General',
      online: map['online'] as bool? ?? false,
      ultimaActualizacion:
          (map['ultimaActualizacion'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipo': tipo.key,
      'estado': estado,
      'gpio': gpio,
      'habitacion': habitacion,
      'online': online,
      'ultimaActualizacion': ultimaActualizacion,
    };
  }

  DeviceModel copyWith({
    String? nombre,
    DeviceType? tipo,
    bool? estado,
    int? gpio,
    String? habitacion,
    bool? online,
    int? ultimaActualizacion,
  }) {
    return DeviceModel(
      id: id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      gpio: gpio ?? this.gpio,
      habitacion: habitacion ?? this.habitacion,
      online: online ?? this.online,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
    );
  }

  /// Etiqueta corta del estado para la interfaz.
  String get estadoLabel => estado ? 'Encendido' : 'Apagado';

  /// Nombre del pin GPIO (p. ej. "GPIO5").
  String get gpioLabel => gpio >= 0 ? 'GPIO$gpio' : 'N/D';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          estado == other.estado &&
          online == other.online &&
          nombre == other.nombre &&
          ultimaActualizacion == other.ultimaActualizacion;

  @override
  int get hashCode =>
      Object.hash(id, estado, online, nombre, ultimaActualizacion);
}
