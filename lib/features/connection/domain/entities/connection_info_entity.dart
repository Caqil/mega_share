import 'package:equatable/equatable.dart';

import '../../../../core/constants/connection_constants.dart';
import 'connection_entity.dart';
import 'endpoint_entity.dart';

enum DiscoveryMode { scanning, advertising, both, stopped }

class ConnectionInfoEntity extends Equatable {
  final String deviceId;
  final String deviceName;
  final DiscoveryMode discoveryMode;
  final List<ConnectionType> availableConnectionTypes;
  final bool isWiFiDirectEnabled;
  final bool isBluetoothEnabled;
  final bool isHotspotEnabled;
  final int activeConnections;
  final int maxConnections;
  final List<EndpointEntity> discoveredDevices;
  final List<ConnectionEntity> activeConnectionsList;
  final DateTime lastScanAt;
  final String? qrCodeData;
  final Map<String, dynamic> capabilities;

  const ConnectionInfoEntity({
    required this.deviceId,
    required this.deviceName,
    required this.discoveryMode,
    required this.availableConnectionTypes,
    required this.isWiFiDirectEnabled,
    required this.isBluetoothEnabled,
    required this.isHotspotEnabled,
    required this.activeConnections,
    required this.maxConnections,
    required this.discoveredDevices,
    required this.activeConnectionsList,
    required this.lastScanAt,
    this.qrCodeData,
    required this.capabilities,
  });

  bool get canAcceptConnections => activeConnections < maxConnections;
  bool get isDiscovering => discoveryMode != DiscoveryMode.stopped;
  bool get hasActiveConnections => activeConnectionsList.isNotEmpty;

  ConnectionInfoEntity copyWith({
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
    return ConnectionInfoEntity(
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

  @override
  List<Object?> get props => [
    deviceId,
    deviceName,
    discoveryMode,
    availableConnectionTypes,
    isWiFiDirectEnabled,
    isBluetoothEnabled,
    isHotspotEnabled,
    activeConnections,
    maxConnections,
    discoveredDevices,
    activeConnectionsList,
    lastScanAt,
    qrCodeData,
    capabilities,
  ];
}
