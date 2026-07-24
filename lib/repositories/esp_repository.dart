import '../core/config/app_constants.dart';
import '../models/esp_status_model.dart';
import '../services/database_service.dart';

/// Repositorio de telemetría del ESP8266 (nodo `esp`).
///
/// Expone en tiempo real el estado del microcontrolador: conectividad,
/// dirección IP, SSID, intensidad de señal, tiempo encendido y versión de
/// firmware.
class EspRepository {
  EspRepository({required DatabaseService databaseService})
      : _db = databaseService;

  final DatabaseService _db;

  /// Observa el estado del ESP8266 en tiempo real.
  Stream<EspStatusModel> watchStatus() {
    return _db.onValue(AppConstants.nodeEsp).map((snapshot) {
      if (!snapshot.exists || snapshot.value == null) {
        return EspStatusModel.unknown();
      }
      return EspStatusModel.fromMap(
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    });
  }

  /// Lee el estado una única vez (por ejemplo, para un "pull to refresh").
  Future<EspStatusModel> fetchStatus() async {
    final snapshot = await _db.once(AppConstants.nodeEsp);
    if (!snapshot.exists || snapshot.value == null) {
      return EspStatusModel.unknown();
    }
    return EspStatusModel.fromMap(
      Map<String, dynamic>.from(snapshot.value as Map),
    );
  }
}
