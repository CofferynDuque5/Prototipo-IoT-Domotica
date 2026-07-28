import '../models/device_model.dart';
import '../services/api_client.dart';
import '../services/realtime_client.dart';

/// Repositorio de dispositivos: combina la API REST (carga inicial y comandos)
/// con el flujo en tiempo real del WebSocket (actualizaciones).
///
/// El backend difunde la lista completa de dispositivos (mensaje tipo
/// `devices`) ante cualquier cambio, por lo que el repositorio simplemente
/// reemplaza la lista local con cada emisión.
class DeviceRepository {
  DeviceRepository({
    required ApiClient apiClient,
    required RealtimeClient realtimeClient,
  })  : _api = apiClient,
        _realtime = realtimeClient;

  final ApiClient _api;
  final RealtimeClient _realtime;

  /// Carga inicial de dispositivos vía REST.
  Future<List<DeviceModel>> fetchDevices() async {
    final dynamic data = await _api.get('/api/devices');
    return (data as List)
        .map((e) => DeviceModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Flujo en tiempo real: emite la carga inicial y luego cada actualización
  /// recibida por WebSocket.
  Stream<List<DeviceModel>> watchDevices() async* {
    try {
      yield await fetchDevices();
    } catch (_) {
      yield <DeviceModel>[];
    }

    yield* _realtime.messages
        .where((m) => m['type'] == 'devices')
        .map((m) => (m['payload'] as List)
            .map((e) =>
                DeviceModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList());
  }

  /// Cambia el estado de un dispositivo (encender/apagar).
  Future<void> setState(DeviceModel device, bool nuevoEstado) async {
    await _api.post('/api/devices/${device.id}/state', {'estado': nuevoEstado});
  }

  /// Alterna el estado actual del dispositivo.
  Future<void> toggle(DeviceModel device) =>
      setState(device, !device.estado);
}
