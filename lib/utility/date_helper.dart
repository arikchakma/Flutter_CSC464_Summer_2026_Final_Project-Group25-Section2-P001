import 'package:intl/intl.dart';

class DateHelper {
  static String formatUpdatedAt(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(value.year, value.month, value.day);
    final difference = today.difference(day).inDays;

    if (difference == 0) return 'Today, ${DateFormat.jm().format(value)}';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return DateFormat.EEEE().format(value);

    return DateFormat.yMMMd().format(value);
  }
}
