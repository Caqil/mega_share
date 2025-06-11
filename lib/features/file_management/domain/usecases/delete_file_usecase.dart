import '../repositories/file_management_repository.dart';

class DeleteFileParams {
  final String? filePath;
  final List<String>? filePaths;
  final bool confirmDeletion;

  const DeleteFileParams({
    this.filePath,
    this.filePaths,
    this.confirmDeletion = true,
  });

  bool get isMultiple => filePaths != null && filePaths!.isNotEmpty;
  bool get isSingle => filePath != null;
  bool get isValid => isSingle || isMultiple;
}

class DeleteFileUseCase {
  final FileManagementRepository _repository;

  DeleteFileUseCase({required FileManagementRepository repository})
    : _repository = repository;

  Future<bool> call(DeleteFileParams params) async {
    try {
      if (!params.isValid) {
        throw Exception('No files specified for deletion');
      }

      // Check permissions
      final hasPermission = await _repository.hasWritePermission();
      if (!hasPermission) {
        final granted = await _repository.requestPermissions();
        if (!granted) {
          throw Exception('Storage write permissions not granted');
        }
      }

      if (params.isSingle) {
        await _repository.deleteFile(params.filePath!);
      } else {
        await _repository.deleteFiles(params.filePaths!);
      }

      return true;
    } catch (e) {
      throw Exception('Failed to delete file(s): $e');
    }
  }

  Future<bool> deleteFolder({
    required String path,
    bool recursive = false,
    bool confirmDeletion = true,
  }) async {
    try {
      // Check permissions
      final hasPermission = await _repository.hasWritePermission();
      if (!hasPermission) {
        final granted = await _repository.requestPermissions();
        if (!granted) {
          throw Exception('Storage write permissions not granted');
        }
      }

      await _repository.deleteFolder(path: path, recursive: recursive);

      return true;
    } catch (e) {
      throw Exception('Failed to delete folder: $e');
    }
  }
}
