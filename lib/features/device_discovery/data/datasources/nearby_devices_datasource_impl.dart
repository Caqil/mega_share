import 'dart:async';
import 'dart:io';
import 'package:nearby_connections/nearby_connections.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/utils/device_info_utils.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/device_model.dart';
import '../models/discovery_result_model.dart';
import 'nearby_devices_datasource.dart';

/// Nearby devices data source implementation
class NearbyDevicesDataSourceImpl implements NearbyDevicesDataSource {
  final LoggerService _logger = LoggerService();
  final PermissionService _permissionService = PermissionService.instance;

  final StreamController<DiscoveryResultModel> _discoveryController =
      StreamController<DiscoveryResultModel>.broadcast();

  bool _isDiscovering = false;
  bool _isAdvertising = false;
  DiscoveryResultModel? _lastResult;
  String? _currentDeviceName;
  Timer? _discoveryTimer;

  @override
  Stream<DiscoveryResultModel> get discoveredDevicesStream =>
      _discoveryController.stream;

  @override
  bool get isDiscovering => _isDiscovering;

  @override
  bool get isAdvertising => _isAdvertising;

  @override
  DiscoveryResultModel? get lastDiscoveryResult => _lastResult;

  @override
  Future<void> startDiscovery({
    ConnectionConstants.ConnectionType? method,
    Duration? timeout,
  }) async {
    try {
      _logger.info('Starting device discovery');

      // Check permissions
      final hasPermissions = await _checkPermissions();
      if (!hasPermissions) {
        throw PermissionException(
          'Required permissions not granted',
          'nearby_devices',
        );
      }

      // Stop any existing discovery
      if (_isDiscovering) {
        await stopDiscovery();
      }

      _isDiscovering = true;

      // Create initial result
      _lastResult = DiscoveryResultModel.active(
        method?.name ??
            ConnectionConstants.ConnectionType.nearbyConnections.name,
      );
      _discoveryController.add(_lastResult!);

      // Start nearby connections discovery
      await _startNearbyConnectionsDiscovery();

      // Start WiFi discovery if supported
      if (Platform.isAndroid) {
        await _startWiFiDiscovery();
      }

      // Set timeout
      final discoveryTimeout = timeout ?? ConnectionConstants.discoveryDuration;
      _discoveryTimer = Timer(discoveryTimeout, () async {
        _logger.info('Discovery timeout reached');
        await stopDiscovery();
      });

      _logger.info('Device discovery started successfully');
    } catch (e) {
      _logger.error('Failed to start discovery: $e');
      _isDiscovering = false;
      throw DiscoveryException('Failed to start discovery: $e');
    }
  }

  @override
  Future<void> stopDiscovery() async {
    try {
      _logger.info('Stopping device discovery');

      _isDiscovering = false;
      _discoveryTimer?.cancel();
      _discoveryTimer = null;

      // Stop nearby connections discovery
      await Nearby().stopDiscovery();

      // Complete last result
      if (_lastResult != null) {
        _lastResult = _lastResult!.complete();
        _discoveryController.add(_lastResult!);
      }

      _logger.info('Device discovery stopped');
    } catch (e) {
      _logger.error('Error stopping discovery: $e');
      throw DiscoveryException('Failed to stop discovery: $e');
    }
  }

  @override
  Future<void> startAdvertising({String? deviceName, Duration? timeout}) async {
    try {
      _logger.info('Starting device advertising');

      // Check permissions
      final hasPermissions = await _checkPermissions();
      if (!hasPermissions) {
        throw PermissionException(
          'Required permissions not granted',
          'nearby_devices',
        );
      }

      // Stop any existing advertising
      if (_isAdvertising) {
        await stopAdvertising();
      }

      // Get device name
      _currentDeviceName = deviceName ?? await _getDeviceName();

      _isAdvertising = true;

      // Start nearby connections advertising
      await _startNearbyConnectionsAdvertising();

      // Set timeout
      final advertisingTimeout =
          timeout ?? ConnectionConstants.advertisingTimeout;
      Timer(advertisingTimeout, () async {
        _logger.info('Advertising timeout reached');
        await stopAdvertising();
      });

      _logger.info('Device advertising started successfully');
    } catch (e) {
      _logger.error('Failed to start advertising: $e');
      _isAdvertising = false;
      throw DiscoveryException('Failed to start advertising: $e');
    }
  }

  @override
  Future<void> stopAdvertising() async {
    try {
      _logger.info('Stopping device advertising');

      _isAdvertising = false;

      // Stop nearby connections advertising
      await Nearby().stopAdvertising();

      _logger.info('Device advertising stopped');
    } catch (e) {
      _logger.error('Error stopping advertising: $e');
      throw DiscoveryException('Failed to stop advertising: $e');
    }
  }

  @override
  Future<void> clearDiscoveryCache() async {
    _lastResult = null;
    _logger.debug('Discovery cache cleared');
  }

  @override
  List<DeviceModel> getCachedDevices() {
    return _lastResult?.devices ?? [];
  }

  @override
  Future<void> dispose() async {
    await stopDiscovery();
    await stopAdvertising();
    await _discoveryController.close();
    _discoveryTimer?.cancel();
  }

  Future<bool> _checkPermissions() async {
    final hasLocation = await _permissionService.hasLocationPermissions();
    final hasNearby = await _permissionService
        .requestNearbyDevicesPermissions();
    return hasLocation && hasNearby;
  }

  Future<String> _getDeviceName() async {
    try {
      final deviceInfo = await DeviceInfoUtils.getDeviceInfo();
      return deviceInfo.deviceName;
    } catch (e) {
      _logger.error('Failed to get device name: $e');
      return 'ShareIt Device';
    }
  }

  Future<void> _startNearbyConnectionsDiscovery() async {
    try {
      bool success = await Nearby().startDiscovery(
        _currentDeviceName ?? await _getDeviceName(),
        Strategy.wifi_p2p,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
        serviceId: ConnectionConstants.serviceId,
      );

      if (!success) {
        throw DiscoveryException(
          'Failed to start nearby connections discovery',
        );
      }

      _logger.debug('Nearby connections discovery started');
    } catch (e) {
      _logger.error('Nearby connections discovery failed: $e');
      throw DiscoveryException('Nearby connections discovery failed: $e');
    }
  }

  Future<void> _startNearbyConnectionsAdvertising() async {
    try {
      bool success = await Nearby().startAdvertising(
        _currentDeviceName!,
        Strategy.wifi_p2p,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: ConnectionConstants.serviceId,
      );

      if (!success) {
        throw DiscoveryException(
          'Failed to start nearby connections advertising',
        );
      }

      _logger.debug('Nearby connections advertising started');
    } catch (e) {
      _logger.error('Nearby connections advertising failed: $e');
      throw DiscoveryException('Nearby connections advertising failed: $e');
    }
  }

  Future<void> _startWiFiDiscovery() async {
    try {
      // WiFi discovery implementation would go here
      // This is a placeholder for WiFi Direct/Hotspot discovery
      _logger.debug('WiFi discovery started (placeholder)');
    } catch (e) {
      _logger.error('WiFi discovery failed: $e');
    }
  }

  void _onEndpointFound(
    String endpointId,
    String endpointName,
    String serviceId,
  ) {
    _logger.info('Endpoint found: $endpointName ($endpointId)');

    final device = DeviceModel.fromNearbyDiscovery(
      endpointId: endpointId,
      endpointName: endpointName,
      serviceId: serviceId,
    );

    if (_lastResult != null) {
      _lastResult = _lastResult!.addDevice(device);
      _discoveryController.add(_lastResult!);
    }
  }

  void _onEndpointLost(String endpointId) {
    _logger.info('Endpoint lost: $endpointId');

    if (_lastResult != null) {
      _lastResult = _lastResult!.removeDevice(endpointId);
      _discoveryController.add(_lastResult!);
    }
  }

  void _onConnectionInitiated(
    String endpointId,
    ConnectionInfo connectionInfo,
  ) {
    _logger.info('Connection initiated with: $endpointId');
    // Handle connection initiation
  }

  void _onConnectionResult(String endpointId, Status status) {
    _logger.info('Connection result for $endpointId: ${status.statusCode}');
    // Handle connection result
  }

  void _onDisconnected(String endpointId) {
    _logger.info('Disconnected from: $endpointId');
    // Handle disconnection
  }
}
