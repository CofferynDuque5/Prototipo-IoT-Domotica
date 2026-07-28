import 'device_model.dart';

/// Agrupación lógica de dispositivos por habitación.
///
/// No se persiste como nodo independiente: se deriva agrupando la lista de
/// [DeviceModel] por su campo `habitacion`. Facilita renderizar el dashboard
/// por secciones (Sala, Cocina, Dormitorio, etc.).
class RoomModel {
  final String nombre;
  final List<DeviceModel> dispositivos;

  const RoomModel({
    required this.nombre,
    required this.dispositivos,
  });

  /// Cantidad de dispositivos actualmente encendidos.
  int get activos => dispositivos.where((d) => d.estado).length;

  /// Cantidad total de dispositivos en la habitación.
  int get total => dispositivos.length;

  /// `true` si al menos un dispositivo de la habitación está encendido.
  bool get tieneActivos => activos > 0;

  /// Agrupa una lista plana de dispositivos en habitaciones ordenadas.
  static List<RoomModel> agrupar(List<DeviceModel> devices) {
    final Map<String, List<DeviceModel>> mapa = {};
    for (final DeviceModel d in devices) {
      mapa.putIfAbsent(d.habitacion, () => []).add(d);
    }

    final List<RoomModel> rooms = mapa.entries
        .map((e) => RoomModel(nombre: e.key, dispositivos: e.value))
        .toList();

    rooms.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    return rooms;
  }
}
