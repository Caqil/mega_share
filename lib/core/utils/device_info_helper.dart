abstract class DeviceInfoHelper {
  Future<String> get deviceId;
  Future<String> get deviceName;
  Future<String> get deviceModel;
  Future<String> get deviceOS;
  Future<String> get deviceOSVersion;
  Future<String> get appVersion;
  Future<String> get appBuildNumber;
  Future<Map<String, dynamic>> get deviceInfo;
}
