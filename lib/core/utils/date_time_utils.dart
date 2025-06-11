import 'package:intl/intl.dart';

/// Utility class for date and time operations
class DateTimeUtils {
  static const Map<String, String> _commonFormats = {
    'default': 'yyyy-MM-dd HH:mm:ss',
    'date': 'yyyy-MM-dd',
    'time': 'HH:mm:ss',
    'dateTime': 'yyyy-MM-dd HH:mm',
    'display': 'MMM dd, yyyy',
    'displayTime': 'MMM dd, yyyy HH:mm',
    'iso': 'yyyy-MM-ddTHH:mm:ss.SSSZ',
    'file': 'yyyyMMdd_HHmmss',
    'readable': 'EEEE, MMMM dd, yyyy',
    'short': 'MM/dd/yyyy',
    'shortTime': 'HH:mm',
    'full': 'EEEE, MMMM dd, yyyy HH:mm:ss',
  };

  /// Format DateTime using predefined format or custom pattern
  static String formatDateTime(
    DateTime dateTime, {
    String format = 'default',
  }) {
    try {
      final pattern = _commonFormats[format] ?? format;
      final formatter = DateFormat(pattern);
      return formatter.format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }

  /// Format DateTime for display (human readable)
  static String formatForDisplay(DateTime dateTime) {
    return formatDateTime(dateTime, format: 'display');
  }

  /// Format DateTime with time for display
  static String formatForDisplayWithTime(DateTime dateTime) {
    return formatDateTime(dateTime, format: 'displayTime');
  }

  /// Format DateTime for file naming (safe characters only)
  static String formatForFileName(DateTime dateTime) {
    return formatDateTime(dateTime, format: 'file');
  }

  /// Get file timestamp for logging/naming
  static String getFileTimestamp() {
    return formatForFileName(DateTime.now());
  }

  /// Format duration in human readable format
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Format duration in compact format
  static String formatDurationCompact(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get relative time (e.g., "2 minutes ago", "in 3 hours")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final isPast = difference.isNegative == false;
    final absDifference = difference.abs();

    String timeUnit;
    int value;

    if (absDifference.inSeconds < 60) {
      return 'Just now';
    } else if (absDifference.inMinutes < 60) {
      value = absDifference.inMinutes;
      timeUnit = value == 1 ? 'minute' : 'minutes';
    } else if (absDifference.inHours < 24) {
      value = absDifference.inHours;
      timeUnit = value == 1 ? 'hour' : 'hours';
    } else if (absDifference.inDays < 7) {
      value = absDifference.inDays;
      timeUnit = value == 1 ? 'day' : 'days';
    } else if (absDifference.inDays < 30) {
      value = absDifference.inDays ~/ 7;
      timeUnit = value == 1 ? 'week' : 'weeks';
    } else if (absDifference.inDays < 365) {
      value = absDifference.inDays ~/ 30;
      timeUnit = value == 1 ? 'month' : 'months';
    } else {
      value = absDifference.inDays ~/ 365;
      timeUnit = value == 1 ? 'year' : 'years';
    }

    if (isPast) {
      return '$value $timeUnit ago';
    } else {
      return 'in $value $timeUnit';
    }
  }

  /// Get time since in short format
  static String getTimeSince(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7}w';
    if (difference.inDays < 365) return '${difference.inDays ~/ 30}mo';
    return '${difference.inDays ~/ 365}y';
  }

  /// Check if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return dateTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        dateTime.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is this month
  static bool isThisMonth(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month;
  }

  /// Check if date is this year
  static bool isThisYear(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime dateTime) {
    final daysFromMonday = dateTime.weekday - 1;
    return startOfDay(dateTime.subtract(Duration(days: daysFromMonday)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime dateTime) {
    final daysToSunday = 7 - dateTime.weekday;
    return endOfDay(dateTime.add(Duration(days: daysToSunday)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime dateTime) {
    final nextMonth = dateTime.month == 12
        ? DateTime(dateTime.year + 1, 1, 1)
        : DateTime(dateTime.year, dateTime.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1));
  }

  /// Parse ISO string to DateTime
  static DateTime? parseIsoString(String isoString) {
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }

  /// Parse date string with custom format
  static DateTime? parseDate(String dateString, String format) {
    try {
      final formatter = DateFormat(format);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get timezone offset string
  static String getTimezoneOffset() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get age from birthdate
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  /// Calculate elapsed time with precision
  static String getElapsedTime(DateTime start, DateTime? end) {
    final endTime = end ?? DateTime.now();
    final duration = endTime.difference(start);
    return formatDuration(duration);
  }

  /// Format time remaining
  static String formatTimeRemaining(Duration remaining) {
    if (remaining.isNegative) return 'Overdue';
    
    if (remaining.inDays > 0) {
      return '${remaining.inDays} day${remaining.inDays == 1 ? '' : 's'} left';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} hour${remaining.inHours == 1 ? '' : 's'} left';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes} minute${remaining.inMinutes == 1 ? '' : 's'} left';
    } else {
      return '${remaining.inSeconds} second${remaining.inSeconds == 1 ? '' : 's'} left';
    }
  }

  /// Get business days between two dates
  static int getBusinessDays(DateTime start, DateTime end) {
    if (start.isAfter(end)) {
      final temp = start;
      start = end;
      end = temp;
    }

    int businessDays = 0;
    DateTime current = start;

    while (current.isBefore(end) || isSameDay(current, end)) {
      if (current.weekday < 6) { // Monday = 1, Sunday = 7
        businessDays++;
      }
      current = current.add(const Duration(days: 1));
    }

    return businessDays;
  }

  /// Format duration for transfer ETA
  static String formatTransferETA(Duration duration) {
    if (duration.inHours > 24) {
      return '> 1 day';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}