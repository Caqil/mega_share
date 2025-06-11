import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import '../storage/secure_storage_impl.dart';

class AppLoggerImpl implements AppLogger {
  @override
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    final logMessage = '[$timestamp] [$levelStr] $message';

    // In debug mode, print to console
    if (kDebugMode) {
      print(logMessage);
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }

    // Log to platform-specific logging system
    developer.log(
      message,
      name: 'ShareIt',
      error: error,
      stackTrace: stackTrace,
      level: _getLogLevel(level),
    );

    // TODO: In production, send critical logs to crash reporting service
    if (level == LogLevel.critical || level == LogLevel.error) {
      // Send to Firebase Crashlytics, Sentry, etc.
    }
  }

  @override
  void debug(String message) => log(message, level: LogLevel.debug);

  @override
  void info(String message) => log(message, level: LogLevel.info);

  @override
  void warning(String message, {Object? error}) =>
      log(message, level: LogLevel.warning, error: error);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);

  @override
  void critical(String message, {Object? error, StackTrace? stackTrace}) => log(
    message,
    level: LogLevel.critical,
    error: error,
    stackTrace: stackTrace,
  );

  int _getLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }
}
