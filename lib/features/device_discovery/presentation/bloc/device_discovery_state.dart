import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/bloc/base_state.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/discovery_result_entity.dart';

part 'device_discovery_state.freezed.dart';

/// Device discovery states
@freezed
class DeviceDiscoveryState extends BaseState with _$DeviceDiscoveryState {
  /// Initial state
  const factory DeviceDiscoveryState.initial() = DeviceDiscoveryInitial;

  /// Loading state
  const factory DeviceDiscoveryState.loading({
    required bool isDiscovering,
    required bool isAdvertising,
    required List<DeviceEntity> devices,
    required List<String> selectedDevices,
    DiscoveryResultEntity? discoveryResult,
  }) = DeviceDiscoveryLoading;

  /// Success state
  const factory DeviceDiscoveryState.success({
    required List<DeviceEntity> devices,
    required bool isDiscovering,
    required bool isAdvertising,
    required List<String> selectedDevices,
    DiscoveryResultEntity? discoveryResult,
  }) = DeviceDiscoverySuccess;

  /// Error state
  const factory DeviceDiscoveryState.error({
    required Failure failure,
    required bool isDiscovering,
    required bool isAdvertising,
    required List<DeviceEntity> devices,
    required List<String> selectedDevices,
    DiscoveryResultEntity? discoveryResult,
  }) = DeviceDiscoveryError;
}

extension DeviceDiscoveryStateExtension on DeviceDiscoveryState {
  /// Check if currently discovering
  bool get isCurrentlyDiscovering => maybeWhen(
    loading: (isDiscovering, _, __, ___, ____) => isDiscovering,
    success: (_, isDiscovering, __, ___, ____) => isDiscovering,
    error: (_, isDiscovering, __, ___, ____, _____) => isDiscovering,
    orElse: () => false,
  );

  /// Check if currently advertising
  bool get isCurrentlyAdvertising => maybeWhen(
    loading: (_, isAdvertising, __, ___, ____) => isAdvertising,
    success: (_, __, isAdvertising, ___, ____) => isAdvertising,
    error: (_, __, isAdvertising, ___, ____, _____) => isAdvertising,
    orElse: () => false,
  );

  /// Get current devices
  List<DeviceEntity> get currentDevices => maybeWhen(
    loading: (_, __, devices, ___, ____) => devices,
    success: (devices, _, __, ___, ____) => devices,
    error: (_, __, ___, devices, ____, _____) => devices,
    orElse: () => [],
  );

  /// Get selected devices
  List<String> get currentSelectedDevices => maybeWhen(
    loading: (_, __, ___, selectedDevices, ____) => selectedDevices,
    success: (_, __, ___, selectedDevices, ____) => selectedDevices,
    error: (_, __, ___, ____, selectedDevices, _____) => selectedDevices,
    orElse: () => [],
  );

  /// Check if device is selected
  bool isDeviceSelected(String deviceId) {
    return currentSelectedDevices.contains(deviceId);
  }

  /// Get selected device entities
  List<DeviceEntity> get selectedDeviceEntities {
    return currentDevices
        .where((device) => currentSelectedDevices.contains(device.id))
        .toList();
  }

  /// Check if any devices are selected
  bool get hasSelectedDevices => currentSelectedDevices.isNotEmpty;

  /// Check if all devices are selected
  bool get allDevicesSelected =>
      currentDevices.isNotEmpty &&
      currentSelectedDevices.length == currentDevices.length;
}
