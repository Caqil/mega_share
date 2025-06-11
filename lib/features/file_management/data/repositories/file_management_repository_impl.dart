import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/file_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/entities/storage_info_entity.dart';
import '../datasources/file_system_datasource.dart';

/// File management repository interface
abstract class FileManagementRepository {
  /// Get files in directory
  Future<Either<Failure, List<FileEntity>>> getFiles(
    String directoryPath, {
    bool includeHidden = false,
     FileCategory? categoryFilter,
    String? searchQuery,
    FileSortOption sortBy = FileSortOption.name,
    FileSortOrder sortOrder = FileSortOrder.ascending,
  });

  /// Get folders in directory
  Future<Either<Failure, List<FolderEntity>>> getFolders(
    String directoryPath, {
    bool includeHidden = false,
    String? searchQuery,
    FileSortOption sortBy = FileSortOption.name,
    FileSortOrder sortOrder = FileSortOrder.ascending,
  });

  /// Get both files and folders
  Future<Either<Failure, Map<String, List<dynamic>>>> getDirectoryContents(
    String directoryPath, {
    bool includeHidden = false,
     FileCategory? categoryFilter,
    String? searchQuery,
    FileSortOption sortBy = FileSortOption.name,
    FileSortOrder sortOrder = FileSortOrder.ascending,
  });

  /// Create new folder
  Future<Either<Failure, FolderEntity>> createFolder(
    String parentPath,
    String folderName,
  );

  /// Delete file
  Future<Either<Failure, void>> deleteFile(String filePath);

  /// Delete folder
  Future<Either<Failure, void>> deleteFolder(
    String folderPath, {
    bool recursive = false,
  });

  /// Move file
  Future<Either<Failure, FileEntity>> moveFile(
    String sourcePath,
    String destinationPath,
  );

  /// Move folder
  Future<Either<Failure, FolderEntity>> moveFolder(
    String sourcePath,
    String destinationPath,
  );

  /// Copy file
  Future<Either<Failure, FileEntity>> copyFile(
    String sourcePath,
    String destinationPath,
  );

  /// Rename file
  Future<Either<Failure, FileEntity>> renameFile(
    String filePath,
    String newName,
  );

  /// Rename folder
  Future<Either<Failure, FolderEntity>> renameFolder(
    String folderPath,
    String newName,
  );

  /// Search files
  Future<Either<Failure, List<FileEntity>>> searchFiles(
    String query, {
    String? rootPath,
     FileCategory? categoryFilter,
    int? maxResults,
  });

  /// Get recent files
  Future<Either<Failure, List<FileEntity>>> getRecentFiles({
    int limit = 50,
    Duration? maxAge,
     FileCategory? categoryFilter,
  });

  /// Get storage information
  Future<Either<Failure, List<StorageInfoEntity>>> getStorageInfo();

  /// Watch directory for changes
  Stream<Either<Failure, FileSystemEvent>> watchDirectory(String directoryPath);
}
