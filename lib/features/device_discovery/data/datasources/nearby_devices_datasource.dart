import 'dart:async';
import '../../../../core/constants/connection_constants.dart';
import '../models/device_model.dart';
import '../models/discovery_result_model.dart';

/// Abstract nearby devices data source
abstract class NearbyDevicesDataSource {
  /// Start device discovery
  Future<void> startDiscovery({ConnectionType? method, Duration? timeout});

  /// Stop device discovery
  Future<void> stopDiscovery();

  /// Start advertising this device
  Future<void> startAdvertising({String? deviceName, Duration? timeout});

  /// Stop advertising this device
  Future<void> stopAdvertising();

  /// Get discovered devices stream
  Stream<DiscoveryResultModel> get discoveredDevicesStream;

  /// Get current discovery status
  bool get isDiscovering;

  /// Get current advertising status
  bool get isAdvertising;

  /// Get last discovery result
  DiscoveryResultModel? get lastDiscoveryResult;

  /// Clear discovery cache
  Future<void> clearDiscoveryCache();

  /// Get cached devices
  List<DeviceModel> getCachedDevices();

  /// Dispose resources
  Future<void> dispose();
}
