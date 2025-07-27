import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('EEE, dd MMM yyyy').format(dateTime);
    } catch (_) {
      return dateString;
    }
  }
}