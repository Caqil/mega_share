
import 'dart:async';
import '../repositories/file_management_repository.dart';
import '../entities/storage_info_entity.dart';

class GetStorageInfoUseCase {
  final FileManagementRepository _repository;

  GetStorageInfoUseCase({required FileManagementRepository repository})
      : _repository = repository;

  Future<StorageInfoEntity> call() async {
    return await _repository.getStorageInfo();
  }

  Stream<StorageInfoEntity> getStream() {
    return _repository.getStorageInfoStream();
  }
}
