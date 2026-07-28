import '../models/esp_status_model.dart';
import '../services/api_client.dart';
import '../services/realtime_client.dart';

/// Repositorio de telemetría del ESP8266: estado inicial vía REST y
/// actualizaciones en tiempo real por WebSocket (mensaje tipo `esp`).
class EspRepository {
  EspRepository({
    required ApiClient apiClient,
    required RealtimeClient realtimeClient,
  })  : _api = apiClient,
        _realtime = realtimeClient;

  final ApiClient _api;
  final RealtimeClient _realtime;

  Future<EspStatusModel> fetchStatus() async {
    try {
      final dynamic data = await _api.get('/api/esp');
      return EspStatusModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return EspStatusModel.unknown();
    }
  }

  Stream<EspStatusModel> watchStatus() async* {
    yield await fetchStatus();

    yield* _realtime.messages
        .where((m) => m['type'] == 'esp')
        .map((m) =>
            EspStatusModel.fromJson(Map<String, dynamic>.from(m['payload'] as Map)));
  }
}
