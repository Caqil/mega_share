// lib/features/device_discovery/data/datasources/nearby_devices_datasource.dart
import 'dart:async';
import '../../../../core/constants/connection_constants.dart';
import '../models/device_model.dart';
import '../models/discovery_result_model.dart';

/// Nearby devices data source interface
abstract class NearbyDevicesDataSource {
  /// Initialize the data source
  Future<void> initialize();

  /// Dispose the data source
  Future<void> dispose();

  /// Start device discovery
  Future<void> startDiscovery({
    required ConnectionType method,
    required Duration timeout,
  });

  /// Stop device discovery
  Future<void> stopDiscovery();

  /// Start advertising this device
  Future<void> startAdvertising({
    String? deviceName,
    required Duration timeout,
  });

  /// Stop advertising this device
  Future<void> stopAdvertising();

  /// Discovery result stream
  Stream<DiscoveryResultModel> get discoveryResultStream;

  /// Get current discovery status
  bool get isDiscovering;

  /// Get current advertising status
  bool get isAdvertising;

  /// Get cached devices
  List<DeviceModel> getCachedDevices();

  /// Clear discovery cache
  Future<void> clearCache();

  /// Check if permissions are granted
  Future<bool> hasRequiredPermissions();

  /// Request required permissions
  Future<bool> requestPermissions();
}
