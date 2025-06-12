import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../models/device_model.dart';
import '../models/discovery_result_model.dart';
import 'nearby_devices_datasource.dart';

/// Nearby devices data source implementation
class NearbyDevicesDataSourceImpl implements NearbyDevicesDataSource {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();

  // State management
  bool _isInitialized = false;
  bool _isDiscovering = false;
  bool _isAdvertising = false;
  String? _deviceId;
  String _deviceName = 'Unknown Device';

  // Discovery management
  Timer? _discoveryTimer;
  Timer? _advertisingTimer;
  Timer? _signalUpdateTimer;
  DateTime? _discoveryStartTime;
  ConnectionType? _currentDiscoveryMethod;

  // Data management
  final Map<String, DeviceModel> _discoveredDevices = {};
  final StreamController<DiscoveryResultModel> _discoveryController =
      StreamController<DiscoveryResultModel>.broadcast();

  // Mock data for simulation
  final List<String> _mockDeviceNames = [
    'John\'s iPhone',
    'Sarah\'s MacBook',
    'Gaming Desktop',
    'Office Laptop',
    'Android Phone',
    'iPad Pro',
    'Work Station',
    'Home PC',
  ];

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeDeviceInfo();
      _startPeriodicUpdates();
      _isInitialized = true;

      LoggerService.instance.info(
        'NearbyDevicesDataSource initialized successfully',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Failed to initialize NearbyDevicesDataSource: $e',
      );
      throw DiscoveryException(
        'Failed to initialize device discovery',
        originalException: e,
      );
    }
  }

  Future<void> _initializeDeviceInfo() async {
    try {
      _deviceId = await _generateDeviceId();

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceName = iosInfo.name;
      } else {
        _deviceName = 'Unknown Device';
      }
    } catch (e) {
      LoggerService.instance.error('Failed to initialize device info: $e');
      throw DiscoveryException('Failed to get device information');
    }
  }

  Future<String> _generateDeviceId() async {
    try {
      String identifier = '';

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        identifier = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        identifier = iosInfo.identifierForVendor ?? '';
      }

      if (identifier.isEmpty) {
        identifier = 'device_${DateTime.now().millisecondsSinceEpoch}';
      }

      return identifier;
    } catch (e) {
      return 'device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  void _startPeriodicUpdates() {
    // Update signal strengths periodically
    _signalUpdateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateSignalStrengths();
    });
  }

  void _updateSignalStrengths() {
    if (!_isDiscovering) return;

    final random = Random();
    final updatedDevices = <String, DeviceModel>{};

    for (final entry in _discoveredDevices.entries) {
      final device = entry.value;
      // Simulate signal strength variation (±10%)
      final variation = (random.nextDouble() - 0.5) * 20;
      final newSignalStrength = (device.signalStrength + variation)
          .clamp(10, 100)
          .round();

      updatedDevices[entry.key] = device.copyWith(
        signalStrength: newSignalStrength,
        lastSeen: DateTime.now(),
      );
    }

    _discoveredDevices.addAll(updatedDevices);
    _emitDiscoveryResult();
  }

  @override
  Future<void> startDiscovery({
    required ConnectionType method,
    required Duration timeout,
  }) async {
    if (_isDiscovering) {
      throw const DiscoveryException('Discovery is already in progress');
    }

    if (!await hasRequiredPermissions()) {
      throw const PermissionException(
        'Required permissions not granted',
        'location',
      );
    }

    try {
      _isDiscovering = true;
      _currentDiscoveryMethod = method;
      _discoveryStartTime = DateTime.now();
      _discoveredDevices.clear();

      LoggerService.instance.info(
        'Starting discovery with method: ${method.name}',
      );

      // Emit initial active discovery state
      _emitDiscoveryResult();

      // Start discovery simulation
      _startDiscoverySimulation(method);

      // Set timeout
      _discoveryTimer = Timer(timeout, () async {
        await stopDiscovery();
      });
    } catch (e) {
      _isDiscovering = false;
      LoggerService.instance.error('Failed to start discovery: $e');
      throw DiscoveryException('Failed to start discovery: ${e.toString()}');
    }
  }

  void _startDiscoverySimulation(ConnectionType method) {
    // Simulate device discovery based on method
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isDiscovering) {
        timer.cancel();
        return;
      }

      _simulateDeviceDiscovery(method);
    });
  }

  void _simulateDeviceDiscovery(ConnectionType method) {
    final random = Random();

    // 30% chance to discover a new device each cycle
    if (random.nextDouble() < 0.3 && _discoveredDevices.length < 8) {
      final device = _generateMockDevice(method);
      _discoveredDevices[device.id] = device;

      LoggerService.instance.debug('Discovered device: ${device.name}');
      _emitDiscoveryResult();
    }

    // 10% chance to lose a device
    if (random.nextDouble() < 0.1 && _discoveredDevices.isNotEmpty) {
      final deviceId = _discoveredDevices.keys.first;
      _discoveredDevices.remove(deviceId);

      LoggerService.instance.debug('Lost device: $deviceId');
      _emitDiscoveryResult();
    }
  }

  DeviceModel _generateMockDevice(ConnectionType method) {
    final random = Random();
    final deviceName =
        _mockDeviceNames[random.nextInt(_mockDeviceNames.length)];
    final deviceTypes = ['android', 'ios', 'windows', 'macos'];
    final deviceType = deviceTypes[random.nextInt(deviceTypes.length)];

    final capabilities = <String, dynamic>{
      'file_transfer': true,
      'audio': random.nextBool(),
      'video': random.nextBool(),
    };

    // Add method-specific capabilities
    switch (method) {
      case ConnectionType.nearbyConnections:
        capabilities['nearby_connections'] = true;
        break;
      case ConnectionType.wifiDirect:
        capabilities['wifi_direct'] = true;
        break;
      case ConnectionType.wifiHotspot:
        capabilities['wifi_hotspot'] = true;
        break;
      case ConnectionType.bluetooth:
        capabilities['bluetooth'] = true;
        break;
      default:
        capabilities['nearby_connections'] = true;
    }

    return DeviceModel(
      id: 'device_${random.nextInt(10000)}',
      name: deviceName,
      type: deviceType,
      signalStrength: 50 + random.nextInt(50), // 50-100%
      isConnectable: true,
      isConnected: false,
      lastSeen: DateTime.now(),
      capabilities: capabilities,
      endpointId: method == ConnectionType.nearbyConnections
          ? 'endpoint_${random.nextInt(1000)}'
          : null,
      distance: random.nextDouble() * 100, // 0-100 meters
      ipAddress:
          method == ConnectionType.wifiDirect ||
              method == ConnectionType.wifiHotspot
          ? '192.168.${random.nextInt(255)}.${random.nextInt(255)}'
          : null,
    );
  }

  @override
  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;

    try {
      _isDiscovering = false;
      _discoveryTimer?.cancel();
      _discoveryTimer = null;

      LoggerService.instance.info('Discovery stopped');

      // Emit final discovery result
      _emitDiscoveryResult();
    } catch (e) {
      LoggerService.instance.error('Failed to stop discovery: $e');
      throw DiscoveryException('Failed to stop discovery: ${e.toString()}');
    }
  }

  @override
  Future<void> startAdvertising({
    String? deviceName,
    required Duration timeout,
  }) async {
    if (_isAdvertising) {
      throw const DiscoveryException('Advertising is already active');
    }

    if (!await hasRequiredPermissions()) {
      throw const PermissionException(
        'Required permissions not granted',
        'location',
      );
    }

    try {
      _isAdvertising = true;

      if (deviceName != null) {
        _deviceName = deviceName;
      }

      LoggerService.instance.info('Started advertising as: $_deviceName');

      // Set timeout
      _advertisingTimer = Timer(timeout, () async {
        await stopAdvertising();
      });
    } catch (e) {
      _isAdvertising = false;
      LoggerService.instance.error('Failed to start advertising: $e');
      throw DiscoveryException('Failed to start advertising: ${e.toString()}');
    }
  }

  @override
  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;

    try {
      _isAdvertising = false;
      _advertisingTimer?.cancel();
      _advertisingTimer = null;

      LoggerService.instance.info('Advertising stopped');
    } catch (e) {
      LoggerService.instance.error('Failed to stop advertising: $e');
      throw DiscoveryException('Failed to stop advertising: ${e.toString()}');
    }
  }

  void _emitDiscoveryResult() {
    final now = DateTime.now();
    final devices = _discoveredDevices.values.toList();

    final result = DiscoveryResultModel(
      devices: devices,
      discoveryMethod: _currentDiscoveryMethod?.name ?? 'unknown',
      startTime: _discoveryStartTime ?? now,
      endTime: _isDiscovering ? null : now,
      isActive: _isDiscovering,
      metadata: {
        'scanning': _isDiscovering,
        'method': _currentDiscoveryMethod?.name ?? 'unknown',
        'device_count': devices.length,
        'connectable_count': devices.where((d) => d.isConnectable).length,
      },
    );

    _discoveryController.add(result);
  }

  @override
  Stream<DiscoveryResultModel> get discoveryResultStream =>
      _discoveryController.stream;

  @override
  bool get isDiscovering => _isDiscovering;

  @override
  bool get isAdvertising => _isAdvertising;

  @override
  List<DeviceModel> getCachedDevices() {
    return _discoveredDevices.values.toList();
  }

  @override
  Future<void> clearCache() async {
    _discoveredDevices.clear();
    LoggerService.instance.info('Discovery cache cleared');
  }

  @override
  Future<bool> hasRequiredPermissions() async {
    try {
      final locationStatus = await Permission.location.status;
      final bluetoothStatus = await Permission.bluetooth.status;

      return locationStatus.isGranted && bluetoothStatus.isGranted;
    } catch (e) {
      LoggerService.instance.error('Failed to check permissions: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.nearbyWifiDevices,
      ].request();

      final allGranted = statuses.values.every(
        (status) => status.isGranted || status.isLimited,
      );

      LoggerService.instance.info(
        'Permission request result: ${allGranted ? 'granted' : 'denied'}',
      );

      return allGranted;
    } catch (e) {
      LoggerService.instance.error('Failed to request permissions: $e');
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await stopDiscovery();
      await stopAdvertising();

      _discoveryTimer?.cancel();
      _advertisingTimer?.cancel();
      _signalUpdateTimer?.cancel();

      await _discoveryController.close();

      LoggerService.instance.info('NearbyDevicesDataSource disposed');
    } catch (e) {
      LoggerService.instance.error(
        'Error disposing NearbyDevicesDataSource: $e',
      );
    }
  }
}
