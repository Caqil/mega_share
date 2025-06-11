// lib/features/device_discovery/domain/entities/device_entity.dart
import '../../../../core/constants/connection_constants.dart';
import '../../../../shared/models/base_model.dart';

/// Device domain entity
class DeviceEntity extends BaseEntity with IdentifiableMixin, TimestampMixin {
  @override
  final String id;
  final String name;
  final DeviceType deviceType;
  final String? ipAddress;
  final String? macAddress;
  final int signalStrength;
  final bool isConnectable;
  final bool isConnected;
  final DateTime lastSeen;
  final Map<String, dynamic> capabilities;
  final String? endpointId;
  final double? distance;
  
  const DeviceEntity({
    required this.id,
    required this.name,
    required this.deviceType,
    this.ipAddress,
    this.macAddress,
    required this.signalStrength,
    required this.isConnectable,
    required this.isConnected,
    required this.lastSeen,
    required this.capabilities,
    this.endpointId,
    this.distance,
  });
  
  @override
  DateTime get createdAt => lastSeen;
  
  @override
  DateTime get updatedAt => lastSeen;
  
  /// Get signal strength as percentage
  double get signalStrengthPercentage => (signalStrength / 100).clamp(0.0, 1.0);
  
  /// Get signal strength category
  SignalStrength get signalStrengthCategory {
    if (signalStrength >= 80) return SignalStrength.excellent;
    if (signalStrength >= 60) return SignalStrength.good;
    if (signalStrength >= 40) return SignalStrength.fair;
    if (signalStrength >= 20) return SignalStrength.poor;
    return SignalStrength.veryPoor;
  }
  
  /// Check if device supports specific capability
  bool supportsCapability(String capability) {
    return capabilities.containsKey(capability) && capabilities[capability] == true;
  }
  
  /// Check if device supports nearby connections
  bool get supportsNearbyConnections => 
      supportsCapability('nearby_connections') || endpointId != null;
  
  /// Check if device supports WiFi Direct
  bool get supportsWiFiDirect => supportsCapability('wifi_direct');
  
  /// Check if device supports WiFi Hotspot
  bool get supportsWiFiHotspot => supportsCapability('wifi_hotspot');
  
  /// Check if device is recently seen (within last 30 seconds)
  bool get isRecentlySeen {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    return difference.inSeconds <= 30;
  }
  
  /// Check if device is stale (not seen for more than 5 minutes)
  bool get isStale {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    return difference.inMinutes > 5;
  }
  
  /// Get device type icon name
  String get deviceTypeIcon {
    switch (deviceType) {
      case DeviceType.android:
        return 'android';
      case DeviceType.ios:
        return 'phone_iphone';
      case DeviceType.windows:
        return 'computer';
      case DeviceType.macos:
        return 'laptop_mac';
      case DeviceType.linux:
        return 'computer';
      case DeviceType.unknown:
        return 'device_unknown';
    }
  }
  
  /// Get display name with fallback
  String get displayName {
    if (name.isNotEmpty && name != 'Unknown Device') {
      return name;
    }
    return '${deviceType.name.toLowerCase().capitalize()} Device';
  }
  
  /// Get connection methods available for this device
  List<ConnectionType> get availableConnectionMethods {
    final methods = <ConnectionType>[];
    
    if (supportsNearbyConnections) {
      methods.add(ConnectionType.nearbyConnections);
    }
    if (supportsWiFiDirect) {
      methods.add(ConnectionType.wifiDirect);
    }
    if (supportsWiFiHotspot) {
      methods.add(ConnectionType.wifiHotspot);
    }
    if (supportsCapability('bluetooth')) {
      methods.add(ConnectionType.bluetooth);
    }
    
    return methods;
  }
  
  /// Get preferred connection method
   ConnectionType get preferredConnectionMethod {
    final methods = availableConnectionMethods;
    if (methods.isEmpty) return  ConnectionType.nearbyConnections;
    
    // Prefer in order: Nearby Connections, WiFi Direct, WiFi Hotspot, Bluetooth
    if (methods.contains( ConnectionType.nearbyConnections)) {
      return  ConnectionType.nearbyConnections;
    }
    if (methods.contains( ConnectionType.wifiDirect)) {
      return  ConnectionType.wifiDirect;
    }
    if (methods.contains( ConnectionType.wifiHotspot)) {
      return  ConnectionType.wifiHotspot;
    }
    
    return methods.first;
  }
  
  /// Create copy with updated values
  DeviceEntity copyWith({
    String? id,
    String? name,
     DeviceType? deviceType,
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
    return DeviceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceType: deviceType ?? this.deviceType,
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
    deviceType,
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

/// Signal strength enumeration
enum SignalStrength {
  veryPoor,
  poor,
  fair,
  good,
  excellent,
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
