import 'dart:io';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import '../utils/date_time_utils.dart';

/// Logging levels
enum LogLevel { verbose, debug, info, warning, error, fatal }

/// Log entry data class
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final dynamic error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    final timeStr = DateTimeUtils.formatDateTime(
      timestamp,
      format: 'yyyy-MM-dd HH:mm:ss.SSS',
    );
    final levelStr = level.name.toUpperCase().padRight(7);
    final tagStr = tag != null ? '[$tag] ' : '';

    var logStr = '$timeStr $levelStr $tagStr$message';

    if (error != null) {
      logStr += '\nError: $error';
    }

    if (stackTrace != null) {
      logStr += '\nStackTrace:\n$stackTrace';
    }

    return logStr;
  }
}

/// Logger service for application-wide logging
class LoggerService {
  static LoggerService? _instance;

  LogLevel _minLogLevel = LogLevel.debug;
  bool _writeToFile = false;
  bool _writeToConsole = true;
  String? _logFilePath;
  IOSink? _logFile;

  final List<LogEntry> _logBuffer = [];
  static const int _maxBufferSize = 1000;
  static const int _maxLogFileSize = 10 * 1024 * 1024; // 10 MB

  LoggerService._();

  static LoggerService get instance {
    _instance ??= LoggerService._();
    return _instance!;
  }

  /// Initialize logger service
  Future<void> initialize({
    LogLevel minLogLevel = LogLevel.debug,
    bool writeToFile = false,
    bool writeToConsole = true,
  }) async {
    _minLogLevel = minLogLevel;
    _writeToFile = writeToFile;
    _writeToConsole = writeToConsole;

    if (_writeToFile) {
      await _initializeLogFile();
    }

    info(
      'LoggerService initialized - Level: ${minLogLevel.name}, File: $writeToFile, Console: $writeToConsole',
    );
  }

  /// Set minimum log level
  void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
    info('Log level changed to: ${level.name}');
  }

  /// Enable/disable file logging
  Future<void> setFileLogging(bool enabled) async {
    if (enabled && !_writeToFile) {
      await _initializeLogFile();
    } else if (!enabled && _writeToFile) {
      await _closeLogFile();
    }

    _writeToFile = enabled;
    info('File logging ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Enable/disable console logging
  void setConsoleLogging(bool enabled) {
    _writeToConsole = enabled;
    info('Console logging ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Log verbose message
  void verbose(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.verbose,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log debug message
  void debug(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log info message
  void info(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log warning message
  void warning(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log error message
  void error(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log fatal message
  void fatal(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Core logging method
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    // Check if we should log this level
    if (level.index < _minLogLevel.index) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    // Add to buffer
    _addToBuffer(entry);

    // Log to console
    if (_writeToConsole) {
      _logToConsole(entry);
    }

    // Log to file
    if (_writeToFile) {
      _logToFile(entry);
    }
  }

  /// Log to console/debug output
  void _logToConsole(LogEntry entry) {
    final message = entry.toString();

    switch (entry.level) {
      case LogLevel.verbose:
      case LogLevel.debug:
        developer.log(
          entry.message,
          time: entry.timestamp,
          name: entry.tag ?? 'ShareIt',
          level: 500,
          error: entry.error,
          stackTrace: entry.stackTrace,
        );
        break;
      case LogLevel.info:
        developer.log(
          entry.message,
          time: entry.timestamp,
          name: entry.tag ?? 'ShareIt',
          level: 800,
          error: entry.error,
          stackTrace: entry.stackTrace,
        );
        break;
      case LogLevel.warning:
        developer.log(
          entry.message,
          time: entry.timestamp,
          name: entry.tag ?? 'ShareIt',
          level: 900,
          error: entry.error,
          stackTrace: entry.stackTrace,
        );
        break;
      case LogLevel.error:
      case LogLevel.fatal:
        developer.log(
          entry.message,
          time: entry.timestamp,
          name: entry.tag ?? 'ShareIt',
          level: 1000,
          error: entry.error,
          stackTrace: entry.stackTrace,
        );
        break;
    }
  }

  /// Log to file
  void _logToFile(LogEntry entry) {
    try {
      _logFile?.writeln(entry.toString());
      _logFile?.flush();
    } catch (e) {
      // If file logging fails, fall back to console
      developer.log('Failed to write to log file: $e');
    }
  }

  /// Add entry to buffer
  void _addToBuffer(LogEntry entry) {
    _logBuffer.add(entry);

    // Maintain buffer size
    if (_logBuffer.length > _maxBufferSize) {
      _logBuffer.removeAt(0);
    }
  }

  /// Initialize log file
  Future<void> _initializeLogFile() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${appDir.path}/logs');

      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final timestamp = DateTimeUtils.getFileTimestamp();
      _logFilePath = '${logsDir.path}/shareit_$timestamp.log';

      final logFile = File(_logFilePath!);
      _logFile = logFile.openWrite(mode: FileMode.append);

      // Write header
      await _logFile?.writeln('=== ShareIt Log Started ===');
      await _logFile?.writeln('Version: ${AppConstants.appVersion}');
      await _logFile?.writeln('Timestamp: ${DateTime.now().toIso8601String()}');
      await _logFile?.writeln('=====================================\n');
      await _logFile?.flush();
    } catch (e) {
      developer.log('Failed to initialize log file: $e');
      _writeToFile = false;
    }
  }

  /// Close log file
  Future<void> _closeLogFile() async {
    try {
      await _logFile?.writeln('\n=== ShareIt Log Ended ===');
      await _logFile?.writeln('Timestamp: ${DateTime.now().toIso8601String()}');
      await _logFile?.writeln('===========================');
      await _logFile?.close();
      _logFile = null;
    } catch (e) {
      developer.log('Failed to close log file: $e');
    }
  }

  /// Get recent log entries
  List<LogEntry> getRecentLogs({int count = 100}) {
    final endIndex = _logBuffer.length;
    final startIndex = (endIndex - count).clamp(0, endIndex);
    return _logBuffer.sublist(startIndex);
  }

  /// Get logs by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logBuffer.where((entry) => entry.level == level).toList();
  }

  /// Get logs by time range
  List<LogEntry> getLogsByTimeRange(DateTime start, DateTime end) {
    return _logBuffer.where((entry) {
      return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
    }).toList();
  }

  /// Clear log buffer
  void clearBuffer() {
    _logBuffer.clear();
    info('Log buffer cleared');
  }

  /// Export logs to string
  String exportLogs({LogLevel? minLevel, DateTime? since}) {
    var logs = _logBuffer.asMap().values;

    if (minLevel != null) {
      logs = logs.where((entry) => entry.level.index >= minLevel.index);
    }

    if (since != null) {
      logs = logs.where((entry) => entry.timestamp.isAfter(since));
    }

    return logs.map((entry) => entry.toString()).join('\n');
  }

  /// Get log file path
  String? get logFilePath => _logFilePath;

  /// Get log statistics
  Map<String, dynamic> getLogStatistics() {
    final stats = <LogLevel, int>{};
    for (final level in LogLevel.values) {
      stats[level] = 0;
    }

    for (final entry in _logBuffer) {
      stats[entry.level] = (stats[entry.level] ?? 0) + 1;
    }

    return {
      'totalLogs': _logBuffer.length,
      'bufferSize': _maxBufferSize,
      'fileLogging': _writeToFile,
      'consoleLogging': _writeToConsole,
      'minLevel': _minLogLevel.name,
      'logFilePath': _logFilePath,
      'levelCounts': stats.map((key, value) => MapEntry(key.name, value)),
    };
  }

  /// Cleanup old log files
  Future<void> cleanupOldLogs({int maxDays = 7}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${appDir.path}/logs');

      if (!await logsDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: maxDays));

      await for (final entity in logsDir.list()) {
        if (entity is File && entity.path.endsWith('.log')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            info('Deleted old log file: ${entity.path}');
          }
        }
      }
    } catch (e) {
      error('Failed to cleanup old logs: $e');
    }
  }

  /// Check log file size and rotate if needed
  Future<void> rotateLogFileIfNeeded() async {
    try {
      if (_logFilePath == null) return;

      final logFile = File(_logFilePath!);
      if (await logFile.exists()) {
        final size = await logFile.length();
        if (size > _maxLogFileSize) {
          await _closeLogFile();
          await _initializeLogFile();
          info('Log file rotated due to size limit');
        }
      }
    } catch (e) {
      error('Failed to rotate log file: $e');
    }
  }

  /// Dispose logger service
  Future<void> dispose() async {
    info('Disposing LoggerService');
    await _closeLogFile();
    clearBuffer();
  }
}
