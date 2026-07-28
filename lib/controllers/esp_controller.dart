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
    // Reevalúa periódicamente el estado online/offline: si deja de llegar
    // telemetría, el heartbeat "caduca" y la UI debe reflejar la desconexión
    // aunque no haya un nuevo mensaje del servidor.
    _staleTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _reevaluate(),
    );
  }

  final EspRepository _repo;
  StreamSubscription<EspStatusModel>? _subscription;
  Timer? _staleTimer;

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

  /// Recalcula la conectividad a partir de la antigüedad del último heartbeat
  /// y detecta la transición a "offline" si el ESP dejó de reportar.
  void _reevaluate() {
    final bool nowOnline = _status.isConnected;
    if (_previousOnline != null && _previousOnline != nowOnline) {
      _pendingTransition = nowOnline;
    }
    _previousOnline = nowOnline;
    notifyListeners();
  }

  Future<void> refresh() async {
    _status = await _repo.fetchStatus();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _staleTimer?.cancel();
    super.dispose();
  }
}
