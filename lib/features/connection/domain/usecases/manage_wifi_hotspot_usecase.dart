import '../repositories/connection_repository.dart';

class ManageWiFiHotspotParams {
  final bool enable;

  const ManageWiFiHotspotParams({required this.enable});
}

class ManageWiFiHotspotUseCase {
  final ConnectionRepository _repository;

  ManageWiFiHotspotUseCase({required ConnectionRepository repository})
    : _repository = repository;

  Future<bool> call(ManageWiFiHotspotParams params) async {
    try {
      if (params.enable) {
        return await _repository.enableWiFiHotspot();
      } else {
        return await _repository.disableWiFiHotspot();
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> isEnabled() async {
    return await _repository.isWiFiHotspotEnabled();
  }
}
