import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../constants/connection_constants.dart';
import '../services/logger_service.dart';

/// Device information utility class
class DeviceInfoUtils {
  static final LoggerService _logger = LoggerService.instance;
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static DeviceInfo? _cachedDeviceInfo;

  /// Get comprehensive device information
  static Future<DeviceInfo> getDeviceInfo() async {
    if (_cachedDeviceInfo != null) {
      return _cachedDeviceInfo!;
    }

    try {
      if (Platform.isAndroid) {
        _cachedDeviceInfo = await _getAndroidDeviceInfo();
      } else if (Platform.isIOS) {
        _cachedDeviceInfo = await _getIOSDeviceInfo();
      } else if (Platform.isWindows) {
        _cachedDeviceInfo = await _getWindowsDeviceInfo();
      } else if (Platform.isMacOS) {
        _cachedDeviceInfo = await _getMacOSDeviceInfo();
      } else if (Platform.isLinux) {
        _cachedDeviceInfo = await _getLinuxDeviceInfo();
      } else {
        _cachedDeviceInfo = _getUnknownDeviceInfo();
      }

      _logger.info('Device info retrieved: ${_cachedDeviceInfo!.deviceName}');
      return _cachedDeviceInfo!;
    } catch (e) {
      _logger.error('Failed to get device info: $e');
      _cachedDeviceInfo = _getUnknownDeviceInfo();
      return _cachedDeviceInfo!;
    }
  }

  /// Get device type
  static Future<DeviceType> getDeviceType() async {
    try {
      if (Platform.isAndroid) {
        return DeviceType.android;
      } else if (Platform.isIOS) {
        return DeviceType.ios;
      } else if (Platform.isWindows) {
        return DeviceType.windows;
      } else if (Platform.isMacOS) {
        return DeviceType.macos;
      } else if (Platform.isLinux) {
        return DeviceType.linux;
      } else {
        return DeviceType.unknown;
      }
    } catch (e) {
      _logger.error('Failed to get device type: $e');
      return DeviceType.unknown;
    }
  }

  /// Get device name for display
  static Future<String> getDeviceName() async {
    try {
      final deviceInfo = await getDeviceInfo();
      return deviceInfo.deviceName;
    } catch (e) {
      _logger.error('Failed to get device name: $e');
      return 'Unknown Device';
    }
  }

  /// Get device model
  static Future<String> getDeviceModel() async {
    try {
      final deviceInfo = await getDeviceInfo();
      return deviceInfo.model;
    } catch (e) {
      _logger.error('Failed to get device model: $e');
      return 'Unknown Model';
    }
  }

  /// Get operating system version
  static Future<String> getOSVersion() async {
    try {
      final deviceInfo = await getDeviceInfo();
      return deviceInfo.osVersion;
    } catch (e) {
      _logger.error('Failed to get OS version: $e');
      return 'Unknown Version';
    }
  }

  /// Get device identifier (unique ID)
  static Future<String> getDeviceId() async {
    try {
      final deviceInfo = await getDeviceInfo();
      return deviceInfo.identifier;
    } catch (e) {
      _logger.error('Failed to get device ID: $e');
      return 'unknown-device';
    }
  }

  /// Check if device is physical (not emulator/simulator)
  static Future<bool> isPhysicalDevice() async {
    try {
      final deviceInfo = await getDeviceInfo();
      return deviceInfo.isPhysicalDevice;
    } catch (e) {
      _logger.error('Failed to check if physical device: $e');
      return true; // Assume physical by default
    }
  }

  /// Get device capabilities
  static Future<Map<String, bool>> getDeviceCapabilities() async {
    try {
      final deviceInfo = await getDeviceInfo();
      return deviceInfo.capabilities;
    } catch (e) {
      _logger.error('Failed to get device capabilities: $e');
      return {};
    }
  }

  /// Get network interface name for the device
  static Future<String?> getNetworkInterfaceName() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        if (interface.name.toLowerCase().contains('wlan') ||
            interface.name.toLowerCase().contains('wifi') ||
            interface.name.toLowerCase().contains('eth')) {
          return interface.name;
        }
      }
      return interfaces.isNotEmpty ? interfaces.first.name : null;
    } catch (e) {
      _logger.error('Failed to get network interface: $e');
      return null;
    }
  }

  /// Get device's IP addresses
  static Future<List<String>> getIPAddresses() async {
    try {
      final interfaces = await NetworkInterface.list();
      final addresses = <String>[];

      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4) {
            addresses.add(address.address);
          }
        }
      }

      return addresses;
    } catch (e) {
      _logger.error('Failed to get IP addresses: $e');
      return [];
    }
  }

  /// Get primary WiFi IP address
  static Future<String?> getWiFiIPAddress() async {
    try {
      final interfaces = await NetworkInterface.list();

      for (final interface in interfaces) {
        if (interface.name.toLowerCase().contains('wlan') ||
            interface.name.toLowerCase().contains('wifi')) {
          for (final address in interface.addresses) {
            if (address.type == InternetAddressType.IPv4 &&
                !address.isLoopback) {
              return address.address;
            }
          }
        }
      }

      // Fallback to any non-loopback IPv4 address
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
            return address.address;
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Failed to get WiFi IP address: $e');
      return null;
    }
  }

  /// Clear cached device info (force refresh)
  static void clearCache() {
    _cachedDeviceInfo = null;
    _logger.debug('Device info cache cleared');
  }

  /// Get Android device information
  static Future<DeviceInfo> _getAndroidDeviceInfo() async {
    final androidInfo = await _deviceInfo.androidInfo;

    return DeviceInfo(
      deviceName: _getAndroidDeviceName(androidInfo),
      model: androidInfo.model,
      manufacturer: androidInfo.manufacturer,
      osVersion: 'Android ${androidInfo.version.release}',
      osVersionCode: androidInfo.version.sdkInt.toString(),
      identifier: androidInfo.id,
      isPhysicalDevice: androidInfo.isPhysicalDevice,
      platform: 'Android',
      platformVersion: androidInfo.version.release,
      capabilities: {
        'nearby_connections': true,
        'wifi_direct': true,
        'wifi_hotspot': true,
        'bluetooth': true,
        'qr_code': true,
      },
      additionalInfo: {
        'brand': androidInfo.brand,
        'device': androidInfo.device,
        'hardware': androidInfo.hardware,
        'product': androidInfo.product,
        'androidId': androidInfo.id,
        'bootloader': androidInfo.bootloader,
        'fingerprint': androidInfo.fingerprint,
        'host': androidInfo.host,
        'supported32BitAbis': androidInfo.supported32BitAbis,
        'supported64BitAbis': androidInfo.supported64BitAbis,
        'supportedAbis': androidInfo.supportedAbis,
      },
    );
  }

  /// Get iOS device information
  static Future<DeviceInfo> _getIOSDeviceInfo() async {
    final iosInfo = await _deviceInfo.iosInfo;

    return DeviceInfo(
      deviceName: iosInfo.name,
      model: iosInfo.model,
      manufacturer: 'Apple',
      osVersion: 'iOS ${iosInfo.systemVersion}',
      osVersionCode: iosInfo.systemVersion,
      identifier: iosInfo.identifierForVendor ?? 'unknown',
      isPhysicalDevice: iosInfo.isPhysicalDevice,
      platform: 'iOS',
      platformVersion: iosInfo.systemVersion,
      capabilities: {
        'nearby_connections': false, // Not available on iOS
        'wifi_direct': false,
        'wifi_hotspot': false,
        'bluetooth': true,
        'qr_code': true,
      },
      additionalInfo: {
        'localizedModel': iosInfo.localizedModel,
        'systemName': iosInfo.systemName,
        'utsname': {
          'sysname': iosInfo.utsname.sysname,
          'nodename': iosInfo.utsname.nodename,
          'release': iosInfo.utsname.release,
          'version': iosInfo.utsname.version,
          'machine': iosInfo.utsname.machine,
        },
      },
    );
  }

  /// Get Windows device information
  static Future<DeviceInfo> _getWindowsDeviceInfo() async {
    final windowsInfo = await _deviceInfo.windowsInfo;

    return DeviceInfo(
      deviceName: windowsInfo.computerName,
      model: 'PC',
      manufacturer: 'Microsoft',
      osVersion: 'Windows ${windowsInfo.productName}',
      osVersionCode: windowsInfo.buildNumber.toString(),
      identifier: windowsInfo.deviceId,
      isPhysicalDevice: true,
      platform: 'Windows',
      platformVersion: windowsInfo.productName,
      capabilities: {
        'nearby_connections': false,
        'wifi_direct': true,
        'wifi_hotspot': true,
        'bluetooth': true,
        'qr_code': true,
      },
      additionalInfo: {
        'numberOfCores': windowsInfo.numberOfCores,
        'computerName': windowsInfo.computerName,
        'systemMemoryInMegabytes': windowsInfo.systemMemoryInMegabytes,
        'userName': windowsInfo.userName,
        'majorVersion': windowsInfo.majorVersion,
        'minorVersion': windowsInfo.minorVersion,
        'buildNumber': windowsInfo.buildNumber,
        'csdVersion': windowsInfo.csdVersion,
      },
    );
  }

  /// Get macOS device information
  static Future<DeviceInfo> _getMacOSDeviceInfo() async {
    final macInfo = await _deviceInfo.macOsInfo;

    return DeviceInfo(
      deviceName: macInfo.computerName,
      model: macInfo.model,
      manufacturer: 'Apple',
      osVersion: 'macOS ${macInfo.osRelease}',
      osVersionCode: macInfo.osRelease,
      identifier: macInfo.systemGUID ?? 'unknown',
      isPhysicalDevice: true,
      platform: 'macOS',
      platformVersion: macInfo.osRelease,
      capabilities: {
        'nearby_connections': false,
        'wifi_direct': false,
        'wifi_hotspot': true,
        'bluetooth': true,
        'qr_code': true,
      },
      additionalInfo: {
        'arch': macInfo.arch,
        'kernelVersion': macInfo.kernelVersion,
        'majorVersion': macInfo.majorVersion,
        'minorVersion': macInfo.minorVersion,
        'patchVersion': macInfo.patchVersion,
        'activeCPUs': macInfo.activeCPUs,
        'memorySize': macInfo.memorySize,
        'cpuFrequency': macInfo.cpuFrequency,
      },
    );
  }

  /// Get Linux device information
  static Future<DeviceInfo> _getLinuxDeviceInfo() async {
    final linuxInfo = await _deviceInfo.linuxInfo;

    return DeviceInfo(
      deviceName: linuxInfo.name,
      model: 'Linux PC',
      manufacturer: 'Linux',
      osVersion: '${linuxInfo.name} ${linuxInfo.version}',
      osVersionCode: linuxInfo.version ?? 'unknown',
      identifier: linuxInfo.machineId ?? 'unknown',
      isPhysicalDevice: true,
      platform: 'Linux',
      platformVersion: linuxInfo.version ?? 'unknown',
      capabilities: {
        'nearby_connections': false,
        'wifi_direct': false,
        'wifi_hotspot': true,
        'bluetooth': true,
        'qr_code': true,
      },
      additionalInfo: {
        'buildId': linuxInfo.buildId,
        'id': linuxInfo.id,
        'idLike': linuxInfo.idLike,
        'prettyName': linuxInfo.prettyName,
        'variant': linuxInfo.variant,
        'variantId': linuxInfo.variantId,
        'versionCodename': linuxInfo.versionCodename,
        'versionId': linuxInfo.versionId,
      },
    );
  }

  /// Get unknown device information
  static DeviceInfo _getUnknownDeviceInfo() {
    return DeviceInfo(
      deviceName: 'Unknown Device',
      model: 'Unknown',
      manufacturer: 'Unknown',
      osVersion: 'Unknown',
      osVersionCode: 'unknown',
      identifier: 'unknown-${DateTime.now().millisecondsSinceEpoch}',
      isPhysicalDevice: true,
      platform: 'Unknown',
      platformVersion: 'unknown',
      capabilities: {'qr_code': true},
      additionalInfo: {},
    );
  }

  /// Get Android device name with fallback
  static String _getAndroidDeviceName(AndroidDeviceInfo androidInfo) {
    // Try to create a meaningful device name
    String deviceName = '';

    if (androidInfo.brand.isNotEmpty && androidInfo.model.isNotEmpty) {
      deviceName = '${androidInfo.brand} ${androidInfo.model}';
    } else if (androidInfo.model.isNotEmpty) {
      deviceName = androidInfo.model;
    } else if (androidInfo.product.isNotEmpty) {
      deviceName = androidInfo.product;
    } else {
      deviceName = 'Android Device';
    }

    return deviceName;
  }
}

/// Device information data class
class DeviceInfo {
  final String deviceName;
  final String model;
  final String manufacturer;
  final String osVersion;
  final String osVersionCode;
  final String identifier;
  final bool isPhysicalDevice;
  final String platform;
  final String platformVersion;
  final Map<String, bool> capabilities;
  final Map<String, dynamic> additionalInfo;

  const DeviceInfo({
    required this.deviceName,
    required this.model,
    required this.manufacturer,
    required this.osVersion,
    required this.osVersionCode,
    required this.identifier,
    required this.isPhysicalDevice,
    required this.platform,
    required this.platformVersion,
    required this.capabilities,
    required this.additionalInfo,
  });

  /// Get device type enum
  DeviceType get deviceType {
    switch (platform.toLowerCase()) {
      case 'android':
        return DeviceType.android;
      case 'ios':
        return DeviceType.ios;
      case 'windows':
        return DeviceType.windows;
      case 'macos':
        return DeviceType.macos;
      case 'linux':
        return DeviceType.linux;
      default:
        return DeviceType.unknown;
    }
  }

  /// Check if device supports a specific capability
  bool supportsCapability(String capability) {
    return capabilities[capability] ?? false;
  }

  /// Get display name for the device
  String get displayName {
    if (deviceName.isNotEmpty && deviceName != 'Unknown Device') {
      return deviceName;
    }
    return '$manufacturer $model';
  }

  /// Get short display name
  String get shortDisplayName {
    if (model.isNotEmpty && model != 'Unknown') {
      return model;
    }
    return deviceName;
  }

  @override
  String toString() {
    return 'DeviceInfo(name: $deviceName, model: $model, platform: $platform $osVersion)';
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'deviceName': deviceName,
      'model': model,
      'manufacturer': manufacturer,
      'osVersion': osVersion,
      'osVersionCode': osVersionCode,
      'identifier': identifier,
      'isPhysicalDevice': isPhysicalDevice,
      'platform': platform,
      'platformVersion': platformVersion,
      'capabilities': capabilities,
      'additionalInfo': additionalInfo,
    };
  }

  /// Create from map
  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      deviceName: map['deviceName'] ?? 'Unknown Device',
      model: map['model'] ?? 'Unknown',
      manufacturer: map['manufacturer'] ?? 'Unknown',
      osVersion: map['osVersion'] ?? 'Unknown',
      osVersionCode: map['osVersionCode'] ?? 'unknown',
      identifier: map['identifier'] ?? 'unknown',
      isPhysicalDevice: map['isPhysicalDevice'] ?? true,
      platform: map['platform'] ?? 'Unknown',
      platformVersion: map['platformVersion'] ?? 'unknown',
      capabilities: Map<String, bool>.from(map['capabilities'] ?? {}),
      additionalInfo: Map<String, dynamic>.from(map['additionalInfo'] ?? {}),
    );
  }
}
