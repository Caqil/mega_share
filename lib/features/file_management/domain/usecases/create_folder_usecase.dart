
import '../entities/folder_entity.dart';
import '../repositories/file_management_repository.dart';

class CreateFolderParams {
  final String parentPath;
  final String name;

  const CreateFolderParams({required this.parentPath, required this.name});
}

class CreateFolderUseCase {
  final FileManagementRepository _repository;

  CreateFolderUseCase({required FileManagementRepository repository})
    : _repository = repository;

  Future<FolderEntity> call(CreateFolderParams params) async {
    try {
      // Validate folder name
      if (params.name.trim().isEmpty) {
        throw Exception('Folder name cannot be empty');
      }

      if (params.name.contains('/') || params.name.contains('\\')) {
        throw Exception('Folder name cannot contain path separators');
      }

      // Check permissions
      final hasPermission = await _repository.hasWritePermission();
      if (!hasPermission) {
        final granted = await _repository.requestPermissions();
        if (!granted) {
          throw Exception('Storage write permissions not granted');
        }
      }

      return await _repository.createFolder(
        parentPath: params.parentPath,
        name: params.name,
      );
    } catch (e) {
      throw Exception('Failed to create folder: $e');
    }
  }
}
