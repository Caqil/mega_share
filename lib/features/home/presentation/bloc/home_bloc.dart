import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/device_info_utils.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/bloc/base_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
  final StorageService _storageService;
  final PermissionService _permissionService;
  final LoggerService _logger;

  StreamSubscription? _permissionSubscription;
  Timer? _dataRefreshTimer;

  HomeBloc({
    StorageService? storageService,
    PermissionService? permissionService,
    LoggerService? logger,
  }) : _storageService = storageService ?? StorageService.instance,
       _permissionService = permissionService ?? PermissionService.instance,
       _logger = logger ?? LoggerService.instance,
       super(const HomeInitialState()) {
    // Listen to permission changes
    _permissionSubscription = _permissionService.permissionStatusStream.listen(
      (status) => add(const RefreshHomeDataEvent()),
    );

    // Set up periodic data refresh
    _dataRefreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => add(const RefreshHomeDataEvent()),
    );
  }

  @override
  Future<void> handleEvent(HomeEvent event, Emitter<HomeState> emit) async {
    switch (event) {
      case LoadHomeDataEvent():
        await _handleLoadHomeData(event, emit);
        break;
      case RefreshHomeDataEvent():
        await _handleRefreshHomeData(emit);
        break;
      case UpdateDeviceStatusEvent():
        await _handleUpdateDeviceStatus(event, emit);
        break;
      case UpdateStorageInfoEvent():
        await _handleUpdateStorageInfo(event, emit);
        break;
      case UpdateTransferProgressEvent():
        await _handleUpdateTransferProgress(event, emit);
        break;
      case UpdatePermissionsStatusEvent():
        await _handleUpdatePermissionsStatus(event, emit);
        break;
      case NavigateToFeatureEvent():
        await _handleNavigateToFeature(event, emit);
        break;
      case ClearTransferHistoryEvent():
        await _handleClearTransferHistory(emit);
        break;
      case RequestPermissionsEvent():
        await _handleRequestPermissions(emit);
        break;
      case QuickActionEvent():
        await _handleQuickAction(event, emit);
        break;
    }
  }

  Future<void> _handleLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      if (!event.forceRefresh && state is HomeLoadedState) {
        return; // Don't reload if already loaded unless forced
      }

      emitLoading(emit, message: 'Loading home data...');

      final homeData = await _loadHomeData();

      emit(HomeLoadedState(data: homeData));
    } catch (e) {
      final failure = Failure('Failed to load home data: $e');
      emitError(emit, failure);
    }
  }

  Future<void> _handleRefreshHomeData(Emitter<HomeState> emit) async {
    try {
      final homeData = await _loadHomeData();

      if (state is HomeLoadedState) {
        emit(HomeDataUpdatedState(data: homeData));
      } else {
        emit(HomeLoadedState(data: homeData));
      }
    } catch (e) {
      _logger.error('Failed to refresh home data: $e');
      // Don't emit error for refresh failures
    }
  }

  Future<void> _handleUpdateDeviceStatus(
    UpdateDeviceStatusEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final currentData = _getCurrentHomeData();
      if (currentData == null) return;

      final updatedDeviceStatus = currentData.deviceStatus.copyWith(
        isDiscovering: event.isDiscovering,
        isAdvertising: event.isAdvertising,
        connectedDevicesCount: event.connectedDevicesCount,
      );

      final updatedData = currentData.copyWith(
        deviceStatus: updatedDeviceStatus,
        lastUpdated: DateTime.now(),
      );

      emit(HomeDataUpdatedState(data: updatedData));
    } catch (e) {
      _logger.error('Failed to update device status: $e');
    }
  }

  Future<void> _handleUpdateStorageInfo(
    UpdateStorageInfoEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final currentData = _getCurrentHomeData();
      if (currentData == null) return;

      final availableSpace = event.totalSpace - event.usedSpace;
      final usagePercentage = event.totalSpace > 0
          ? (event.usedSpace / event.totalSpace) * 100
          : 0.0;

      final updatedStorageStatus = StorageStatus(
        usedSpace: event.usedSpace,
        totalSpace: event.totalSpace,
        availableSpace: availableSpace,
        usagePercentage: usagePercentage,
        filesCount: currentData.storageStatus.filesCount,
        foldersCount: currentData.storageStatus.foldersCount,
      );

      final updatedData = currentData.copyWith(
        storageStatus: updatedStorageStatus,
        lastUpdated: DateTime.now(),
      );

      emit(HomeDataUpdatedState(data: updatedData));
    } catch (e) {
      _logger.error('Failed to update storage info: $e');
    }
  }

  Future<void> _handleUpdateTransferProgress(
    UpdateTransferProgressEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final currentData = _getCurrentHomeData();
      if (currentData == null) return;

      final updatedTransferStatus = TransferStatus(
        activeTransfers: event.activeTransfers,
        overallProgress: event.overallProgress,
        completedToday: currentData.transferStatus.completedToday,
        totalTransfers: currentData.transferStatus.totalTransfers,
        averageSpeed: currentData.transferStatus.averageSpeed,
        hasActiveTransfers: event.activeTransfers > 0,
      );

      final updatedData = currentData.copyWith(
        transferStatus: updatedTransferStatus,
        lastUpdated: DateTime.now(),
      );

      emit(HomeDataUpdatedState(data: updatedData));
    } catch (e) {
      _logger.error('Failed to update transfer progress: $e');
    }
  }

  Future<void> _handleUpdatePermissionsStatus(
    UpdatePermissionsStatusEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final currentData = _getCurrentHomeData();
      if (currentData == null) return;

      final updatedPermissionStatus = PermissionStatus(
        hasAllPermissions: event.hasRequiredPermissions,
        hasStoragePermission: !event.missingPermissions.contains('storage'),
        hasLocationPermission: !event.missingPermissions.contains('location'),
        hasCameraPermission: !event.missingPermissions.contains('camera'),
        hasNotificationPermission: !event.missingPermissions.contains(
          'notification',
        ),
        missingPermissions: event.missingPermissions,
      );

      final updatedData = currentData.copyWith(
        permissionStatus: updatedPermissionStatus,
        lastUpdated: DateTime.now(),
      );

      emit(HomeDataUpdatedState(data: updatedData));
    } catch (e) {
      _logger.error('Failed to update permission status: $e');
    }
  }

  Future<void> _handleNavigateToFeature(
    NavigateToFeatureEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      _logger.info('Navigating to feature: ${event.feature}');
      emit(HomeNavigationState(event.feature, arguments: event.arguments));
    } catch (e) {
      _logger.error('Failed to navigate to feature: $e');
    }
  }

  Future<void> _handleClearTransferHistory(Emitter<HomeState> emit) async {
    try {
      await _storageService.clearTransferHistory();

      final currentData = _getCurrentHomeData();
      if (currentData != null) {
        final updatedData = currentData.copyWith(
          recentTransfers: [],
          lastUpdated: DateTime.now(),
        );
        emit(
          HomeDataUpdatedState(
            data: updatedData,
            updateMessage: 'Transfer history cleared',
          ),
        );
      }

      _logger.info('Transfer history cleared');
    } catch (e) {
      final failure = Failure('Failed to clear transfer history: $e');
      emitError(emit, failure);
    }
  }

  Future<void> _handleRequestPermissions(Emitter<HomeState> emit) async {
    try {
      final granted = await _permissionService
          .requestNearbyDevicesPermissions(); // _permissionService.requestCriticalPermissions();

      if (granted) {
        add(const RefreshHomeDataEvent());
      } else {
        final failure = Failure('Failed to grant required permissions');
        emitError(emit, failure);
      }
    } catch (e) {
      final failure = Failure('Error requesting permissions: $e');
      emitError(emit, failure);
    }
  }

  Future<void> _handleQuickAction(
    QuickActionEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      String destination;
      Map<String, dynamic>? arguments;

      switch (event.actionType) {
        case QuickActionType.sendFiles:
          destination = '/file-selection';
          arguments = {'mode': 'send'};
          break;
        case QuickActionType.receiveFiles:
          destination = '/receive';
          break;
        case QuickActionType.scanQR:
          destination = '/qr-scanner';
          break;
        case QuickActionType.openFileManager:
          destination = '/file-manager';
          break;
        case QuickActionType.startDiscovery:
          destination = '/discovery';
          break;
        case QuickActionType.viewHistory:
          destination = '/transfer-history';
          break;
        case QuickActionType.requestPermissions:
          // TODO: Handle this case.
          throw UnimplementedError();
      }

      emit(HomeNavigationState(destination, arguments: arguments));
    } catch (e) {
      _logger.error('Failed to handle quick action: $e');
    }
  }

  Future<HomeData> _loadHomeData() async {
    try {
      // Load device info
      final deviceInfo = await DeviceInfoUtils.getDeviceInfo();
      final deviceName = _storageService.getDeviceName();

      // Load storage info
      final storageInfo = await _storageService.getStorageInfo();

      // Load permission status
      final permissionDetails = await _permissionService
          .getDetailedPermissionStatus();

      // Load transfer history
      final transferHistory = _storageService.getTransferHistory();

      // Create device status
      final deviceStatus = DeviceStatus(
        deviceName: deviceName,
        isDiscovering: false, // Will be updated by discovery service
        isAdvertising: false, // Will be updated by discovery service
        connectedDevicesCount: 0, // Will be updated by connection service
        nearbyDevicesCount: 0, // Will be updated by discovery service
        isWiFiEnabled: true, // Assume enabled by default
        isBluetoothEnabled: true, // Assume enabled by default
      );

      // Create storage status
      final storageStatus = StorageStatus(
        usedSpace: storageInfo.totalUsed,
        totalSpace: storageInfo.totalUsed + 1000000000, // Mock total space
        availableSpace: 1000000000 - storageInfo.totalUsed,
        usagePercentage: (storageInfo.totalUsed / 1000000000) * 100,
        filesCount: 0, // Will be calculated if needed
        foldersCount: 0, // Will be calculated if needed
      );

      // Create transfer status
      final today = DateTime.now();
      final todayTransfers = transferHistory.where((transfer) {
        final transferDate = DateTime.tryParse(transfer['timestamp'] ?? '');
        return transferDate != null &&
            transferDate.year == today.year &&
            transferDate.month == today.month &&
            transferDate.day == today.day;
      }).length;

      final transferStatus = TransferStatus(
        activeTransfers: 0, // Will be updated by transfer service
        overallProgress: 0.0, // Will be updated by transfer service
        completedToday: todayTransfers,
        totalTransfers: transferHistory.length,
        averageSpeed: 0.0, // Will be calculated from transfer data
        hasActiveTransfers: false,
      );

      // Create permission status
      final permissionStatus = PermissionStatus(
        hasAllPermissions: permissionDetails.values.every((granted) => granted),
        hasStoragePermission: permissionDetails['storage'] ?? false,
        hasLocationPermission: permissionDetails['location'] ?? false,
        hasCameraPermission: permissionDetails['camera'] ?? false,
        hasNotificationPermission: permissionDetails['notification'] ?? false,
        missingPermissions: permissionDetails.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList(),
      );

      // Create recent transfers
      final recentTransfers = transferHistory
          .take(5)
          .map(
            (transfer) => RecentTransfer(
              id: transfer['id'] ?? '',
              fileName: transfer['fileName'] ?? 'Unknown',
              fileSize: transfer['fileSize'] ?? 0,
              deviceName: transfer['deviceName'] ?? 'Unknown Device',
              direction: transfer['direction'] == 'send'
                  ? TransferDirection.send
                  : TransferDirection.receive,
              status: _parseTransferStatus(transfer['status']),
              timestamp:
                  DateTime.tryParse(transfer['timestamp'] ?? '') ??
                  DateTime.now(),
              duration: transfer['duration'] != null
                  ? Duration(milliseconds: transfer['duration'])
                  : null,
            ),
          )
          .toList();

      return HomeData(
        deviceStatus: deviceStatus,
        storageStatus: storageStatus,
        transferStatus: transferStatus,
        permissionStatus: permissionStatus,
        recentTransfers: recentTransfers,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      _logger.error('Error loading home data: $e');
      rethrow;
    }
  }

  TransferResult _parseTransferStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'completed':
      case 'success':
        return TransferResult.success;
      case 'failed':
      case 'error':
        return TransferResult.failed;
      case 'cancelled':
        return TransferResult.cancelled;
      case 'in_progress':
      case 'transferring':
        return TransferResult.inProgress;
      default:
        return TransferResult.failed;
    }
  }

  HomeData? _getCurrentHomeData() {
    final currentState = state;
    if (currentState is HomeLoadedState) {
      return currentState.data;
    } else if (currentState is HomeDataUpdatedState) {
      return currentState.data;
    }
    return null;
  }

  @override
  HomeState? createLoadingState(String? message) {
    return HomeLoadingState(loadingMessage: message);
  }

  @override
  HomeState? createSuccessState({dynamic data, String? message}) {
    if (data is HomeData) {
      return HomeLoadedState(data: data, successMessage: message);
    }
    return null;
  }

  @override
  HomeState? createErrorState(Failure failure, {String? message}) {
    return HomeErrorState(failure, errorMessage: message);
  }

  @override
  Future<void> close() {
    _permissionSubscription?.cancel();
    _dataRefreshTimer?.cancel();
    return super.close();
  }
}

// Extension to add copyWith to DeviceStatus
extension DeviceStatusExtension on DeviceStatus {
  DeviceStatus copyWith({
    String? deviceName,
    bool? isDiscovering,
    bool? isAdvertising,
    int? connectedDevicesCount,
    int? nearbyDevicesCount,
    bool? isWiFiEnabled,
    bool? isBluetoothEnabled,
  }) {
    return DeviceStatus(
      deviceName: deviceName ?? this.deviceName,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      isAdvertising: isAdvertising ?? this.isAdvertising,
      connectedDevicesCount:
          connectedDevicesCount ?? this.connectedDevicesCount,
      nearbyDevicesCount: nearbyDevicesCount ?? this.nearbyDevicesCount,
      isWiFiEnabled: isWiFiEnabled ?? this.isWiFiEnabled,
      isBluetoothEnabled: isBluetoothEnabled ?? this.isBluetoothEnabled,
    );
  }
}
