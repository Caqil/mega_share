import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import '../../../../core/constants/connection_constants.dart';
import '../models/connection_model.dart';
import '../models/connection_info_model.dart';
import '../models/endpoint_model.dart';
import '../../domain/entities/connection_entity.dart';
import '../../domain/entities/connection_info_entity.dart';
import 'nearby_connection_datasource.dart';

class NearbyConnectionDataSourceImpl implements NearbyConnectionDataSource {
  static const String _serviceId = 'com.shareit.fileservice';
  static const String _strategy = 'P2P_CLUSTER';
  static const int _maxConnections = 8;

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();

  // Streams
  final StreamController<ConnectionInfoModel> _connectionInfoController =
      StreamController<ConnectionInfoModel>.broadcast();
  final StreamController<EndpointModel> _endpointFoundController =
      StreamController<EndpointModel>.broadcast();
  final StreamController<String> _endpointLostController =
      StreamController<String>.broadcast();
  final StreamController<ConnectionModel> _connectionInitiatedController =
      StreamController<ConnectionModel>.broadcast();
  final StreamController<ConnectionModel> _connectionResultController =
      StreamController<ConnectionModel>.broadcast();
  final StreamController<String> _disconnectedController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, double>> _signalStrengthController =
      StreamController<Map<String, double>>.broadcast();

  // State
  String? _deviceId;
  String _deviceName = '';
  final Map<String, EndpointModel> _discoveredEndpoints = {};
  final Map<String, ConnectionModel> _activeConnections = {};
  final Map<String, StreamController<ConnectionModel>> _connectionStreams = {};
  DiscoveryMode _discoveryMode = DiscoveryMode.stopped;
  bool _isInitialized = false;
  Timer? _discoveryTimer;
  Timer? _signalStrengthTimer;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Get device info
    await _initializeDeviceInfo();

    // Start periodic updates
    _startPeriodicUpdates();

    _isInitialized = true;
  }

  Future<void> _initializeDeviceInfo() async {
    _deviceId = await _generateDeviceId();

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      _deviceName = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      _deviceName = iosInfo.name;
    } else {
      _deviceName = 'Unknown Device';
    }
  }

  Future<String> _generateDeviceId() async {
    String identifier = '';

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      identifier = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      identifier = iosInfo.identifierForVendor ?? '';
    }

    final bytes = utf8.encode(identifier + DateTime.now().toString());
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  void _startPeriodicUpdates() {
    // Simulate device discovery
    _discoveryTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_discoveryMode == DiscoveryMode.scanning ||
          _discoveryMode == DiscoveryMode.both) {
        _simulateEndpointDiscovery();
      }
    });

    // Update signal strength
    _signalStrengthTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateSignalStrength();
    });
  }

  void _simulateEndpointDiscovery() {
    final random = Random();

    // Randomly discover new endpoints
    if (random.nextBool() && _discoveredEndpoints.length < 5) {
      final endpoint = _generateRandomEndpoint();
      _discoveredEndpoints[endpoint.endpointId] = endpoint;
      _endpointFoundController.add(endpoint);
    }

    // Randomly lose endpoints
    if (random.nextDouble() < 0.1 && _discoveredEndpoints.isNotEmpty) {
      final endpointId = _discoveredEndpoints.keys.first;
      _discoveredEndpoints.remove(endpointId);
      _endpointLostController.add(endpointId);
    }

    _emitConnectionInfo();
  }

  EndpointModel _generateRandomEndpoint() {
    final random = Random();
    final deviceTypes = ['Android', 'iPhone', 'Windows', 'Mac'];
    final deviceNames = [
      'John\'s Phone',
      'Sarah\'s Laptop',
      'Gaming PC',
      'Work MacBook',
    ];

    return EndpointModel(
      endpointId: 'endpoint_${random.nextInt(10000)}',
      deviceName: deviceNames[random.nextInt(deviceNames.length)],
      deviceType: deviceTypes[random.nextInt(deviceTypes.length)],
      connectionCapability: random.nextInt(7) + 1, // 1-7 (binary flags)
      isReachable: true,
      distance: random.nextDouble() * 100,
      discoveredAt: DateTime.now(),
      metadata: {
        'platform': deviceTypes[random.nextInt(deviceTypes.length)],
        'version': '1.0.0',
        'capabilities': ['file_transfer', 'audio', 'video'],
      },
    );
  }

  void _updateSignalStrength() {
    final random = Random();
    final signalMap = <String, double>{};

    for (final connectionId in _activeConnections.keys) {
      signalMap[connectionId] = 0.3 + random.nextDouble() * 0.7; // 30-100%
    }

    if (signalMap.isNotEmpty) {
      _signalStrengthController.add(signalMap);
    }
  }

  @override
  Stream<ConnectionInfoModel> getConnectionInfoStream() =>
      _connectionInfoController.stream;

  @override
  Future<ConnectionInfoModel> getCurrentConnectionInfo() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final availableTypes = <ConnectionType>[];

    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      availableTypes.add(ConnectionType.wifiDirect);
      availableTypes.add(ConnectionType.wifiHotspot);
    }
    if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      availableTypes.add(ConnectionType.bluetooth);
    }

    return ConnectionInfoModel(
      deviceId: _deviceId ?? '',
      deviceName: _deviceName,
      discoveryMode: _discoveryMode,
      availableConnectionTypes: availableTypes,
      isWiFiDirectEnabled: availableTypes.contains(ConnectionType.wifiDirect),
      isBluetoothEnabled: availableTypes.contains(ConnectionType.bluetooth),
      isHotspotEnabled: availableTypes.contains(ConnectionType.wifiHotspot),
      activeConnections: _activeConnections.length,
      maxConnections: _maxConnections,
      discoveredDevices: _discoveredEndpoints.values.toList(),
      activeConnectionsList: _activeConnections.values.toList(),
      lastScanAt: DateTime.now(),
      qrCodeData: await _generateQRCodeData(),
      capabilities: {
        'max_connections': _maxConnections,
        'supported_types': availableTypes.map((e) => e.name).toList(),
        'encryption': true,
        'compression': true,
      },
    );
  }

  Future<String> _generateQRCodeData() async {
    final data = {
      'deviceId': _deviceId,
      'deviceName': _deviceName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'capabilities': ['wifi_direct', 'bluetooth', 'hotspot'],
    };
    return base64Encode(utf8.encode(jsonEncode(data)));
  }

  void _emitConnectionInfo() {
    getCurrentConnectionInfo().then((info) {
      _connectionInfoController.add(info);
    });
  }

  @override
  Future<void> updateDeviceName(String name) async {
    _deviceName = name;
    _emitConnectionInfo();
  }

  @override
  Future<void> startDiscovery({required List<ConnectionType> types}) async {
    _discoveryMode = _discoveryMode == DiscoveryMode.advertising
        ? DiscoveryMode.both
        : DiscoveryMode.scanning;
    _emitConnectionInfo();
  }

  @override
  Future<void> stopDiscovery() async {
    _discoveryMode = _discoveryMode == DiscoveryMode.both
        ? DiscoveryMode.advertising
        : DiscoveryMode.stopped;
    _emitConnectionInfo();
  }

  @override
  Future<void> startAdvertising({required List<ConnectionType> types}) async {
    _discoveryMode = _discoveryMode == DiscoveryMode.scanning
        ? DiscoveryMode.both
        : DiscoveryMode.advertising;
    _emitConnectionInfo();
  }

  @override
  Future<void> stopAdvertising() async {
    _discoveryMode = _discoveryMode == DiscoveryMode.both
        ? DiscoveryMode.scanning
        : DiscoveryMode.stopped;
    _emitConnectionInfo();
  }

  @override
  Stream<EndpointModel> get onEndpointFound => _endpointFoundController.stream;

  @override
  Stream<String> get onEndpointLost => _endpointLostController.stream;

  @override
  Future<bool> requestConnection(
    String endpointId, {
    ConnectionType? preferredType,
  }) async {
    final endpoint = _discoveredEndpoints[endpointId];
    if (endpoint == null) return false;

    final connection = ConnectionModel(
      connectionId: 'conn_${Random().nextInt(10000)}',
      endpointId: endpointId,
      deviceName: endpoint.deviceName,
      status: ConnectionStatus.connecting,
      type: preferredType ?? ConnectionType.wifiDirect,
      isIncoming: false,
      connectedAt: DateTime.now(),
      signalStrength: 0.8,
      dataTransferred: 0,
      transferSpeed: 0.0,
      isEncrypted: true,
      metadata: {'initiated_by': 'user'},
    );

    _connectionInitiatedController.add(connection);

    // Simulate connection process
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    final success = random.nextBool(); // 50% success rate

    final resultConnection = connection.copyWith(
      status: success ? ConnectionStatus.connected : ConnectionStatus.failed,
    );

    if (success) {
      _activeConnections[endpointId] = resultConnection;
      _getOrCreateConnectionStream(endpointId).add(resultConnection);
    }

    _connectionResultController.add(resultConnection);
    _emitConnectionInfo();

    return success;
  }

  @override
  Future<bool> acceptConnection(String endpointId) async {
    final connection = _activeConnections[endpointId];
    if (connection == null ||
        connection.status != ConnectionStatus.connecting) {
      return false;
    }

    final acceptedConnection = connection.copyWith(
      status: ConnectionStatus.connected,
      lastActiveAt: DateTime.now(),
    );

    _activeConnections[endpointId] = acceptedConnection;
    _getOrCreateConnectionStream(endpointId).add(acceptedConnection);
    _connectionResultController.add(acceptedConnection);
    _emitConnectionInfo();

    return true;
  }

  @override
  Future<bool> rejectConnection(String endpointId) async {
    final connection = _activeConnections[endpointId];
    if (connection == null) return false;

    final rejectedConnection = connection.copyWith(
      status: ConnectionStatus.rejected,
    );

    _activeConnections.remove(endpointId);
    _getOrCreateConnectionStream(endpointId).add(rejectedConnection);
    _connectionResultController.add(rejectedConnection);
    _emitConnectionInfo();

    return true;
  }

  @override
  Future<void> disconnectFromEndpoint(String endpointId) async {
    _activeConnections.remove(endpointId);
    _disconnectedController.add(endpointId);
    _connectionStreams[endpointId]?.close();
    _connectionStreams.remove(endpointId);
    _emitConnectionInfo();
  }

  StreamController<ConnectionModel> _getOrCreateConnectionStream(
    String endpointId,
  ) {
    return _connectionStreams.putIfAbsent(
      endpointId,
      () => StreamController<ConnectionModel>.broadcast(),
    );
  }

  @override
  Stream<ConnectionModel> get onConnectionInitiated =>
      _connectionInitiatedController.stream;

  @override
  Stream<ConnectionModel> get onConnectionResult =>
      _connectionResultController.stream;

  @override
  Stream<String> get onDisconnected => _disconnectedController.stream;

  @override
  Stream<ConnectionModel> getConnectionStream(String endpointId) =>
      _getOrCreateConnectionStream(endpointId).stream;

  @override
  Future<List<ConnectionModel>> getActiveConnections() async =>
      _activeConnections.values.toList();

  @override
  Future<ConnectionModel?> getConnection(String endpointId) async =>
      _activeConnections[endpointId];

  @override
  Future<String> generateQRCode() => _generateQRCodeData();

  @override
  Future<bool> connectFromQRCode(String qrData) async {
    try {
      final decodedBytes = base64Decode(qrData);
      final decodedString = utf8.decode(decodedBytes);
      final data = jsonDecode(decodedString) as Map<String, dynamic>;

      final deviceId = data['deviceId'] as String;
      final deviceName = data['deviceName'] as String;

      // Simulate QR code connection
      final endpoint = EndpointModel(
        endpointId: deviceId,
        deviceName: deviceName,
        deviceType: 'QR_CODE',
        connectionCapability: 7, // All capabilities
        isReachable: true,
        distance: 0.0,
        discoveredAt: DateTime.now(),
        metadata: data,
      );

      _discoveredEndpoints[deviceId] = endpoint;
      _endpointFoundController.add(endpoint);

      // Auto-connect
      return await requestConnection(deviceId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> enableWiFiHotspot() async {
    // Platform-specific WiFi hotspot implementation would go here
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> disableWiFiHotspot() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> isWiFiHotspotEnabled() async {
    return false; // Default implementation
  }

  @override
  Future<bool> requestPermissions() async {
    final permissions = [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.nearbyWifiDevices,
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  @override
  Future<bool> hasRequiredPermissions() async {
    final permissions = [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.nearbyWifiDevices,
    ];

    for (final permission in permissions) {
      final status = await permission.status;
      if (status != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  @override
  Stream<Map<String, double>> get onSignalStrengthChanged =>
      _signalStrengthController.stream;

  @override
  Future<void> dispose() async {
    _discoveryTimer?.cancel();
    _signalStrengthTimer?.cancel();

    await _connectionInfoController.close();
    await _endpointFoundController.close();
    await _endpointLostController.close();
    await _connectionInitiatedController.close();
    await _connectionResultController.close();
    await _disconnectedController.close();
    await _signalStrengthController.close();

    for (final controller in _connectionStreams.values) {
      await controller.close();
    }
    _connectionStreams.clear();

    _isInitialized = false;
  }
}
