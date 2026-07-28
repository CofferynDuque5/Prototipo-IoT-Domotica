import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/event_log_model.dart';
import '../repositories/event_repository.dart';

/// Controlador del historial de eventos. Escucha en tiempo real y expone la
/// lista ordenada de eventos recientes a la interfaz.
class EventController extends ChangeNotifier {
  EventController({required EventRepository eventRepository})
      : _repo = eventRepository {
    _subscribe();
  }

  final EventRepository _repo;
  StreamSubscription<List<EventLogModel>>? _subscription;

  List<EventLogModel> _events = [];
  bool _loading = true;

  List<EventLogModel> get events => _events;
  bool get loading => _loading;
  bool get isEmpty => !_loading && _events.isEmpty;

  /// Devuelve los últimos [count] eventos (para vistas resumidas).
  List<EventLogModel> latest(int count) =>
      _events.take(count).toList(growable: false);

  void _subscribe() {
    _subscription = _repo.watchEvents().listen((list) {
      _events = list;
      _loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
