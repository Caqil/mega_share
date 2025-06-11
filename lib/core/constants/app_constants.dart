class AppConstants {
  // App Information
  static const String appName = 'ShareIt Flutter';
  static const String appVersion = '1.0.0';
  static const String appPackageName = 'com.example.shareit';

  // Database
  static const String databaseName = 'shareit_db';
  static const int databaseVersion = 1;

  // SharedPreferences Keys
  static const String keyFirstTime = 'first_time';
  static const String keyThemeMode = 'theme_mode';
  static const String keyDeviceName = 'device_name';
  static const String keyAutoAcceptFiles = 'auto_accept_files';
  static const String keyTransferHistory = 'transfer_history';
  static const String keyLanguage = 'language';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyWifiOnlyTransfer = 'wifi_only_transfer';
  static const String keyCompressionEnabled = 'compression_enabled';

  // Default Values
  static const String defaultDeviceName = 'ShareIt Device';
  static const String defaultDownloadPath =
      '/storage/emulated/0/Download/ShareIt';
  static const bool defaultAutoAcceptFiles = false;
  static const bool defaultNotificationsEnabled = true;
  static const bool defaultWifiOnlyTransfer = false;
  static const bool defaultCompressionEnabled = true;

  // API & Network
  static const int requestTimeoutSeconds = 30;
  static const int connectionTimeoutSeconds = 15;
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Device Discovery
  static const Duration discoveryTimeout = Duration(seconds: 30);
  static const Duration advertisingTimeout = Duration(minutes: 5);
  static const int maxDiscoveredDevices = 20;

  // Error Messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String noInternetMessage = 'No internet connection available.';
  static const String permissionDeniedMessage =
      'Permission denied. Please grant the required permissions.';
  static const String deviceNotFoundMessage =
      'Device not found or disconnected.';
  static const String transferFailedMessage =
      'File transfer failed. Please try again.';
}
