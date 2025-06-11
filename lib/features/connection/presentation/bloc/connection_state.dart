import 'package:equatable/equatable.dart';
import '../../domain/entities/connection_entity.dart';
import '../../domain/entities/connection_info_entity.dart';
import '../../domain/entities/endpoint_entity.dart';

enum ConnectionBlocStatus { initial, loading, loaded, error }

class ConnectionState extends Equatable {
  final ConnectionBlocStatus status;
  final ConnectionInfoEntity? connectionInfo;
  final List<EndpointEntity> discoveredDevices;
  final List<ConnectionEntity> activeConnections;
  final Map<String, ConnectionEntity> connectionStates;
  final String? qrCodeData;
  final bool isWiFiHotspotEnabled;
  final bool hasRequiredPermissions;
  final String? errorMessage;
  final bool isDiscovering;
  final bool isAdvertising;

  const ConnectionState({
    this.status = ConnectionBlocStatus.initial,
    this.connectionInfo,
    this.discoveredDevices = const [],
    this.activeConnections = const [],
    this.connectionStates = const {},
    this.qrCodeData,
    this.isWiFiHotspotEnabled = false,
    this.hasRequiredPermissions = false,
    this.errorMessage,
    this.isDiscovering = false,
    this.isAdvertising = false,
  });

  ConnectionState copyWith({
    ConnectionBlocStatus? status,
    ConnectionInfoEntity? connectionInfo,
    List<EndpointEntity>? discoveredDevices,
    List<ConnectionEntity>? activeConnections,
    Map<String, ConnectionEntity>? connectionStates,
    String? qrCodeData,
    bool? isWiFiHotspotEnabled,
    bool? hasRequiredPermissions,
    String? errorMessage,
    bool? isDiscovering,
    bool? isAdvertising,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      connectionInfo: connectionInfo ?? this.connectionInfo,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      activeConnections: activeConnections ?? this.activeConnections,
      connectionStates: connectionStates ?? this.connectionStates,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      isWiFiHotspotEnabled: isWiFiHotspotEnabled ?? this.isWiFiHotspotEnabled,
      hasRequiredPermissions:
          hasRequiredPermissions ?? this.hasRequiredPermissions,
      errorMessage: errorMessage,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      isAdvertising: isAdvertising ?? this.isAdvertising,
    );
  }

  ConnectionState clearError() {
    return copyWith(errorMessage: null);
  }

  bool get canStartDiscovery => hasRequiredPermissions && !isDiscovering;
  bool get canConnect => hasRequiredPermissions && discoveredDevices.isNotEmpty;
  bool get hasActiveConnections => activeConnections.isNotEmpty;
  int get maxConnections => connectionInfo?.maxConnections ?? 8;
  bool get canAcceptMoreConnections =>
      activeConnections.length < maxConnections;

  ConnectionEntity? getConnectionByEndpoint(String endpointId) {
    return connectionStates[endpointId];
  }

  @override
  List<Object?> get props => [
    status,
    connectionInfo,
    discoveredDevices,
    activeConnections,
    connectionStates,
    qrCodeData,
    isWiFiHotspotEnabled,
    hasRequiredPermissions,
    errorMessage,
    isDiscovering,
    isAdvertising,
  ];
}
