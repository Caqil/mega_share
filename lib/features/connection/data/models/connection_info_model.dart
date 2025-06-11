import 'package:mega_share/core/constants/connection_constants.dart';

import '../../domain/entities/connection_info_entity.dart';
import '../../domain/entities/endpoint_entity.dart';
import '../../domain/entities/connection_entity.dart';
import 'endpoint_model.dart';
import 'connection_model.dart';

class ConnectionInfoModel extends ConnectionInfoEntity {
  const ConnectionInfoModel({
    required super.deviceId,
    required super.deviceName,
    required super.discoveryMode,
    required super.availableConnectionTypes,
    required super.isWiFiDirectEnabled,
    required super.isBluetoothEnabled,
    required super.isHotspotEnabled,
    required super.activeConnections,
    required super.maxConnections,
    required super.discoveredDevices,
    required super.activeConnectionsList,
    required super.lastScanAt,
    super.qrCodeData,
    required super.capabilities,
  });

  factory ConnectionInfoModel.fromJson(Map<String, dynamic> json) {
    return ConnectionInfoModel(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      discoveryMode: DiscoveryMode.values.firstWhere(
        (e) => e.name == json['discoveryMode'] as String,
        orElse: () => DiscoveryMode.stopped,
      ),
      availableConnectionTypes: (json['availableConnectionTypes'] as List)
          .map(
            (e) => ConnectionType.values.firstWhere(
              (type) => type.name == e as String,
              orElse: () => ConnectionType.unknown,
            ),
          )
          .toList(),
      isWiFiDirectEnabled: json['isWiFiDirectEnabled'] as bool,
      isBluetoothEnabled: json['isBluetoothEnabled'] as bool,
      isHotspotEnabled: json['isHotspotEnabled'] as bool,
      activeConnections: json['activeConnections'] as int,
      maxConnections: json['maxConnections'] as int,
      discoveredDevices: (json['discoveredDevices'] as List)
          .map((e) => EndpointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeConnectionsList: (json['activeConnectionsList'] as List)
          .map((e) => ConnectionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastScanAt: DateTime.parse(json['lastScanAt'] as String),
      qrCodeData: json['qrCodeData'] as String?,
      capabilities: Map<String, dynamic>.from(json['capabilities'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'discoveryMode': discoveryMode.name,
      'availableConnectionTypes': availableConnectionTypes
          .map((e) => e.name)
          .toList(),
      'isWiFiDirectEnabled': isWiFiDirectEnabled,
      'isBluetoothEnabled': isBluetoothEnabled,
      'isHotspotEnabled': isHotspotEnabled,
      'activeConnections': activeConnections,
      'maxConnections': maxConnections,
      'discoveredDevices': discoveredDevices
          .map((e) => EndpointModel.fromEntity(e).toJson())
          .toList(),
      'activeConnectionsList': activeConnectionsList
          .map((e) => ConnectionModel.fromEntity(e).toJson())
          .toList(),
      'lastScanAt': lastScanAt.toIso8601String(),
      'qrCodeData': qrCodeData,
      'capabilities': capabilities,
    };
  }

  factory ConnectionInfoModel.fromEntity(ConnectionInfoEntity entity) {
    return ConnectionInfoModel(
      deviceId: entity.deviceId,
      deviceName: entity.deviceName,
      discoveryMode: entity.discoveryMode,
      availableConnectionTypes: entity.availableConnectionTypes,
      isWiFiDirectEnabled: entity.isWiFiDirectEnabled,
      isBluetoothEnabled: entity.isBluetoothEnabled,
      isHotspotEnabled: entity.isHotspotEnabled,
      activeConnections: entity.activeConnections,
      maxConnections: entity.maxConnections,
      discoveredDevices: entity.discoveredDevices,
      activeConnectionsList: entity.activeConnectionsList,
      lastScanAt: entity.lastScanAt,
      qrCodeData: entity.qrCodeData,
      capabilities: entity.capabilities,
    );
  }

  @override
  ConnectionInfoModel copyWith({
    String? deviceId,
    String? deviceName,
    DiscoveryMode? discoveryMode,
    List<ConnectionType>? availableConnectionTypes,
    bool? isWiFiDirectEnabled,
    bool? isBluetoothEnabled,
    bool? isHotspotEnabled,
    int? activeConnections,
    int? maxConnections,
    List<EndpointEntity>? discoveredDevices,
    List<ConnectionEntity>? activeConnectionsList,
    DateTime? lastScanAt,
    String? qrCodeData,
    Map<String, dynamic>? capabilities,
  }) {
    return ConnectionInfoModel(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      discoveryMode: discoveryMode ?? this.discoveryMode,
      availableConnectionTypes:
          availableConnectionTypes ?? this.availableConnectionTypes,
      isWiFiDirectEnabled: isWiFiDirectEnabled ?? this.isWiFiDirectEnabled,
      isBluetoothEnabled: isBluetoothEnabled ?? this.isBluetoothEnabled,
      isHotspotEnabled: isHotspotEnabled ?? this.isHotspotEnabled,
      activeConnections: activeConnections ?? this.activeConnections,
      maxConnections: maxConnections ?? this.maxConnections,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      activeConnectionsList:
          activeConnectionsList ?? this.activeConnectionsList,
      lastScanAt: lastScanAt ?? this.lastScanAt,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      capabilities: capabilities ?? this.capabilities,
    );
  }
}
