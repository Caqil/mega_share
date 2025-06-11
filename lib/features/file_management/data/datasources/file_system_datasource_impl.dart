// lib/features/file_management/data/datasources/file_system_datasource_impl.dart
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/file_constants.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/file_model.dart';
import '../models/folder_model.dart';
import '../models/storage_info_model.dart';
import 'file_system_datasource.dart';

/// File system data source implementation
class FileSystemDataSourceImpl implements FileSystemDataSource {
  final LoggerService _logger = LoggerService();
  final PermissionService _permissionService = PermissionService.instance;
  
  final Map<String, StreamController<FileSystemEvent>> _watchControllers = {};
  
  @override
  Future<List<FileModel>> getFiles(
    String directoryPath, {
    bool includeHidden = false,
    FileConstants.FileCategory? categoryFilter,
    String? searchQuery,
    FileSortOption sortBy = FileSortOption.name,
    FileSortOrder sortOrder = FileSortOrder.ascending,
  }) async {
    try {
      _logger.debug('Getting files from: $directoryPath');
      
      // Check permissions
      await _checkStoragePermissions();
      
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        throw FileSystemException('Directory does not exist', filePath: directoryPath);
      }
      
      final files = <FileModel>[];
      
      await for (final entity in directory.list()) {
        if (entity is File) {
          try {
            final fileModel = await _createFileModel(entity);
            
            // Apply filters
            if (!includeHidden && fileModel.isHidden) continue;
            if (categoryFilter != null && fileModel.category != categoryFilter) continue;
            if (searchQuery != null && !_matchesSearchQuery(fileModel.name, searchQuery)) continue;
            
            files.add(fileModel);
          } catch (e) {
            _logger.warning('Failed to process file ${entity.path}: $e');
            continue;
          }
        }
      }
      
      // Sort files
      _sortFiles(files, sortBy, sortOrder);
      
      _logger.debug('Found ${files.length} files in $directoryPath');
      return files;
    } catch (e) {
      _logger.error('Error getting files from $directoryPath: $e');
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Failed to get files: $e', filePath: directoryPath);
    }
  }
  
  @override
  Future<List<FolderModel>> getFolders(
    String directoryPath, {
    bool includeHidden = false,
    String? searchQuery,
    FileSortOption sortBy = FileSortOption.name,
    FileSortOrder sortOrder = FileSortOrder.ascending,
  }) async {
    try {
      _logger.debug('Getting folders from: $directoryPath');
      
      await _checkStoragePermissions();
      
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        throw FileSystemException('Directory does not exist', filePath: directoryPath);
      }
      
      final folders = <FolderModel>[];
      
      await for (final entity in directory.list()) {
        if (entity is Directory) {
          try {
            final folderModel = await _createFolderModel(entity);
            
            // Apply filters
            if (!includeHidden && folderModel.isHidden) continue;
            if (searchQuery != null && !_matchesSearchQuery(folderModel.name, searchQuery)) continue;
            
            folders.add(folderModel);
          } catch (e) {
            _logger.warning('Failed to process folder ${entity.path}: $e');
            continue;
          }
        }
      }
      
      // Sort folders
      _sortFolders(folders, sortBy, sortOrder);
      
      _logger.debug('Found ${folders.length} folders in $directoryPath');
      return folders;
    } catch (e) {
      _logger.error('Error getting folders from $directoryPath: $e');
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Failed to get folders: $e', filePath: directoryPath);
    }
  }
  
  @override
  Future<Map<String, List<dynamic>>> getDirectoryContents(
    String directoryPath, {
    bool includeHidden = false,
    FileConstants.FileCategory? categoryFilter,
    String? searchQuery,
    FileSortOption sortBy = FileSortOption.name,
    FileSortOrder sortOrder = FileSortOrder.ascending,
  }) async {
    try {
      final files = await getFiles(
        directoryPath,
        includeHidden: includeHidden,
        categoryFilter: categoryFilter,
        searchQuery: searchQuery,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      
      final folders = await getFolders(
        directoryPath,
        includeHidden: includeHidden,
        searchQuery: searchQuery,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      
      return {
        'files': files,
        'folders': folders,
      };
    } catch (e) {
      _logger.error('Error getting directory contents: $e');
      rethrow;
    }
  }
  
  @override
  Future<FolderModel> createFolder(String parentPath, String folderName) async {
    try {
      _logger.debug('Creating folder: $folderName in $parentPath');
      
      await _checkStoragePermissions();
      
      final folderPath = path.join(parentPath, folderName);
      final directory = Directory(folderPath);
      
      if (await directory.exists()) {
        throw FileSystemException('Folder already exists', filePath: folderPath);
      }
      
      await directory.create(recursive: true);
      
      final folderModel = await _createFolderModel(directory);
      _logger.info('Created folder: $folderPath');
      
      return folderModel;
    } catch (e) {
      _logger.error('Error creating folder $folderName: $e');
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Failed to create folder: $e', filePath: path.join(parentPath, folderName));
    }
  }
  
  @override
  Future<void> deleteFile(String filePath) async {
    try {
      _logger.debug('Deleting file: $filePath');
      
      await _checkStoragePermissions();
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileSystemException('File does not exist', filePath: filePath);
      }
      
      await file.delete();
      _logger.info('Deleted file: $filePath');
    } catch (e) {
      _logger.error('Error deleting file $filePath: $e');
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Failed to delete file: $e', filePath: filePath);
    }
  }
  
  @override
  Future<void> deleteFolder(String folderPath, {bool recursive = false}) async {
    try {
      _logger.debug('Deleting folder: $folderPath (recursive: $recursive)');
      
      await _checkStoragePermissions();
      
      final directory = Directory(folderPath);
      if (!await directory.exists()) {
        throw FileSystemException('Folder does not exist', filePath: folderPath);
      }
      
      await directory.delete(recursive: recursive);
      _logger.info('Deleted folder: $folderPath');
    } catch (e) {
      _logger.error('Error deleting folder $folderPath: $e');
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Failed to delete folder: $e', filePath: folderPath);
    }
  }
  
  @override
  Future<FileModel> moveFile(String sourcePath, String destinationPath) async {
    try {
      _logger.debug('Moving file from $sourcePath to $destinationPath');
      
      await _checkStoragePermissions();
      
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw FileSystemException('Source file does not exist', filePath: sourcePath);
      }
      
      // Ensure destination directory exists
      final destinationDir = Directory(path.dirname(destinationPath));
      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
      }
      
      final movedFile = await sourceFile.rename(destinationPath);
      final fileModel = await _createFileModel(movedFile);
      
      _logger.info('Moved file from $sourcePath to $destinationPath');
      return fileModel;
    } catch (e) {
      _logger.error('Error moving file: $e');
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Failed to move file: $e', filePath: sourcePath);
    }
  }
  
  @override
  Future<FolderModel> moveFolder(String sourcePath, String destinationPath) async {
    try {
      _logger.debug('Moving folder from $sourcePath to $destinationPath');
      
      await _checkStoragePermissions();
      
      final sourceDirectory = Directory(sourcePath);
      if (!await sourceDirectory.exists()) {
        throw FileSystemException('Source folder does not exist', filePath: sourcePath);
      }
      
      final movedDirectory = await sourceDirectory.rename(destinationPath);
      final folderModel = await _createFolderModel(movedDirectory);
      
      _logger.info('Moved folder from $sourcePath to $destinationPath');
      return folderModel;
    } catch (e) {
      _logger.error('Error moving folder: $e');
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Failed to move folder: $e', filePath: sourcePath);
    }
  }
  
  @override
  Future<FileModel> copyFile(String sourcePath, String destinationPath) async {
    try {
      _logger.debug('Copying file from $sourcePath to $destinationPath');
      
      await _checkStoragePermissions();
      
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw FileSystemException('Source file does not exist', filePath: sourcePath);
      }
      
      // Ensure destination directory exists
      final destinationDir = Directory(path.dirname(destinationPath));
      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
      }
      
      final copiedFile = await sourceFile.copy(destinationPath);
      final fileModel = await _createFileModel(copiedFile);
      
      _logger.info('Copied file from $sourcePath to $destinationPath');
      return fileModel;
    } catch (e) {
      _logger.error('Error copying file: $e');
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Failed to copy file: $e', filePath: sourcePath);
    }
  }
  
  @override
  Future<FileModel> renameFile(String filePath, String newName) async {
    try {
      _logger.debug('Renaming file $filePath to $newName');
      
      final directory = path.dirname(filePath);
      final newPath = path.join(directory, newName);
      
      return await moveFile(filePath, newPath);
    } catch (e) {
      _logger.error('Error renaming file: $e');
      rethrow;
    }
  }
  
  @override
  Future<FolderModel> renameFolder(String folderPath, String newName) async {
    try {
      _logger.debug('Renaming folder $folderPath to $newName');
      
      final parentDirectory = path.dirname(folderPath);
      final newPath = path.join(parentDirectory, newName);
      
      return await moveFolder(folderPath, newPath);
    } catch (e) {
      _logger.error('Error renaming folder: $e');
      rethrow;
    }
  }
  
  @override
  Future<FileModel> getFileDetails(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileSystemException('File does not exist', filePath: filePath);
      }
      
      return await _createFileModel(file);
    } catch (e) {
      _logger.error('Error getting file details: $e');
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Failed to get file details: $e', filePath: filePath);
    }
  }
  
  @override
  Future<FolderModel> getFolderDetails(String folderPath) async {
    try {
      final directory = Directory(folderPath);
      if (!await directory.exists()) {
        throw FileSystemException('Folder does not exist', filePath: folderPath);
      }
      
      return await _createFolderModel(directory);
    } catch (e) {
      _logger.error('Error getting folder details: $e');
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Failed to get folder details: $e', filePath: folderPath);
    }
  }
  
  @override
  Future<List<FileModel>> searchFiles(
    String query, {
    String? rootPath,
    FileConstants.FileCategory? categoryFilter,
    int? maxResults,
  }) async {
    try {
      _logger.debug('Searching files for: $query');
      
      await _checkStoragePermissions();
      
      final searchPath = rootPath ?? (await _getDefaultSearchPath());
      final searchResults = <FileModel>[];
      
      await _searchRecursive(
        Directory(searchPath),
        query,
        searchResults,
        categoryFilter: categoryFilter,
        maxResults: maxResults,
      );
      
      _logger.debug('Found ${searchResults.length} files matching: $query');
      return searchResults;
    } catch (e) {
      _logger.error('Error searching files: $e');
      throw FileSystemException('Failed to search files: $e');
    }
  }
  
  @override
  Future<List<FileModel>> getRecentFiles({
    int limit = 50,
    Duration? maxAge,
    FileConstants.FileCategory? categoryFilter,
  }) async {
    try {
      _logger.debug('Getting recent files (limit: $limit)');
      
      await _checkStoragePermissions();
      
      final maxAgeLimit = maxAge ?? const Duration(days: 7);
      final cutoffDate = DateTime.now().subtract(maxAgeLimit);
      
      final recentFiles = <FileModel>[];
      final searchPaths = await getAvailableStoragePaths();
      
      for (final searchPath in searchPaths) {
        await _findRecentFiles(
          Directory(searchPath),
          cutoffDate,
          recentFiles,
          categoryFilter: categoryFilter,
          maxResults: limit,
        );
        
        if (recentFiles.length >= limit) break;
      }
      
      // Sort by modification date (newest first)
      recentFiles.sort((a, b) => b.dateModified.compareTo(a.dateModified));
      
      final result = recentFiles.take(limit).toList();
      _logger.debug('Found ${result.length} recent files');
      
      return result;
    } catch (e) {
      _logger.error('Error getting recent files: $e');
      throw FileSystemException('Failed to get recent files: $e');
    }
  }
  
  @override
  Future<List<StorageInfoModel>> getStorageInfo() async {
    try {
      _logger.debug('Getting storage information');
      
      final storageList = <StorageInfoModel>[];
      
      // Get internal storage
      final internalDir = await getApplicationDocumentsDirectory();
      final internalStat = await internalDir.stat();
      
      storageList.add(StorageInfoModel(
        path: internalDir.path,
        totalSpace: 0, // Platform-specific implementation needed
        freeSpace: 0,  // Platform-specific implementation needed
        usedSpace: 0,  // Platform-specific implementation needed
        fileSystemType: 'internal',
        isRemovable: false,
        isEmulated: false,
        displayName: 'Internal Storage',
        metadata: {
          'type': 'internal',
          'accessed': internalStat.accessed.toIso8601String(),
        },
      ));
      
      // Get external storage (Android)
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final externalStat = await externalDir.stat();
          
          storageList.add(StorageInfoModel(
            path: externalDir.path,
            totalSpace: 0, // Platform-specific implementation needed
            freeSpace: 0,  // Platform-specific implementation needed
            usedSpace: 0,  // Platform-specific implementation needed
            fileSystemType: 'external',
            isRemovable: true,
            isEmulated: true,
            displayName: 'External Storage',
            metadata: {
              'type': 'external',
              'accessed': externalStat.accessed.toIso8601String(),
            },
          ));
        }
      } catch (e) {
        _logger.debug('External storage not available: $e');
      }
      
      _logger.debug('Found ${storageList.length} storage locations');
      return storageList;
    } catch (e) {
      _logger.error('Error getting storage info: $e');
      throw FileSystemException('Failed to get storage info: $e');
    }
  }
  
  @override
  Future<List<String>> getAvailableStoragePaths() async {
    try {
      final paths = <String>[];
      
      // Add common directories
      final documentsDir = await getApplicationDocumentsDirectory();
      paths.add(documentsDir.path);
      
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          paths.add(externalDir.path);
        }
      } catch (e) {
        _logger.debug('External storage not available: $e');
      }
      
      // Add downloads directory
      try {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          paths.add(downloadsDir.path);
        }
      } catch (e) {
        _logger.debug('Downloads directory not available: $e');
      }
      
      return paths;
    } catch (e) {
      _logger.error('Error getting storage paths: $e');
      throw FileSystemException('Failed to get storage paths: $e');
    }
  }
  
  @override
  Future<bool> pathExists(String path) async {
    try {
      final entity = FileSystemEntity.typeSync(path);
      return entity != FileSystemEntityType.notFound;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileSystemException('File does not exist', filePath: filePath);
      }
      
      return await file.length();
    } catch (e) {
      _logger.error('Error getting file size: $e');
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Failed to get file size: $e', filePath: filePath);
    }
  }
  
  @override
  Future<int> getFolderSize(String folderPath) async {
    try {
      return await FileUtils.getDirectorySize(folderPath);
    } catch (e) {
      _logger.error('Error getting folder size: $e');
      throw FileSystemException('Failed to get folder size: $e', filePath: folderPath);
    }
  }
  
  @override
  Stream<FileSystemEvent> watchDirectory(String directoryPath) {
    _logger.debug('Watching directory: $directoryPath');
    
    if (_watchControllers.containsKey(directoryPath)) {
      return _watchControllers[directoryPath]!.stream;
    }
    
    final controller = StreamController<FileSystemEvent>.broadcast();
    _watchControllers[directoryPath] = controller;
    
    final directory = Directory(directoryPath);
    final subscription = directory.watch(recursive: false).listen(
      (event) {
        _logger.debug('File system event: ${event.type} - ${event.path}');
        controller.add(event);
      },
      onError: (error) {
        _logger.error('File system watch error: $error');
        controller.addError(error);
      },
      onDone: () {
        _logger.debug('File system watch completed for: $directoryPath');
        controller.close();
        _watchControllers.remove(directoryPath);
      },
    );
    
    // Clean up when controller is closed
    controller.onCancel = () {
      subscription.cancel();
      _watchControllers.remove(directoryPath);
    };
    
    return controller.stream;
  }
  
  // Private helper methods
  
  Future<void> _checkStoragePermissions() async {
    final hasPermissions = await _permissionService.hasStoragePermissions();
    if (!hasPermissions) {
      throw PermissionException(
        'Storage permissions are required',
        'storage',
      );
    }
  }
  
  Future<FileModel> _createFileModel(File file) async {
    try {
      final stat = await file.stat();
      return FileModel.fromFileWithStat(file, stat);
    } catch (e) {
      _logger.warning('Failed to get file stats for ${file.path}: $e');
      return FileModel.fromFile(file);
    }
  }
  
  Future<FolderModel> _createFolderModel(Directory directory) async {
    try {
      final stat = await directory.stat();
      
      // Count contents
      int fileCount = 0;
      int folderCount = 0;
      int totalSize = 0;
      
      try {
        await for (final entity in directory.list()) {
          if (entity is File) {
            fileCount++;
            try {
              final size = await entity.length();
              totalSize += size;
            } catch (e) {
              // Skip files we can't access
            }
          } else if (entity is Directory) {
            folderCount++;
          }
        }
      } catch (e) {
        _logger.debug('Could not enumerate directory contents: $e');
      }
      
      return FolderModel.fromDirectoryWithStat(
        directory,
        stat,
        fileCount: fileCount,
        folderCount: folderCount,
        totalSize: totalSize,
      );
    } catch (e) {
      _logger.warning('Failed to get folder stats for ${directory.path}: $e');
      return FolderModel.fromDirectory(directory);
    }
  }
  
  bool _matchesSearchQuery(String filename, String query) {
    return filename.toLowerCase().contains(query.toLowerCase());
  }
  
  void _sortFiles(List<FileModel> files, FileSortOption sortBy, FileSortOrder sortOrder) {
    files.sort((a, b) {
      int comparison;
      
      switch (sortBy) {
        case FileSortOption.name:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case FileSortOption.date:
          comparison = a.dateModified.compareTo(b.dateModified);
          break;
        case FileSortOption.size:
          comparison = a.size.compareTo(b.size);
          break;
        case FileSortOption.type:
          comparison = a.extension.compareTo(b.extension);
          break;
      }
      
      return sortOrder == FileSortOrder.ascending ? comparison : -comparison;
    });
  }
  
  void _sortFolders(List<FolderModel> folders, FileSortOption sortBy, FileSortOrder sortOrder) {
    folders.sort((a, b) {
      int comparison;
      
      switch (sortBy) {
        case FileSortOption.name:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case FileSortOption.date:
          comparison = a.dateModified.compareTo(b.dateModified);
          break;
        case FileSortOption.size:
          comparison = a.totalSize.compareTo(b.totalSize);
          break;
        case FileSortOption.type:
          comparison = 0; // Folders don't have types
          break;
      }
      
      return sortOrder == FileSortOrder.ascending ? comparison : -comparison;
    });
  }
  
  Future<String> _getDefaultSearchPath() async {
    final paths = await getAvailableStoragePaths();
    return paths.isNotEmpty ? paths.first : '/';
  }
  
  Future<void> _searchRecursive(
    Directory directory,
    String query,
    List<FileModel> results, {
    FileConstants.FileCategory? categoryFilter,
    int? maxResults,
  }) async {
    if (maxResults != null && results.length >= maxResults) return;
    
    try {
      await for (final entity in directory.list()) {
        if (maxResults != null && results.length >= maxResults) break;
        
        if (entity is File) {
          try {
            final fileModel = await _createFileModel(entity);
            
            if (_matchesSearchQuery(fileModel.name, query)) {
              if (categoryFilter == null || fileModel.category == categoryFilter) {
                results.add(fileModel);
              }
            }
          } catch (e) {
            // Skip files we can't access
          }
        } else if (entity is Directory) {
          // Recursively search subdirectories
          try {
            await _searchRecursive(entity, query, results,
                categoryFilter: categoryFilter, maxResults: maxResults);
          } catch (e) {
            // Skip directories we can't access
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
  }
  
  Future<void> _findRecentFiles(
    Directory directory,
    DateTime cutoffDate,
    List<FileModel> results, {
    FileConstants.FileCategory? categoryFilter,
    int? maxResults,
  }) async {
    if (maxResults != null && results.length >= maxResults) return;
    
    try {
      await for (final entity in directory.list()) {
        if (maxResults != null && results.length >= maxResults) break;
        
        if (entity is File) {
          try {
            final fileModel = await _createFileModel(entity);
            
            if (fileModel.dateModified.isAfter(cutoffDate)) {
              if (categoryFilter == null || fileModel.category == categoryFilter) {
                results.add(fileModel);
              }
            }
          } catch (e) {
            // Skip files we can't access
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
  }
  
  /// Dispose resources
  void dispose() {
    for (final controller in _watchControllers.values) {
      controller.close();
    }
    _watchControllers.clear();
  }
}

// lib/features/file_management/data/repositories/file_management_repository_impl.dart
import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/entities/storage_info_entity.dart';
import '../../domain/repositories/file_management_repository.dart';
import '../../../../core/constants/file_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/services/logger_service.dart';
import '../datasources/file_system_datasource.dart';

/// File management repository implementation
class FileManagementRepositoryImpl implements FileManagementRepository {
  final FileSystemDataSource _dataSource;
  final LoggerService _logger = LoggerService();
  
  FileManagementRepositoryImpl(this._dataSource);
  
  @override
  Future<Either<Failure, List<FileEntity>>> getFiles(
    String directoryPath, {
    bool includeHidden = false,
    FileConstants.FileCategory? categoryFilter,
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
    FileConstants.FileCategory? categoryFilter,
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
        'files': (contents['files'] as List).map((file) => file.toEntity()).toList(),
        'folders': (contents['folders'] as List).map((folder) => folder.toEntity()).toList(),
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
  Future<Either<Failure, FolderEntity>> createFolder(String parentPath, String folderName) async {
    try {
      final folderModel = await _dataSource.createFolder(parentPath, folderName);
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
  Future<Either<Failure, void>> deleteFolder(String folderPath, {bool recursive = false}) async {
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
  Future<Either<Failure, FileEntity>> moveFile(String sourcePath, String destinationPath) async {
    try {
      final fileModel = await _dataSource.moveFile(sourcePath, destinationPath);
      final entity = fileModel.toEntity();
      
      _logger.info('Successfully moved file from $sourcePath to $destinationPath');
      return Right(entity);
    } catch (e) {
      _logger.error('Failed to move file: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }
  
  @override
  Future<Either<Failure, FolderEntity>> moveFolder(String sourcePath, String destinationPath) async {
    try {
      final folderModel = await _dataSource.moveFolder(sourcePath, destinationPath);
      final entity = folderModel.toEntity();
      
      _logger.info('Successfully moved folder from $sourcePath to $destinationPath');
      return Right(entity);
    } catch (e) {
      _logger.error('Failed to move folder: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }
  
  @override
  Future<Either<Failure, FileEntity>> copyFile(String sourcePath, String destinationPath) async {
    try {
      final fileModel = await _dataSource.copyFile(sourcePath, destinationPath);
      final entity = fileModel.toEntity();
      
      _logger.info('Successfully copied file from $sourcePath to $destinationPath');
      return Right(entity);
    } catch (e) {
      _logger.error('Failed to copy file: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }
  
  @override
  Future<Either<Failure, FileEntity>> renameFile(String filePath, String newName) async {
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
  Future<Either<Failure, FolderEntity>> renameFolder(String folderPath, String newName) async {
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
    FileConstants.FileCategory? categoryFilter,
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
    FileConstants.FileCategory? categoryFilter,
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
      final entities = storageList.map((storage) => storage.toEntity()).toList();
      
      _logger.debug('Retrieved storage info for ${entities.length} locations');
      return Right(entities);
    } catch (e) {
      _logger.error('Failed to get storage info: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }
  
  @override
  Stream<Either<Failure, FileSystemEvent>> watchDirectory(String directoryPath) {
    return _dataSource.watchDirectory(directoryPath).map(
      (event) => Right(event),
    ).handleError((error) {
      _logger.error('File system watch error: $error');
      final failure = ErrorHandler.handleException(error as Exception);
      return Left(failure);
    });
  }
}