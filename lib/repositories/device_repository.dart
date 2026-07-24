import '../core/config/app_constants.dart';
import '../models/device_model.dart';
import '../models/event_log_model.dart';
import '../services/database_service.dart';
import 'event_repository.dart';

/// Repositorio de dispositivos: fuente única de verdad para el nodo `devices`.
///
/// Expone el flujo en tiempo real de dispositivos y las operaciones de control
/// (encender/apagar), registrando además el evento correspondiente en el
/// historial a través de [EventRepository].
class DeviceRepository {
  DeviceRepository({
    required DatabaseService databaseService,
    required EventRepository eventRepository,
  })  : _db = databaseService,
        _events = eventRepository;

  final DatabaseService _db;
  final EventRepository _events;

  /// Stream en tiempo real con la lista de dispositivos, ordenada por nombre.
  Stream<List<DeviceModel>> watchDevices() {
    return _db.onValue(AppConstants.nodeDevices).map((snapshot) {
      if (!snapshot.exists || snapshot.value == null) {
        return <DeviceModel>[];
      }

      final Map<dynamic, dynamic> raw =
          snapshot.value as Map<dynamic, dynamic>;

      final List<DeviceModel> devices = raw.entries.map((entry) {
        return DeviceModel.fromMap(
          entry.key.toString(),
          Map<String, dynamic>.from(entry.value as Map),
        );
      }).toList();

      devices.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );
      return devices;
    });
  }

  /// Stream de un dispositivo concreto.
  Stream<DeviceModel?> watchDevice(String deviceId) {
    return _db
        .onValue('${AppConstants.nodeDevices}/$deviceId')
        .map((snapshot) {
      if (!snapshot.exists || snapshot.value == null) return null;
      return DeviceModel.fromMap(
        deviceId,
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    });
  }

  /// Cambia el estado (encendido/apagado) de un dispositivo y registra el
  /// evento. La UI se actualiza sola gracias al stream en tiempo real.
  Future<void> setState(DeviceModel device, bool nuevoEstado) async {
    final int now = DateTime.now().millisecondsSinceEpoch;

    await _db.update(
      '${AppConstants.nodeDevices}/${device.id}',
      {
        'estado': nuevoEstado,
        'ultimaActualizacion': now,
      },
    );

    await _events.log(
      deviceId: device.id,
      deviceName: device.nombre,
      action: nuevoEstado ? EventAction.encendido : EventAction.apagado,
    );
  }

  /// Alterna el estado actual del dispositivo.
  Future<void> toggle(DeviceModel device) =>
      setState(device, !device.estado);

  /// Crea o reemplaza un dispositivo (usado para el aprovisionamiento inicial).
  Future<void> upsert(DeviceModel device) {
    return _db.set(
      '${AppConstants.nodeDevices}/${device.id}',
      device.toMap(),
    );
  }
}
