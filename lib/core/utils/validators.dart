/// Validadores reutilizables para formularios.
///
/// Todos devuelven `null` cuando el valor es válido o un mensaje de error
/// en caso contrario, siguiendo el contrato de [FormFieldValidator].
class Validators {
  Validators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static String? email(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'Ingresa tu correo electrónico';
    if (!_emailRegExp.hasMatch(text)) return 'Correo electrónico no válido';
    return null;
  }

  static String? password(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return 'Ingresa tu contraseña';
    if (text.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Confirma tu contraseña';
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? notEmpty(String? value, {String field = 'Este campo'}) {
    if ((value ?? '').trim().isEmpty) return '$field es obligatorio';
    return null;
  }

  static String? name(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'Ingresa tu nombre';
    if (text.length < 2) return 'Nombre demasiado corto';
    return null;
  }
}
