import '../../../../core/constants/connection_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/bloc/base_event.dart';
import '../../domain/entities/discovery_result_entity.dart';

/// Device discovery events
sealed class DeviceDiscoveryEvent extends BaseEvent {
  const DeviceDiscoveryEvent();
}

/// Start discovery event
class StartDiscoveryEvent extends DeviceDiscoveryEvent {
  final ConnectionConstants.ConnectionType? method;
  final Duration? timeout;

  const StartDiscoveryEvent({this.method, this.timeout});

  @override
  List<Object?> get props => [method, timeout];
}

/// Stop discovery event
class StopDiscoveryEvent extends DeviceDiscoveryEvent {
  const StopDiscoveryEvent();
}

/// Start advertising event
class StartAdvertisingEvent extends DeviceDiscoveryEvent {
  final String? deviceName;
  final Duration? timeout;

  const StartAdvertisingEvent({this.deviceName, this.timeout});

  @override
  List<Object?> get props => [deviceName, timeout];
}

/// Stop advertising event
class StopAdvertisingEvent extends DeviceDiscoveryEvent {
  const StopAdvertisingEvent();
}

/// Discovery stream update event
class DeviceDiscoveryStreamUpdate extends DeviceDiscoveryEvent {
  final DiscoveryResultEntity discoveryResult;

  const DeviceDiscoveryStreamUpdate(this.discoveryResult);

  @override
  List<Object?> get props => [discoveryResult];
}

/// Discovery stream error event
class DeviceDiscoveryStreamError extends DeviceDiscoveryEvent {
  final Failure failure;

  const DeviceDiscoveryStreamError(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// Refresh discovery event
class RefreshDiscoveryEvent extends DeviceDiscoveryEvent {
  final ConnectionConstants.ConnectionType? method;
  final Duration? timeout;

  const RefreshDiscoveryEvent({this.method, this.timeout});

  @override
  List<Object?> get props => [method, timeout];
}

/// Clear discovery cache event
class ClearDiscoveryCacheEvent extends DeviceDiscoveryEvent {
  const ClearDiscoveryCacheEvent();
}

/// Select device event
class SelectDeviceEvent extends DeviceDiscoveryEvent {
  final String deviceId;

  const SelectDeviceEvent(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

/// Deselect device event
class DeselectDeviceEvent extends DeviceDiscoveryEvent {
  final String deviceId;

  const DeselectDeviceEvent(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

/// Clear device selection event
class ClearDeviceSelectionEvent extends DeviceDiscoveryEvent {
  const ClearDeviceSelectionEvent();
}
