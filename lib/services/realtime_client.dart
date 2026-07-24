import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/config/api_config.dart';

/// Cliente WebSocket que recibe actualizaciones en tiempo real del backend.
///
/// Expone un único flujo de mensajes ([messages]) que sobrevive a las
/// reconexiones: cuando el socket se cae, se reintenta la conexión de forma
/// automática y los mensajes siguen llegando por el mismo stream, por lo que
/// los repositorios no necesitan resuscribirse.
class RealtimeClient {
  final StreamController<Map<String, dynamic>> _messages =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connection =
      StreamController<bool>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  String? _token;
  bool _disposed = false;

  /// Flujo de mensajes decodificados: `{ "type": ..., "payload": ... }`.
  Stream<Map<String, dynamic>> get messages => _messages.stream;

  /// Flujo del estado de la conexión (true = conectado).
  Stream<bool> get connectionState => _connection.stream;

  /// Inicia (o reinicia) la conexión con el token de sesión.
  void connect(String token) {
    _token = token;
    _reconnectTimer?.cancel();
    _open();
  }

  void _open() {
    if (_disposed || _token == null) return;
    try {
      final Uri uri = Uri.parse('${ApiConfig.wsUrl}?token=$_token');
      _channel = WebSocketChannel.connect(uri);
    } catch (_) {
      _scheduleReconnect();
      return;
    }

    _subscription = _channel!.stream.listen(
      (dynamic data) {
        _connection.add(true);
        _onData(data);
      },
      onDone: _scheduleReconnect,
      onError: (_) => _scheduleReconnect(),
      cancelOnError: true,
    );
  }

  void _onData(dynamic data) {
    try {
      final dynamic decoded = jsonDecode(data as String);
      if (decoded is Map<String, dynamic>) {
        _messages.add(decoded);
      }
    } catch (_) {
      // Mensaje no-JSON: se ignora.
    }
  }

  void _scheduleReconnect() {
    _connection.add(false);
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    if (_disposed || _token == null) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), _open);
  }

  /// Cierra la conexión (p. ej. al cerrar sesión) sin destruir el cliente.
  void disconnect() {
    _token = null;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _connection.add(false);
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _messages.close();
    _connection.close();
  }
}
