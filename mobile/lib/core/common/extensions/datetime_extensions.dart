import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  // ═══════════════════════════════════════════════════════════════
  // FORMAT
  // ═══════════════════════════════════════════════════════════════

  /// Format date with pattern
  /// Example: 25/12/2025
  String format([String pattern = 'dd/MM/yyyy']) {
    return DateFormat(pattern).format(this);
  }

  String get toDateString => format('dd/MM/yyyy');
  String get toTimeString => format('HH:mm');
  String get toDateTimeString => format('dd/MM/yyyy HH:mm');
  String get toFullDateTimeString => format('dd/MM/yyyy HH:mm:ss');
  String get toMonthYearString => format('MM/yyyy');

  // ═══════════════════════════════════════════════════════════════
  // TIME AGO
  // ═══════════════════════════════════════════════════════════════

  /// Get relative time (Vietnamese)
  /// Example: 5 phút trước
  String get timeAgo {
    final difference = DateTime.now().difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CHECK
  // ═══════════════════════════════════════════════════════════════

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());

  // ═══════════════════════════════════════════════════════════════
  // CALCULATION
  // ═══════════════════════════════════════════════════════════════

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfMonth => DateTime(year, month, 1);
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  int get daysInMonth => DateTime(year, month + 1, 0).day;

  DateTime addDays(int days) => add(Duration(days: days));
  DateTime subtractDays(int days) => subtract(Duration(days: days));
}

/// Extension for Nullable DateTime to handle UI safely
extension NullableDateTimeExtensions on DateTime? {
  String get toDateStringOrEmpty => this?.toDateString ?? '';
  String get toTimeStringOrEmpty => this?.toTimeString ?? '';
  String get toDateTimeStringOrEmpty => this?.toDateTimeString ?? '';
  String get timeAgoOrEmpty => this?.timeAgo ?? '';
}
