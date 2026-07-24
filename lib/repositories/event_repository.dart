import '../models/event_log_model.dart';
import '../services/api_client.dart';
import '../services/realtime_client.dart';

/// Repositorio del historial de eventos: carga inicial vía REST y
/// actualizaciones en tiempo real por WebSocket (mensaje tipo `events`).
class EventRepository {
  EventRepository({
    required ApiClient apiClient,
    required RealtimeClient realtimeClient,
  })  : _api = apiClient,
        _realtime = realtimeClient;

  final ApiClient _api;
  final RealtimeClient _realtime;

  Future<List<EventLogModel>> fetchEvents() async {
    final dynamic data = await _api.get('/api/events');
    return (data as List)
        .map((e) =>
            EventLogModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Stream<List<EventLogModel>> watchEvents() async* {
    try {
      yield await fetchEvents();
    } catch (_) {
      yield <EventLogModel>[];
    }

    yield* _realtime.messages
        .where((m) => m['type'] == 'events')
        .map((m) => (m['payload'] as List)
            .map((e) =>
                EventLogModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList());
  }
}
