import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../file_management/data/datasources/file_system_datasource.dart';
import '../../../file_management/data/repositories/file_management_repository_impl.dart';
import '../../../file_management/domain/entities/file_entity.dart';
import '../../../../core/constants/file_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/services/logger_service.dart';
import '../../../file_management/domain/entities/folder_entity.dart';
import '../../../file_management/domain/entities/storage_info_entity.dart';
/// File management repository implementation
class FileManagementRepositoryImpl implements FileManagementRepository {
  final FileSystemDataSource _dataSource;
  final LoggerService _logger = LoggerService.instance;

  FileManagementRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<FileEntity>>> getFiles(
    String directoryPath, {
    bool includeHidden = false,
    FileCategory? categoryFilter,
    String? searchQuery,
    FileSortOption sortBy = FileSortOption.name,
    FileSortOrder sortOrder = FileSortOrder.ascending,
  }) async {
    try {
      final files = await _dataSource.getFiles(
        directoryPath,
        includeHidden: includeHidden,
        categoryFilter: categoryFilter,
        searchQuery: searchQuery,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final entities = files.map((file) => file.toEntity()).toList();
      _logger.debug('Successfully retrieved ${entities.length} files');

      return Right(entities);
    } catch (e) {
      _logger.error('Failed to get files: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<FolderEntity>>> getFolders(
    String directoryPath, {
    bool includeHidden = false,
    String? searchQuery,
    FileSortOption sortBy = FileSortOption.name,
    FileSortOrder sortOrder = FileSortOrder.ascending,
  }) async {
    try {
      final folders = await _dataSource.getFolders(
        directoryPath,
        includeHidden: includeHidden,
        searchQuery: searchQuery,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final entities = folders.map((folder) => folder.toEntity()).toList();
      _logger.debug('Successfully retrieved ${entities.length} folders');

      return Right(entities);
    } catch (e) {
      _logger.error('Failed to get folders: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Map<String, List<dynamic>>>> getDirectoryContents(
    String directoryPath, {
    bool includeHidden = false,
    FileCategory? categoryFilter,
    String? searchQuery,
    FileSortOption sortBy = FileSortOption.name,
    FileSortOrder sortOrder = FileSortOrder.ascending,
  }) async {
    try {
      final contents = await _dataSource.getDirectoryContents(
        directoryPath,
        includeHidden: includeHidden,
        categoryFilter: categoryFilter,
        searchQuery: searchQuery,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final result = {
        'files': (contents['files'] as List)
            .map((file) => file.toEntity())
            .toList(),
        'folders': (contents['folders'] as List)
            .map((folder) => folder.toEntity())
            .toList(),
      };

      _logger.debug('Successfully retrieved directory contents');
      return Right(result);
    } catch (e) {
      _logger.error('Failed to get directory contents: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, FolderEntity>> createFolder(
    String parentPath,
    String folderName,
  ) async {
    try {
      final folderModel = await _dataSource.createFolder(
        parentPath,
        folderName,
      );
      final entity = folderModel.toEntity();

      _logger.info('Successfully created folder: ${entity.path}');
      return Right(entity);
    } catch (e) {
      _logger.error('Failed to create folder: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> deleteFile(String filePath) async {
    try {
      await _dataSource.deleteFile(filePath);
      _logger.info('Successfully deleted file: $filePath');
      return const Right(null);
    } catch (e) {
      _logger.error('Failed to delete file: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> deleteFolder(
    String folderPath, {
    bool recursive = false,
  }) async {
    try {
      await _dataSource.deleteFolder(folderPath, recursive: recursive);
      _logger.info('Successfully deleted folder: $folderPath');
      return const Right(null);
    } catch (e) {
      _logger.error('Failed to delete folder: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, FileEntity>> moveFile(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final fileModel = await _dataSource.moveFile(sourcePath, destinationPath);
      final entity = fileModel.toEntity();

      _logger.info(
        'Successfully moved file from $sourcePath to $destinationPath',
      );
      return Right(entity);
    } catch (e) {
      _logger.error('Failed to move file: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, FolderEntity>> moveFolder(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final folderModel = await _dataSource.moveFolder(
        sourcePath,
        destinationPath,
      );
      final entity = folderModel.toEntity();

      _logger.info(
        'Successfully moved folder from $sourcePath to $destinationPath',
      );
      return Right(entity);
    } catch (e) {
      _logger.error('Failed to move folder: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, FileEntity>> copyFile(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final fileModel = await _dataSource.copyFile(sourcePath, destinationPath);
      final entity = fileModel.toEntity();

      _logger.info(
        'Successfully copied file from $sourcePath to $destinationPath',
      );
      return Right(entity);
    } catch (e) {
      _logger.error('Failed to copy file: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, FileEntity>> renameFile(
    String filePath,
    String newName,
  ) async {
    try {
      final fileModel = await _dataSource.renameFile(filePath, newName);
      final entity = fileModel.toEntity();

      _logger.info('Successfully renamed file: $filePath to $newName');
      return Right(entity);
    } catch (e) {
      _logger.error('Failed to rename file: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, FolderEntity>> renameFolder(
    String folderPath,
    String newName,
  ) async {
    try {
      final folderModel = await _dataSource.renameFolder(folderPath, newName);
      final entity = folderModel.toEntity();

      _logger.info('Successfully renamed folder: $folderPath to $newName');
      return Right(entity);
    } catch (e) {
      _logger.error('Failed to rename folder: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<FileEntity>>> searchFiles(
    String query, {
    String? rootPath,
    FileCategory? categoryFilter,
    int? maxResults,
  }) async {
    try {
      final files = await _dataSource.searchFiles(
        query,
        rootPath: rootPath,
        categoryFilter: categoryFilter,
        maxResults: maxResults,
      );

      final entities = files.map((file) => file.toEntity()).toList();
      _logger.debug('Search found ${entities.length} files for query: $query');

      return Right(entities);
    } catch (e) {
      _logger.error('Failed to search files: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<FileEntity>>> getRecentFiles({
    int limit = 50,
    Duration? maxAge,
    FileCategory? categoryFilter,
  }) async {
    try {
      final files = await _dataSource.getRecentFiles(
        limit: limit,
        maxAge: maxAge,
        categoryFilter: categoryFilter,
      );

      final entities = files.map((file) => file.toEntity()).toList();
      _logger.debug('Retrieved ${entities.length} recent files');

      return Right(entities);
    } catch (e) {
      _logger.error('Failed to get recent files: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<StorageInfoEntity>>> getStorageInfo() async {
    try {
      final storageList = await _dataSource.getStorageInfo();
      final entities = storageList
          .map((storage) => storage.toEntity())
          .toList();

      _logger.debug('Retrieved storage info for ${entities.length} locations');
      return Right(entities);
    } catch (e) {
      _logger.error('Failed to get storage info: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Stream<Either<Failure, FileSystemEvent>> watchDirectory(
    String directoryPath,
  ) {
    return _dataSource
        .watchDirectory(directoryPath)
        .map((event) => Right(event))
        .handleError((error) {
          _logger.error('File system watch error: $error');
          final failure = ErrorHandler.handleException(error as Exception);
          return Left(failure);
        });
  }
}
