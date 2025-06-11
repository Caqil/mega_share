import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'device_info_helper.dart';

class DeviceInfoHelperImpl implements DeviceInfoHelper {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  PackageInfo? _packageInfo;

  Future<PackageInfo> get _package async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!;
  }

  @override
  Future<String> get deviceId async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown';
    }
    return 'unknown';
  }

  @override
  Future<String> get deviceName async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return '${androidInfo.brand} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.name;
    }
    return 'Unknown Device';
  }

  @override
  Future<String> get deviceModel async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.model;
    }
    return 'Unknown';
  }

  @override
  Future<String> get deviceOS async {
    return Platform.operatingSystem;
  }

  @override
  Future<String> get deviceOSVersion async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.version.release;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.systemVersion;
    }
    return Platform.operatingSystemVersion;
  }

  @override
  Future<String> get appVersion async {
    final package = await _package;
    return package.version;
  }

  @override
  Future<String> get appBuildNumber async {
    final package = await _package;
    return package.buildNumber;
  }

  @override
  Future<Map<String, dynamic>> get deviceInfo async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'platform': 'Android',
        'deviceId': androidInfo.id,
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'manufacturer': androidInfo.manufacturer,
        'product': androidInfo.product,
        'device': androidInfo.device,
        'board': androidInfo.board,
        'hardware': androidInfo.hardware,
        'osVersion': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
        'fingerprint': androidInfo.fingerprint,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return {
        'platform': 'iOS',
        'deviceId': iosInfo.identifierForVendor ?? 'unknown',
        'name': iosInfo.name,
        'model': iosInfo.model,
        'localizedModel': iosInfo.localizedModel,
        'systemName': iosInfo.systemName,
        'systemVersion': iosInfo.systemVersion,
        'isPhysicalDevice': iosInfo.isPhysicalDevice,
        'utsname': {
          'machine': iosInfo.utsname.machine,
          'nodename': iosInfo.utsname.nodename,
          'release': iosInfo.utsname.release,
          'sysname': iosInfo.utsname.sysname,
          'version': iosInfo.utsname.version,
        },
      };
    }

    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
    };
  }
}
