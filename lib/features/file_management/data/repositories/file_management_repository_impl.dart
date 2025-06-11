import 'dart:async';
import '../../domain/entities/file_entity.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/entities/storage_info_entity.dart';
import '../../domain/repositories/file_management_repository.dart';
import '../datasources/file_system_datasource.dart';

class FileManagementRepositoryImpl implements FileManagementRepository {
  final FileSystemDataSource _dataSource;

  FileManagementRepositoryImpl({required FileSystemDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<StorageInfoEntity> getStorageInfo() => _dataSource.getStorageInfo();

  @override
  Stream<StorageInfoEntity> getStorageInfoStream() =>
      _dataSource.getStorageInfoStream();

  @override
  Future<List<StorageVolumeEntity>> getStorageVolumes() =>
      _dataSource.getStorageVolumes();

  @override
  Future<List<FileEntity>> getFiles({
    required String path,
    FileFilter? filter,
    SortBy sortBy = SortBy.name,
    SortOrder sortOrder = SortOrder.ascending,
    int? limit,
    int? offset,
  }) async {
    final files = await _dataSource.getFiles(
      path: path,
      filter: filter,
      sortBy: sortBy,
      sortOrder: sortOrder,
      limit: limit,
      offset: offset,
    );
    return files.cast<FileEntity>();
  }

  @override
  Future<List<FileEntity>> getFilesByType({
    required FileType type,
    String? path,
    SortBy sortBy = SortBy.dateModified,
    SortOrder sortOrder = SortOrder.descending,
    int? limit,
  }) async {
    final files = await _dataSource.getFilesByType(
      type: type,
      path: path,
      sortBy: sortBy,
      sortOrder: sortOrder,
      limit: limit,
    );
    return files.cast<FileEntity>();
  }

  @override
  Future<List<FileEntity>> getRecentFiles({
    int limit = 50,
    List<FileType>? types,
  }) async {
    final files = await _dataSource.getRecentFiles(limit: limit, types: types);
    return files.cast<FileEntity>();
  }

  @override
  Future<List<FileEntity>> getFavoriteFiles({List<FileType>? types}) async {
    final files = await _dataSource.getFavoriteFiles(types: types);
    return files.cast<FileEntity>();
  }

  @override
  Future<List<FileEntity>> getLargeFiles({int limit = 20, int? minSize}) async {
    final files = await _dataSource.getLargeFiles(
      limit: limit,
      minSize: minSize,
    );
    return files.cast<FileEntity>();
  }

  @override
  Future<List<FileEntity>> searchFiles({
    required String query,
    String? path,
    List<FileType>? types,
    int? limit,
  }) async {
    final files = await _dataSource.searchFiles(
      query: query,
      path: path,
      types: types,
      limit: limit,
    );
    return files.cast<FileEntity>();
  }

  @override
  Future<List<FolderEntity>> getFolders({
    required String path,
    bool includeHidden = false,
    SortBy sortBy = SortBy.name,
    SortOrder sortOrder = SortOrder.ascending,
  }) async {
    final folders = await _dataSource.getFolders(
      path: path,
      includeHidden: includeHidden,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
    return folders.cast<FolderEntity>();
  }

  @override
  Future<FolderEntity> createFolder({
    required String parentPath,
    required String name,
  }) => _dataSource.createFolder(parentPath: parentPath, name: name);

  @override
  Future<void> deleteFolder({required String path, bool recursive = false}) =>
      _dataSource.deleteFolder(path: path, recursive: recursive);

  @override
  Future<FolderEntity> renameFolder({
    required String path,
    required String newName,
  }) => _dataSource.renameFolder(path: path, newName: newName);

  @override
  Future<void> deleteFile(String path) => _dataSource.deleteFile(path);

  @override
  Future<void> deleteFiles(List<String> paths) =>
      _dataSource.deleteFiles(paths);

  @override
  Future<FileEntity> renameFile({
    required String path,
    required String newName,
  }) => _dataSource.renameFile(path: path, newName: newName);

  @override
  Future<FileEntity> copyFile({
    required String sourcePath,
    required String destinationPath,
  }) => _dataSource.copyFile(
    sourcePath: sourcePath,
    destinationPath: destinationPath,
  );

  @override
  Future<FileEntity> moveFile({
    required String sourcePath,
    required String destinationPath,
  }) => _dataSource.moveFile(
    sourcePath: sourcePath,
    destinationPath: destinationPath,
  );

  @override
  Future<void> addToFavorites(String path) => _dataSource.addToFavorites(path);

  @override
  Future<void> removeFromFavorites(String path) =>
      _dataSource.removeFromFavorites(path);

  @override
  Future<void> addTag(String path, String tag) => _dataSource.addTag(path, tag);

  @override
  Future<void> removeTag(String path, String tag) =>
      _dataSource.removeTag(path, tag);

  @override
  Future<Map<String, dynamic>> getFileMetadata(String path) =>
      _dataSource.getFileMetadata(path);

  @override
  Future<String?> generateThumbnail(String path) =>
      _dataSource.generateThumbnail(path);

  @override
  Future<void> updateAccessCount(String path) =>
      _dataSource.updateAccessCount(path);

  @override
  Future<bool> hasReadPermission() => _dataSource.hasReadPermission();

  @override
  Future<bool> hasWritePermission() => _dataSource.hasWritePermission();

  @override
  Future<bool> requestPermissions() => _dataSource.requestPermissions();
}
