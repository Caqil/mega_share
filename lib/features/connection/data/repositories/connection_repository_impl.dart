import 'dart:async';
import 'package:mega_share/core/constants/connection_constants.dart';

import '../../domain/entities/connection_entity.dart';
import '../../domain/entities/connection_info_entity.dart';
import '../../domain/entities/endpoint_entity.dart';
import '../../domain/repositories/connection_repository.dart';
import '../datasources/nearby_connection_datasource.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  final NearbyConnectionDataSource _dataSource;

  ConnectionRepositoryImpl({required NearbyConnectionDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Stream<ConnectionInfoEntity> getConnectionInfoStream() =>
      _dataSource.getConnectionInfoStream();

  @override
  Future<ConnectionInfoEntity> getConnectionInfo() =>
      _dataSource.getCurrentConnectionInfo();

  @override
  Future<void> updateDeviceName(String name) =>
      _dataSource.updateDeviceName(name);

  @override
  Future<void> startDiscovery({required List<ConnectionType> types}) =>
      _dataSource.startDiscovery(types: types);

  @override
  Future<void> stopDiscovery() => _dataSource.stopDiscovery();

  @override
  Future<void> startAdvertising({required List<ConnectionType> types}) =>
      _dataSource.startAdvertising(types: types);

  @override
  Future<void> stopAdvertising() => _dataSource.stopAdvertising();

  @override
  Future<bool> connectToDevice(
    String endpointId, {
    ConnectionType? preferredType,
  }) => _dataSource.requestConnection(endpointId, preferredType: preferredType);

  @override
  Future<bool> acceptConnection(String endpointId) =>
      _dataSource.acceptConnection(endpointId);

  @override
  Future<bool> rejectConnection(String endpointId) =>
      _dataSource.rejectConnection(endpointId);

  @override
  Future<void> disconnectFromDevice(String endpointId) =>
      _dataSource.disconnectFromEndpoint(endpointId);

  @override
  Future<void> disconnectAll() async {
    final connections = await _dataSource.getActiveConnections();
    for (final connection in connections) {
      await _dataSource.disconnectFromEndpoint(connection.endpointId);
    }
  }

  @override
  Stream<ConnectionEntity> getConnectionStream(String endpointId) =>
      _dataSource.getConnectionStream(endpointId);

  @override
  Stream<List<ConnectionEntity>> getActiveConnectionsStream() => _dataSource
      .getConnectionInfoStream()
      .map((info) => info.activeConnectionsList);

  @override
  Future<List<ConnectionEntity>> getActiveConnections() async {
    final connections = await _dataSource.getActiveConnections();
    return connections.cast<ConnectionEntity>();
  }

  @override
  Future<ConnectionEntity?> getConnection(String endpointId) =>
      _dataSource.getConnection(endpointId);

  @override
  Future<String> generateQRCode() => _dataSource.generateQRCode();

  @override
  Future<bool> connectFromQRCode(String qrData) =>
      _dataSource.connectFromQRCode(qrData);

  @override
  Future<bool> enableWiFiHotspot() => _dataSource.enableWiFiHotspot();

  @override
  Future<bool> disableWiFiHotspot() => _dataSource.disableWiFiHotspot();

  @override
  Future<bool> isWiFiHotspotEnabled() => _dataSource.isWiFiHotspotEnabled();

  @override
  Future<bool> requestPermissions() => _dataSource.requestPermissions();

  @override
  Future<bool> hasRequiredPermissions() => _dataSource.hasRequiredPermissions();

  @override
  Future<void> openSettings() async {
    // Platform-specific settings opening would go here
    throw UnimplementedError('Settings opening not implemented');
  }
}
