import '../../../../core/errors/failures.dart';
import '../../../../shared/bloc/base_state.dart';

/// Home feature states
sealed class HomeState extends BaseState {
  const HomeState();
}

/// Initial home state
class HomeInitialState extends HomeState {
  const HomeInitialState();
}

/// Loading home data state
class HomeLoadingState extends HomeState with LoadingState {
  @override
  final String? loadingMessage;

  const HomeLoadingState({this.loadingMessage});

  @override
  List<Object?> get props => [loadingMessage];
}

/// Home data loaded state
class HomeLoadedState extends HomeState with SuccessState<HomeData> {
  @override
  final HomeData data;
  @override
  final String? successMessage;

  const HomeLoadedState({required this.data, this.successMessage});

  @override
  List<Object?> get props => [data, successMessage];
}

/// Home error state
class HomeErrorState extends HomeState with ErrorState {
  @override
  final Failure failure;
  @override
  final String? errorMessage;

  const HomeErrorState(this.failure, {this.errorMessage});

  @override
  List<Object?> get props => [failure, errorMessage];
}

/// Home data updated state
class HomeDataUpdatedState extends HomeState {
  final HomeData data;
  final String? updateMessage;

  const HomeDataUpdatedState({required this.data, this.updateMessage});

  @override
  List<Object?> get props => [data, updateMessage];
}

/// Navigation triggered state
class HomeNavigationState extends HomeState {
  final String destination;
  final Map<String, dynamic>? arguments;

  const HomeNavigationState(this.destination, {this.arguments});

  @override
  List<Object?> get props => [destination, arguments];
}

/// Home data model
class HomeData {
  final DeviceStatus deviceStatus;
  final StorageStatus storageStatus;
  final TransferStatus transferStatus;
  final PermissionStatus permissionStatus;
  final List<RecentTransfer> recentTransfers;
  final DateTime lastUpdated;

  const HomeData({
    required this.deviceStatus,
    required this.storageStatus,
    required this.transferStatus,
    required this.permissionStatus,
    required this.recentTransfers,
    required this.lastUpdated,
  });

  HomeData copyWith({
    DeviceStatus? deviceStatus,
    StorageStatus? storageStatus,
    TransferStatus? transferStatus,
    PermissionStatus? permissionStatus,
    List<RecentTransfer>? recentTransfers,
    DateTime? lastUpdated,
  }) {
    return HomeData(
      deviceStatus: deviceStatus ?? this.deviceStatus,
      storageStatus: storageStatus ?? this.storageStatus,
      transferStatus: transferStatus ?? this.transferStatus,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      recentTransfers: recentTransfers ?? this.recentTransfers,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Device status data
class DeviceStatus {
  final String deviceName;
  final bool isDiscovering;
  final bool isAdvertising;
  final int connectedDevicesCount;
  final int nearbyDevicesCount;
  final bool isWiFiEnabled;
  final bool isBluetoothEnabled;

  const DeviceStatus({
    required this.deviceName,
    required this.isDiscovering,
    required this.isAdvertising,
    required this.connectedDevicesCount,
    required this.nearbyDevicesCount,
    required this.isWiFiEnabled,
    required this.isBluetoothEnabled,
  });

  bool get isActive =>
      isDiscovering || isAdvertising || connectedDevicesCount > 0;

  DeviceConnectionState get connectionState {
    if (connectedDevicesCount > 0) return DeviceConnectionState.connected;
    if (isDiscovering || isAdvertising)
      return DeviceConnectionState.discovering;
    if (isWiFiEnabled || isBluetoothEnabled) return DeviceConnectionState.ready;
    return DeviceConnectionState.disabled;
  }
}

/// Storage status data
class StorageStatus {
  final int usedSpace;
  final int totalSpace;
  final int availableSpace;
  final double usagePercentage;
  final int filesCount;
  final int foldersCount;

  const StorageStatus({
    required this.usedSpace,
    required this.totalSpace,
    required this.availableSpace,
    required this.usagePercentage,
    required this.filesCount,
    required this.foldersCount,
  });

  StorageLevel get level {
    if (usagePercentage >= 95) return StorageLevel.critical;
    if (usagePercentage >= 85) return StorageLevel.high;
    if (usagePercentage >= 70) return StorageLevel.medium;
    return StorageLevel.low;
  }

  bool get hasEnoughSpace => availableSpace > 100 * 1024 * 1024; // 100MB
}

/// Transfer status data
class TransferStatus {
  final int activeTransfers;
  final double overallProgress;
  final int completedToday;
  final int totalTransfers;
  final double averageSpeed;
  final bool hasActiveTransfers;

  const TransferStatus({
    required this.activeTransfers,
    required this.overallProgress,
    required this.completedToday,
    required this.totalTransfers,
    required this.averageSpeed,
    required this.hasActiveTransfers,
  });

  TransferStatusLevel get level {
    if (activeTransfers > 5) return TransferStatusLevel.high;
    if (activeTransfers > 2) return TransferStatusLevel.medium;
    if (activeTransfers > 0) return TransferStatusLevel.low;
    return TransferStatusLevel.idle;
  }
}

/// Permission status data
class PermissionStatus {
  final bool hasAllPermissions;
  final bool hasStoragePermission;
  final bool hasLocationPermission;
  final bool hasCameraPermission;
  final bool hasNotificationPermission;
  final List<String> missingPermissions;

  const PermissionStatus({
    required this.hasAllPermissions,
    required this.hasStoragePermission,
    required this.hasLocationPermission,
    required this.hasCameraPermission,
    required this.hasNotificationPermission,
    required this.missingPermissions,
  });

  bool get hasCriticalPermissions =>
      hasStoragePermission && hasLocationPermission;

  PermissionLevel get level {
    if (hasAllPermissions) return PermissionLevel.complete;
    if (hasCriticalPermissions) return PermissionLevel.partial;
    return PermissionLevel.missing;
  }
}

/// Recent transfer data
class RecentTransfer {
  final String id;
  final String fileName;
  final int fileSize;
  final String deviceName;
  final TransferDirection direction;
  final TransferResult status;
  final DateTime timestamp;
  final Duration? duration;

  const RecentTransfer({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.deviceName,
    required this.direction,
    required this.status,
    required this.timestamp,
    this.duration,
  });
}

/// Enumerations
enum DeviceConnectionState { connected, discovering, ready, disabled }

enum StorageLevel { low, medium, high, critical }

enum TransferStatusLevel { idle, low, medium, high }

enum PermissionLevel { missing, partial, complete }

enum TransferDirection { send, receive }

enum TransferResult { success, failed, cancelled, inProgress }
