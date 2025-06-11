import 'dart:async';
import '../../domain/entities/file_entity.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/entities/storage_info_entity.dart';

enum SortBy { name, size, dateModified, dateCreated, type }

enum SortOrder { ascending, descending }

class FileFilter {
  final List<FileType>? types;
  final int? minSize;
  final int? maxSize;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final bool? includeFavorites;
  final bool? includeHidden;
  final List<String>? tags;

  const FileFilter({
    this.types,
    this.minSize,
    this.maxSize,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.includeFavorites,
    this.includeHidden,
    this.tags,
  });
}

abstract class FileManagementRepository {
  // Storage Information
  Future<StorageInfoEntity> getStorageInfo();
  Stream<StorageInfoEntity> getStorageInfoStream();
  Future<List<StorageVolumeEntity>> getStorageVolumes();

  // File Operations
  Future<List<FileEntity>> getFiles({
    required String path,
    FileFilter? filter,
    SortBy sortBy = SortBy.name,
    SortOrder sortOrder = SortOrder.ascending,
    int? limit,
    int? offset,
  });

  Future<List<FileEntity>> getFilesByType({
    required FileType type,
    String? path,
    SortBy sortBy = SortBy.dateModified,
    SortOrder sortOrder = SortOrder.descending,
    int? limit,
  });

  Future<List<FileEntity>> getRecentFiles({
    int limit = 50,
    List<FileType>? types,
  });

  Future<List<FileEntity>> getFavoriteFiles({List<FileType>? types});

  Future<List<FileEntity>> getLargeFiles({int limit = 20, int? minSize});

  Future<List<FileEntity>> searchFiles({
    required String query,
    String? path,
    List<FileType>? types,
    int? limit,
  });

  // Folder Operations
  Future<List<FolderEntity>> getFolders({
    required String path,
    bool includeHidden = false,
    SortBy sortBy = SortBy.name,
    SortOrder sortOrder = SortOrder.ascending,
  });

  Future<FolderEntity> createFolder({
    required String parentPath,
    required String name,
  });

  Future<void> deleteFolder({required String path, bool recursive = false});

  Future<FolderEntity> renameFolder({
    required String path,
    required String newName,
  });

  // File Management
  Future<void> deleteFile(String path);
  Future<void> deleteFiles(List<String> paths);
  Future<FileEntity> renameFile({
    required String path,
    required String newName,
  });

  Future<FileEntity> copyFile({
    required String sourcePath,
    required String destinationPath,
  });

  Future<FileEntity> moveFile({
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
