import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/connection_entity.dart';
import '../../domain/entities/connection_info_entity.dart';
import '../../domain/usecases/get_connection_info_usecase.dart';
import '../../domain/usecases/connect_to_device_usecase.dart';
import '../../domain/usecases/accept_connection_usecase.dart';
import '../../domain/usecases/reject_connection_usecase.dart';
import '../../domain/usecases/disconnect_from_device_usecase.dart';
import '../../domain/usecases/start_discovery_usecase.dart';
import '../../domain/usecases/stop_discovery_usecase.dart';
import '../../domain/usecases/generate_qr_code_usecase.dart';
import '../../domain/usecases/connect_from_qr_code_usecase.dart';
import '../../domain/usecases/manage_wifi_hotspot_usecase.dart';
import '../../domain/repositories/connection_repository.dart';
import 'connection_event.dart';
import 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final GetConnectionInfoUseCase _getConnectionInfoUseCase;
  final ConnectToDeviceUseCase _connectToDeviceUseCase;
  final AcceptConnectionUseCase _acceptConnectionUseCase;
  final RejectConnectionUseCase _rejectConnectionUseCase;
  final DisconnectFromDeviceUseCase _disconnectFromDeviceUseCase;
  final StartDiscoveryUseCase _startDiscoveryUseCase;
  final StopDiscoveryUseCase _stopDiscoveryUseCase;
  final GenerateQRCodeUseCase _generateQRCodeUseCase;
  final ConnectFromQRCodeUseCase _connectFromQRCodeUseCase;
  final ManageWiFiHotspotUseCase _manageWiFiHotspotUseCase;
  final ConnectionRepository _repository;

  StreamSubscription<ConnectionInfoEntity>? _connectionInfoSubscription;
  final Map<String, StreamSubscription<ConnectionEntity>>
  _connectionSubscriptions = {};

  ConnectionBloc({
    required GetConnectionInfoUseCase getConnectionInfoUseCase,
    required ConnectToDeviceUseCase connectToDeviceUseCase,
    required AcceptConnectionUseCase acceptConnectionUseCase,
    required RejectConnectionUseCase rejectConnectionUseCase,
    required DisconnectFromDeviceUseCase disconnectFromDeviceUseCase,
    required StartDiscoveryUseCase startDiscoveryUseCase,
    required StopDiscoveryUseCase stopDiscoveryUseCase,
    required GenerateQRCodeUseCase generateQRCodeUseCase,
    required ConnectFromQRCodeUseCase connectFromQRCodeUseCase,
    required ManageWiFiHotspotUseCase manageWiFiHotspotUseCase,
    required ConnectionRepository repository,
  }) : _getConnectionInfoUseCase = getConnectionInfoUseCase,
       _connectToDeviceUseCase = connectToDeviceUseCase,
       _acceptConnectionUseCase = acceptConnectionUseCase,
       _rejectConnectionUseCase = rejectConnectionUseCase,
       _disconnectFromDeviceUseCase = disconnectFromDeviceUseCase,
       _startDiscoveryUseCase = startDiscoveryUseCase,
       _stopDiscoveryUseCase = stopDiscoveryUseCase,
       _generateQRCodeUseCase = generateQRCodeUseCase,
       _connectFromQRCodeUseCase = connectFromQRCodeUseCase,
       _manageWiFiHotspotUseCase = manageWiFiHotspotUseCase,
       _repository = repository,
       super(const ConnectionState()) {
    on<LoadConnectionInfo>(_onLoadConnectionInfo);
    on<UpdateDeviceName>(_onUpdateDeviceName);
    on<StartDiscovery>(_onStartDiscovery);
    on<StopDiscovery>(_onStopDiscovery);
    on<ConnectToDevice>(_onConnectToDevice);
    on<AcceptConnection>(_onAcceptConnection);
    on<RejectConnection>(_onRejectConnection);
    on<DisconnectFromDevice>(_onDisconnectFromDevice);
    on<GenerateQRCode>(_onGenerateQRCode);
    on<ConnectFromQRCode>(_onConnectFromQRCode);
    on<EnableWiFiHotspot>(_onEnableWiFiHotspot);
    on<DisableWiFiHotspot>(_onDisableWiFiHotspot);
    on<CheckWiFiHotspotStatus>(_onCheckWiFiHotspotStatus);
    on<RequestPermissions>(_onRequestPermissions);
    on<CheckPermissions>(_onCheckPermissions);
    on<ConnectionStatusUpdated>(_onConnectionStatusUpdated);

    // Start listening to connection info changes
    _startConnectionInfoStream();
  }

  void _startConnectionInfoStream() {
    _connectionInfoSubscription?.cancel();
    _connectionInfoSubscription = _getConnectionInfoUseCase.getStream().listen(
      (connectionInfo) {
        emit(
          state.copyWith(
            connectionInfo: connectionInfo,
            discoveredDevices: connectionInfo.discoveredDevices,
            activeConnections: connectionInfo.activeConnectionsList,
            isDiscovering:
                connectionInfo.discoveryMode == DiscoveryMode.scanning ||
                connectionInfo.discoveryMode == DiscoveryMode.both,
            isAdvertising:
                connectionInfo.discoveryMode == DiscoveryMode.advertising ||
                connectionInfo.discoveryMode == DiscoveryMode.both,
          ),
        );

        // Update connection subscriptions
        _updateConnectionSubscriptions(connectionInfo.activeConnectionsList);
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: ConnectionBlocStatus.error,
            errorMessage: 'Connection info stream error: $error',
          ),
        );
      },
    );
  }

  void _updateConnectionSubscriptions(List<ConnectionEntity> connections) {
    // Cancel old subscriptions
    for (final subscription in _connectionSubscriptions.values) {
      subscription.cancel();
    }
    _connectionSubscriptions.clear();

    // Create new subscriptions
    for (final connection in connections) {
      _connectionSubscriptions[connection.endpointId] = _repository
          .getConnectionStream(connection.endpointId)
          .listen(
            (updatedConnection) {
              add(
                ConnectionStatusUpdated(
                  endpointId: updatedConnection.endpointId,
                  status: updatedConnection.status,
                ),
              );
            },
            onError: (error) {
              emit(
                state.copyWith(errorMessage: 'Connection stream error: $error'),
              );
            },
          );
    }
  }

  Future<void> _onLoadConnectionInfo(
    LoadConnectionInfo event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ConnectionBlocStatus.loading));

      final connectionInfo = await _getConnectionInfoUseCase();
      final hasPermissions = await _repository.hasRequiredPermissions();
      final isHotspotEnabled = await _repository.isWiFiHotspotEnabled();

      emit(
        state.copyWith(
          status: ConnectionBlocStatus.loaded,
          connectionInfo: connectionInfo,
          discoveredDevices: connectionInfo.discoveredDevices,
          activeConnections: connectionInfo.activeConnectionsList,
          hasRequiredPermissions: hasPermissions,
          isWiFiHotspotEnabled: isHotspotEnabled,
          isDiscovering:
              connectionInfo.discoveryMode == DiscoveryMode.scanning ||
              connectionInfo.discoveryMode == DiscoveryMode.both,
          isAdvertising:
              connectionInfo.discoveryMode == DiscoveryMode.advertising ||
              connectionInfo.discoveryMode == DiscoveryMode.both,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConnectionBlocStatus.error,
          errorMessage: 'Failed to load connection info: $e',
        ),
      );
    }
  }

  Future<void> _onUpdateDeviceName(
    UpdateDeviceName event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      await _repository.updateDeviceName(event.deviceName);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update device name: $e'));
    }
  }

  Future<void> _onStartDiscovery(
    StartDiscovery event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final success = await _startDiscoveryUseCase(
        StartDiscoveryParams(
          connectionTypes: event.connectionTypes,
          enableAdvertising: event.enableAdvertising,
        ),
      );

      if (!success) {
        emit(state.copyWith(errorMessage: 'Failed to start discovery'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Discovery start error: $e'));
    }
  }

  Future<void> _onStopDiscovery(
    StopDiscovery event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      await _stopDiscoveryUseCase();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to stop discovery: $e'));
    }
  }

  Future<void> _onConnectToDevice(
    ConnectToDevice event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final success = await _connectToDeviceUseCase(
        ConnectToDeviceParams(
          endpointId: event.endpointId,
          preferredType: event.preferredType,
        ),
      );

      if (!success) {
        emit(state.copyWith(errorMessage: 'Failed to connect to device'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Connection error: $e'));
    }
  }

  Future<void> _onAcceptConnection(
    AcceptConnection event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final success = await _acceptConnectionUseCase(
        AcceptConnectionParams(endpointId: event.endpointId),
      );

      if (!success) {
        emit(state.copyWith(errorMessage: 'Failed to accept connection'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Accept connection error: $e'));
    }
  }

  Future<void> _onRejectConnection(
    RejectConnection event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final success = await _rejectConnectionUseCase(
        RejectConnectionParams(
          endpointId: event.endpointId,
          reason: event.reason,
        ),
      );

      if (!success) {
        emit(state.copyWith(errorMessage: 'Failed to reject connection'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Reject connection error: $e'));
    }
  }

  Future<void> _onDisconnectFromDevice(
    DisconnectFromDevice event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      await _disconnectFromDeviceUseCase(
        DisconnectFromDeviceParams(endpointId: event.endpointId),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Disconnect error: $e'));
    }
  }

  Future<void> _onGenerateQRCode(
    GenerateQRCode event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final qrData = await _generateQRCodeUseCase();
      emit(state.copyWith(qrCodeData: qrData));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to generate QR code: $e'));
    }
  }

  Future<void> _onConnectFromQRCode(
    ConnectFromQRCode event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final success = await _connectFromQRCodeUseCase(
        ConnectFromQRCodeParams(qrData: event.qrData),
      );

      if (!success) {
        emit(state.copyWith(errorMessage: 'Failed to connect from QR code'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'QR code connection error: $e'));
    }
  }

  Future<void> _onEnableWiFiHotspot(
    EnableWiFiHotspot event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final success = await _manageWiFiHotspotUseCase(
        const ManageWiFiHotspotParams(enable: true),
      );

      emit(state.copyWith(isWiFiHotspotEnabled: success));

      if (!success) {
        emit(state.copyWith(errorMessage: 'Failed to enable WiFi hotspot'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'WiFi hotspot error: $e'));
    }
  }

  Future<void> _onDisableWiFiHotspot(
    DisableWiFiHotspot event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final success = await _manageWiFiHotspotUseCase(
        const ManageWiFiHotspotParams(enable: false),
      );

      emit(state.copyWith(isWiFiHotspotEnabled: !success));

      if (!success) {
        emit(state.copyWith(errorMessage: 'Failed to disable WiFi hotspot'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'WiFi hotspot error: $e'));
    }
  }

  Future<void> _onCheckWiFiHotspotStatus(
    CheckWiFiHotspotStatus event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final isEnabled = await _manageWiFiHotspotUseCase.isEnabled();
      emit(state.copyWith(isWiFiHotspotEnabled: isEnabled));
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Failed to check WiFi hotspot status: $e'),
      );
    }
  }

  Future<void> _onRequestPermissions(
    RequestPermissions event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final granted = await _repository.requestPermissions();
      emit(state.copyWith(hasRequiredPermissions: granted));

      if (!granted) {
        emit(state.copyWith(errorMessage: 'Required permissions not granted'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Permission request error: $e'));
    }
  }

  Future<void> _onCheckPermissions(
    CheckPermissions event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final hasPermissions = await _repository.hasRequiredPermissions();
      emit(state.copyWith(hasRequiredPermissions: hasPermissions));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Permission check error: $e'));
    }
  }

  void _onConnectionStatusUpdated(
    ConnectionStatusUpdated event,
    Emitter<ConnectionState> emit,
  ) {
    final currentStates = Map<String, ConnectionEntity>.from(
      state.connectionStates,
    );

    // Update specific connection state
    if (currentStates.containsKey(event.endpointId)) {
      final currentConnection = currentStates[event.endpointId]!;
      currentStates[event.endpointId] = currentConnection.copyWith(
        status: event.status,
        lastActiveAt: DateTime.now(),
      );

      emit(state.copyWith(connectionStates: currentStates));
    }
  }

  @override
  Future<void> close() async {
    await _connectionInfoSubscription?.cancel();
    for (final subscription in _connectionSubscriptions.values) {
      await subscription.cancel();
    }
    return super.close();
  }
}
