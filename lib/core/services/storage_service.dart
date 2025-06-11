import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import '../utils/file_utils.dart';
import 'logger_service.dart';

/// Local storage service for app data
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;
  final LoggerService _logger = LoggerService();

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Initialize storage service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _logger.info('StorageService initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize StorageService: $e');
      rethrow;
    }
  }

  /// Get SharedPreferences instance
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'StorageService not initialized. Call initialize() first.',
      );
    }
    return _prefs!;
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    try {
      final result = await prefs.setString(key, value);
      _logger.debug('Stored string key: $key');
      return result;
    } catch (e) {
      _logger.error('Error storing string $key: $e');
      return false;
    }
  }

  String? getString(String key, {String? defaultValue}) {
    try {
      return prefs.getString(key) ?? defaultValue;
    } catch (e) {
      _logger.error('Error getting string $key: $e');
      return defaultValue;
    }
  }

  // Integer operations
  Future<bool> setInt(String key, int value) async {
    try {
      final result = await prefs.setInt(key, value);
      _logger.debug('Stored int key: $key');
      return result;
    } catch (e) {
      _logger.error('Error storing int $key: $e');
      return false;
    }
  }

  int getInt(String key, {int defaultValue = 0}) {
    try {
      return prefs.getInt(key) ?? defaultValue;
    } catch (e) {
      _logger.error('Error getting int $key: $e');
      return defaultValue;
    }
  }

  // Double operations
  Future<bool> setDouble(String key, double value) async {
    try {
      final result = await prefs.setDouble(key, value);
      _logger.debug('Stored double key: $key');
      return result;
    } catch (e) {
      _logger.error('Error storing double $key: $e');
      return false;
    }
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return prefs.getDouble(key) ?? defaultValue;
    } catch (e) {
      _logger.error('Error getting double $key: $e');
      return defaultValue;
    }
  }

  // Boolean operations
  Future<bool> setBool(String key, bool value) async {
    try {
      final result = await prefs.setBool(key, value);
      _logger.debug('Stored bool key: $key');
      return result;
    } catch (e) {
      _logger.error('Error storing bool $key: $e');
      return false;
    }
  }

  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return prefs.getBool(key) ?? defaultValue;
    } catch (e) {
      _logger.error('Error getting bool $key: $e');
      return defaultValue;
    }
  }

  // List operations
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final result = await prefs.setStringList(key, value);
      _logger.debug('Stored string list key: $key');
      return result;
    } catch (e) {
      _logger.error('Error storing string list $key: $e');
      return false;
    }
  }

  List<String> getStringList(String key, {List<String>? defaultValue}) {
    try {
      return prefs.getStringList(key) ?? defaultValue ?? [];
    } catch (e) {
      _logger.error('Error getting string list $key: $e');
      return defaultValue ?? [];
    }
  }

  // JSON operations
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      _logger.error('Error storing object $key: $e');
      return false;
    }
  }

  Map<String, dynamic>? getObject(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _logger.error('Error getting object $key: $e');
      return null;
    }
  }

  Future<bool> setObjectList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      _logger.error('Error storing object list $key: $e');
      return false;
    }
  }

  List<Map<String, dynamic>> getObjectList(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return [];
      final decoded = jsonDecode(jsonString) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      _logger.error('Error getting object list $key: $e');
      return [];
    }
  }

  // Remove operations
  Future<bool> remove(String key) async {
    try {
      final result = await prefs.remove(key);
      _logger.debug('Removed key: $key');
      return result;
    } catch (e) {
      _logger.error('Error removing key $key: $e');
      return false;
    }
  }

  Future<bool> removeMultiple(List<String> keys) async {
    try {
      bool allSuccessful = true;
      for (final key in keys) {
        final success = await remove(key);
        if (!success) allSuccessful = false;
      }
      return allSuccessful;
    } catch (e) {
      _logger.error('Error removing multiple keys: $e');
      return false;
    }
  }

  // Check operations
  bool containsKey(String key) {
    try {
      return prefs.containsKey(key);
    } catch (e) {
      _logger.error('Error checking key $key: $e');
      return false;
    }
  }

  Set<String> getAllKeys() {
    try {
      return prefs.getKeys();
    } catch (e) {
      _logger.error('Error getting all keys: $e');
      return <String>{};
    }
  }

  // Clear operations
  Future<bool> clear() async {
    try {
      final result = await prefs.clear();
      _logger.info('Cleared all storage');
      return result;
    } catch (e) {
      _logger.error('Error clearing storage: $e');
      return false;
    }
  }

  Future<bool> clearExcept(List<String> keysToKeep) async {
    try {
      final allKeys = getAllKeys();
      final keysToRemove = allKeys.where((key) => !keysToKeep.contains(key));
      return await removeMultiple(keysToRemove.toList());
    } catch (e) {
      _logger.error('Error clearing storage except keys: $e');
      return false;
    }
  }

  // App-specific convenience methods
  Future<bool> setDeviceName(String name) async {
    return await setString(AppConstants.keyDeviceName, name);
  }

  String getDeviceName() {
    return getString(
          AppConstants.keyDeviceName,
          defaultValue: AppConstants.defaultDeviceName,
        ) ??
        AppConstants.defaultDeviceName;
  }

  Future<bool> setFirstTimeUser(bool isFirstTime) async {
    return await setBool(AppConstants.keyFirstTime, isFirstTime);
  }

  bool isFirstTimeUser() {
    return getBool(AppConstants.keyFirstTime, defaultValue: true);
  }

  Future<bool> setAutoAcceptFiles(bool autoAccept) async {
    return await setBool(AppConstants.keyAutoAcceptFiles, autoAccept);
  }

  bool getAutoAcceptFiles() {
    return getBool(
      AppConstants.keyAutoAcceptFiles,
      defaultValue: AppConstants.defaultAutoAcceptFiles,
    );
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await setBool(AppConstants.keyNotificationsEnabled, enabled);
  }

  bool getNotificationsEnabled() {
    return getBool(
      AppConstants.keyNotificationsEnabled,
      defaultValue: AppConstants.defaultNotificationsEnabled,
    );
  }

  Future<bool> setWifiOnlyTransfer(bool wifiOnly) async {
    return await setBool(AppConstants.keyWifiOnlyTransfer, wifiOnly);
  }

  bool getWifiOnlyTransfer() {
    return getBool(
      AppConstants.keyWifiOnlyTransfer,
      defaultValue: AppConstants.defaultWifiOnlyTransfer,
    );
  }

  Future<bool> setCompressionEnabled(bool enabled) async {
    return await setBool(AppConstants.keyCompressionEnabled, enabled);
  }

  bool getCompressionEnabled() {
    return getBool(
      AppConstants.keyCompressionEnabled,
      defaultValue: AppConstants.defaultCompressionEnabled,
    );
  }

  // Transfer history management
  Future<bool> addTransferHistory(Map<String, dynamic> transfer) async {
    try {
      final history = getTransferHistory();
      history.insert(0, transfer); // Add to beginning

      // Keep only last 100 transfers
      if (history.length > 100) {
        history.removeRange(100, history.length);
      }

      return await setObjectList(AppConstants.keyTransferHistory, history);
    } catch (e) {
      _logger.error('Error adding transfer history: $e');
      return false;
    }
  }

  List<Map<String, dynamic>> getTransferHistory() {
    return getObjectList(AppConstants.keyTransferHistory);
  }

  Future<bool> clearTransferHistory() async {
    return await remove(AppConstants.keyTransferHistory);
  }

  // File operations for larger data
  Future<bool> saveToFile(String fileName, String content) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(content);
      _logger.debug('Saved content to file: $fileName');
      return true;
    } catch (e) {
      _logger.error('Error saving to file $fileName: $e');
      return false;
    }
  }

  Future<String?> readFromFile(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        final content = await file.readAsString();
        _logger.debug('Read content from file: $fileName');
        return content;
      }
      return null;
    } catch (e) {
      _logger.error('Error reading from file $fileName: $e');
      return null;
    }
  }

  Future<bool> deleteFile(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
        _logger.debug('Deleted file: $fileName');
      }
      return true;
    } catch (e) {
      _logger.error('Error deleting file $fileName: $e');
      return false;
    }
  }

  // Cache management
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      return await FileUtils.getDirectorySize(cacheDir.path);
    } catch (e) {
      _logger.error('Error getting cache size: $e');
      return 0;
    }
  }

  Future<bool> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }
      _logger.info('Cache cleared successfully');
      return true;
    } catch (e) {
      _logger.error('Error clearing cache: $e');
      return false;
    }
  }

  // Storage info
  Future<StorageInfo> getStorageInfo() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = await getTemporaryDirectory();

      final appSize = await FileUtils.getDirectorySize(appDir.path);
      final cacheSize = await FileUtils.getDirectorySize(cacheDir.path);
      final totalUsed = appSize + cacheSize;

      return StorageInfo(
        appDataSize: appSize,
        cacheSize: cacheSize,
        totalUsed: totalUsed,
        preferencesKeys: getAllKeys().length,
      );
    } catch (e) {
      _logger.error('Error getting storage info: $e');
      return StorageInfo(
        appDataSize: 0,
        cacheSize: 0,
        totalUsed: 0,
        preferencesKeys: 0,
      );
    }
  }

  // Backup and restore
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      final allKeys = getAllKeys();
      final settings = <String, dynamic>{};

      for (final key in allKeys) {
        final value = prefs.get(key);
        settings[key] = value;
      }

      return {
        'version': AppConstants.appVersion,
        'exportTime': DateTime.now().toIso8601String(),
        'settings': settings,
      };
    } catch (e) {
      _logger.error('Error exporting settings: $e');
      return {};
    }
  }

  Future<bool> importSettings(Map<String, dynamic> backup) async {
    try {
      final settings = backup['settings'] as Map<String, dynamic>?;
      if (settings == null) return false;

      for (final entry in settings.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is String) {
          await setString(key, value);
        } else if (value is int) {
          await setInt(key, value);
        } else if (value is double) {
          await setDouble(key, value);
        } else if (value is bool) {
          await setBool(key, value);
        } else if (value is List<String>) {
          await setStringList(key, value);
        }
      }

      _logger.info('Settings imported successfully');
      return true;
    } catch (e) {
      _logger.error('Error importing settings: $e');
      return false;
    }
  }
}

/// Storage information data class
class StorageInfo {
  final int appDataSize;
  final int cacheSize;
  final int totalUsed;
  final int preferencesKeys;

  const StorageInfo({
    required this.appDataSize,
    required this.cacheSize,
    required this.totalUsed,
    required this.preferencesKeys,
  });

  @override
  String toString() {
    return 'StorageInfo(app: ${appDataSize ~/ 1024}KB, cache: ${cacheSize ~/ 1024}KB, total: ${totalUsed ~/ 1024}KB)';
  }
}
