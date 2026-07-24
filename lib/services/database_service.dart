import 'package:firebase_database/firebase_database.dart';

/// Servicio de bajo nivel sobre Firebase Realtime Database.
///
/// Encapsula la instancia de [FirebaseDatabase] y expone operaciones genéricas
/// (leer, escribir, escuchar) para que los repositorios no dependan
/// directamente del SDK. Sigue el principio de inversión de dependencias:
/// los repositorios dependen de esta abstracción, no del paquete Firebase.
class DatabaseService {
  DatabaseService(this._db) {
    // Habilita la persistencia local para tolerar cortes de red y mantener
    // sincronizada la UI mientras se restablece la conexión. En Web esta API
    // no está soportada, por lo que se ignora el error de forma segura.
    try {
      _db.setPersistenceEnabled(true);
    } catch (_) {
      // Persistencia no disponible en esta plataforma (p. ej. Web).
    }
  }

  final FirebaseDatabase _db;

  DatabaseReference ref(String path) => _db.ref(path);

  /// Stream con el valor completo de un nodo. Cada cambio en Firebase emite
  /// un nuevo [DataSnapshot], permitiendo actualizar la UI en tiempo real.
  Stream<DataSnapshot> onValue(String path) =>
      _db.ref(path).onValue.map((event) => event.snapshot);

  /// Escribe (reemplaza) el valor de un nodo.
  Future<void> set(String path, Object? value) => _db.ref(path).set(value);

  /// Actualiza parcialmente los campos de un nodo.
  Future<void> update(String path, Map<String, Object?> value) =>
      _db.ref(path).update(value);

  /// Genera una clave única y devuelve la referencia hija (push).
  DatabaseReference push(String path) => _db.ref(path).push();

  /// Lee una única vez el valor de un nodo.
  Future<DataSnapshot> once(String path) async {
    final DatabaseEvent event = await _db.ref(path).once();
    return event.snapshot;
  }

  /// Elimina un nodo.
  Future<void> remove(String path) => _db.ref(path).remove();

  /// Marca un nodo para actualizarse automáticamente cuando el cliente se
  /// desconecte (útil para el estado `online` desde la app).
  Future<void> setOnDisconnect(String path, Object? value) =>
      _db.ref(path).onDisconnect().set(value);
}
