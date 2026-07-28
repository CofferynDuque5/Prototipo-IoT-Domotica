import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_constants.dart';

/// Servicio de persistencia local basado en [SharedPreferences].
///
/// Guarda preferencias ligeras del usuario: modo de tema y último correo
/// recordado. Se inicializa una sola vez al arrancar la app.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  /// Fábrica asíncrona que resuelve la instancia de SharedPreferences.
  static Future<PreferencesService> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  // ------------------------------------------------------------------
  // Tema
  // ------------------------------------------------------------------
  ThemeMode getThemeMode() {
    final String? value = _prefs.getString(AppConstants.prefThemeMode);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(AppConstants.prefThemeMode, mode.name);
  }

  // ------------------------------------------------------------------
  // Correo recordado
  // ------------------------------------------------------------------
  String? getRememberedEmail() =>
      _prefs.getString(AppConstants.prefRememberEmail);

  Future<void> setRememberedEmail(String? email) async {
    if (email == null || email.isEmpty) {
      await _prefs.remove(AppConstants.prefRememberEmail);
    } else {
      await _prefs.setString(AppConstants.prefRememberEmail, email);
    }
  }
}
