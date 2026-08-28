import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dayDateFormat = DateFormat('EEEE, d MMM yyyy', 'id_ID');
  static final DateFormat _shortDateFormat = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _dayNameFormat = DateFormat('EEEE', 'id_ID');

  static String formatFullDate(DateTime date) {
    try {
      return _dayDateFormat.format(date);
    } catch (_) {
      return DateFormat('EEEE, d MMM yyyy').format(date);
    }
  }

  static String formatShortDate(DateTime date) {
    try {
      return _shortDateFormat.format(date);
    } catch (_) {
      return DateFormat('d MMM yyyy').format(date);
    }
  }

  static String formatMonthYear(DateTime date) {
    try {
      return _monthYearFormat.format(date);
    } catch (_) {
      return DateFormat('MMMM yyyy').format(date);
    }
  }

  static String formatDayName(DateTime date) {
    try {
      return _dayNameFormat.format(date);
    } catch (_) {
      return DateFormat('EEEE').format(date);
    }
  }

  static String formatSessionDate(DateTime date, String startTime, String endTime) {
    final dayFormatted = formatFullDate(date);
    return '$dayFormatted • $startTime - $endTime';
  }
}

