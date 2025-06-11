import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_constants.dart';
import '../services/logger_service.dart';
import 'network_info.dart';

/// Advanced connection checker with ping capabilities
class ConnectionChecker {
  final NetworkInfo _networkInfo;
  final LoggerService _logger;

  static const List<String> _defaultHosts = [
    'google.com',
    'cloudflare.com',
    '8.8.8.8',
  ];

  static const Duration _defaultTimeout = Duration(seconds: 10);
  static const int _defaultPort = 53; // DNS port

  ConnectionChecker({NetworkInfo? networkInfo, LoggerService? logger})
    : _networkInfo = networkInfo ?? NetworkInfo(),
      _logger = logger ?? LoggerService();

  /// Check internet connectivity with ping
  Future<bool> hasInternetConnection({
    List<String>? hosts,
    Duration? timeout,
    int? port,
  }) async {
    try {
      final testHosts = hosts ?? _defaultHosts;
      final testTimeout = timeout ?? _defaultTimeout;
      final testPort = port ?? _defaultPort;

      // First check basic connectivity
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        _logger.debug('No basic connectivity');
        return false;
      }

      // Test internet access with multiple hosts
      for (final host in testHosts) {
        try {
          final result = await _pingHost(host, testPort, testTimeout);
          if (result) {
            _logger.debug('Internet connection verified via $host');
            return true;
          }
        } catch (e) {
          _logger.debug('Failed to ping $host: $e');
          continue;
        }
      }

      _logger.debug('All ping tests failed');
      return false;
    } catch (e) {
      _logger.error('Error checking internet connection: $e');
      return false;
    }
  }

  /// Check connection to a specific host
  Future<bool> canReachHost(String host, {int? port, Duration? timeout}) async {
    try {
      return await _pingHost(
        host,
        port ?? _defaultPort,
        timeout ?? _defaultTimeout,
      );
    } catch (e) {
      _logger.error('Error reaching host $host: $e');
      return false;
    }
  }

  /// Get connection quality metrics
  Future<ConnectionQuality> getConnectionQuality() async {
    try {
      final startTime = DateTime.now();

      // Test basic connectivity
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return ConnectionQuality.none;
      }

      // Test internet access with latency measurement
      bool hasInternet = false;
      int totalLatency = 0;
      int successfulPings = 0;

      for (final host in _defaultHosts.take(2)) {
        final pingStart = DateTime.now();
        final canReach = await _pingHost(host, _defaultPort, _defaultTimeout);

        if (canReach) {
          hasInternet = true;
          final latency = DateTime.now().difference(pingStart).inMilliseconds;
          totalLatency += latency;
          successfulPings++;
        }
      }

      if (!hasInternet) {
        return ConnectionQuality.none;
      }

      // Calculate average latency
      final avgLatency = successfulPings > 0
          ? totalLatency ~/ successfulPings
          : 1000;

      // Determine quality based on latency and network type
      final networkStatus = _networkInfo.currentStatus;

      if (avgLatency < 50) {
        return networkStatus == NetworkStatus.wifi ||
                networkStatus == NetworkStatus.ethernet
            ? ConnectionQuality.excellent
            : ConnectionQuality.good;
      } else if (avgLatency < 150) {
        return ConnectionQuality.good;
      } else if (avgLatency < 300) {
        return ConnectionQuality.fair;
      } else {
        return ConnectionQuality.poor;
      }
    } catch (e) {
      _logger.error('Error getting connection quality: $e');
      return ConnectionQuality.unknown;
    }
  }

  /// Monitor connection status with periodic checks
  Stream<ConnectionStatus> monitorConnection({
    Duration checkInterval = const Duration(seconds: 30),
    List<String>? hosts,
  }) async* {
    final testHosts = hosts ?? _defaultHosts;

    while (true) {
      try {
        final hasInternet = await hasInternetConnection(hosts: testHosts);
        final quality = await getConnectionQuality();
        final networkStatus = _networkInfo.currentStatus;

        yield ConnectionStatus(
          isConnected: hasInternet,
          networkType: networkStatus,
          quality: quality,
          timestamp: DateTime.now(),
        );

        await Future.delayed(checkInterval);
      } catch (e) {
        _logger.error('Error in connection monitoring: $e');
        yield ConnectionStatus(
          isConnected: false,
          networkType: NetworkStatus.unknown,
          quality: ConnectionQuality.unknown,
          timestamp: DateTime.now(),
        );
        await Future.delayed(checkInterval);
      }
    }
  }

  /// Wait for internet connection to be available
  Future<bool> waitForConnection({
    Duration timeout = const Duration(minutes: 2),
    Duration checkInterval = const Duration(seconds: 5),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      final hasConnection = await hasInternetConnection();
      if (hasConnection) {
        return true;
      }

      await Future.delayed(checkInterval);
    }

    return false;
  }

  /// Ping a specific host and port
  Future<bool> _pingHost(String host, int port, Duration timeout) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get detailed network diagnostics
  Future<NetworkDiagnostics> getDiagnostics() async {
    try {
      final startTime = DateTime.now();

      // Basic connectivity
      final isConnected = await _networkInfo.isConnected;
      final networkType = _networkInfo.currentStatus;

      // WiFi info if available
      WiFiInfo? wifiInfo;
      if (networkType == NetworkStatus.wifi) {
        wifiInfo = await _networkInfo.getWiFiInfo();
      }

      // Internet connectivity
      final hasInternet = await hasInternetConnection();

      // Connection quality
      final quality = await getConnectionQuality();

      // DNS resolution test
      bool dnsWorking = false;
      try {
        await InternetAddress.lookup('google.com');
        dnsWorking = true;
      } catch (e) {
        _logger.debug('DNS resolution failed: $e');
      }

      final diagnosticsTime = DateTime.now().difference(startTime);

      return NetworkDiagnostics(
        isConnected: isConnected,
        hasInternet: hasInternet,
        networkType: networkType,
        quality: quality,
        dnsWorking: dnsWorking,
        wifiInfo: wifiInfo,
        diagnosticsTime: diagnosticsTime,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.error('Error getting network diagnostics: $e');
      return NetworkDiagnostics(
        isConnected: false,
        hasInternet: false,
        networkType: NetworkStatus.unknown,
        quality: ConnectionQuality.unknown,
        dnsWorking: false,
        diagnosticsTime: Duration.zero,
        timestamp: DateTime.now(),
      );
    }
  }
}

/// Connection quality levels
enum ConnectionQuality { excellent, good, fair, poor, none, unknown }

/// Connection status information
class ConnectionStatus {
  final bool isConnected;
  final NetworkStatus networkType;
  final ConnectionQuality quality;
  final DateTime timestamp;

  const ConnectionStatus({
    required this.isConnected,
    required this.networkType,
    required this.quality,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'ConnectionStatus(connected: $isConnected, type: $networkType, quality: $quality)';
  }
}

/// Detailed network diagnostics
class NetworkDiagnostics {
  final bool isConnected;
  final bool hasInternet;
  final NetworkStatus networkType;
  final ConnectionQuality quality;
  final bool dnsWorking;
  final WiFiInfo? wifiInfo;
  final Duration diagnosticsTime;
  final DateTime timestamp;

  const NetworkDiagnostics({
    required this.isConnected,
    required this.hasInternet,
    required this.networkType,
    required this.quality,
    required this.dnsWorking,
    this.wifiInfo,
    required this.diagnosticsTime,
    required this.timestamp,
  });

  bool get isHealthy => isConnected && hasInternet && dnsWorking;

  @override
  String toString() {
    return 'NetworkDiagnostics(connected: $isConnected, internet: $hasInternet, '
        'type: $networkType, quality: $quality, dns: $dnsWorking)';
  }
}
