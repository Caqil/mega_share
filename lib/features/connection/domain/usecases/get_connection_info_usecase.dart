import 'dart:async';
import '../entities/connection_info_entity.dart';
import '../repositories/connection_repository.dart';

class GetConnectionInfoUseCase {
  final ConnectionRepository _repository;

  GetConnectionInfoUseCase({required ConnectionRepository repository})
    : _repository = repository;

  Future<ConnectionInfoEntity> call() async {
    return await _repository.getConnectionInfo();
  }

  Stream<ConnectionInfoEntity> getStream() {
    return _repository.getConnectionInfoStream();
  }
}
