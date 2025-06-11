
import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../injection/register_modules.dart';

class SecureStorageImpl implements SecureStorage {
  static const String _prefix = 'secure_';
  
  SharedPreferences get _prefs => GetIt.instance<SharedPreferences>();

  @override
  Future<void> write(String key, String value) async {
    // In a real implementation, you would encrypt the value
    await _prefs.setString(_prefix + key, _encryptValue(value));
  }

  @override
  Future<String?> read(String key) async {
    final encryptedValue = _prefs.getString(_prefix + key);
    if (encryptedValue == null) return null;
    return _decryptValue(encryptedValue);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(_prefix + key);
  }

  @override
  Future<void> deleteAll() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(_prefix + key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    final result = <String, String>{};
    final keys = _prefs.getKeys().where((key) => key.startsWith(_prefix));
    
    for (final key in keys) {
      final value = _prefs.getString(key);
      if (value != null) {
        final originalKey = key.substring(_prefix.length);
        result[originalKey] = _decryptValue(value);
      }
    }
    
    return result;
  }

  String _encryptValue(String value) {
    // Simple base64 encoding for demo - use proper encryption in production
    return base64Encode(utf8.encode(value));
  }

  String _decryptValue(String encryptedValue) {
    // Simple base64 decoding for demo - use proper decryption in production
    return utf8.decode(base64Decode(encryptedValue));
  }
}

// lib/core/utils/logger.dart
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

abstract class AppLogger {
  void log(String message, {LogLevel level = LogLevel.info, Object? error, StackTrace? stackTrace});
  void debug(String message);
  void info(String message);
  void warning(String message, {Object? error});
  void error(String message, {Object? error, StackTrace? stackTrace});
  void critical(String message, {Object? error, StackTrace? stackTrace});
}