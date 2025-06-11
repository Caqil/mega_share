import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../../domain/entities/storage_info_entity.dart';
import '../models/file_model.dart';
import '../models/folder_model.dart';
import '../models/storage_info_model.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_management_repository.dart';
import 'file_system_datasource.dart';
import 'package:path/path.dart' as path_utils;

class FileSystemDataSourceImpl implements FileSystemDataSource {
  static const String _favoritesKey = 'favorites_files';
  static const String _tagsKey = 'file_tags';
  static const String _accessCountKey = 'file_access_count';

  SharedPreferences? _prefs;
  final StreamController<StorageInfoModel> _storageInfoController =
      StreamController<StorageInfoModel>.broadcast();

  Timer? _storageUpdateTimer;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();

    // Start periodic storage updates
    _storageUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateStorageInfo(),
    );

    // Initial storage update
    _updateStorageInfo();

    _isInitialized = true;
  }

  Future<void> _updateStorageInfo() async {
    try {
      final storageInfo = await getStorageInfo();
      _storageInfoController.add(storageInfo);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Future<void> dispose() async {
    _storageUpdateTimer?.cancel();
    await _storageInfoController.close();
    _isInitialized = false;
  }

  @override
  Future<StorageInfoModel> getStorageInfo() async {
    final volumes = await getStorageVolumes();
    final primaryStorage = volumes.firstWhere(
      (v) => v.isPrimary,
      orElse: () => volumes.first,
    );

    final totalSpace = volumes.fold<int>(0, (sum, v) => sum + v.totalSpace);
    final totalFreeSpace = volumes.fold<int>(0, (sum, v) => sum + v.freeSpace);
    final totalUsedSpace = totalSpace - totalFreeSpace;

    // Get file type distribution
    final fileTypeDistribution = await _getFileTypeDistribution();

    // Get largest folders
    final largestFolders = await _getLargestFolders();

    // Get recent and large files
    final recentFiles = await getRecentFiles(limit: 20);
    final largeFiles = await getLargeFiles(limit: 10);

    return StorageInfoModel(
      volumes: volumes,
      primaryStorage: primaryStorage,
      totalSpace: totalSpace,
      totalFreeSpace: totalFreeSpace,
      totalUsedSpace: totalUsedSpace,
      fileTypeDistribution: fileTypeDistribution,
      largestFolders: largestFolders,
      recentFiles: recentFiles,
      largeFiles: largeFiles,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Stream<StorageInfoModel> getStorageInfoStream() =>
      _storageInfoController.stream;

  @override
  Future<List<StorageVolumeModel>> getStorageVolumes() async {
    final volumes = <StorageVolumeModel>[];

    // Primary internal storage
    final internalPath = Platform.isAndroid
        ? '/storage/emulated/0'
        : Directory.systemTemp.parent.path;
    final internalDir = Directory(internalPath);

    if (await internalDir.exists()) {
      final stat = await internalDir.stat();
      final totalSpace = await _getDirectorySize(internalPath) * 4; // Estimate
      final freeSpace = totalSpace ~/ 3; // Estimate

      volumes.add(
        StorageVolumeModel(
          id: 'internal_storage',
          name: 'Internal Storage',
          path: internalPath,
          type: StorageType.internal,
          totalSpace: totalSpace,
          freeSpace: freeSpace,
          usedSpace: totalSpace - freeSpace,
          isRemovable: false,
          isEmulated: Platform.isAndroid,
          isPrimary: true,
          isWritable: true,
          isAvailable: true,
          metadata: {'file_system': 'ext4', 'mount_point': internalPath},
        ),
      );
    }

    // External storage (Android)
    if (Platform.isAndroid) {
      final externalPaths = ['/storage/sdcard1', '/storage/extSdCard'];

      for (final externalPath in externalPaths) {
        final externalDir = Directory(externalPath);
        if (await externalDir.exists()) {
          final totalSpace =
              await _getDirectorySize(externalPath) * 2; // Estimate
          final freeSpace = totalSpace ~/ 2; // Estimate

          volumes.add(
            StorageVolumeModel(
              id: 'external_storage_${volumes.length}',
              name: 'SD Card',
              path: externalPath,
              type: StorageType.external,
              totalSpace: totalSpace,
              freeSpace: freeSpace,
              usedSpace: totalSpace - freeSpace,
              isRemovable: true,
              isEmulated: false,
              isPrimary: false,
              isWritable: true,
              isAvailable: true,
              metadata: {'file_system': 'fat32', 'mount_point': externalPath},
            ),
          );
        }
      }
    }

    return volumes;
  }

  Future<int> _getDirectorySize(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      int size = 0;

      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            size += stat.size;
          } catch (e) {
            // Skip files we can't access
          }
        }
      }

      return size;
    } catch (e) {
      return 1024 * 1024 * 1024; // Default 1GB estimate
    }
  }

  Future<Map<FileType, int>> _getFileTypeDistribution() async {
    final distribution = <FileType, int>{};

    // Initialize all types
    for (final type in FileType.values) {
      distribution[type] = 0;
    }

    // Sample common directories
    final commonPaths = [
      '/storage/emulated/0/Pictures',
      '/storage/emulated/0/Videos',
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Documents',
      '/storage/emulated/0/Download',
    ];

    for (final dirPath in commonPaths) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        try {
          await for (final entity in dir.list()) {
            if (entity is File) {
              final fileType = _getFileTypeFromPath(entity.path);
              distribution[fileType] = distribution[fileType]! + 1;
            }
          }
        } catch (e) {
          // Skip directories we can't access
        }
      }
    }

    return distribution;
  }

  Future<Map<String, int>> _getLargestFolders() async {
    final folders = <String, int>{};

    final commonPaths = [
      '/storage/emulated/0/Pictures',
      '/storage/emulated/0/Videos',
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Documents',
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Android',
    ];

    for (final dirPath in commonPaths) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        try {
          final size = await _getDirectorySize(dirPath);
          folders[path.basename(dirPath)] = size;
        } catch (e) {
          // Skip directories we can't access
        }
      }
    }

    return folders;
  }

  @override
  Future<List<FileModel>> getFiles({
    required String path,
    FileFilter? filter,
    SortBy sortBy = SortBy.name,
    SortOrder sortOrder = SortOrder.ascending,
    int? limit,
    int? offset,
  }) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    final files = <FileModel>[];

    try {
      await for (final entity in dir.list()) {
        if (entity is File) {
          final fileModel = await _createFileModel(entity);

          // Apply filters
          if (filter != null && !_passesFilter(fileModel, filter)) {
            continue;
          }

          files.add(fileModel);
        }
      }
    } catch (e) {
      // Return empty list if we can't access the directory
      return [];
    }

    // Sort files
    _sortFiles(files, sortBy, sortOrder);

    // Apply pagination
    if (offset != null && offset > 0) {
      if (offset >= files.length) return [];
      files.removeRange(0, offset);
    }

    if (limit != null && limit > 0 && files.length > limit) {
      files.removeRange(limit, files.length);
    }

    return files;
  }

  Future<FileModel> _createFileModel(File file) async {
    final stat = await file.stat();
    final filePath = file.path;
    final fileName = path.basename(filePath);
    final fileExtension = path.extension(filePath).toLowerCase();
    final parentPath = path.dirname(filePath);

    // Generate file ID from path hash
    final pathBytes = utf8.encode(filePath);
    final pathHash = sha256.convert(pathBytes);
    final fileId = pathHash.toString().substring(0, 16);

    // Determine file type and MIME type
    final fileType = _getFileTypeFromPath(filePath);
    final mimeType = _getMimeTypeFromExtension(fileExtension);

    // Get favorites and tags
    final favorites = _getFavoritesList();
    final tags = _getTagsList(filePath);
    final accessCount = _getAccessCount(filePath);

    // Basic metadata
    final metadata = <String, dynamic>{
      'file_system_path': filePath,
      'absolute_path': file.absolute.path,
    };

    // Add type-specific metadata
    if (fileType == FileType.image || fileType == FileType.video) {
      // In a real implementation, you'd use packages like flutter_ffmpeg
      // or image packages to get actual dimensions
      metadata['width'] = 1920;
      metadata['height'] = 1080;
    }

    if (fileType == FileType.video || fileType == FileType.audio) {
      // Mock duration - in real implementation use media_info package
      metadata['duration_ms'] = 120000; // 2 minutes
    }

    return FileModel(
      id: fileId,
      name: fileName,
      path: filePath,
      extension: fileExtension,
      size: stat.size,
      dateCreated: stat.accessed, // File system limitation
      dateModified: stat.modified,
      dateAccessed: stat.accessed,
      type: fileType,
      source: _getFileSource(filePath),
      mimeType: mimeType,
      isHidden: fileName.startsWith('.'),
      isReadOnly: stat.mode & 0x200 == 0, // Check write permission
      isDirectory: false,
      thumbnailPath: null, // Would be generated on demand
      metadata: metadata,
      parentPath: parentPath,
      isFavorite: favorites.contains(filePath),
      accessCount: accessCount,
      tags: tags,
    );
  }

  FileType _getFileTypeFromPath(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    const videoExtensions = ['.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv'];
    const audioExtensions = ['.mp3', '.wav', '.flac', '.aac', '.ogg', '.m4a'];
    const documentExtensions = [
      '.pdf',
      '.doc',
      '.docx',
      '.txt',
      '.rtf',
      '.odt',
    ];
    const archiveExtensions = ['.zip', '.rar', '.7z', '.tar', '.gz'];
    const appExtensions = ['.apk', '.exe', '.dmg', '.deb'];

    if (imageExtensions.contains(extension)) return FileType.image;
    if (videoExtensions.contains(extension)) return FileType.video;
    if (audioExtensions.contains(extension)) return FileType.audio;
    if (documentExtensions.contains(extension)) return FileType.document;
    if (archiveExtensions.contains(extension)) return FileType.archive;
    if (appExtensions.contains(extension)) return FileType.application;
    if (extension == '.txt') return FileType.text;

    return FileType.unknown;
  }

  String _getMimeTypeFromExtension(String extension) {
    const mimeTypes = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.mp4': 'video/mp4',
      '.mp3': 'audio/mpeg',
      '.pdf': 'application/pdf',
      '.txt': 'text/plain',
      '.zip': 'application/zip',
    };

    return mimeTypes[extension] ?? 'application/octet-stream';
  }

  FileSource _getFileSource(String filePath) {
    if (filePath.contains('/Pictures')) return FileSource.pictures;
    if (filePath.contains('/Videos')) return FileSource.videos;
    if (filePath.contains('/Music')) return FileSource.music;
    if (filePath.contains('/Documents')) return FileSource.documents;
    if (filePath.contains('/Download')) return FileSource.downloads;
    if (filePath.contains('/DCIM')) return FileSource.dcim;
    if (filePath.contains('/storage/emulated/0')) return FileSource.internal;
    if (filePath.contains('/storage/')) return FileSource.external;

    return FileSource.custom;
  }

  bool _passesFilter(FileModel file, FileFilter filter) {
    if (filter.types != null && !filter.types!.contains(file.type)) {
      return false;
    }

    if (filter.minSize != null && file.size < filter.minSize!) {
      return false;
    }

    if (filter.maxSize != null && file.size > filter.maxSize!) {
      return false;
    }

    if (filter.startDate != null &&
        file.dateModified.isBefore(filter.startDate!)) {
      return false;
    }

    if (filter.endDate != null && file.dateModified.isAfter(filter.endDate!)) {
      return false;
    }

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      if (!file.name.toLowerCase().contains(query)) {
        return false;
      }
    }

    if (filter.includeFavorites == true && !file.isFavorite) {
      return false;
    }

    if (filter.includeHidden == false && file.isHidden) {
      return false;
    }

    if (filter.tags != null && filter.tags!.isNotEmpty) {
      if (!filter.tags!.any((tag) => file.tags.contains(tag))) {
        return false;
      }
    }

    return true;
  }

  void _sortFiles(List<FileModel> files, SortBy sortBy, SortOrder sortOrder) {
    files.sort((a, b) {
      int comparison;

      switch (sortBy) {
        case SortBy.name:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortBy.size:
          comparison = a.size.compareTo(b.size);
          break;
        case SortBy.dateModified:
          comparison = a.dateModified.compareTo(b.dateModified);
          break;
        case SortBy.dateCreated:
          comparison = a.dateCreated.compareTo(b.dateCreated);
          break;
        case SortBy.type:
          comparison = a.type.index.compareTo(b.type.index);
          break;
      }

      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
  }

  @override
  Future<List<FileModel>> getFilesByType({
    required FileType type,
    String? path,
    SortBy sortBy = SortBy.dateModified,
    SortOrder sortOrder = SortOrder.descending,
    int? limit,
  }) async {
    final filter = FileFilter(types: [type]);
    final searchPaths = path != null ? [path] : _getDefaultPathsForType(type);

    final allFiles = <FileModel>[];

    for (final searchPath in searchPaths) {
      final files = await getFiles(
        path: searchPath,
        filter: filter,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      allFiles.addAll(files);
    }

    // Remove duplicates and sort
    final uniqueFiles = allFiles.toSet().toList();
    _sortFiles(uniqueFiles, sortBy, sortOrder);

    if (limit != null && uniqueFiles.length > limit) {
      uniqueFiles.removeRange(limit, uniqueFiles.length);
    }

    return uniqueFiles;
  }

  List<String> _getDefaultPathsForType(FileType type) {
    switch (type) {
      case FileType.image:
        return ['/storage/emulated/0/Pictures', '/storage/emulated/0/DCIM'];
      case FileType.video:
        return ['/storage/emulated/0/Videos', '/storage/emulated/0/DCIM'];
      case FileType.audio:
        return ['/storage/emulated/0/Music'];
      case FileType.document:
        return [
          '/storage/emulated/0/Documents',
          '/storage/emulated/0/Download',
        ];
      default:
        return ['/storage/emulated/0'];
    }
  }

  @override
  Future<List<FileModel>> getRecentFiles({
    int limit = 50,
    List<FileType>? types,
  }) async {
    final allFiles = <FileModel>[];
    final commonPaths = [
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Pictures',
      '/storage/emulated/0/Videos',
      '/storage/emulated/0/Documents',
    ];

    for (final dirPath in commonPaths) {
      final files = await getFiles(
        path: dirPath,
        filter: types != null ? FileFilter(types: types) : null,
        sortBy: SortBy.dateModified,
        sortOrder: SortOrder.descending,
      );
      allFiles.addAll(files);
    }

    // Sort by modification date and limit
    allFiles.sort((a, b) => b.dateModified.compareTo(a.dateModified));

    if (allFiles.length > limit) {
      allFiles.removeRange(limit, allFiles.length);
    }

    return allFiles;
  }

  @override
  Future<List<FileModel>> getFavoriteFiles({List<FileType>? types}) async {
    final favorites = _getFavoritesList();
    final favoriteFiles = <FileModel>[];

    for (final filePath in favorites) {
      final file = File(filePath);
      if (await file.exists()) {
        try {
          final fileModel = await _createFileModel(file);
          if (types == null || types.contains(fileModel.type)) {
            favoriteFiles.add(fileModel);
          }
        } catch (e) {
          // Skip files we can't process
        }
      }
    }

    return favoriteFiles;
  }

  @override
  Future<List<FileModel>> getLargeFiles({int limit = 20, int? minSize}) async {
    final threshold = minSize ?? 10 * 1024 * 1024; // Default 10MB
    final filter = FileFilter(minSize: threshold);

    final allFiles = <FileModel>[];
    final commonPaths = ['/storage/emulated/0'];

    for (final dirPath in commonPaths) {
      final files = await getFiles(
        path: dirPath,
        filter: filter,
        sortBy: SortBy.size,
        sortOrder: SortOrder.descending,
        limit: limit,
      );
      allFiles.addAll(files);
    }

    // Sort by size and limit
    allFiles.sort((a, b) => b.size.compareTo(a.size));

    if (allFiles.length > limit) {
      allFiles.removeRange(limit, allFiles.length);
    }

    return allFiles;
  }

  @override
  Future<List<FileModel>> searchFiles({
    required String query,
    String? path,
    List<FileType>? types,
    int? limit,
  }) async {
    final filter = FileFilter(searchQuery: query, types: types);

    final searchPath = path ?? '/storage/emulated/0';
    return await getFiles(
      path: searchPath,
      filter: filter,
      sortBy: SortBy.name,
      sortOrder: SortOrder.ascending,
      limit: limit,
    );
  }

  @override
  Future<List<FolderModel>> getFolders({
    required String path,
    bool includeHidden = false,
    SortBy sortBy = SortBy.name,
    SortOrder sortOrder = SortOrder.ascending,
  }) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    final folders = <FolderModel>[];

    try {
      await for (final entity in dir.list()) {
        if (entity is Directory) {
          final folderModel = await _createFolderModel(entity, includeHidden);
          if (folderModel != null) {
            folders.add(folderModel);
          }
        }
      }
    } catch (e) {
      return [];
    }

    // Sort folders
    _sortFolders(folders, sortBy, sortOrder);

    return folders;
  }

  Future<FolderModel?> _createFolderModel(
    Directory dir,
    bool includeHidden,
  ) async {
    final stat = await dir.stat();
    final dirPath = dir.path;
    final dirName = path.basename(dirPath);
    final parentPath = path.dirname(dirPath);

    // Skip hidden folders if not included
    if (!includeHidden && dirName.startsWith('.')) {
      return null;
    }

    // Generate folder ID from path hash
    final pathBytes = utf8.encode(dirPath);
    final pathHash = sha256.convert(pathBytes);
    final folderId = pathHash.toString().substring(0, 16);

    // Count files and folders
    int fileCount = 0;
    int folderCount = 0;
    int totalSize = 0;
    bool hasSubfolders = false;

    try {
      await for (final entity in dir.list()) {
        if (entity is File) {
          fileCount++;
          final fileStat = await entity.stat();
          totalSize += fileStat.size;
        } else if (entity is Directory) {
          folderCount++;
          hasSubfolders = true;
        }
      }
    } catch (e) {
      // Use default values if we can't access the directory
    }

    // Get favorites and tags
    final favorites = _getFavoritesList();
    final tags = _getTagsList(dirPath);

    return FolderModel(
      id: folderId,
      name: dirName,
      path: dirPath,
      dateCreated: stat.accessed, // File system limitation
      dateModified: stat.modified,
      dateAccessed: stat.accessed,
      source: _getFileSource(dirPath),
      isHidden: dirName.startsWith('.'),
      isReadOnly: stat.mode & 0x200 == 0, // Check write permission
      parentPath: parentPath,
      fileCount: fileCount,
      folderCount: folderCount,
      totalSize: totalSize,
      isFavorite: favorites.contains(dirPath),
      tags: tags,
      metadata: {
        'file_system_path': dirPath,
        'absolute_path': dir.absolute.path,
      },
      hasSubfolders: hasSubfolders,
      isExpanded: false,
    );
  }

  void _sortFolders(
    List<FolderModel> folders,
    SortBy sortBy,
    SortOrder sortOrder,
  ) {
    folders.sort((a, b) {
      int comparison;

      switch (sortBy) {
        case SortBy.name:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortBy.size:
          comparison = a.totalSize.compareTo(b.totalSize);
          break;
        case SortBy.dateModified:
          comparison = a.dateModified.compareTo(b.dateModified);
          break;
        case SortBy.dateCreated:
          comparison = a.dateCreated.compareTo(b.dateCreated);
          break;
        case SortBy.type:
          comparison = 0; // All folders are the same type
          break;
      }

      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
  }

  @override
  Future<FolderModel> createFolder({
    required String parentPath,
    required String name,
  }) async {
    final folderPath = path.join(parentPath, name);
    final dir = Directory(folderPath);

    if (await dir.exists()) {
      throw Exception('Folder already exists');
    }

    await dir.create(recursive: true);

    // Handle the nullable return from _createFolderModel
    final folderModel = await _createFolderModel(dir, true);
    if (folderModel == null) {
      throw Exception('Failed to create folder model');
    }

    return folderModel;
  }

  @override
  Future<void> deleteFolder({
    required String path,
    bool recursive = false,
  }) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: recursive);

      // Remove from favorites and tags
      await removeFromFavorites(path);
      _removeAllTags(path);
    }
  }

  @override
  Future<void> deleteFiles(List<String> paths) async {
    for (final filePath in paths) {
      await deleteFile(filePath);
    }
  }

  @override
  Future<FileModel> copyFile({
    required String sourcePath,
    required String destinationPath,
  }) async {
    final sourceFile = File(sourcePath);
    final copiedFile = await sourceFile.copy(destinationPath);

    return await _createFileModel(copiedFile);
  }

  @override
  Future<FileModel> moveFile({
    required String sourcePath,
    required String destinationPath,
  }) async {
    final sourceFile = File(sourcePath);

    // Copy then delete original
    await sourceFile.copy(destinationPath);
    await sourceFile.delete();

    // Update references
    await removeFromFavorites(sourcePath);
    _removeAllTags(sourcePath);
    _removeAccessCount(sourcePath);

    final movedFile = File(destinationPath);
    return await _createFileModel(movedFile);
  }

  @override
  Future<void> addToFavorites(String path) async {
    final favorites = _getFavoritesList();
    if (!favorites.contains(path)) {
      favorites.add(path);
      await _prefs?.setStringList(_favoritesKey, favorites);
    }
  }

  @override
  Future<void> removeFromFavorites(String path) async {
    final favorites = _getFavoritesList();
    if (favorites.remove(path)) {
      await _prefs?.setStringList(_favoritesKey, favorites);
    }
  }

  List<String> _getFavoritesList() {
    return _prefs?.getStringList(_favoritesKey) ?? [];
  }

  @override
  Future<void> addTag(String path, String tag) async {
    final tags = _getTagsMap();
    final fileTags = tags[path] ?? <String>[];

    if (!fileTags.contains(tag)) {
      fileTags.add(tag);
      tags[path] = fileTags;
      await _saveTagsMap(tags);
    }
  }

  @override
  Future<void> removeTag(String path, String tag) async {
    final tags = _getTagsMap();
    final fileTags = tags[path];

    if (fileTags != null && fileTags.remove(tag)) {
      if (fileTags.isEmpty) {
        tags.remove(path);
      } else {
        tags[path] = fileTags;
      }
      await _saveTagsMap(tags);
    }
  }

  List<String> _getTagsList(String path) {
    final tags = _getTagsMap();
    return tags[path] ?? [];
  }

  void _removeAllTags(String path) {
    final tags = _getTagsMap();
    if (tags.remove(path) != null) {
      _saveTagsMap(tags);
    }
  }

  Map<String, List<String>> _getTagsMap() {
    final tagsJson = _prefs?.getString(_tagsKey) ?? '{}';
    final tagsData = jsonDecode(tagsJson) as Map<String, dynamic>;

    return tagsData.map(
      (key, value) => MapEntry(key, List<String>.from(value as List)),
    );
  }

  Future<void> _saveTagsMap(Map<String, List<String>> tags) async {
    final tagsJson = jsonEncode(tags);
    await _prefs?.setString(_tagsKey, tagsJson);
  }

  @override
  Future<Map<String, dynamic>> getFileMetadata(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('File not found');
    }

    final fileModel = await _createFileModel(file);
    return fileModel.metadata;
  }

  @override
  Future<String?> generateThumbnail(String filePath) async {
    // Renamed parameter
    final file = File(filePath);
    if (!await file.exists()) return null;

    final fileType = _getFileTypeFromPath(filePath);

    // In a real implementation, you would use packages like:
    // - video_thumbnail for video thumbnails
    // - flutter_image_compress for image thumbnails
    // - pdf_thumbnail for PDF thumbnails

    if (fileType == FileType.image || fileType == FileType.video) {
      // Mock thumbnail path
      final fileName = path.basename(filePath); // Uses path package correctly
      final thumbnailDir = Directory('/storage/emulated/0/.thumbnails');
      await thumbnailDir.create(recursive: true);

      return path.join(
        thumbnailDir.path,
        '${fileName}_thumb.jpg',
      ); // Uses path package correctly
    }

    return null;
  }

  @override
  Future<void> updateAccessCount(String path) async {
    final accessCounts = _getAccessCountMap();
    accessCounts[path] = (accessCounts[path] ?? 0) + 1;
    await _saveAccessCountMap(accessCounts);
  }

  int _getAccessCount(String path) {
    final accessCounts = _getAccessCountMap();
    return accessCounts[path] ?? 0;
  }

  void _removeAccessCount(String path) {
    final accessCounts = _getAccessCountMap();
    if (accessCounts.remove(path) != null) {
      _saveAccessCountMap(accessCounts);
    }
  }

  Map<String, int> _getAccessCountMap() {
    final accessJson = _prefs?.getString(_accessCountKey) ?? '{}';
    final accessData = jsonDecode(accessJson) as Map<String, dynamic>;

    return accessData.map((key, value) => MapEntry(key, value as int));
  }

  Future<void> _saveAccessCountMap(Map<String, int> accessCounts) async {
    final accessJson = jsonEncode(accessCounts);
    await _prefs?.setString(_accessCountKey, accessJson);
  }

  @override
  Future<bool> hasReadPermission() async {
    return await Permission.storage.isGranted;
  }

  @override
  Future<bool> hasWritePermission() async {
    return await Permission.storage.isGranted;
  }

  @override
  Future<bool> requestPermissions() async {
    final permissions = [Permission.storage, Permission.manageExternalStorage];

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    return statuses.values.every(
      (status) => status == PermissionStatus.granted,
    );
  }

  @override
  Future<void> deleteFile(String filePath) async {
    // Renamed parameter
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();

      // Remove from favorites and tags
      await removeFromFavorites(filePath);
      _removeAllTags(filePath);
      _removeAccessCount(filePath);
    }
  }

  @override
  Future<FileModel> renameFile({
    required String path, // Keep interface parameter name
    required String newName,
  }) async {
    final file = File(path);
    final parentPath = file.parent.path;
    // Use qualified import: path_utils.join instead of path.join
    final newPath = path_utils.join(parentPath, newName);

    final renamedFile = await file.rename(newPath);

    return await _createFileModel(renamedFile);
  }

  @override
  Future<FolderModel> renameFolder({
    required String path, // Keep interface parameter name
    required String newName,
  }) async {
    final dir = Directory(path);
    final parentPath = dir.parent.path;
    // Use qualified import: path_utils.join instead of path.join
    final newPath = path_utils.join(parentPath, newName);

    final renamedDir = await dir.rename(newPath);

    final folderModel = await _createFolderModel(renamedDir, true);
    if (folderModel == null) {
      throw Exception('Failed to create renamed folder model');
    }

    return folderModel;
  }
}
