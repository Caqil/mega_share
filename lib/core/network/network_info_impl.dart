import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../injection/register_modules.dart';
import 'network_info.dart';

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }

  @override
  Future<String?> get connectionType async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.wifi)) {
      return 'wifi';
    } else if (result.contains(ConnectivityResult.mobile)) {
      return 'mobile';
    } else if (result.contains(ConnectivityResult.ethernet)) {
      return 'ethernet';
    }
    return null;
  }

  @override
  Future<String?> get wifiName async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.wifi)) {
      // Implementation would use platform channels to get actual SSID
      return 'WiFi Network';
    }
    return null;
  }

  @override
  Future<String?> get wifiBSSID async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.wifi)) {
      // Implementation would use platform channels to get actual BSSID
      return 'AA:BB:CC:DD:EE:FF';
    }
    return null;
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      return result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);
    });
  }
}
