import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import '../utils/permission_utils.dart';
import '../constants/app_constants.dart';
import 'logger_service.dart';

/// Permission management service
class PermissionService {
  static PermissionService? _instance;
  final LoggerService _logger = LoggerService();
  final StreamController<PermissionStatus> _permissionStatusController =
      StreamController<PermissionStatus>.broadcast();

  PermissionService._();

  static PermissionService get instance {
    _instance ??= PermissionService._();
    return _instance!;
  }

  /// Stream of permission status changes
  Stream<PermissionStatus> get permissionStatusStream =>
      _permissionStatusController.stream;

  /// Initialize permission service
  Future<void> initialize() async {
    try {
      // Check initial permission status
      final status = await checkAllPermissions();
      _permissionStatusController.add(status);
      _logger.info('PermissionService initialized with status: $status');
    } catch (e) {
      _logger.error('Failed to initialize PermissionService: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _permissionStatusController.close();
  }

  /// Request all required permissions
  Future<PermissionStatus> requestAllPermissions() async {
    try {
      _logger.info('Requesting all permissions...');
      final status = await PermissionUtils.requestAllPermissions();
      _permissionStatusController.add(status);
      _logger.info('Permission request completed with status: $status');
      return status;
    } catch (e) {
      _logger.error('Error requesting all permissions: $e');
      final errorStatus = PermissionStatus.error;
      _permissionStatusController.add(errorStatus);
      return errorStatus;
    }
  }

  /// Request storage permissions
  Future<bool> requestStoragePermissions() async {
    try {
      _logger.info('Requesting storage permissions...');
      final granted = await PermissionUtils.requestStoragePermissions();
      _logger.info('Storage permissions ${granted ? 'granted' : 'denied'}');
      _updatePermissionStatus();
      return granted;
    } catch (e) {
      _logger.error('Error requesting storage permissions: $e');
      return false;
    }
  }

  /// Request location permissions
  Future<bool> requestLocationPermissions() async {
    try {
      _logger.info('Requesting location permissions...');
      final granted = await PermissionUtils.requestLocationPermissions();
      _logger.info('Location permissions ${granted ? 'granted' : 'denied'}');
      _updatePermissionStatus();
      return granted;
    } catch (e) {
      _logger.error('Error requesting location permissions: $e');
      return false;
    }
  }

  /// Request camera permissions
  Future<bool> requestCameraPermissions() async {
    try {
      _logger.info('Requesting camera permissions...');
      final granted = await PermissionUtils.requestCameraPermissions();
      _logger.info('Camera permissions ${granted ? 'granted' : 'denied'}');
      _updatePermissionStatus();
      return granted;
    } catch (e) {
      _logger.error('Error requesting camera permissions: $e');
      return false;
    }
  }

  /// Request nearby devices permissions
  Future<bool> requestNearbyDevicesPermissions() async {
    try {
      _logger.info('Requesting nearby devices permissions...');
      final granted = await PermissionUtils.requestNearbyDevicesPermissions();
      _logger.info(
        'Nearby devices permissions ${granted ? 'granted' : 'denied'}',
      );
      _updatePermissionStatus();
      return granted;
    } catch (e) {
      _logger.error('Error requesting nearby devices permissions: $e');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    try {
      _logger.info('Requesting notification permissions...');
      final granted = await PermissionUtils.requestNotificationPermissions();
      _logger.info(
        'Notification permissions ${granted ? 'granted' : 'denied'}',
      );
      _updatePermissionStatus();
      return granted;
    } catch (e) {
      _logger.error('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Check if storage permissions are granted
  Future<bool> hasStoragePermissions() async {
    try {
      return await PermissionUtils.hasStoragePermissions();
    } catch (e) {
      _logger.error('Error checking storage permissions: $e');
      return false;
    }
  }

  /// Check if location permissions are granted
  Future<bool> hasLocationPermissions() async {
    try {
      return await PermissionUtils.hasLocationPermissions();
    } catch (e) {
      _logger.error('Error checking location permissions: $e');
      return false;
    }
  }

  /// Check if camera permissions are granted
  Future<bool> hasCameraPermissions() async {
    try {
      return await PermissionUtils.hasCameraPermissions();
    } catch (e) {
      _logger.error('Error checking camera permissions: $e');
      return false;
    }
  }

  /// Check if notification permissions are granted
  Future<bool> hasNotificationPermissions() async {
    try {
      return await PermissionUtils.hasNotificationPermissions();
    } catch (e) {
      _logger.error('Error checking notification permissions: $e');
      return false;
    }
  }

  /// Check all permissions status
  Future<PermissionStatus> checkAllPermissions() async {
    try {
      final permissionMap = await PermissionUtils.getPermissionStatus();

      final allGranted = permissionMap.values.every((granted) => granted);
      final anyGranted = permissionMap.values.any((granted) => granted);

      if (allGranted) {
        return PermissionStatus.allGranted;
      } else if (anyGranted) {
        return PermissionStatus.partiallyGranted;
      } else {
        return PermissionStatus.denied;
      }
    } catch (e) {
      _logger.error('Error checking all permissions: $e');
      return PermissionStatus.error;
    }
  }

  /// Get detailed permission status
  Future<Map<String, bool>> getDetailedPermissionStatus() async {
    try {
      return await PermissionUtils.getPermissionStatus();
    } catch (e) {
      _logger.error('Error getting detailed permission status: $e');
      return {
        'storage': false,
        'location': false,
        'camera': false,
        'notification': false,
      };
    }
  }

  /// Check if permission is permanently denied
  Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    try {
      return await PermissionUtils.isPermissionPermanentlyDenied(permission);
    } catch (e) {
      _logger.error('Error checking if permission is permanently denied: $e');
      return false;
    }
  }

  /// Open app settings for manual permission grant
  Future<bool> openAppSettings() async {
    try {
      _logger.info('Opening app settings for manual permission grant...');
      return await PermissionUtils.openAppSettings();
    } catch (e) {
      _logger.error('Error opening app settings: $e');
      return false;
    }
  }

  /// Get permission rationale message
  String getPermissionRationale(String permissionType) {
    return PermissionUtils.getPermissionRationale(permissionType);
  }

  /// Check if we need to show permission rationale
  Future<bool> shouldShowPermissionRationale(String permissionType) async {
    try {
      Permission permission;
      switch (permissionType.toLowerCase()) {
        case 'storage':
          permission = Permission.storage;
          break;
        case 'location':
          permission = Permission.location;
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
      _logger.error('Error checking if should show rationale: $e');
      return false;
    }
  }

  /// Request permission with rationale handling
  Future<bool> requestPermissionWithRationale(
    String permissionType, {
    Function(String)? onShowRationale,
    Function()? onPermanentlyDenied,
  }) async {
    try {
      // Check if we should show rationale first
      final shouldShowRationale = await this.shouldShowPermissionRationale(
        permissionType,
      );
      if (shouldShowRationale && onShowRationale != null) {
        final rationale = getPermissionRationale(permissionType);
        onShowRationale(rationale);
        // Give user time to read rationale
        await Future.delayed(const Duration(seconds: 2));
      }

      // Request permission
      bool granted = false;
      switch (permissionType.toLowerCase()) {
        case 'storage':
          granted = await requestStoragePermissions();
          break;
        case 'location':
          granted = await requestLocationPermissions();
          break;
        case 'camera':
          granted = await requestCameraPermissions();
          break;
        case 'notification':
          granted = await requestNotificationPermissions();
          break;
      }

      // Check if permanently denied
      if (!granted) {
        Permission permission;
        switch (permissionType.toLowerCase()) {
          case 'storage':
            permission = Permission.storage;
            break;
          case 'location':
            permission = Permission.location;
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

        final isPermanentlyDenied = await isPermissionPermanentlyDenied(
          permission,
        );
        if (isPermanentlyDenied && onPermanentlyDenied != null) {
          onPermanentlyDenied();
        }
      }

      return granted;
    } catch (e) {
      _logger.error('Error requesting permission with rationale: $e');
      return false;
    }
  }

  /// Schedule permission check
  Timer? _permissionCheckTimer;

  void startPeriodicPermissionCheck({
    Duration interval = const Duration(minutes: 5),
  }) {
    _permissionCheckTimer?.cancel();
    _permissionCheckTimer = Timer.periodic(interval, (_) async {
      await _updatePermissionStatus();
    });
    _logger.info('Started periodic permission check');
  }

  void stopPeriodicPermissionCheck() {
    _permissionCheckTimer?.cancel();
    _permissionCheckTimer = null;
    _logger.info('Stopped periodic permission check');
  }

  /// Update permission status and notify listeners
  Future<void> _updatePermissionStatus() async {
    try {
      final status = await checkAllPermissions();
      _permissionStatusController.add(status);
    } catch (e) {
      _logger.error('Error updating permission status: $e');
    }
  }

  /// Get critical permissions that are required for core functionality
  Future<List<String>> getCriticalMissingPermissions() async {
    try {
      final permissionMap = await getDetailedPermissionStatus();
      final criticalPermissions = [
        'storage',
        'location',
      ]; // Core required permissions

      return criticalPermissions
          .where((permission) => permissionMap[permission] == false)
          .toList();
    } catch (e) {
      _logger.error('Error getting critical missing permissions: $e');
      return [];
    }
  }

  /// Check if app can function with current permissions
  Future<bool> canAppFunction() async {
    try {
      final criticalMissing = await getCriticalMissingPermissions();
      return criticalMissing.isEmpty;
    } catch (e) {
      _logger.error('Error checking if app can function: $e');
      return false;
    }
  }
}
