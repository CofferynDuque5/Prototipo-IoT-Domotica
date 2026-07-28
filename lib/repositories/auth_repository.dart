import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/realtime_client.dart';
import '../services/token_storage.dart';

/// Repositorio de autenticación. Coordina el servicio REST de auth, el
/// almacenamiento del token y el ciclo de vida de la conexión en tiempo real.
///
/// Al iniciar sesión guarda el token y abre el WebSocket; al cerrar sesión lo
/// limpia y cierra la conexión.
class AuthRepository {
  AuthRepository({
    required AuthService authService,
    required TokenStorage tokenStorage,
    required RealtimeClient realtimeClient,
  })  : _auth = authService,
        _tokens = tokenStorage,
        _realtime = realtimeClient;

  final AuthService _auth;
  final TokenStorage _tokens;
  final RealtimeClient _realtime;

  bool get hasSession => _tokens.hasToken;

  Future<UserModel> signIn(String email, String password) async {
    final AuthResult result =
        await _auth.login(email: email, password: password);
    await _tokens.save(result.token);
    _realtime.connect(result.token);
    return result.user;
  }

  Future<UserModel> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final AuthResult result = await _auth.register(
      nombre: nombre,
      email: email,
      password: password,
    );
    await _tokens.save(result.token);
    _realtime.connect(result.token);
    return result.user;
  }

  /// Restaura la sesión al arrancar la app validando el token guardado.
  /// Devuelve el usuario si el token sigue siendo válido, o `null`.
  Future<UserModel?> restoreSession() async {
    if (!_tokens.hasToken) return null;
    try {
      final UserModel user = await _auth.me();
      _realtime.connect(_tokens.token!);
      return user;
    } catch (_) {
      await _tokens.clear();
      return null;
    }
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.forgotPassword(email);

  Future<UserModel> updateProfileName(UserModel user, String nombre) =>
      _auth.updateProfile(nombre);

  Future<void> signOut() async {
    await _tokens.clear();
    _realtime.disconnect();
  }
}
