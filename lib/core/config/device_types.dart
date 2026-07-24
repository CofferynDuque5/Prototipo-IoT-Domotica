import 'package:flutter/material.dart';

/// Catálogo de tipos de dispositivo soportados por el sistema.
///
/// Cada tipo asocia una etiqueta legible y un par de iconos (encendido/apagado)
/// para que la interfaz sea coherente en toda la aplicación.
enum DeviceType {
  luz,
  ventilador,
  puerta,
  tomacorriente,
  generico;

  /// Convierte el valor almacenado en Firebase (string) al enum.
  static DeviceType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'luz':
        return DeviceType.luz;
      case 'ventilador':
        return DeviceType.ventilador;
      case 'puerta':
        return DeviceType.puerta;
      case 'tomacorriente':
        return DeviceType.tomacorriente;
      default:
        return DeviceType.generico;
    }
  }

  /// Valor persistido en la base de datos.
  String get key => name;

  /// Etiqueta legible mostrada al usuario.
  String get label {
    switch (this) {
      case DeviceType.luz:
        return 'Luz';
      case DeviceType.ventilador:
        return 'Ventilador';
      case DeviceType.puerta:
        return 'Puerta';
      case DeviceType.tomacorriente:
        return 'Tomacorriente';
      case DeviceType.generico:
        return 'Dispositivo';
    }
  }

  /// Icono mostrado cuando el dispositivo está encendido / activo.
  IconData get activeIcon {
    switch (this) {
      case DeviceType.luz:
        return Icons.lightbulb;
      case DeviceType.ventilador:
        return Icons.air;
      case DeviceType.puerta:
        return Icons.meeting_room;
      case DeviceType.tomacorriente:
        return Icons.power;
      case DeviceType.generico:
        return Icons.toggle_on;
    }
  }

  /// Icono mostrado cuando el dispositivo está apagado / inactivo.
  IconData get inactiveIcon {
    switch (this) {
      case DeviceType.luz:
        return Icons.lightbulb_outline;
      case DeviceType.ventilador:
        return Icons.air;
      case DeviceType.puerta:
        return Icons.door_front_door;
      case DeviceType.tomacorriente:
        return Icons.power_off;
      case DeviceType.generico:
        return Icons.toggle_off;
    }
  }
}
