import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../services/logger_service.dart';

/// Utility class for handling app permissions
class PermissionUtils {
  static final LoggerService _logger = LoggerService.instance;

  /// Request all required permissions for the app
  static Future<PermissionStatus> requestAllPermissions() async {
    try {
      _logger.info('Requesting all required permissions');

      final permissions = <Permission>[
        Permission.storage,
        Permission.location,
        Permission.camera,
        Permission.notification,
      ];

      // Add platform-specific permissions
      if (Platform.isAndroid) {
        permissions.addAll([
          Permission.manageExternalStorage,
          Permission.accessMediaLocation,
          Permission.nearbyWifiDevices,
        ]);
      }

      final statuses = await permissions.request();

      final grantedCount = statuses.values
          .where((status) => status.isGranted)
          .length;
      final totalCount = statuses.length;

      _logger.info('Permissions granted: $grantedCount/$totalCount');

      if (grantedCount == totalCount) {
        return PermissionStatus.allGranted;
      } else if (grantedCount > 0) {
        return PermissionStatus.partiallyGranted;
      } else {
        return PermissionStatus.denied;
      }
    } catch (e) {
      _logger.error('Error requesting all permissions: $e');
      return PermissionStatus.error;
    }
  }

  /// Request storage permissions
  static Future<bool> requestStoragePermissions() async {
    try {
      _logger.debug('Requesting storage permissions');

      if (Platform.isAndroid) {
        // For Android 11+ (API 30+), we need different permissions
        final androidInfo = await _getAndroidVersion();

        if (androidInfo >= 30) {
          // Request manage external storage for Android 11+
          final manageStatus = await Permission.manageExternalStorage.request();
          final storageStatus = await Permission.storage.request();

          return manageStatus.isGranted || storageStatus.isGranted;
        } else {
          // For older Android versions
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      } else if (Platform.isIOS) {
        // iOS doesn't require explicit storage permissions for app documents
        return true;
      }

      return false;
    } catch (e) {
      _logger.error('Error requesting storage permissions: $e');
      return false;
    }
  }

  /// Request location permissions
  static Future<bool> requestLocationPermissions() async {
    try {
      _logger.debug('Requesting location permissions');

      // Request location when in use first
      var status = await Permission.locationWhenInUse.request();

      if (status.isGranted) {
        // For nearby connections, we might need background location
        if (Platform.isAndroid) {
          final backgroundStatus = await Permission.locationAlways.request();
          return backgroundStatus.isGranted || status.isGranted;
        }
        return true;
      }

      return false;
    } catch (e) {
      _logger.error('Error requesting location permissions: $e');
      return false;
    }
  }

  /// Request camera permissions
  static Future<bool> requestCameraPermissions() async {
    try {
      _logger.debug('Requesting camera permissions');
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      _logger.error('Error requesting camera permissions: $e');
      return false;
    }
  }

  /// Request nearby devices permissions (Android 12+)
  static Future<bool> requestNearbyDevicesPermissions() async {
    try {
      _logger.debug('Requesting nearby devices permissions');

      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();

        if (androidInfo >= 31) {
          // Android 12+
          final nearbyStatus = await Permission.nearbyWifiDevices.request();
          final bluetoothStatus = await Permission.bluetoothConnect.request();
          final bluetoothScanStatus = await Permission.bluetoothScan.request();

          return nearbyStatus.isGranted &&
              bluetoothStatus.isGranted &&
              bluetoothScanStatus.isGranted;
        } else {
          // For older versions, location permission is sufficient
          return await hasLocationPermissions();
        }
      } else if (Platform.isIOS) {
        // iOS uses different approach for nearby connections
        return true; // Handled by the nearby connections framework
      }

      return false;
    } catch (e) {
      _logger.error('Error requesting nearby devices permissions: $e');
      return false;
    }
  }

  /// Request notification permissions
  static Future<bool> requestNotificationPermissions() async {
    try {
      _logger.debug('Requesting notification permissions');
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      _logger.error('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Check if storage permissions are granted
  static Future<bool> hasStoragePermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();

        if (androidInfo >= 30) {
          final manageStatus = await Permission.manageExternalStorage.status;
          final storageStatus = await Permission.storage.status;
          return manageStatus.isGranted || storageStatus.isGranted;
        } else {
          final status = await Permission.storage.status;
          return status.isGranted;
        }
      } else if (Platform.isIOS) {
        return true; // iOS handles this differently
      }

      return false;
    } catch (e) {
      _logger.error('Error checking storage permissions: $e');
      return false;
    }
  }

  /// Check if location permissions are granted
  static Future<bool> hasLocationPermissions() async {
    try {
      final whenInUseStatus = await Permission.locationWhenInUse.status;
      final alwaysStatus = await Permission.locationAlways.status;

      return whenInUseStatus.isGranted || alwaysStatus.isGranted;
    } catch (e) {
      _logger.error('Error checking location permissions: $e');
      return false;
    }
  }

  /// Check if camera permissions are granted
  static Future<bool> hasCameraPermissions() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      _logger.error('Error checking camera permissions: $e');
      return false;
    }
  }

  /// Check if notification permissions are granted
  static Future<bool> hasNotificationPermissions() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      _logger.error('Error checking notification permissions: $e');
      return false;
    }
  }

  /// Get detailed permission status for all permissions
  static Future<Map<String, bool>> getPermissionStatus() async {
    try {
      final results = <String, bool>{};

      results['storage'] = await hasStoragePermissions();
      results['location'] = await hasLocationPermissions();
      results['camera'] = await hasCameraPermissions();
      results['notification'] = await hasNotificationPermissions();

      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        if (androidInfo >= 31) {
          final nearbyStatus = await Permission.nearbyWifiDevices.status;
          results['nearby_devices'] = nearbyStatus.isGranted;
        }
      }

      return results;
    } catch (e) {
      _logger.error('Error getting permission status: $e');
      return {
        'storage': false,
        'location': false,
        'camera': false,
        'notification': false,
      };
    }
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied(
    Permission permission,
  ) async {
    try {
      final status = await permission.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      _logger.error('Error checking permanent denial: $e');
      return false;
    }
  }

  /// Open app settings for manual permission grant
  static Future<bool> openAppSettings() async {
    try {
      _logger.info('Opening app settings');
      return await openAppSettings();
    } catch (e) {
      _logger.error('Error opening app settings: $e');
      return false;
    }
  }

  /// Get permission rationale message
  static String getPermissionRationale(String permissionType) {
    switch (permissionType.toLowerCase()) {
      case 'storage':
        return 'Storage permission is needed to access and share files on your device. '
            'This allows you to select files for transfer and save received files.';

      case 'location':
        return 'Location permission is required to discover nearby devices. '
            'This enables the app to find other devices in your vicinity for file sharing.';

      case 'camera':
        return 'Camera permission is needed to scan QR codes for quick device connection. '
            'This provides an easy way to connect with other devices.';

      case 'notification':
        return 'Notification permission allows the app to show you transfer progress, '
            'completion status, and connection requests even when the app is in the background.';

      case 'nearby_devices':
        return 'Nearby devices permission is required to discover and connect to devices '
            'in your area. This is essential for the file sharing functionality.';

      default:
        return 'This permission is required for the app to function properly.';
    }
  }

  /// Get critical permissions that must be granted for core functionality
  static List<String> getCriticalPermissions() {
    return ['storage', 'location'];
  }

  /// Get optional permissions that enhance user experience
  static List<String> getOptionalPermissions() {
    return ['camera', 'notification'];
  }

  /// Check if all critical permissions are granted
  static Future<bool> hasCriticalPermissions() async {
    try {
      final criticalPermissions = getCriticalPermissions();
      final statusMap = await getPermissionStatus();

      return criticalPermissions.every(
        (permission) => statusMap[permission] == true,
      );
    } catch (e) {
      _logger.error('Error checking critical permissions: $e');
      return false;
    }
  }

  /// Get missing critical permissions
  static Future<List<String>> getMissingCriticalPermissions() async {
    try {
      final criticalPermissions = getCriticalPermissions();
      final statusMap = await getPermissionStatus();

      return criticalPermissions
          .where((permission) => statusMap[permission] != true)
          .toList();
    } catch (e) {
      _logger.error('Error getting missing critical permissions: $e');
      return getCriticalPermissions();
    }
  }

  /// Request only critical permissions
  static Future<bool> requestCriticalPermissions() async {
    try {
      _logger.info('Requesting critical permissions');

      final storageGranted = await requestStoragePermissions();
      final locationGranted = await requestLocationPermissions();

      return storageGranted && locationGranted;
    } catch (e) {
      _logger.error('Error requesting critical permissions: $e');
      return false;
    }
  }

  /// Handle permission denial with user-friendly messages
  static Future<PermissionActionResult> handlePermissionDenial(
    String permissionType,
  ) async {
    try {
      Permission permission;
      switch (permissionType.toLowerCase()) {
        case 'storage':
          permission = Permission.storage;
          break;
        case 'location':
          permission = Permission.locationWhenInUse;
          break;
        case 'camera':
          permission = Permission.camera;
          break;
        case 'notification':
          permission = Permission.notification;
          break;
        default:
          return PermissionActionResult.error('Unknown permission type');
      }

      final status = await permission.status;

      if (status.isPermanentlyDenied) {
        return PermissionActionResult.permanentlyDenied(
          'Permission permanently denied. Please enable it in Settings.',
        );
      } else if (status.isDenied) {
        return PermissionActionResult.denied(
          'Permission denied. ${getPermissionRationale(permissionType)}',
        );
      } else if (status.isGranted) {
        return PermissionActionResult.granted('Permission already granted');
      }

      return PermissionActionResult.unknown('Permission status unknown');
    } catch (e) {
      _logger.error('Error handling permission denial: $e');
      return PermissionActionResult.error('Error checking permission status');
    }
  }

  /// Get Android SDK version
  static Future<int> _getAndroidVersion() async {
    try {
      if (Platform.isAndroid) {
        // This would need platform channel implementation
        // For now, return a default value
        return 30; // Android 11 as default
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if permission should show rationale
  static Future<bool> shouldShowRequestPermissionRationale(
    String permissionType,
  ) async {
    try {
      Permission permission;
      switch (permissionType.toLowerCase()) {
        case 'storage':
          permission = Permission.storage;
          break;
        case 'location':
          permission = Permission.locationWhenInUse;
          break;
        case 'camera':
          permission = Permission.camera;
          break;
        case 'notification':
          permission = Permission.notification;
          break;
        default:
          return false;
      }

      final status = await permission.status;
      return status.isDenied && !status.isPermanentlyDenied;
    } catch (e) {
      _logger.error('Error checking rationale requirement: $e');
      return false;
    }
  }
}

/// Permission status enumeration
enum PermissionStatus { allGranted, partiallyGranted, denied, error }

/// Permission action result
class PermissionActionResult {
  final PermissionActionType type;
  final String message;

  const PermissionActionResult._(this.type, this.message);

  factory PermissionActionResult.granted(String message) =>
      PermissionActionResult._(PermissionActionType.granted, message);

  factory PermissionActionResult.denied(String message) =>
      PermissionActionResult._(PermissionActionType.denied, message);

  factory PermissionActionResult.permanentlyDenied(String message) =>
      PermissionActionResult._(PermissionActionType.permanentlyDenied, message);

  factory PermissionActionResult.unknown(String message) =>
      PermissionActionResult._(PermissionActionType.unknown, message);

  factory PermissionActionResult.error(String message) =>
      PermissionActionResult._(PermissionActionType.error, message);

  bool get isGranted => type == PermissionActionType.granted;
  bool get isDenied => type == PermissionActionType.denied;
  bool get isPermanentlyDenied =>
      type == PermissionActionType.permanentlyDenied;
  bool get isError => type == PermissionActionType.error;
}

/// Permission action type enumeration
enum PermissionActionType { granted, denied, permanentlyDenied, unknown, error }
