import 'package:flutter_base/core/common/utils/validators.dart';

extension StringExtensions on String {
  // ═══════════════════════════════════════════════════════════════
  // NULL & EMPTY CHECK
  // ═══════════════════════════════════════════════════════════════

  bool get isNullOrEmpty => isEmpty;
  bool get isNotNullOrEmpty => isNotEmpty;

  // ═══════════════════════════════════════════════════════════════
  // CAPITALIZE
  // ═══════════════════════════════════════════════════════════════

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalize each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(
      ' ',
    ).map((word) => word.isEmpty ? word : word.capitalize).join(' ');
  }

  // ═══════════════════════════════════════════════════════════════
  // VALIDATION (Reuse from Validators - DRY principle)
  // ═══════════════════════════════════════════════════════════════

  /// Check if valid email
  /// Returns true if passes Validators.email
  bool get isValidEmail => Validators.email(this) == null;

  /// Check if valid Vietnamese phone number
  /// Returns true if passes Validators.phoneVN
  bool get isValidPhoneVN => Validators.phoneVN(this) == null;

  // ═══════════════════════════════════════════════════════════════
  // VIETNAMESE
  // ═══════════════════════════════════════════════════════════════

  /// Remove Vietnamese diacritics
  String get removeDiacritics {
    var str = this;
    str = str.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    str = str.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    str = str.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    str = str.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    str = str.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    str = str.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    str = str.replaceAll(RegExp(r'[đ]'), 'd');
    str = str.replaceAll(RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'), 'A');
    str = str.replaceAll(RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'), 'E');
    str = str.replaceAll(RegExp(r'[ÌÍỊỈĨ]'), 'I');
    str = str.replaceAll(RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'), 'O');
    str = str.replaceAll(RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'), 'U');
    str = str.replaceAll(RegExp(r'[ỲÝỴỶỸ]'), 'Y');
    str = str.replaceAll(RegExp(r'[Đ]'), 'D');
    return str;
  }

  // ═══════════════════════════════════════════════════════════════
  // MANIPULATION
  // ═══════════════════════════════════════════════════════════════

  /// Truncate with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  // ═══════════════════════════════════════════════════════════════
  // PARSING
  // ═══════════════════════════════════════════════════════════════

  /// Parse to int with default value
  int toIntOrDefault([int defaultValue = 0]) {
    return int.tryParse(this) ?? defaultValue;
  }

  /// Parse to double with default value
  double toDoubleOrDefault([double defaultValue = 0.0]) {
    return double.tryParse(this) ?? defaultValue;
  }

  // ═══════════════════════════════════════════════════════════════
  // FORMATTING (Consolidated from Formatters)
  // ═══════════════════════════════════════════════════════════════

  /// Mask phone: 0912***345
  String get maskPhone {
    if (length < 7) return this;
    return '${substring(0, 4)}***${substring(length - 3)}';
  }

  /// Mask email: a***@gmail.com
  String get maskEmail {
    if (!contains('@')) return this;
    final parts = split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return this;
    return '${name[0]}***@$domain';
  }
}
