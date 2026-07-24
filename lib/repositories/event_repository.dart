import 'package:firebase_database/firebase_database.dart';

import '../core/config/app_constants.dart';
import '../models/event_log_model.dart';
import '../services/database_service.dart';

/// Repositorio del historial de eventos (nodo `events`).
///
/// Permite registrar nuevos eventos y observar el historial reciente ordenado
/// de más nuevo a más antiguo.
class EventRepository {
  EventRepository({required DatabaseService databaseService})
      : _db = databaseService;

  final DatabaseService _db;

  /// Registra un evento con marca de tiempo del servidor lógico (cliente).
  Future<void> log({
    required String deviceId,
    required String deviceName,
    required EventAction action,
  }) async {
    final DatabaseReference ref = _db.push(AppConstants.nodeEvents);
    final EventLogModel event = EventLogModel(
      id: ref.key ?? '',
      deviceId: deviceId,
      deviceName: deviceName,
      action: action,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await ref.set(event.toMap());
  }

  /// Observa el historial de eventos en tiempo real (más reciente primero).
  Stream<List<EventLogModel>> watchEvents() {
    return _db.ref(AppConstants.nodeEvents).onValue.map((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) {
        return <EventLogModel>[];
      }

      final Map<dynamic, dynamic> raw =
          snapshot.value as Map<dynamic, dynamic>;

      final List<EventLogModel> events = raw.entries.map((entry) {
        return EventLogModel.fromMap(
          entry.key.toString(),
          Map<String, dynamic>.from(entry.value as Map),
        );
      }).toList();

      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (events.length > AppConstants.maxEventHistory) {
        return events.sublist(0, AppConstants.maxEventHistory);
      }
      return events;
    });
  }
}
