import '../repositories/connection_repository.dart';

class DisconnectFromDeviceParams {
  final String? endpointId; // null means disconnect all
  final bool graceful;

  const DisconnectFromDeviceParams({this.endpointId, this.graceful = true});
}

class DisconnectFromDeviceUseCase {
  final ConnectionRepository _repository;

  DisconnectFromDeviceUseCase({required ConnectionRepository repository})
    : _repository = repository;

  Future<bool> call(DisconnectFromDeviceParams params) async {
    try {
      if (params.endpointId != null) {
        // Disconnect from specific device
        await _repository.disconnectFromDevice(params.endpointId!);
      } else {
        // Disconnect from all devices
        await _repository.disconnectAll();
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
