import 'dart:async';
import 'dart:io';
import '../models/file_model.dart';
import '../models/folder_model.dart';
import '../models/storage_info_model.dart';
import '../../../../core/constants/file_constants.dart';

/// File sorting options
enum FileSortOption { name, date, size, type }

/// File sort order
enum FileSortOrder { ascending, descending }

/// Abstract file system data source
abstract class FileSystemDataSource {
  /// Get files in directory
  Future<List<FileModel>> getFiles(
    String directoryPath, {
    bool includeHidden = false,
    FileCategory? categoryFilter,
    String? searchQuery,
    FileSortOption sortBy = FileSortOption.name,
    FileSortOrder sortOrder = FileSortOrder.ascending,
  });

  /// Get folders in directory
  Future<List<FolderModel>> getFolders(
    String directoryPath, {
    bool includeHidden = false,
    String? searchQuery,
    FileSortOption sortBy = FileSortOption.name,
    FileSortOrder sortOrder = FileSortOrder.ascending,
  });

  /// Get both files and folders
  Future<Map<String, List<dynamic>>> getDirectoryContents(
    String directoryPath, {
    bool includeHidden = false,
    FileCategory? categoryFilter,
    String? searchQuery,
    FileSortOption sortBy = FileSortOption.name,
    FileSortOrder sortOrder = FileSortOrder.ascending,
  });

  /// Create new folder
  Future<FolderModel> createFolder(String parentPath, String folderName);

  /// Delete file
  Future<void> deleteFile(String filePath);

  /// Delete folder
  Future<void> deleteFolder(String folderPath, {bool recursive = false});

  /// Move file
  Future<FileModel> moveFile(String sourcePath, String destinationPath);

  /// Move folder
  Future<FolderModel> moveFolder(String sourcePath, String destinationPath);

  /// Copy file
  Future<FileModel> copyFile(String sourcePath, String destinationPath);

  /// Rename file
  Future<FileModel> renameFile(String filePath, String newName);

  /// Rename folder
  Future<FolderModel> renameFolder(String folderPath, String newName);

  /// Get file details
  Future<FileModel> getFileDetails(String filePath);

  /// Get folder details
  Future<FolderModel> getFolderDetails(String folderPath);

  /// Search files
  Future<List<FileModel>> searchFiles(
    String query, {
    String? rootPath,
    FileCategory? categoryFilter,
    int? maxResults,
  });

  /// Get recent files
  Future<List<FileModel>> getRecentFiles({
    int limit = 50,
    Duration? maxAge,
    FileCategory? categoryFilter,
  });

  /// Get storage information
  Future<List<StorageInfoModel>> getStorageInfo();

  /// Get available storage paths
  Future<List<String>> getAvailableStoragePaths();

  /// Check if path exists
  Future<bool> pathExists(String path);

  /// Get file size
  Future<int> getFileSize(String filePath);

  /// Get folder size
  Future<int> getFolderSize(String folderPath);

  /// Watch directory for changes
  Stream<FileSystemEvent> watchDirectory(String directoryPath);
}
