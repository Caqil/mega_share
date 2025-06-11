import '../repositories/file_management_repository.dart';
import '../entities/file_entity.dart';
import '../entities/folder_entity.dart';

class RenameFileParams {
  final String path;
  final String newName;

  const RenameFileParams({required this.path, required this.newName});
}

class CopyFileParams {
  final String sourcePath;
  final String destinationPath;

  const CopyFileParams({
    required this.sourcePath,
    required this.destinationPath,
  });
}

class MoveFileParams {
  final String sourcePath;
  final String destinationPath;

  const MoveFileParams({
    required this.sourcePath,
    required this.destinationPath,
  });
}

class ManageFileUseCase {
  final FileManagementRepository _repository;

  ManageFileUseCase({required FileManagementRepository repository})
    : _repository = repository;

  Future<FileEntity> renameFile(RenameFileParams params) async {
    try {
      if (params.newName.trim().isEmpty) {
        throw Exception('File name cannot be empty');
      }

      if (params.newName.contains('/') || params.newName.contains('\\')) {
        throw Exception('File name cannot contain path separators');
      }

      // Check permissions
      final hasPermission = await _repository.hasWritePermission();
      if (!hasPermission) {
        final granted = await _repository.requestPermissions();
        if (!granted) {
          throw Exception('Storage write permissions not granted');
        }
      }

      return await _repository.renameFile(
        path: params.path,
        newName: params.newName,
      );
    } catch (e) {
      throw Exception('Failed to rename file: $e');
    }
  }

  Future<FolderEntity> renameFolder({
    required String path,
    required String newName,
  }) async {
    try {
      if (newName.trim().isEmpty) {
        throw Exception('Folder name cannot be empty');
      }

      if (newName.contains('/') || newName.contains('\\')) {
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

      return await _repository.renameFolder(path: path, newName: newName);
    } catch (e) {
      throw Exception('Failed to rename folder: $e');
    }
  }

  Future<FileEntity> copyFile(CopyFileParams params) async {
    try {
      // Check permissions
      final hasPermission = await _repository.hasWritePermission();
      if (!hasPermission) {
        final granted = await _repository.requestPermissions();
        if (!granted) {
          throw Exception('Storage write permissions not granted');
        }
      }

      return await _repository.copyFile(
        sourcePath: params.sourcePath,
        destinationPath: params.destinationPath,
      );
    } catch (e) {
      throw Exception('Failed to copy file: $e');
    }
  }

  Future<FileEntity> moveFile(MoveFileParams params) async {
    try {
      // Check permissions
      final hasPermission = await _repository.hasWritePermission();
      if (!hasPermission) {
        final granted = await _repository.requestPermissions();
        if (!granted) {
          throw Exception('Storage write permissions not granted');
        }
      }

      return await _repository.moveFile(
        sourcePath: params.sourcePath,
        destinationPath: params.destinationPath,
      );
    } catch (e) {
      throw Exception('Failed to move file: $e');
    }
  }

  Future<void> addToFavorites(String path) async {
    try {
      await _repository.addToFavorites(path);
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String path) async {
    try {
      await _repository.removeFromFavorites(path);
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  Future<void> addTag(String path, String tag) async {
    try {
      if (tag.trim().isEmpty) {
        throw Exception('Tag cannot be empty');
      }

      await _repository.addTag(path, tag.trim());
    } catch (e) {
      throw Exception('Failed to add tag: $e');
    }
  }

  Future<void> removeTag(String path, String tag) async {
    try {
      await _repository.removeTag(path, tag);
    } catch (e) {
      throw Exception('Failed to remove tag: $e');
    }
  }

  Future<Map<String, dynamic>> getFileMetadata(String path) async {
    try {
      return await _repository.getFileMetadata(path);
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }

  Future<String?> generateThumbnail(String path) async {
    try {
      return await _repository.generateThumbnail(path);
    } catch (e) {
      // Thumbnail generation failure is not critical
      return null;
    }
  }

  Future<void> updateAccessCount(String path) async {
    try {
      await _repository.updateAccessCount(path);
    } catch (e) {
      // Access count update failure is not critical
    }
  }
}
