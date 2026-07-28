import 'package:intl/intl.dart';

/// Utilidades de formato de fechas y tiempos.
///
/// Convierte marcas de tiempo (epoch en milisegundos) provenientes de Firebase
/// a cadenas legibles y a formatos "hace X tiempo".
class DateFormatter {
  DateFormatter._();

  static final DateFormat _fullFormat = DateFormat('dd/MM/yyyy · HH:mm:ss');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  // Sin argumento de locale para no depender de `initializeDateFormatting`.
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  static DateTime _fromEpoch(int epochMillis) =>
      DateTime.fromMillisecondsSinceEpoch(epochMillis);

  static String full(int? epochMillis) {
    if (epochMillis == null || epochMillis == 0) return 'Sin datos';
    return _fullFormat.format(_fromEpoch(epochMillis));
  }

  static String time(int? epochMillis) {
    if (epochMillis == null || epochMillis == 0) return '--:--';
    return _timeFormat.format(_fromEpoch(epochMillis));
  }

  static String date(int? epochMillis) {
    if (epochMillis == null || epochMillis == 0) return 'Sin datos';
    return _dateFormat.format(_fromEpoch(epochMillis));
  }

  /// Devuelve una representación relativa: "hace 3 min", "hace 2 h", etc.
  static String relative(int? epochMillis) {
    if (epochMillis == null || epochMillis == 0) return 'nunca';
    final Duration diff =
        DateTime.now().difference(_fromEpoch(epochMillis));

    if (diff.inSeconds < 5) return 'justo ahora';
    if (diff.inSeconds < 60) return 'hace ${diff.inSeconds} s';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'hace ${diff.inDays} d';
    return date(epochMillis);
  }

  /// Formatea una duración en segundos como "2d 4h 30m".
  static String uptime(int? seconds) {
    if (seconds == null || seconds <= 0) return '0m';
    final int days = seconds ~/ 86400;
    final int hours = (seconds % 86400) ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;

    final List<String> parts = [];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0 || parts.isEmpty) parts.add('${minutes}m');
    return parts.join(' ');
  }
}
