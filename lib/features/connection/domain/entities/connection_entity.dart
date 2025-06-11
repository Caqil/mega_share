import 'package:equatable/equatable.dart';

import '../../../../core/constants/connection_constants.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  authenticating,
  authenticated,
  failed,
  rejected,
  lost,
}

class ConnectionEntity extends Equatable {
  final String connectionId;
  final String endpointId;
  final String deviceName;
  final ConnectionStatus status;
  final ConnectionType type;
  final bool isIncoming;
  final DateTime connectedAt;
  final DateTime? lastActiveAt;
  final double signalStrength;
  final int dataTransferred;
  final double transferSpeed;
  final bool isEncrypted;
  final String? authenticationToken;
  final Map<String, dynamic> metadata;

  const ConnectionEntity({
    required this.connectionId,
    required this.endpointId,
    required this.deviceName,
    required this.status,
    required this.type,
    required this.isIncoming,
    required this.connectedAt,
    this.lastActiveAt,
    required this.signalStrength,
    required this.dataTransferred,
    required this.transferSpeed,
    required this.isEncrypted,
    this.authenticationToken,
    required this.metadata,
  });

  bool get isActive =>
      status == ConnectionStatus.connected ||
      status == ConnectionStatus.authenticated;

  ConnectionEntity copyWith({
    String? connectionId,
    String? endpointId,
    String? deviceName,
    ConnectionStatus? status,
    ConnectionType? type,
    bool? isIncoming,
    DateTime? connectedAt,
    DateTime? lastActiveAt,
    double? signalStrength,
    int? dataTransferred,
    double? transferSpeed,
    bool? isEncrypted,
    String? authenticationToken,
    Map<String, dynamic>? metadata,
  }) {
    return ConnectionEntity(
      connectionId: connectionId ?? this.connectionId,
      endpointId: endpointId ?? this.endpointId,
      deviceName: deviceName ?? this.deviceName,
      status: status ?? this.status,
      type: type ?? this.type,
      isIncoming: isIncoming ?? this.isIncoming,
      connectedAt: connectedAt ?? this.connectedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      signalStrength: signalStrength ?? this.signalStrength,
      dataTransferred: dataTransferred ?? this.dataTransferred,
      transferSpeed: transferSpeed ?? this.transferSpeed,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      authenticationToken: authenticationToken ?? this.authenticationToken,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    connectionId,
    endpointId,
    deviceName,
    status,
    type,
    isIncoming,
    connectedAt,
    lastActiveAt,
    signalStrength,
    dataTransferred,
    transferSpeed,
    isEncrypted,
    authenticationToken,
    metadata,
  ];
}
