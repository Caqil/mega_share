// lib/features/connection/data/models/endpoint_model.dart
import '../../domain/entities/endpoint_entity.dart';

class EndpointModel extends EndpointEntity {
  const EndpointModel({
    required super.endpointId,
    required super.deviceName,
    required super.deviceType,
    required super.connectionCapability,
    required super.isReachable,
    required super.distance,
    required super.discoveredAt,
    required super.metadata,
  });

  factory EndpointModel.fromJson(Map<String, dynamic> json) {
    return EndpointModel(
      endpointId: json['endpointId'] as String,
      deviceName: json['deviceName'] as String,
      deviceType: json['deviceType'] as String,
      connectionCapability: json['connectionCapability'] as int,
      isReachable: json['isReachable'] as bool,
      distance: (json['distance'] as num).toDouble(),
      discoveredAt: DateTime.parse(json['discoveredAt'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'endpointId': endpointId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'connectionCapability': connectionCapability,
      'isReachable': isReachable,
      'distance': distance,
      'discoveredAt': discoveredAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory EndpointModel.fromEntity(EndpointEntity entity) {
    return EndpointModel(
      endpointId: entity.endpointId,
      deviceName: entity.deviceName,
      deviceType: entity.deviceType,
      connectionCapability: entity.connectionCapability,
      isReachable: entity.isReachable,
      distance: entity.distance,
      discoveredAt: entity.discoveredAt,
      metadata: entity.metadata,
    );
  }

  EndpointModel copyWith({
    String? endpointId,
    String? deviceName,
    String? deviceType,
    int? connectionCapability,
    bool? isReachable,
    double? distance,
    DateTime? discoveredAt,
    Map<String, dynamic>? metadata,
  }) {
    return EndpointModel(
      endpointId: endpointId ?? this.endpointId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      connectionCapability: connectionCapability ?? this.connectionCapability,
      isReachable: isReachable ?? this.isReachable,
      distance: distance ?? this.distance,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
