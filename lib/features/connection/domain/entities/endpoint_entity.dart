import 'package:equatable/equatable.dart';

class EndpointEntity extends Equatable {
  final String endpointId;
  final String deviceName;
  final String deviceType;
  final int connectionCapability;
  final bool isReachable;
  final double distance;
  final DateTime discoveredAt;
  final Map<String, dynamic> metadata;

  const EndpointEntity({
    required this.endpointId,
    required this.deviceName,
    required this.deviceType,
    required this.connectionCapability,
    required this.isReachable,
    required this.distance,
    required this.discoveredAt,
    required this.metadata,
  });

  bool get supportsWiFiDirect => (connectionCapability & 1) != 0;
  bool get supportsBluetooth => (connectionCapability & 2) != 0;
  bool get supportsHotspot => (connectionCapability & 4) != 0;

  @override
  List<Object?> get props => [
    endpointId,
    deviceName,
    deviceType,
    connectionCapability,
    isReachable,
    distance,
    discoveredAt,
    metadata,
  ];
}
