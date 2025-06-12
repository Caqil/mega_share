import 'package:equatable/equatable.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../../../shared/bloc/base_state.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/discovery_result_entity.dart';

/// Device discovery status enumeration
enum DeviceDiscoveryStatus {
  idle,
  starting,
  discovering,
  stopping,
  completed,
  error,
}

/// Advertising status enumeration
enum AdvertisingStatus { idle, starting, advertising, stopping, error }

/// Device discovery state
class DeviceDiscoveryState extends BaseState {
  final DeviceDiscoveryStatus status;
  final AdvertisingStatus advertisingStatus;
  final bool isDiscovering;
  final bool isAdvertising;
  final List<DeviceEntity> devices;
  final Map<String, DeviceEntity> selectedDevices;
  final DiscoveryResultEntity? discoveryResult;
  final ConnectionType? discoveryMethod;
  final String? error;
  final String? advertisingError;
  final DateTime? lastUpdated;

  const DeviceDiscoveryState({
    this.status = DeviceDiscoveryStatus.idle,
    this.advertisingStatus = AdvertisingStatus.idle,
    this.isDiscovering = false,
    this.isAdvertising = false,
    this.devices = const [],
    this.selectedDevices = const {},
    this.discoveryResult,
    this.discoveryMethod,
    this.error,
    this.advertisingError,
    this.lastUpdated,
  });

  /// Convenience getters
  bool get hasDevices => devices.isNotEmpty;
  bool get hasSelectedDevices => selectedDevices.isNotEmpty;
  bool get hasError => error != null;
  bool get hasAdvertisingError => advertisingError != null;
  bool get isLoading =>
      status == DeviceDiscoveryStatus.starting ||
      status == DeviceDiscoveryStatus.stopping;
  bool get isIdle => status == DeviceDiscoveryStatus.idle;
  bool get isCompleted => status == DeviceDiscoveryStatus.completed;

  /// Get connectable devices
  List<DeviceEntity> get connectableDevices =>
      devices.where((device) => device.isConnectable).toList();

  /// Get connected devices
  List<DeviceEntity> get connectedDevices =>
      devices.where((device) => device.isConnected).toList();

  /// Get devices with strong signal
  List<DeviceEntity> get strongSignalDevices => devices
      .where(
        (device) =>
            device.signalStrengthCategory == SignalStrength.excellent ||
            device.signalStrengthCategory == SignalStrength.good,
      )
      .toList();

  /// Get recent devices (seen within last minute)
  List<DeviceEntity> get recentDevices =>
      devices.where((device) => device.isRecentlySeen).toList();

  /// Get discovery metrics
  DiscoveryMetrics? get discoveryMetrics => discoveryResult?.metrics;

  /// Get device count by type
  Map<DeviceType, int> get deviceCountByType {
    final counts = <DeviceType, int>{};
    for (final device in devices) {
      counts[device.deviceType] = (counts[device.deviceType] ?? 0) + 1;
    }
    return counts;
  }

  /// Check if device is selected
  bool isDeviceSelected(String deviceId) =>
      selectedDevices.containsKey(deviceId);

  /// Get selected device count
  int get selectedDeviceCount => selectedDevices.length;

  /// Get discovery status description
  String get statusDescription {
    switch (status) {
      case DeviceDiscoveryStatus.idle:
        return 'Ready to discover devices';
      case DeviceDiscoveryStatus.starting:
        return 'Starting device discovery...';
      case DeviceDiscoveryStatus.discovering:
        return 'Discovering nearby devices...';
      case DeviceDiscoveryStatus.stopping:
        return 'Stopping discovery...';
      case DeviceDiscoveryStatus.completed:
        return 'Discovery completed';
      case DeviceDiscoveryStatus.error:
        return error ?? 'Discovery error occurred';
    }
  }

  /// Get advertising status description
  String get advertisingStatusDescription {
    switch (advertisingStatus) {
      case AdvertisingStatus.idle:
        return 'Device not visible to others';
      case AdvertisingStatus.starting:
        return 'Making device discoverable...';
      case AdvertisingStatus.advertising:
        return 'Device is visible to others';
      case AdvertisingStatus.stopping:
        return 'Stopping advertising...';
      case AdvertisingStatus.error:
        return advertisingError ?? 'Advertising error occurred';
    }
  }

  DeviceDiscoveryState copyWith({
    DeviceDiscoveryStatus? status,
    AdvertisingStatus? advertisingStatus,
    bool? isDiscovering,
    bool? isAdvertising,
    List<DeviceEntity>? devices,
    Map<String, DeviceEntity>? selectedDevices,
    DiscoveryResultEntity? discoveryResult,
    ConnectionType? discoveryMethod,
    String? error,
    String? advertisingError,
    DateTime? lastUpdated,
  }) {
    return DeviceDiscoveryState(
      status: status ?? this.status,
      advertisingStatus: advertisingStatus ?? this.advertisingStatus,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      isAdvertising: isAdvertising ?? this.isAdvertising,
      devices: devices ?? this.devices,
      selectedDevices: selectedDevices ?? this.selectedDevices,
      discoveryResult: discoveryResult ?? this.discoveryResult,
      discoveryMethod: discoveryMethod ?? this.discoveryMethod,
      error: error,
      advertisingError: advertisingError,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    status,
    advertisingStatus,
    isDiscovering,
    isAdvertising,
    devices,
    selectedDevices,
    discoveryResult,
    discoveryMethod,
    error,
    advertisingError,
    lastUpdated,
  ];
}
