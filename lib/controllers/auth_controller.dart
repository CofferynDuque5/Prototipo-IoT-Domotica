import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';

/// Estados posibles del flujo de autenticación.
enum AuthStatus { unknown, authenticating, authenticated, unauthenticated }

/// Controlador de autenticación. Gobierna la sesión del usuario y expone el
/// estado a la capa de presentación (pantallas de login/registro y router).
class AuthController extends ChangeNotifier {
  AuthController({
    required AuthRepository authRepository,
    required PreferencesService preferencesService,
  })  : _repo = authRepository,
        _prefs = preferencesService {
    _bootstrap();
  }

  final AuthRepository _repo;
  final PreferencesService _prefs;

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;
  bool _busy = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _busy;
  String? get rememberedEmail => _prefs.getRememberedEmail();

  /// Restaura la sesión existente al arrancar la app.
  void _bootstrap() {
    final currentUser = _repo.currentUser;
    if (currentUser != null) {
      _user = UserModel(
        uid: currentUser.uid,
        nombre: currentUser.displayName ?? 'Usuario',
        email: currentUser.email ?? '',
      );
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
    bool remember = true,
  }) async {
    return _run(() async {
      _user = await _repo.signIn(email, password);
      await _prefs.setRememberedEmail(remember ? email.trim() : null);
    });
  }

  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    return _run(() async {
      _user = await _repo.register(
        nombre: nombre,
        email: email,
        password: password,
      );
      await _prefs.setRememberedEmail(email.trim());
    });
  }

  Future<bool> sendPasswordReset(String email) async {
    _errorMessage = null;
    _setBusy(true);
    try {
      await _repo.sendPasswordReset(email);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Actualiza el nombre del perfil del usuario en sesión.
  Future<bool> updateName(String nombre) async {
    if (_user == null) return false;
    _setBusy(true);
    try {
      _user = await _repo.updateProfileName(_user!, nombre);
      return true;
    } catch (_) {
      _errorMessage = 'No se pudo actualizar el perfil.';
      return false;
    } finally {
      _setBusy(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Ejecuta una acción de autenticación gestionando estado y errores.
  Future<bool> _run(Future<void> Function() action) async {
    _errorMessage = null;
    _status = AuthStatus.authenticating;
    _setBusy(true);
    try {
      await action();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }
}
