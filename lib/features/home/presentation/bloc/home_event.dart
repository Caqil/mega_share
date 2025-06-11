import '../../../../shared/bloc/base_event.dart';

/// Home feature events
sealed class HomeEvent extends BaseEvent {
  const HomeEvent();
}

/// Load home data event
class LoadHomeDataEvent extends HomeEvent {
  final bool forceRefresh;

  const LoadHomeDataEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Refresh home data event
class RefreshHomeDataEvent extends HomeEvent {
  const RefreshHomeDataEvent();
}

/// Update device status event
class UpdateDeviceStatusEvent extends HomeEvent {
  final bool isDiscovering;
  final bool isAdvertising;
  final int connectedDevicesCount;

  const UpdateDeviceStatusEvent({
    required this.isDiscovering,
    required this.isAdvertising,
    required this.connectedDevicesCount,
  });

  @override
  List<Object?> get props => [
    isDiscovering,
    isAdvertising,
    connectedDevicesCount,
  ];
}

/// Update storage info event
class UpdateStorageInfoEvent extends HomeEvent {
  final int usedSpace;
  final int totalSpace;

  const UpdateStorageInfoEvent({
    required this.usedSpace,
    required this.totalSpace,
  });

  @override
  List<Object?> get props => [usedSpace, totalSpace];
}

/// Update transfer progress event
class UpdateTransferProgressEvent extends HomeEvent {
  final int activeTransfers;
  final double overallProgress;

  const UpdateTransferProgressEvent({
    required this.activeTransfers,
    required this.overallProgress,
  });

  @override
  List<Object?> get props => [activeTransfers, overallProgress];
}

/// Update permissions status event
class UpdatePermissionsStatusEvent extends HomeEvent {
  final bool hasRequiredPermissions;
  final List<String> missingPermissions;

  const UpdatePermissionsStatusEvent({
    required this.hasRequiredPermissions,
    required this.missingPermissions,
  });

  @override
  List<Object?> get props => [hasRequiredPermissions, missingPermissions];
}

/// Navigate to feature event
class NavigateToFeatureEvent extends HomeEvent {
  final String feature;
  final Map<String, dynamic>? arguments;

  const NavigateToFeatureEvent(this.feature, {this.arguments});

  @override
  List<Object?> get props => [feature, arguments];
}

/// Clear transfer history event
class ClearTransferHistoryEvent extends HomeEvent {
  const ClearTransferHistoryEvent();
}

/// Request permissions event
class RequestPermissionsEvent extends HomeEvent {
  const RequestPermissionsEvent();
}

/// Quick action event
class QuickActionEvent extends HomeEvent {
  final QuickActionType actionType;

  const QuickActionEvent(this.actionType);

  @override
  List<Object?> get props => [actionType];
}

/// Quick action types
enum QuickActionType {
  sendFiles,
  receiveFiles,
  scanQR,
  openFileManager,
  startDiscovery,
  viewHistory,
  requestPermissions,
}
