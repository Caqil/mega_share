// lib/features/device_discovery/presentation/bloc/device_discovery_bloc.dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/bloc/base_bloc.dart';
import '../../domain/entities/discovery_result_entity.dart';
import '../../domain/repositories/device_discovery_repository.dart';
import '../../domain/usecases/start_advertising_usecase.dart';
import '../../domain/usecases/start_discovery_usecase.dart';
import '../../domain/usecases/stop_advertising_usecase.dart';
import '../../domain/usecases/stop_discovery_usecase.dart';
import 'device_discovery_event.dart';
import 'device_discovery_state.dart';

/// Device discovery BLoC
class DeviceDiscoveryBloc
    extends BaseBloc<DeviceDiscoveryEvent, DeviceDiscoveryState> {
  final StartDiscoveryUseCase _startDiscoveryUseCase;
  final StopDiscoveryUseCase _stopDiscoveryUseCase;
  final StartAdvertisingUseCase _startAdvertisingUseCase;
  final StopAdvertisingUseCase _stopAdvertisingUseCase;
  final DeviceDiscoveryRepository _repository;

  StreamSubscription<Either<Failure, DiscoveryResultEntity>>?
  _discoverySubscription;

  DeviceDiscoveryBloc({
    required StartDiscoveryUseCase startDiscoveryUseCase,
    required StopDiscoveryUseCase stopDiscoveryUseCase,
    required StartAdvertisingUseCase startAdvertisingUseCase,
    required StopAdvertisingUseCase stopAdvertisingUseCase,
    required DeviceDiscoveryRepository repository,
  }) : _startDiscoveryUseCase = startDiscoveryUseCase,
       _stopDiscoveryUseCase = stopDiscoveryUseCase,
       _startAdvertisingUseCase = startAdvertisingUseCase,
       _stopAdvertisingUseCase = stopAdvertisingUseCase,
       _repository = repository,
       super(const DeviceDiscoveryInitial()) {
    // Listen to discovery stream
    _discoverySubscription = _repository.discoveredDevicesStream.listen((
      result,
    ) {
      result.fold(
        (failure) => add(DeviceDiscoveryStreamError(failure)),
        (discoveryResult) => add(DeviceDiscoveryStreamUpdate(discoveryResult)),
      );
    });
  }

  @override
  Future<void> handleEvent(
    DeviceDiscoveryEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    switch (event) {
      case StartDiscoveryEvent():
        await _handleStartDiscovery(event, emit);
        break;
      case StopDiscoveryEvent():
        await _handleStopDiscovery(event, emit);
        break;
      case StartAdvertisingEvent():
        await _handleStartAdvertising(event, emit);
        break;
      case StopAdvertisingEvent():
        await _handleStopAdvertising(event, emit);
        break;
      case DeviceDiscoveryStreamUpdate():
        await _handleStreamUpdate(event, emit);
        break;
      case DeviceDiscoveryStreamError():
        await _handleStreamError(event, emit);
        break;
      case RefreshDiscoveryEvent():
        await _handleRefreshDiscovery(event, emit);
        break;
      case ClearDiscoveryCacheEvent():
        await _handleClearCache(event, emit);
        break;
      case SelectDeviceEvent():
        await _handleSelectDevice(event, emit);
        break;
      case DeselectDeviceEvent():
        await _handleDeselectDevice(event, emit);
        break;
      case ClearDeviceSelectionEvent():
        await _handleClearSelection(event, emit);
        break;
    }
  }

  Future<void> _handleStartDiscovery(
    StartDiscoveryEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    emit(
      DeviceDiscoveryLoading(
        isDiscovering: true,
        isAdvertising: _repository.isAdvertising,
        devices: _getCurrentDevices(),
        selectedDevices: _getSelectedDevices(),
      ),
    );

    final result = await _startDiscoveryUseCase(
      StartDiscoveryParams(method: event.method, timeout: event.timeout),
    );

    result.fold(
      (failure) => emit(
        DeviceDiscoveryError(
          failure: failure,
          isDiscovering: false,
          isAdvertising: _repository.isAdvertising,
          devices: _getCurrentDevices(),
          selectedDevices: _getSelectedDevices(),
        ),
      ),
      (_) {
        // Discovery started, wait for stream updates
        // State will be updated via stream listener
      },
    );
  }

  Future<void> _handleStopDiscovery(
    StopDiscoveryEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    final result = await _stopDiscoveryUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        DeviceDiscoveryError(
          failure: failure,
          isDiscovering: _repository.isDiscovering,
          isAdvertising: _repository.isAdvertising,
          devices: _getCurrentDevices(),
          selectedDevices: _getSelectedDevices(),
        ),
      ),
      (_) => emit(
        DeviceDiscoverySuccess(
          devices: _getCurrentDevices(),
          isDiscovering: false,
          isAdvertising: _repository.isAdvertising,
          selectedDevices: _getSelectedDevices(),
        ),
      ),
    );
  }

  Future<void> _handleStartAdvertising(
    StartAdvertisingEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    final result = await _startAdvertisingUseCase(
      StartAdvertisingParams(
        deviceName: event.deviceName,
        timeout: event.timeout,
      ),
    );

    result.fold(
      (failure) => emit(
        DeviceDiscoveryError(
          failure: failure,
          isDiscovering: _repository.isDiscovering,
          isAdvertising: false,
          devices: _getCurrentDevices(),
          selectedDevices: _getSelectedDevices(),
        ),
      ),
      (_) => emit(
        DeviceDiscoverySuccess(
          devices: _getCurrentDevices(),
          isDiscovering: _repository.isDiscovering,
          isAdvertising: true,
          selectedDevices: _getSelectedDevices(),
        ),
      ),
    );
  }

  Future<void> _handleStopAdvertising(
    StopAdvertisingEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    final result = await _stopAdvertisingUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        DeviceDiscoveryError(
          failure: failure,
          isDiscovering: _repository.isDiscovering,
          isAdvertising: _repository.isAdvertising,
          devices: _getCurrentDevices(),
          selectedDevices: _getSelectedDevices(),
        ),
      ),
      (_) => emit(
        DeviceDiscoverySuccess(
          devices: _getCurrentDevices(),
          isDiscovering: _repository.isDiscovering,
          isAdvertising: false,
          selectedDevices: _getSelectedDevices(),
        ),
      ),
    );
  }

  Future<void> _handleStreamUpdate(
    DeviceDiscoveryStreamUpdate event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    final discoveryResult = event.discoveryResult;

    if (discoveryResult.isActive) {
      emit(
        DeviceDiscoveryLoading(
          isDiscovering: true,
          isAdvertising: _repository.isAdvertising,
          devices: discoveryResult.devices,
          selectedDevices: _getSelectedDevices(),
          discoveryResult: discoveryResult,
        ),
      );
    } else if (discoveryResult.hasFailed) {
      emit(
        DeviceDiscoveryError(
          failure: ValidationFailure(
            discoveryResult.error ?? 'Discovery failed',
          ),
          isDiscovering: false,
          isAdvertising: _repository.isAdvertising,
          devices: discoveryResult.devices,
          selectedDevices: _getSelectedDevices(),
          discoveryResult: discoveryResult,
        ),
      );
    } else {
      emit(
        DeviceDiscoverySuccess(
          devices: discoveryResult.devices,
          isDiscovering: false,
          isAdvertising: _repository.isAdvertising,
          selectedDevices: _getSelectedDevices(),
          discoveryResult: discoveryResult,
        ),
      );
    }
  }

  Future<void> _handleStreamError(
    DeviceDiscoveryStreamError event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    emit(
      DeviceDiscoveryError(
        failure: event.failure,
        isDiscovering: false,
        isAdvertising: _repository.isAdvertising,
        devices: _getCurrentDevices(),
        selectedDevices: _getSelectedDevices(),
      ),
    );
  }

  Future<void> _handleRefreshDiscovery(
    RefreshDiscoveryEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    // Stop current discovery if running
    if (_repository.isDiscovering) {
      await _stopDiscoveryUseCase(const NoParams());
    }

    // Clear cache
    await _repository.clearDiscoveryCache();

    // Start new discovery
    await _handleStartDiscovery(
      StartDiscoveryEvent(method: event.method, timeout: event.timeout),
      emit,
    );
  }

  Future<void> _handleClearCache(
    ClearDiscoveryCacheEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    final result = await _repository.clearDiscoveryCache();

    result.fold(
      (failure) => emit(
        DeviceDiscoveryError(
          failure: failure,
          isDiscovering: _repository.isDiscovering,
          isAdvertising: _repository.isAdvertising,
          devices: [],
          selectedDevices: [],
        ),
      ),
      (_) => emit(
        DeviceDiscoverySuccess(
          devices: [],
          isDiscovering: _repository.isDiscovering,
          isAdvertising: _repository.isAdvertising,
          selectedDevices: [],
        ),
      ),
    );
  }

  Future<void> _handleSelectDevice(
    SelectDeviceEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DeviceDiscoverySuccess) return;

    final selectedDevices = Set<String>.from(currentState.selectedDevices);
    selectedDevices.add(event.deviceId);

    emit(currentState.copyWith(selectedDevices: selectedDevices.toList()));
  }

  Future<void> _handleDeselectDevice(
    DeselectDeviceEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DeviceDiscoverySuccess) return;

    final selectedDevices = Set<String>.from(currentState.selectedDevices);
    selectedDevices.remove(event.deviceId);

    emit(currentState.copyWith(selectedDevices: selectedDevices.toList()));
  }

  Future<void> _handleClearSelection(
    ClearDeviceSelectionEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    final currentState = state;
    if (currentState is DeviceDiscoverySuccess) {
      emit(currentState.copyWith(selectedDevices: []));
    }
  }

  List<DeviceEntity> _getCurrentDevices() {
    return state.maybeWhen(
      success: (devices, _, __, ___, ____) => devices,
      loading: (devices, _, __, ___, ____) => devices,
      error: (devices, _, __, ___, ____, _____) => devices,
      orElse: () => [],
    );
  }

  List<String> _getSelectedDevices() {
    return state.maybeWhen(
      success: (_, __, ___, ____, selectedDevices) => selectedDevices,
      loading: (_, __, ___, ____, selectedDevices) => selectedDevices,
      error: (_, __, ___, ____, _____, selectedDevices) => selectedDevices,
      orElse: () => [],
    );
  }

  @override
  DeviceDiscoveryState? createLoadingState(String? message) {
    return DeviceDiscoveryLoading(
      isDiscovering: _repository.isDiscovering,
      isAdvertising: _repository.isAdvertising,
      devices: _getCurrentDevices(),
      selectedDevices: _getSelectedDevices(),
    );
  }

  @override
  DeviceDiscoveryState? createSuccessState({dynamic data, String? message}) {
    return DeviceDiscoverySuccess(
      devices: data ?? _getCurrentDevices(),
      isDiscovering: _repository.isDiscovering,
      isAdvertising: _repository.isAdvertising,
      selectedDevices: _getSelectedDevices(),
    );
  }

  @override
  DeviceDiscoveryState? createErrorState(Failure failure, {String? message}) {
    return DeviceDiscoveryError(
      failure: failure,
      isDiscovering: _repository.isDiscovering,
      isAdvertising: _repository.isAdvertising,
      devices: _getCurrentDevices(),
      selectedDevices: _getSelectedDevices(),
    );
  }

  @override
  Future<void> close() {
    _discoverySubscription?.cancel();
    return super.close();
  }
}
