// lib/features/device_discovery/presentation/bloc/device_discovery_bloc.dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/discovery_result_entity.dart';
import '../../domain/repositories/device_discovery_repository.dart';
import '../../domain/usecases/start_advertising_usecase.dart';
import '../../domain/usecases/start_discovery_usecase.dart';
import '../../domain/usecases/stop_advertising_usecase.dart';
import '../../domain/usecases/stop_discovery_usecase.dart';
import 'device_discovery_event.dart';
import 'device_discovery_state.dart';

/// Device discovery BLoC
class DeviceDiscoveryBloc extends Bloc<DeviceDiscoveryEvent, DeviceDiscoveryState> {
  final StartDiscoveryUseCase _startDiscoveryUseCase;
  final StopDiscoveryUseCase _stopDiscoveryUseCase;
  final StartAdvertisingUseCase _startAdvertisingUseCase;
  final StopAdvertisingUseCase _stopAdvertisingUseCase;
  final DeviceDiscoveryRepository _repository;

  StreamSubscription<Either<dynamic, DiscoveryResultEntity>>? _discoverySubscription;

  DeviceDiscoveryBloc({
    required StartDiscoveryUseCase startDiscoveryUseCase,
    required StopDiscoveryUseCase stopDiscoveryUseCase,
    required StartAdvertisingUseCase startAdvertisingUseCase,
    required StopAdvertisingUseCase stopAdvertisingUseCase,
    required DeviceDiscoveryRepository repository,
  })  : _startDiscoveryUseCase = startDiscoveryUseCase,
        _stopDiscoveryUseCase = stopDiscoveryUseCase,
        _startAdvertisingUseCase = startAdvertisingUseCase,
        _stopAdvertisingUseCase = stopAdvertisingUseCase,
        _repository = repository,
        super(const DeviceDiscoveryState()) {
    
    on<StartDiscoveryEvent>(_onStartDiscovery);
    on<StopDiscoveryEvent>(_onStopDiscovery);
    on<StartAdvertisingEvent>(_onStartAdvertising);
    on<StopAdvertisingEvent>(_onStopAdvertising);
    on<DeviceDiscoveryStreamUpdate>(_onDiscoveryStreamUpdate);
    on<DeviceDiscoveryStreamError>(_onDiscoveryStreamError);
    on<RefreshDiscoveryEvent>(_onRefreshDiscovery);
    on<ClearDiscoveryCacheEvent>(_onClearDiscoveryCache);
    on<SelectDeviceEvent>(_onSelectDevice);
    on<DeselectDeviceEvent>(_onDeselectDevice);
    on<ClearDeviceSelectionEvent>(_onClearDeviceSelection);

    _initializeDiscoveryStream();
  }

  void _initializeDiscoveryStream() {
    _discoverySubscription = _repository.discoveredDevicesStream.listen(
      (result) {
        result.fold(
          (failure) => add(DeviceDiscoveryStreamError(failure)),
          (discoveryResult) => add(DeviceDiscoveryStreamUpdate(discoveryResult)),
        );
      },
    );
  }

  Future<void> _onStartDiscovery(
    StartDiscoveryEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    if (state.isDiscovering) {
      LoggerService.instance.warning('Discovery already in progress');
      return;
    }

    emit(state.copyWith(
      status: DeviceDiscoveryStatus.starting,
      error: null,
    ));

    try {
      final params = StartDiscoveryParams(
        method: event.method,
        timeout: event.timeout,
      );

      final result = await _startDiscoveryUseCase(params);

      result.fold(
        (failure) {
          LoggerService.instance.error('Failed to start discovery: ${failure.message}');
          emit(state.copyWith(
            status: DeviceDiscoveryStatus.error,
            error: failure.message,
            isDiscovering: false,
          ));
        },
        (_) {
          LoggerService.instance.info('Discovery started successfully');
          emit(state.copyWith(
            status: DeviceDiscoveryStatus.discovering,
            isDiscovering: true,
            error: null,
            discoveryMethod: event.method,
          ));
        },
      );
    } catch (e) {
      LoggerService.instance.error('Unexpected error starting discovery: $e');
      emit(state.copyWith(
        status: DeviceDiscoveryStatus.error,
        error: 'Unexpected error: ${e.toString()}',
        isDiscovering: false,
      ));
    }
  }

  Future<void> _onStopDiscovery(
    StopDiscoveryEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    if (!state.isDiscovering) {
      LoggerService.instance.warning('Discovery not in progress');
      return;
    }

    emit(state.copyWith(status: DeviceDiscoveryStatus.stopping));

    try {
      final result = await _stopDiscoveryUseCase(const NoParams());

      result.fold(
        (failure) {
          LoggerService.instance.error('Failed to stop discovery: ${failure.message}');
          emit(state.copyWith(
            status: DeviceDiscoveryStatus.error,
            error: failure.message,
          ));
        },
        (_) {
          LoggerService.instance.info('Discovery stopped successfully');
          emit(state.copyWith(
            status: DeviceDiscoveryStatus.idle,
            isDiscovering: false,
            error: null,
          ));
        },
      );
    } catch (e) {
      LoggerService.instance.error('Unexpected error stopping discovery: $e');
      emit(state.copyWith(
        status: DeviceDiscoveryStatus.error,
        error: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onStartAdvertising(
    StartAdvertisingEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    if (state.isAdvertising) {
      LoggerService.instance.warning('Advertising already active');
      return;
    }

    emit(state.copyWith(advertisingStatus: AdvertisingStatus.starting));

    try {
      final params = StartAdvertisingParams(
        deviceName: event.deviceName,
        timeout: event.timeout,
      );

      final result = await _startAdvertisingUseCase(params);

      result.fold(
        (failure) {
          LoggerService.instance.error('Failed to start advertising: ${failure.message}');
          emit(state.copyWith(
            advertisingStatus: AdvertisingStatus.error,
            advertisingError: failure.message,
            isAdvertising: false,
          ));
        },
        (_) {
          LoggerService.instance.info('Advertising started successfully');
          emit(state.copyWith(
            advertisingStatus: AdvertisingStatus.advertising,
            isAdvertising: true,
            advertisingError: null,
          ));
        },
      );
    } catch (e) {
      LoggerService.instance.error('Unexpected error starting advertising: $e');
      emit(state.copyWith(
        advertisingStatus: AdvertisingStatus.error,
        advertisingError: 'Unexpected error: ${e.toString()}',
        isAdvertising: false,
      ));
    }
  }

  Future<void> _onStopAdvertising(
    StopAdvertisingEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    if (!state.isAdvertising) {
      LoggerService.instance.warning('Advertising not active');
      return;
    }

    emit(state.copyWith(advertisingStatus: AdvertisingStatus.stopping));

    try {
      final result = await _stopAdvertisingUseCase(const NoParams());

      result.fold(
        (failure) {
          LoggerService.instance.error('Failed to stop advertising: ${failure.message}');
          emit(state.copyWith(
            advertisingStatus: AdvertisingStatus.error,
            advertisingError: failure.message,
          ));
        },
        (_) {
          LoggerService.instance.info('Advertising stopped successfully');
          emit(state.copyWith(
            advertisingStatus: AdvertisingStatus.idle,
            isAdvertising: false,
            advertisingError: null,
          ));
        },
      );
    } catch (e) {
      LoggerService.instance.error('Unexpected error stopping advertising: $e');
      emit(state.copyWith(
        advertisingStatus: AdvertisingStatus.error,
        advertisingError: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  void _onDiscoveryStreamUpdate(
    DeviceDiscoveryStreamUpdate event,
    Emitter<DeviceDiscoveryState> emit,
  ) {
    final discoveryResult = event.discoveryResult;
    
    emit(state.copyWith(
      discoveryResult: discoveryResult,
      devices: discoveryResult.devices,
      status: discoveryResult.isActive 
          ? DeviceDiscoveryStatus.discovering 
          : DeviceDiscoveryStatus.completed,
      isDiscovering: discoveryResult.isActive,
      lastUpdated: DateTime.now(),
      error: discoveryResult.error,
    ));

    LoggerService.instance.debug(
      'Discovery update: ${discoveryResult.deviceCount} devices found',
    );
  }

  void _onDiscoveryStreamError(
    DeviceDiscoveryStreamError event,
    Emitter<DeviceDiscoveryState> emit,
  ) {
    LoggerService.instance.error('Discovery stream error: ${event.failure.message}');
    
    emit(state.copyWith(
      status: DeviceDiscoveryStatus.error,
      error: event.failure.message,
      isDiscovering: false,
    ));
  }

  Future<void> _onRefreshDiscovery(
    RefreshDiscoveryEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    if (state.isDiscovering) {
      // Stop current discovery first
      add(const StopDiscoveryEvent());
      // Wait a bit for stop to complete
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Start new discovery
    add(StartDiscoveryEvent(
      method: event.method,
      timeout: event.timeout,
    ));
  }

  Future<void> _onClearDiscoveryCache(
    ClearDiscoveryCacheEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) async {
    try {
      final result = await _repository.clearDiscoveryCache();
      
      result.fold(
        (failure) {
          LoggerService.instance.error('Failed to clear cache: ${failure.message}');
          emit(state.copyWith(
            error: failure.message,
          ));
        },
        (_) {
          LoggerService.instance.info('Discovery cache cleared');
          emit(state.copyWith(
            devices: [],
            discoveryResult: null,
            selectedDevices: {},
            error: null,
          ));
        },
      );
    } catch (e) {
      LoggerService.instance.error('Unexpected error clearing cache: $e');
      emit(state.copyWith(
        error: 'Failed to clear cache: ${e.toString()}',
      ));
    }
  }

  void _onSelectDevice(
    SelectDeviceEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) {
    final device = state.devices.firstWhere(
      (d) => d.id == event.deviceId,
      orElse: () => throw StateError('Device not found: ${event.deviceId}'),
    );

    final updatedSelection = Map<String, DeviceEntity>.from(state.selectedDevices);
    updatedSelection[event.deviceId] = device;

    emit(state.copyWith(selectedDevices: updatedSelection));
    
    LoggerService.instance.debug('Device selected: ${device.name}');
  }

  void _onDeselectDevice(
    DeselectDeviceEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) {
    final updatedSelection = Map<String, DeviceEntity>.from(state.selectedDevices);
    updatedSelection.remove(event.deviceId);

    emit(state.copyWith(selectedDevices: updatedSelection));
    
    LoggerService.instance.debug('Device deselected: ${event.deviceId}');
  }

  void _onClearDeviceSelection(
    ClearDeviceSelectionEvent event,
    Emitter<DeviceDiscoveryState> emit,
  ) {
    emit(state.copyWith(selectedDevices: {}));
    LoggerService.instance.debug('Device selection cleared');
  }

  @override
  Future<void> close() {
    _discoverySubscription?.cancel();
    return super.close();
  }
}