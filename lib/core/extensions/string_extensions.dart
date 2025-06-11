import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Extension methods for String class
extension StringExtensions on String {
  /// Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(
      ' ',
    ).map((word) => word.isEmpty ? word : word.capitalize).join(' ');
  }

  /// Convert to camelCase
  String get toCamelCase {
    if (isEmpty) return this;
    final words = split(' ');
    if (words.isEmpty) return this;

    final first = words.first.toLowerCase();
    final rest = words.skip(1).map((word) => word.capitalize);
    return [first, ...rest].join();
  }

  /// Convert to snake_case
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Check if string is a valid phone number
  bool get isValidPhoneNumber {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    return RegExp(r'^https?://[\w\-\.]+(:\d+)?(/.*)?$').hasMatch(this);
  }

  /// Check if string is numeric
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Check if string is alphabetic only
  bool get isAlphabetic {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Check if string is alphanumeric only
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  /// Remove all whitespace
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Remove extra whitespace (keep single spaces)
  String get normalizeWhitespace {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Reverse the string
  String get reversed {
    return split('').reversed.join();
  }

  /// Truncate string to specified length with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Get file extension from path/filename
  String get fileExtension {
    final lastDot = lastIndexOf('.');
    return lastDot == -1 ? '' : substring(lastDot).toLowerCase();
  }

  /// Get filename without extension
  String get fileNameWithoutExtension {
    final lastSlash = lastIndexOf('/');
    final lastDot = lastIndexOf('.');
    final start = lastSlash == -1 ? 0 : lastSlash + 1;
    final end = lastDot == -1 ? length : lastDot;
    return substring(start, end);
  }

  /// Generate MD5 hash
  String get md5Hash {
    return md5.convert(utf8.encode(this)).toString();
  }

  /// Generate SHA256 hash
  String get sha256Hash {
    return sha256.convert(utf8.encode(this)).toString();
  }

  /// Convert to base64
  String get toBase64 {
    return base64.encode(utf8.encode(this));
  }

  /// Decode from base64
  String get fromBase64 {
    try {
      return utf8.decode(base64.decode(this));
    } catch (e) {
      return this;
    }
  }

  /// Extract numbers from string
  List<int> get extractNumbers {
    final regex = RegExp(r'\d+');
    return regex
        .allMatches(this)
        .map((match) => int.parse(match.group(0)!))
        .toList();
  }

  /// Remove HTML tags
  String get stripHtml {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Convert to slug (URL-friendly string)
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  /// Mask string (e.g., for passwords, phone numbers)
  String mask({
    int visibleStart = 0,
    int visibleEnd = 0,
    String maskChar = '*',
  }) {
    if (length <= visibleStart + visibleEnd) return this;

    final start = substring(0, visibleStart);
    final end = substring(length - visibleEnd);
    final middle = maskChar * (length - visibleStart - visibleEnd);

    return '$start$middle$end';
  }

  /// Check if string contains only whitespace
  bool get isWhitespace {
    return trim().isEmpty;
  }

  /// Generate random string
  static String random(
    int length, {
    bool includeNumbers = true,
    bool includeSymbols = false,
  }) {
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = letters;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    final random = Random();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Parse as int with fallback
  int toIntOrDefault(int defaultValue) {
    return int.tryParse(this) ?? defaultValue;
  }

  /// Parse as double with fallback
  double toDoubleOrDefault(double defaultValue) {
    return double.tryParse(this) ?? defaultValue;
  }

  /// Parse as bool with fallback
  bool toBoolOrDefault(bool defaultValue) {
    final lower = toLowerCase();
    if (lower == 'true' || lower == '1' || lower == 'yes') return true;
    if (lower == 'false' || lower == '0' || lower == 'no') return false;
    return defaultValue;
  }

  /// Word count
  int get wordCount {
    return trim().isEmpty ? 0 : trim().split(RegExp(r'\s+')).length;
  }

  /// Character count without spaces
  int get characterCountNoSpaces {
    return replaceAll(' ', '').length;
  }

  /// Check if string is palindrome
  bool get isPalindrome {
    final cleaned = toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return cleaned == cleaned.split('').reversed.join('');
  }
}
