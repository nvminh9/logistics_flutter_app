import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateVN(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
  }

  // ⭐ NEW: Format date for API (ISO 8601 format)
  static String formatDateForApi(DateTime date) {
    // Format: yyyy-MM-ddTHH:mm:ss
    return date.toIso8601String();
  }

  // ⭐ NEW: Format date for API (simple format)
  static String formatDateSimpleForApi(DateTime date) {
    // Format: yyyy-MM-dd
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // ⭐ NEW: Parse date from API
  static DateTime? parseDateFromApi(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      print('⚠️ Error parsing date: $e');
      return null;
    }
  }

  // ⭐ NEW: Get today at start of day
  static DateTime getTodayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // ⭐ NEW: Get today at end of day
  static DateTime getTodayEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  // ⭐ NEW: Get start of week
  static DateTime getWeekStart() {
    final now = DateTime.now();
    final weekDay = now.weekday;
    final firstDayOfWeek = now.subtract(Duration(days: weekDay - 1));
    return DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
  }

  // ⭐ NEW: Get start of month
  static DateTime getMonthStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
}