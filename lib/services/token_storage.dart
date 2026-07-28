import 'package:shared_preferences/shared_preferences.dart';

/// Almacena el token JWT de sesión de forma persistente y con acceso síncrono.
///
/// Mantiene una copia en memoria para que [ApiClient] pueda adjuntar el token
/// a cada petición sin necesidad de operaciones asíncronas.
class TokenStorage {
  static const String _key = 'auth_token';

  TokenStorage(this._prefs) {
    _token = _prefs.getString(_key);
  }

  final SharedPreferences _prefs;
  String? _token;

  String? get token => _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  Future<void> save(String token) async {
    _token = token;
    await _prefs.setString(_key, token);
  }

  Future<void> clear() async {
    _token = null;
    await _prefs.remove(_key);
  }
}
