import 'package:intl/intl.dart';

class AppUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTimeAgo(String timeStr) {
    // Dans le web, c'est du statique "Il y a 10 min", on garde la logique identique
    return timeStr;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return phone.startsWith('+') || RegExp(r'^\d+$').hasMatch(phone);
  }
}
