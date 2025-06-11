import '../repositories/file_management_repository.dart';

class RequestPermissionsUseCase {
  final FileManagementRepository _repository;

  RequestPermissionsUseCase({required FileManagementRepository repository})
    : _repository = repository;

  Future<bool> call() async {
    try {
      return await _repository.requestPermissions();
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasReadPermission() async {
    try {
      return await _repository.hasReadPermission();
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasWritePermission() async {
    try {
      return await _repository.hasWritePermission();
    } catch (e) {
      return false;
    }
  }
}
