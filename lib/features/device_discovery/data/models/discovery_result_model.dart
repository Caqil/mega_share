import '../../domain/entities/discovery_result_entity.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../../../shared/models/base_model.dart';
import 'device_model.dart';

/// Discovery result data model
class DiscoveryResultModel extends BaseModel {
  final List<DeviceModel> devices;
  final String discoveryMethod;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  final String? error;
  final Map<String, dynamic> metadata;

  const DiscoveryResultModel({
    required this.devices,
    required this.discoveryMethod,
    required this.startTime,
    this.endTime,
    required this.isActive,
    this.error,
    required this.metadata,
  });

  factory DiscoveryResultModel.fromJson(Map<String, dynamic> json) {
    return DiscoveryResultModel(
      devices:
          (json['devices'] as List<dynamic>?)
              ?.map((device) => DeviceModel.fromJson(device))
              .toList() ??
          [],
      discoveryMethod: json['discoveryMethod'] ?? 'unknown',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      isActive: json['isActive'] ?? false,
      error: json['error'],
      metadata: json['metadata']?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'devices': devices.map((device) => device.toJson()).toList(),
      'discoveryMethod': discoveryMethod,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isActive': isActive,
      'error': error,
      'metadata': metadata,
    };
  }

  /// Convert to domain entity
  DiscoveryResultEntity toEntity() {
    return DiscoveryResultEntity(
      devices: devices.map((device) => device.toEntity()).toList(),
      discoveryMethod: _parseDiscoveryMethod(discoveryMethod),
      startTime: startTime,
      endTime: endTime,
      isActive: isActive,
      error: error,
      metadata: metadata,
    );
  }

  /// Create from domain entity
  factory DiscoveryResultModel.fromEntity(DiscoveryResultEntity entity) {
    return DiscoveryResultModel(
      devices: entity.devices
          .map((device) => DeviceModel.fromEntity(device))
          .toList(),
      discoveryMethod: entity.discoveryMethod.name,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isActive: entity.isActive,
      error: entity.error,
      metadata: entity.metadata,
    );
  }

  /// Create empty result
  factory DiscoveryResultModel.empty(String method) {
    return DiscoveryResultModel(
      devices: [],
      discoveryMethod: method,
      startTime: DateTime.now(),
      isActive: false,
      metadata: {},
    );
  }

  /// Create active discovery
  factory DiscoveryResultModel.active(String method) {
    return DiscoveryResultModel(
      devices: [],
      discoveryMethod: method,
      startTime: DateTime.now(),
      isActive: true,
      metadata: {'scanning': true},
    );
  }

   ConnectionType _parseDiscoveryMethod(String method) {
    switch (method.toLowerCase()) {
      case 'nearby_connections':
      case 'nearbyconnections':
        return  ConnectionType.nearbyConnections;
      case 'wifi_direct':
      case 'wifidirect':
        return  ConnectionType.wifiDirect;
      case 'wifi_hotspot':
      case 'wifihotspot':
        return  ConnectionType.wifiHotspot;
      case 'bluetooth':
        return  ConnectionType.bluetooth;
      case 'qr_code':
      case 'qrcode':
        return  ConnectionType.qrCode;
      default:
        return  ConnectionType.nearbyConnections;
    }
  }

  /// Add device to result
  DiscoveryResultModel addDevice(DeviceModel device) {
    final updatedDevices = List<DeviceModel>.from(devices);

    // Check if device already exists
    final existingIndex = updatedDevices.indexWhere((d) => d.id == device.id);
    if (existingIndex != -1) {
      // Update existing device
      updatedDevices[existingIndex] = device;
    } else {
      // Add new device
      updatedDevices.add(device);
    }

    return copyWith(devices: updatedDevices);
  }

  /// Remove device from result
  DiscoveryResultModel removeDevice(String deviceId) {
    final updatedDevices = devices
        .where((device) => device.id != deviceId)
        .toList();
    return copyWith(devices: updatedDevices);
  }

  /// Update device in result
  DiscoveryResultModel updateDevice(DeviceModel updatedDevice) {
    return addDevice(updatedDevice);
  }

  /// Mark discovery as completed
  DiscoveryResultModel complete({String? error}) {
    return copyWith(
      isActive: false,
      endTime: DateTime.now(),
      error: error,
      metadata: Map.from(metadata)..['scanning'] = false,
    );
  }

  /// Copy with modifications
  DiscoveryResultModel copyWith({
    List<DeviceModel>? devices,
    String? discoveryMethod,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    String? error,
    Map<String, dynamic>? metadata,
  }) {
    return DiscoveryResultModel(
      devices: devices ?? this.devices,
      discoveryMethod: discoveryMethod ?? this.discoveryMethod,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get discovery duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Get device count
  int get deviceCount => devices.length;

  /// Get connectable devices
  List<DeviceModel> get connectableDevices =>
      devices.where((device) => device.isConnectable).toList();

  /// Get connected devices
  List<DeviceModel> get connectedDevices =>
      devices.where((device) => device.isConnected).toList();

  @override
  List<Object?> get props => [
    devices,
    discoveryMethod,
    startTime,
    endTime,
    isActive,
    error,
    metadata,
  ];
}
