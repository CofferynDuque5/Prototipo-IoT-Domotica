import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

/// Controlador del tema de la aplicación (claro / oscuro / sistema).
///
/// Persiste la elección con [PreferencesService] y notifica a los oyentes para
/// que `MaterialApp` reconstruya el tema al instante.
class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs) {
    _themeMode = _prefs.getThemeMode();
  }

  final PreferencesService _prefs;
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  /// Cambia a un modo concreto.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs.setThemeMode(mode);
  }

  /// Alterna rápidamente entre claro y oscuro (usado por el interruptor).
  Future<void> toggle() async {
    final ThemeMode next =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}
