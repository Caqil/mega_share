import '../../../../core/constants/connection_constants.dart';
import '../../../../shared/models/base_model.dart';
import 'device_entity.dart';

/// Discovery result domain entity
class DiscoveryResultEntity extends BaseEntity with TimestampMixin {
  final List<DeviceEntity> devices;
  final ConnectionType discoveryMethod;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  final String? error;
  final Map<String, dynamic> metadata;

  const DiscoveryResultEntity({
    required this.devices,
    required this.discoveryMethod,
    required this.startTime,
    this.endTime,
    required this.isActive,
    this.error,
    required this.metadata,
  });

  @override
  DateTime get createdAt => startTime;

  @override
  DateTime get updatedAt => endTime ?? DateTime.now();

  /// Get discovery duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Get device count
  int get deviceCount => devices.length;

  /// Get connectable devices
  List<DeviceEntity> get connectableDevices =>
      devices.where((device) => device.isConnectable).toList();

  /// Get connected devices
  List<DeviceEntity> get connectedDevices =>
      devices.where((device) => device.isConnected).toList();

  /// Get devices by type
  List<DeviceEntity> getDevicesByType(DeviceType type) {
    return devices.where((device) => device.deviceType == type).toList();
  }

  /// Get devices with strong signal
  List<DeviceEntity> get strongSignalDevices {
    return devices
        .where(
          (device) =>
              device.signalStrengthCategory == SignalStrength.excellent ||
              device.signalStrengthCategory == SignalStrength.good,
        )
        .toList();
  }

  /// Get recently seen devices (within last minute)
  List<DeviceEntity> get recentDevices {
    return devices.where((device) => device.isRecentlySeen).toList();
  }

  /// Check if discovery was successful
  bool get isSuccessful => error == null && deviceCount > 0;

  /// Check if discovery failed
  bool get hasFailed => error != null;

  /// Check if discovery is completed
  bool get isCompleted => !isActive && endTime != null;

  /// Check if discovery is scanning
  bool get isScanning => isActive && metadata['scanning'] == true;

  /// Get discovery status
  DiscoveryStatus get status {
    if (isActive) return DiscoveryStatus.active;
    if (hasFailed) return DiscoveryStatus.failed;
    if (isSuccessful) return DiscoveryStatus.success;
    return DiscoveryStatus.empty;
  }

  /// Find device by ID
  DeviceEntity? findDeviceById(String deviceId) {
    try {
      return devices.firstWhere((device) => device.id == deviceId);
    } catch (e) {
      return null;
    }
  }

  /// Check if device exists
  bool containsDevice(String deviceId) {
    return findDeviceById(deviceId) != null;
  }

  /// Get devices sorted by signal strength
  List<DeviceEntity> get devicesSortedBySignal {
    final sortedDevices = List<DeviceEntity>.from(devices);
    sortedDevices.sort((a, b) => b.signalStrength.compareTo(a.signalStrength));
    return sortedDevices;
  }

  /// Get devices sorted by last seen (most recent first)
  List<DeviceEntity> get devicesSortedByLastSeen {
    final sortedDevices = List<DeviceEntity>.from(devices);
    sortedDevices.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    return sortedDevices;
  }

  /// Get devices sorted by name
  List<DeviceEntity> get devicesSortedByName {
    final sortedDevices = List<DeviceEntity>.from(devices);
    sortedDevices.sort((a, b) => a.displayName.compareTo(b.displayName));
    return sortedDevices;
  }

  /// Group devices by type
  Map<DeviceType, List<DeviceEntity>> get devicesByType {
    final groupedDevices = <DeviceType, List<DeviceEntity>>{};

    for (final device in devices) {
      groupedDevices.putIfAbsent(device.deviceType, () => []).add(device);
    }

    return groupedDevices;
  }

  /// Get discovery performance metrics
  DiscoveryMetrics get metrics {
    return DiscoveryMetrics(
      totalDevices: deviceCount,
      connectableDevices: connectableDevices.length,
      connectedDevices: connectedDevices.length,
      strongSignalDevices: strongSignalDevices.length,
      averageSignalStrength: devices.isEmpty
          ? 0.0
          : devices.map((d) => d.signalStrength).reduce((a, b) => a + b) /
                devices.length,
      discoveryDuration: duration,
      method: discoveryMethod,
    );
  }

  @override
  List<Object?> get props => [
    devices,
    discoveryMethod,
    startTime,
    endTime,
    isActive,
    error,
    metadata,
  ];
}

/// Discovery status enumeration
enum DiscoveryStatus { active, success, failed, empty }

/// Discovery metrics
class DiscoveryMetrics {
  final int totalDevices;
  final int connectableDevices;
  final int connectedDevices;
  final int strongSignalDevices;
  final double averageSignalStrength;
  final Duration discoveryDuration;
  final ConnectionType method;

  const DiscoveryMetrics({
    required this.totalDevices,
    required this.connectableDevices,
    required this.connectedDevices,
    required this.strongSignalDevices,
    required this.averageSignalStrength,
    required this.discoveryDuration,
    required this.method,
  });

  /// Get success rate as percentage
  double get successRate {
    if (totalDevices == 0) return 0.0;
    return (connectableDevices / totalDevices) * 100;
  }

  /// Get devices per second discovery rate
  double get discoveryRate {
    final seconds = discoveryDuration.inSeconds;
    if (seconds == 0) return 0.0;
    return totalDevices / seconds;
  }
}
