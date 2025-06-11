import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../constants/connection_constants.dart';
import '../services/logger_service.dart';

/// Network information and connectivity status provider
class AppNetworkInfo {
  final Connectivity _connectivity;
  final NetworkInfo _networkInfo;
  final LoggerService _logger;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<NetworkStatus> _networkStatusController =
      StreamController<NetworkStatus>.broadcast();

  NetworkStatus _currentStatus = NetworkStatus.unknown;

  AppNetworkInfo({
    Connectivity? connectivity,
    NetworkInfo? networkInfo,
    LoggerService? logger,
  }) : _connectivity = connectivity ?? Connectivity(),
       _networkInfo = networkInfo ?? NetworkInfo(),
       _logger = logger ?? LoggerService.instance;

  /// Stream of network status changes
  Stream<NetworkStatus> get networkStatusStream =>
      _networkStatusController.stream;

  /// Current network status
  NetworkStatus get currentStatus => _currentStatus;

  /// Initialize network monitoring
  Future<void> initialize() async {
    try {
      // Get initial connectivity status
      final results = await _connectivity.checkConnectivity();
      await _updateNetworkStatus(results);

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateNetworkStatus,
        onError: (error) {
          _logger.error('Connectivity stream error: $error');
          _updateNetworkStatus([ConnectivityResult.none]);
        },
      );

      _logger.info('NetworkInfo initialized with status: $_currentStatus');
    } catch (e) {
      _logger.error('Failed to initialize NetworkInfo: $e');
      _currentStatus = NetworkStatus.unknown;
      _networkStatusController.add(_currentStatus);
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _networkStatusController.close();
  }

  /// Check if device is connected to internet
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none) && results.isNotEmpty;
    } catch (e) {
      _logger.error('Error checking connectivity: $e');
      return false;
    }
  }

  /// Check if device has internet access (ping test)
  Future<bool> hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _logger.debug('Internet access check failed: $e');
      return false;
    }
  }

  /// Get current connectivity types
  Future<List<ConnectivityResult>> getConnectivityTypes() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      _logger.error('Error getting connectivity types: $e');
      return [ConnectivityResult.none];
    }
  }

  /// Get primary connectivity type
  Future<ConnectivityResult> getPrimaryConnectivityType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty) return ConnectivityResult.none;

      // Prioritize WiFi over mobile
      if (results.contains(ConnectivityResult.wifi)) {
        return ConnectivityResult.wifi;
      }
      if (results.contains(ConnectivityResult.mobile)) {
        return ConnectivityResult.mobile;
      }
      if (results.contains(ConnectivityResult.ethernet)) {
        return ConnectivityResult.ethernet;
      }

      return results.first;
    } catch (e) {
      _logger.error('Error getting primary connectivity type: $e');
      return ConnectivityResult.none;
    }
  }

  /// Get WiFi information
  Future<WiFiInfo?> getWiFiInfo() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      if (!connectivityResults.contains(ConnectivityResult.wifi)) {
        return null;
      }

      final wifiName = await _networkInfo.getWifiName();
      final wifiBSSID = await _networkInfo.getWifiBSSID();
      final wifiIP = await _networkInfo.getWifiIP();
      final wifiGateway = await _networkInfo.getWifiGatewayIP();
      final wifiSubmask = await _networkInfo.getWifiSubmask();
      final wifiBroadcast = await _networkInfo.getWifiBroadcast();

      return WiFiInfo(
        ssid: wifiName,
        bssid: wifiBSSID,
        ipAddress: wifiIP,
        gatewayIP: wifiGateway,
        submask: wifiSubmask,
        broadcast: wifiBroadcast,
      );
    } catch (e) {
      _logger.error('Error getting WiFi info: $e');
      return null;
    }
  }

  /// Get mobile network information
  Future<MobileInfo?> getMobileInfo() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      if (!connectivityResults.contains(ConnectivityResult.mobile)) {
        return null;
      }

      // Note: Mobile network details are limited on mobile platforms
      return MobileInfo(
        networkType: ConnectivityResult.mobile,
        hasStrongSignal:
            true, // This would need platform-specific implementation
      );
    } catch (e) {
      _logger.error('Error getting mobile info: $e');
      return null;
    }
  }

  /// Get network speed estimation (rough)
  Future<NetworkSpeed> estimateNetworkSpeed() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      // Prioritize the best available connection
      if (connectivityResults.contains(ConnectivityResult.ethernet)) {
        return NetworkSpeed.high;
      }
      if (connectivityResults.contains(ConnectivityResult.wifi)) {
        return NetworkSpeed.high;
      }
      if (connectivityResults.contains(ConnectivityResult.mobile)) {
        return NetworkSpeed.medium;
      }
      if (connectivityResults.contains(ConnectivityResult.bluetooth)) {
        return NetworkSpeed.low;
      }

      return NetworkSpeed.none;
    } catch (e) {
      _logger.error('Error estimating network speed: $e');
      return NetworkSpeed.none;
    }
  }

  /// Check if current network is suitable for file transfer
  Future<bool> isSuitableForTransfer() async {
    try {
      final isConnected = await this.isConnected;
      if (!isConnected) return false;

      final speed = await estimateNetworkSpeed();
      return speed != NetworkSpeed.none && speed != NetworkSpeed.low;
    } catch (e) {
      _logger.error('Error checking transfer suitability: $e');
      return false;
    }
  }

  /// Update network status based on connectivity results
  Future<void> _updateNetworkStatus(List<ConnectivityResult> results) async {
    try {
      NetworkStatus newStatus;

      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        newStatus = NetworkStatus.disconnected;
      } else {
        // Prioritize the best available connection type
        if (results.contains(ConnectivityResult.wifi)) {
          newStatus = NetworkStatus.wifi;
        } else if (results.contains(ConnectivityResult.ethernet)) {
          newStatus = NetworkStatus.ethernet;
        } else if (results.contains(ConnectivityResult.mobile)) {
          newStatus = NetworkStatus.mobile;
        } else if (results.contains(ConnectivityResult.bluetooth)) {
          newStatus = NetworkStatus.bluetooth;
        } else {
          newStatus = NetworkStatus.unknown;
        }
      }

      if (_currentStatus != newStatus) {
        _currentStatus = newStatus;
        _networkStatusController.add(_currentStatus);
        _logger.info('Network status changed to: $_currentStatus');
      }
    } catch (e) {
      _logger.error('Error updating network status: $e');
    }
  }
}

/// Network status enumeration
enum NetworkStatus { wifi, mobile, ethernet, bluetooth, disconnected, unknown }

/// Network speed enumeration
enum NetworkSpeed {
  high, // WiFi, Ethernet
  medium, // Mobile 4G/5G
  low, // Mobile 2G/3G, Bluetooth
  none, // No connection
}

/// WiFi network information
class WiFiInfo {
  final String? ssid;
  final String? bssid;
  final String? ipAddress;
  final String? gatewayIP;
  final String? submask;
  final String? broadcast;

  const WiFiInfo({
    this.ssid,
    this.bssid,
    this.ipAddress,
    this.gatewayIP,
    this.submask,
    this.broadcast,
  });

  bool get isValid => ssid != null && ipAddress != null;

  @override
  String toString() {
    return 'WiFiInfo(ssid: $ssid, ip: $ipAddress, gateway: $gatewayIP)';
  }
}

/// Mobile network information
class MobileInfo {
  final ConnectivityResult networkType;
  final bool hasStrongSignal;

  const MobileInfo({required this.networkType, required this.hasStrongSignal});

  @override
  String toString() {
    return 'MobileInfo(type: $networkType, strongSignal: $hasStrongSignal)';
  }
}
