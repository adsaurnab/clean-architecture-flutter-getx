import 'dart:math';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  /// Returns first N characters or the whole string if shorter.
  String truncate(int maxLength, {String ellipsis = '…'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  /// Capitalize first letter.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Returns initials from a display name (max 2 letters).
  String get initials {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

extension DateTimeExtensions on DateTime {
  /// Returns "Today", "Yesterday", or a formatted date.
  String get chatDateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(year, month, day);
    final diff = today.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(this);
  }

  /// Short time like "14:32".
  String get shortTime => DateFormat('HH:mm').format(this);

  /// Full date-time like "Jun 1, 2026 14:32".
  String get fullDatetime => DateFormat('MMM d, yyyy HH:mm').format(this);
}

extension IntExtensions on int {
  /// Converts byte count to human-readable like "1.23 MB".
  String get bytesFormatted {
    if (this < 1024) return '$this B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Converts seconds to "mm:ss".
  String get secondsFormatted {
    final m = (this ~/ 60).toString().padLeft(2, '0');
    final s = (this % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

extension DoubleExtensions on double {
  /// Rounds to N decimal places.
  double roundTo(int places) {
    final mod = pow(10.0, places);
    return (this * mod).round() / mod;
  }
}
