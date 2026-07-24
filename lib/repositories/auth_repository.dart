import 'package:firebase_auth/firebase_auth.dart';

import '../core/config/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

/// Repositorio que orquesta autenticación y perfil de usuario.
///
/// Combina [AuthService] (Firebase Auth) con [DatabaseService] (Realtime
/// Database) para mantener el nodo `users/{uid}` sincronizado con la cuenta.
class AuthRepository {
  AuthRepository({
    required AuthService authService,
    required DatabaseService databaseService,
  })  : _auth = authService,
        _db = databaseService;

  final AuthService _auth;
  final DatabaseService _db;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel> signIn(String email, String password) async {
    final User user = await _auth.signIn(email: email, password: password);
    return _fetchOrCreateProfile(user);
  }

  Future<UserModel> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final User user = await _auth.register(
      email: email,
      password: password,
      nombre: nombre,
    );

    final UserModel model = UserModel(
      uid: user.uid,
      nombre: nombre.trim(),
      email: email.trim(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.set('${AppConstants.nodeUsers}/${user.uid}', model.toMap());
    return model;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordReset(email);

  Future<void> signOut() => _auth.signOut();

  /// Recupera el perfil desde la base de datos; si no existe lo crea a partir
  /// de la información de la cuenta de Firebase Auth.
  Future<UserModel> _fetchOrCreateProfile(User user) async {
    final snapshot =
        await _db.once('${AppConstants.nodeUsers}/${user.uid}');

    if (snapshot.exists && snapshot.value is Map) {
      return UserModel.fromMap(
        user.uid,
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    }

    final UserModel model = UserModel(
      uid: user.uid,
      nombre: user.displayName ?? 'Usuario',
      email: user.email ?? '',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.set('${AppConstants.nodeUsers}/${user.uid}', model.toMap());
    return model;
  }

  /// Actualiza el nombre visible del perfil.
  Future<UserModel> updateProfileName(UserModel user, String nombre) async {
    await _db.update(
      '${AppConstants.nodeUsers}/${user.uid}',
      {'nombre': nombre.trim()},
    );
    await _auth.currentUser?.updateDisplayName(nombre.trim());
    return user.copyWith(nombre: nombre.trim());
  }
}
