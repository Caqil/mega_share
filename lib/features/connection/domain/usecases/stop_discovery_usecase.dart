import '../repositories/connection_repository.dart';

class StopDiscoveryUseCase {
  final ConnectionRepository _repository;

  StopDiscoveryUseCase({required ConnectionRepository repository})
    : _repository = repository;

  Future<bool> call() async {
    try {
      await _repository.stopDiscovery();
      await _repository.stopAdvertising();
      return true;
    } catch (e) {
      return false;
    }
  }
}
