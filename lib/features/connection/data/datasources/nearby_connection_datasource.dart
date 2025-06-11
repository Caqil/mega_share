import 'dart:async';
import '../../../../core/constants/connection_constants.dart';
import '../models/connection_model.dart';
import '../models/connection_info_model.dart';
import '../models/endpoint_model.dart';
import '../../domain/entities/connection_entity.dart';

abstract class NearbyConnectionDataSource {
  // Initialization
  Future<void> initialize();
  Future<void> dispose();

  // Connection Info
  Stream<ConnectionInfoModel> getConnectionInfoStream();
  Future<ConnectionInfoModel> getCurrentConnectionInfo();
  Future<void> updateDeviceName(String name);

  // Discovery
  Future<void> startDiscovery({required List<ConnectionType> types});
  Future<void> stopDiscovery();
  Future<void> startAdvertising({required List<ConnectionType> types});
  Future<void> stopAdvertising();

  // Endpoint Discovery Events
  Stream<EndpointModel> get onEndpointFound;
  Stream<String> get onEndpointLost;

  // Connection Management
  Future<bool> requestConnection(
    String endpointId, {
    ConnectionType? preferredType,
  });
  Future<bool> acceptConnection(String endpointId);
  Future<bool> rejectConnection(String endpointId);
  Future<void> disconnectFromEndpoint(String endpointId);

  // Connection Events
  Stream<ConnectionModel> get onConnectionInitiated;
  Stream<ConnectionModel> get onConnectionResult;
  Stream<String> get onDisconnected;

  // Connection Status
  Stream<ConnectionModel> getConnectionStream(String endpointId);
  Future<List<ConnectionModel>> getActiveConnections();
  Future<ConnectionModel?> getConnection(String endpointId);

  // QR Code
  Future<String> generateQRCode();
  Future<bool> connectFromQRCode(String qrData);

  // WiFi Hotspot
  Future<bool> enableWiFiHotspot();
  Future<bool> disableWiFiHotspot();
  Future<bool> isWiFiHotspotEnabled();

  // Permissions
  Future<bool> requestPermissions();
  Future<bool> hasRequiredPermissions();

  // Signal Strength
  Stream<Map<String, double>> get onSignalStrengthChanged;
}
