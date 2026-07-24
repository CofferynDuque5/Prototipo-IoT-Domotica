/// Modelo de dominio que representa a un usuario autenticado.
///
/// Es inmutable y expone constructores para mapear desde/hacia el nodo
/// `users/{uid}` de Firebase Realtime Database.
class UserModel {
  final String uid;
  final String nombre;
  final String email;
  final String? photoUrl;
  final int createdAt;

  const UserModel({
    required this.uid,
    required this.nombre,
    required this.email,
    this.photoUrl,
    this.createdAt = 0,
  });

  /// Iniciales del nombre para mostrar en avatares.
  String get initials {
    final List<String> parts =
        nombre.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      nombre: (map['nombre'] as String?)?.trim() ?? 'Usuario',
      email: (map['email'] as String?) ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? nombre,
    String? email,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }
}
