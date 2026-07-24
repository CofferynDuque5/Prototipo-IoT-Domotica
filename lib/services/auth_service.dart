import 'package:firebase_auth/firebase_auth.dart';

/// Servicio de bajo nivel sobre Firebase Authentication.
///
/// Aísla el SDK de autenticación del resto de la aplicación. Traduce las
/// excepciones [FirebaseAuthException] a mensajes en español mediante
/// [AuthException] para que la capa de presentación no maneje códigos crudos.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  /// Usuario actualmente autenticado (o `null`).
  User? get currentUser => _auth.currentUser;

  /// Flujo de cambios de sesión (login / logout).
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    }
  }

  Future<User> register({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.updateDisplayName(nombre.trim());
      return cred.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Traduce los códigos de error de Firebase a mensajes legibles.
  String _mapError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red.';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde.';
      default:
        return 'Ocurrió un error de autenticación. ($code)';
    }
  }
}

/// Excepción de dominio con un mensaje ya traducido para el usuario.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
