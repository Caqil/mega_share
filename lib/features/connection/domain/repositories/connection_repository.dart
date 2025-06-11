// lib/features/connection/domain/repositories/connection_repository.dart
import 'dart:async';
import '../../../../core/constants/connection_constants.dart';
import '../entities/connection_entity.dart';
import '../entities/connection_info_entity.dart';
import '../entities/endpoint_entity.dart';

abstract class ConnectionRepository {
  // Connection Info
  Stream<ConnectionInfoEntity> getConnectionInfoStream();
  Future<ConnectionInfoEntity> getConnectionInfo();
  Future<void> updateDeviceName(String name);
  
  // Device Discovery
  Future<void> startDiscovery({required List<ConnectionType> types});
  Future<void> stopDiscovery();
  Future<void> startAdvertising({required List<ConnectionType> types});
  Future<void> stopAdvertising();
  
  // Connection Management
  Future<bool> connectToDevice(String endpointId, {ConnectionType? preferredType});
  Future<bool> acceptConnection(String endpointId);
  Future<bool> rejectConnection(String endpointId);
  Future<void> disconnectFromDevice(String endpointId);
  Future<void> disconnectAll();
  
  // Connection Status
  Stream<ConnectionEntity> getConnectionStream(String endpointId);
  Stream<List<ConnectionEntity>> getActiveConnectionsStream();
  Future<List<ConnectionEntity>> getActiveConnections();
  Future<ConnectionEntity?> getConnection(String endpointId);
  
  // QR Code
  Future<String> generateQRCode();
  Future<bool> connectFromQRCode(String qrData);
  
  // WiFi Hotspot
  Future<bool> enableWiFiHotspot();
  Future<bool> disableWiFiHotspot();
  Future<bool> isWiFiHotspotEnabled();
  
  // Permissions & Settings
  Future<bool> requestPermissions();
  Future<bool> hasRequiredPermissions();
  Future<void> openSettings();
}
