import 'package:mega_share/core/constants/connection_constants.dart';

import '../../domain/entities/connection_entity.dart';

class ConnectionModel extends ConnectionEntity {
  const ConnectionModel({
    required super.connectionId,
    required super.endpointId,
    required super.deviceName,
    required super.status,
    required super.type,
    required super.isIncoming,
    required super.connectedAt,
    super.lastActiveAt,
    required super.signalStrength,
    required super.dataTransferred,
    required super.transferSpeed,
    required super.isEncrypted,
    super.authenticationToken,
    required super.metadata,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      connectionId: json['connectionId'] as String,
      endpointId: json['endpointId'] as String,
      deviceName: json['deviceName'] as String,
      status: ConnectionStatus.values.firstWhere(
        (e) => e.name == json['status'] as String,
        orElse: () => ConnectionStatus.disconnected,
      ),
      type: ConnectionType.values.firstWhere(
        (e) => e.name == json['type'] as String,
        orElse: () => ConnectionType.unknown,
      ),
      isIncoming: json['isIncoming'] as bool,
      connectedAt: DateTime.parse(json['connectedAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      signalStrength: (json['signalStrength'] as num).toDouble(),
      dataTransferred: json['dataTransferred'] as int,
      transferSpeed: (json['transferSpeed'] as num).toDouble(),
      isEncrypted: json['isEncrypted'] as bool,
      authenticationToken: json['authenticationToken'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connectionId': connectionId,
      'endpointId': endpointId,
      'deviceName': deviceName,
      'status': status.name,
      'type': type.name,
      'isIncoming': isIncoming,
      'connectedAt': connectedAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'signalStrength': signalStrength,
      'dataTransferred': dataTransferred,
      'transferSpeed': transferSpeed,
      'isEncrypted': isEncrypted,
      'authenticationToken': authenticationToken,
      'metadata': metadata,
    };
  }

  factory ConnectionModel.fromEntity(ConnectionEntity entity) {
    return ConnectionModel(
      connectionId: entity.connectionId,
      endpointId: entity.endpointId,
      deviceName: entity.deviceName,
      status: entity.status,
      type: entity.type,
      isIncoming: entity.isIncoming,
      connectedAt: entity.connectedAt,
      lastActiveAt: entity.lastActiveAt,
      signalStrength: entity.signalStrength,
      dataTransferred: entity.dataTransferred,
      transferSpeed: entity.transferSpeed,
      isEncrypted: entity.isEncrypted,
      authenticationToken: entity.authenticationToken,
      metadata: entity.metadata,
    );
  }

  @override
  ConnectionModel copyWith({
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
    return ConnectionModel(
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
}
