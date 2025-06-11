

import '../repositories/connection_repository.dart';

class GenerateQRCodeUseCase {
  final ConnectionRepository _repository;

  GenerateQRCodeUseCase({required ConnectionRepository repository})
      : _repository = repository;

  Future<String> call() async {
    return await _repository.generateQRCode();
  }
}
