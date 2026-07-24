import '../models/user_model.dart';
import 'api_client.dart';

/// Resultado de una operación de autenticación: token + perfil.
class AuthResult {
  final String token;
  final UserModel user;
  const AuthResult({required this.token, required this.user});
}

/// Servicio de autenticación sobre la API REST del backend.
///
/// Traduce las respuestas JSON a modelos de dominio. Los errores llegan como
/// [ApiException] (ya con mensaje legible) desde [ApiClient].
class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      '/api/auth/login',
      {'email': email.trim(), 'password': password},
      auth: false,
    );
    return _toResult(data);
  }

  Future<AuthResult> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      '/api/auth/register',
      {'nombre': nombre.trim(), 'email': email.trim(), 'password': password},
      auth: false,
    );
    return _toResult(data);
  }

  Future<UserModel> me() async {
    final data = await _api.get('/api/auth/me');
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile(String nombre) async {
    final data = await _api.patch('/api/auth/me', {'nombre': nombre.trim()});
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> forgotPassword(String email) async {
    await _api.post(
      '/api/auth/forgot-password',
      {'email': email.trim()},
      auth: false,
    );
  }

  AuthResult _toResult(dynamic data) {
    final map = data as Map<String, dynamic>;
    return AuthResult(
      token: map['token'] as String,
      user: UserModel.fromJson(map['user'] as Map<String, dynamic>),
    );
  }
}
