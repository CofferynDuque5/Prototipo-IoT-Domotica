import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/device_model.dart';
import '../models/room_model.dart';
import '../repositories/device_repository.dart';

/// Controlador de dispositivos. Escucha el flujo en tiempo real del repositorio
/// y expone la lista, el agrupamiento por habitaciones y las acciones de
/// control a la interfaz.
class DeviceController extends ChangeNotifier {
  DeviceController({required DeviceRepository deviceRepository})
      : _repo = deviceRepository {
    _subscribe();
  }

  final DeviceRepository _repo;
  StreamSubscription<List<DeviceModel>>? _subscription;

  List<DeviceModel> _devices = [];
  bool _loading = true;
  String? _error;
  String? _pendingDeviceId; // dispositivo con acción en curso

  List<DeviceModel> get devices => _devices;
  bool get loading => _loading;
  String? get error => _error;

  /// Dispositivos agrupados por habitación para el dashboard.
  List<RoomModel> get rooms => RoomModel.agrupar(_devices);

  /// Lista de nombres de habitaciones disponibles.
  List<String> get roomNames =>
      rooms.map((r) => r.nombre).toList(growable: false);

  int get totalDevices => _devices.length;
  int get activeDevices => _devices.where((d) => d.estado).length;
  int get onlineDevices => _devices.where((d) => d.online).length;

  bool isPending(String deviceId) => _pendingDeviceId == deviceId;

  void _subscribe() {
    _subscription = _repo.watchDevices().listen(
      (list) {
        _devices = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = 'No se pudieron cargar los dispositivos.';
        notifyListeners();
      },
    );
  }

  /// Alterna el estado de un dispositivo con feedback de "acción en curso".
  Future<void> toggle(DeviceModel device) async {
    _pendingDeviceId = device.id;
    notifyListeners();
    try {
      await _repo.toggle(device);
    } catch (_) {
      _error = 'No se pudo actualizar "${device.nombre}".';
    } finally {
      _pendingDeviceId = null;
      notifyListeners();
    }
  }

  /// Establece explícitamente el estado (usado en la pantalla de detalle).
  Future<void> setState(DeviceModel device, bool value) async {
    _pendingDeviceId = device.id;
    notifyListeners();
    try {
      await _repo.setState(device, value);
    } catch (_) {
      _error = 'No se pudo actualizar "${device.nombre}".';
    } finally {
      _pendingDeviceId = null;
      notifyListeners();
    }
  }

  /// Devuelve un dispositivo por id desde la caché local (o `null`).
  DeviceModel? byId(String id) {
    for (final DeviceModel d in _devices) {
      if (d.id == id) return d;
    }
    return null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
