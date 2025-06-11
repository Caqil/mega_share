import 'dart:async';
import '../models/file_model.dart';
import '../models/folder_model.dart';
import '../models/storage_info_model.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_management_repository.dart';

abstract class FileSystemDataSource {
  // Initialization
  Future<void> initialize();
  Future<void> dispose();

  // Storage Information
  Future<StorageInfoModel> getStorageInfo();
  Stream<StorageInfoModel> getStorageInfoStream();
  Future<List<StorageVolumeModel>> getStorageVolumes();

  // File Operations
  Future<List<FileModel>> getFiles({
    required String path,
    FileFilter? filter,
    SortBy sortBy = SortBy.name,
    SortOrder sortOrder = SortOrder.ascending,
    int? limit,
    int? offset,
  });

  Future<List<FileModel>> getFilesByType({
    required FileType type,
    String? path,
    SortBy sortBy = SortBy.dateModified,
    SortOrder sortOrder = SortOrder.descending,
    int? limit,
  });

  Future<List<FileModel>> getRecentFiles({
    int limit = 50,
    List<FileType>? types,
  });

  Future<List<FileModel>> getFavoriteFiles({List<FileType>? types});

  Future<List<FileModel>> getLargeFiles({int limit = 20, int? minSize});

  Future<List<FileModel>> searchFiles({
    required String query,
    String? path,
    List<FileType>? types,
    int? limit,
  });

  // Folder Operations
  Future<List<FolderModel>> getFolders({
    required String path,
    bool includeHidden = false,
    SortBy sortBy = SortBy.name,
    SortOrder sortOrder = SortOrder.ascending,
  });

  Future<FolderModel> createFolder({
    required String parentPath,
    required String name,
  });

  Future<void> deleteFolder({required String path, bool recursive = false});

  Future<FolderModel> renameFolder({
    required String path,
    required String newName,
  });

  // File Management
  Future<void> deleteFile(String path);
  Future<void> deleteFiles(List<String> paths);
  Future<FileModel> renameFile({required String path, required String newName});

  Future<FileModel> copyFile({
    required String sourcePath,
    required String destinationPath,
  });

  Future<FileModel> moveFile({
    required String sourcePath,
    required String destinationPath,
  });

  // Favorites and Tags
  Future<void> addToFavorites(String path);
  Future<void> removeFromFavorites(String path);
  Future<void> addTag(String path, String tag);
  Future<void> removeTag(String path, String tag);

  // Metadata and Thumbnails
  Future<Map<String, dynamic>> getFileMetadata(String path);
  Future<String?> generateThumbnail(String path);
  Future<void> updateAccessCount(String path);

  // Permissions
  Future<bool> hasReadPermission();
  Future<bool> hasWritePermission();
  Future<bool> requestPermissions();
}
