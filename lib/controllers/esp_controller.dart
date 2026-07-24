import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/esp_status_model.dart';
import '../repositories/esp_repository.dart';

/// Controlador de telemetría del ESP8266.
///
/// Mantiene el último estado conocido del microcontrolador y detecta las
/// transiciones online → offline para poder notificarlas en la interfaz.
class EspController extends ChangeNotifier {
  EspController({required EspRepository espRepository}) : _repo = espRepository {
    _subscribe();
  }

  final EspRepository _repo;
  StreamSubscription<EspStatusModel>? _subscription;

  EspStatusModel _status = EspStatusModel.unknown();
  bool _loading = true;
  bool? _previousOnline;

  EspStatusModel get status => _status;
  bool get loading => _loading;
  bool get isOnline => _status.isConnected;

  /// Se establece a `true`/`false` cuando cambia la conectividad, para que la
  /// UI dispare una notificación. La pantalla debe llamar a [consumeTransition].
  bool? _pendingTransition;
  bool? get pendingTransition => _pendingTransition;

  void _subscribe() {
    _subscription = _repo.watchStatus().listen((status) {
      _status = status;
      _loading = false;

      final bool nowOnline = status.isConnected;
      if (_previousOnline != null && _previousOnline != nowOnline) {
        _pendingTransition = nowOnline;
      }
      _previousOnline = nowOnline;

      notifyListeners();
    });
  }

  /// La UI llama a esto tras mostrar la notificación de cambio de estado.
  void consumeTransition() {
    _pendingTransition = null;
  }

  Future<void> refresh() async {
    _status = await _repo.fetchStatus();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
