import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _fullDateTimeFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  static final DateFormat _shortDateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  static String formatFull(DateTime dateTime) {
    return _fullDateTimeFormat.format(dateTime.toLocal());
  }

  static String formatShort(DateTime dateTime) {
    return _shortDateTimeFormat.format(dateTime.toLocal());
  }

  static String formatIsoOrFallback(String? isoString, {String fallback = 'N/A'}) {
    if (isoString == null || isoString.isEmpty) return fallback;
    try {
      final dt = DateTime.parse(isoString);
      return formatFull(dt);
    } catch (_) {
      return fallback;
    }
  }
}
