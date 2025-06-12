// lib/features/device_discovery/domain/repositories/device_discovery_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../../../core/errors/failures.dart';
import '../entities/device_entity.dart';
import '../entities/discovery_result_entity.dart';

/// Device discovery repository interface
abstract class DeviceDiscoveryRepository {
  /// Start device discovery
  Future<Either<Failure, void>> startDiscovery({
    ConnectionType? method,
    Duration? timeout,
  });

  /// Stop device discovery
  Future<Either<Failure, void>> stopDiscovery();

  /// Start advertising this device
  Future<Either<Failure, void>> startAdvertising({
    String? deviceName,
    Duration? timeout,
  });

  /// Stop advertising this device
  Future<Either<Failure, void>> stopAdvertising();

  /// Get discovered devices stream
  Stream<Either<Failure, DiscoveryResultEntity>> get discoveredDevicesStream;

  /// Get current discovery status
  bool get isDiscovering;

  /// Get current advertising status
  bool get isAdvertising;

  /// Get last discovery result
  Either<Failure, DiscoveryResultEntity?> getLastDiscoveryResult();

  /// Clear discovery cache
  Future<Either<Failure, void>> clearDiscoveryCache();

  /// Get cached devices
  Either<Failure, List<DeviceEntity>> getCachedDevices();
}
