import '../../domain/entities/device_entity.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../../../shared/models/base_model.dart';

/// Device data model
class DeviceModel extends BaseModel {
  final String id;
  final String name;
  final String type;
  final String? ipAddress;
  final String? macAddress;
  final int signalStrength;
  final bool isConnectable;
  final bool isConnected;
  final DateTime lastSeen;
  final Map<String, dynamic>? capabilities;
  final String? endpointId;
  final double? distance;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    this.ipAddress,
    this.macAddress,
    required this.signalStrength,
    required this.isConnectable,
    required this.isConnected,
    required this.lastSeen,
    this.capabilities,
    this.endpointId,
    this.distance,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Device',
      type: json['type'] ?? 'unknown',
      ipAddress: json['ipAddress'],
      macAddress: json['macAddress'],
      signalStrength: json['signalStrength'] ?? 0,
      isConnectable: json['isConnectable'] ?? false,
      isConnected: json['isConnected'] ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : DateTime.now(),
      capabilities: json['capabilities']?.cast<String, dynamic>(),
      endpointId: json['endpointId'],
      distance: json['distance']?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'ipAddress': ipAddress,
      'macAddress': macAddress,
      'signalStrength': signalStrength,
      'isConnectable': isConnectable,
      'isConnected': isConnected,
      'lastSeen': lastSeen.toIso8601String(),
      'capabilities': capabilities,
      'endpointId': endpointId,
      'distance': distance,
    };
  }

  /// Convert to domain entity
  DeviceEntity toEntity() {
    return DeviceEntity(
      id: id,
      name: name,
      deviceType: _parseDeviceType(type),
      ipAddress: ipAddress,
      macAddress: macAddress,
      signalStrength: signalStrength,
      isConnectable: isConnectable,
      isConnected: isConnected,
      lastSeen: lastSeen,
      capabilities: capabilities ?? {},
      endpointId: endpointId,
      distance: distance,
    );
  }

  /// Create from domain entity
  factory DeviceModel.fromEntity(DeviceEntity entity) {
    return DeviceModel(
      id: entity.id,
      name: entity.name,
      type: entity.deviceType.name,
      ipAddress: entity.ipAddress,
      macAddress: entity.macAddress,
      signalStrength: entity.signalStrength,
      isConnectable: entity.isConnectable,
      isConnected: entity.isConnected,
      lastSeen: entity.lastSeen,
      capabilities: entity.capabilities,
      endpointId: entity.endpointId,
      distance: entity.distance,
    );
  }

  /// Create from nearby connections discovery
  factory DeviceModel.fromNearbyDiscovery({
    required String endpointId,
    required String endpointName,
    required String serviceId,
  }) {
    return DeviceModel(
      id: endpointId,
      name: endpointName,
      type: 'mobile',
      signalStrength: 80, // Default for nearby connections
      isConnectable: true,
      isConnected: false,
      lastSeen: DateTime.now(),
      endpointId: endpointId,
      capabilities: {'nearby_connections': true, 'service_id': serviceId},
    );
  }

  /// Create from WiFi discovery
  factory DeviceModel.fromWiFiDiscovery({
    required String name,
    required String ipAddress,
    String? macAddress,
    int signalStrength = 70,
  }) {
    return DeviceModel(
      id: ipAddress,
      name: name,
      type: 'wifi',
      ipAddress: ipAddress,
      macAddress: macAddress,
      signalStrength: signalStrength,
      isConnectable: true,
      isConnected: false,
      lastSeen: DateTime.now(),
      capabilities: {'wifi_direct': true, 'hotspot': true},
    );
  }

  DeviceType _parseDeviceType(String type) {
    switch (type.toLowerCase()) {
      case 'android':
        return DeviceType.android;
      case 'ios':
        return DeviceType.ios;
      case 'windows':
        return DeviceType.windows;
      case 'macos':
        return DeviceType.macos;
      case 'linux':
        return DeviceType.linux;
      default:
        return DeviceType.unknown;
    }
  }

  /// Copy with modifications
  DeviceModel copyWith({
    String? id,
    String? name,
    String? type,
    String? ipAddress,
    String? macAddress,
    int? signalStrength,
    bool? isConnectable,
    bool? isConnected,
    DateTime? lastSeen,
    Map<String, dynamic>? capabilities,
    String? endpointId,
    double? distance,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      signalStrength: signalStrength ?? this.signalStrength,
      isConnectable: isConnectable ?? this.isConnectable,
      isConnected: isConnected ?? this.isConnected,
      lastSeen: lastSeen ?? this.lastSeen,
      capabilities: capabilities ?? this.capabilities,
      endpointId: endpointId ?? this.endpointId,
      distance: distance ?? this.distance,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    ipAddress,
    macAddress,
    signalStrength,
    isConnectable,
    isConnected,
    lastSeen,
    capabilities,
    endpointId,
    distance,
  ];
}
