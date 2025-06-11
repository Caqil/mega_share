import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import '../constants/file_constants.dart';
import '../services/logger_service.dart';

/// File utility class for common file operations
class FileUtils {
  static final LoggerService _logger = LoggerService.instance;

  /// Get file extension from path (includes the dot)
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Get file name with extension from path
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Get file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    final fileName = path.basename(filePath);
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return fileName;
    return fileName.substring(0, lastDot);
  }

  /// Get parent directory path
  static String getParentDirectory(String filePath) {
    return path.dirname(filePath);
  }

  /// Get MIME type from file path
  static String getMimeType(String filePath) {
    final extension = getFileExtension(filePath);
    return  mimeTypes[extension] ?? 'application/octet-stream';
  }

  /// Get file category based on extension
  static  FileCategory getFileCategory(String filePath) {
    final extension = getFileExtension(filePath);

    if ( FileConstants.imageExtensions.contains(extension)) {
      return  FileCategory.image;
    } else if ( FileConstants.videoExtensions.contains(extension)) {
      return  FileCategory.video;
    } else if ( FileConstants.audioExtensions.contains(extension)) {
      return  FileCategory.audio;
    } else if ( FileConstants.documentExtensions.contains(extension)) {
      return  FileCategory.document;
    } else if ( FileConstants.archiveExtensions.contains(extension)) {
      return  FileCategory.archive;
    } else if ( FileConstants.codeExtensions.contains(extension)) {
      return  FileCategory.code;
    } else if (extension == '.apk' || extension == '.ipa') {
      return  FileCategory.app;
    } else {
      return  FileCategory.other;
    }
  }

  /// Validate file for safety and constraints
  static Future<FileValidationResult> validateFile(String filePath) async {
    try {
      final file = File(filePath);
      
      // Check if file exists
      if (!await file.exists()) {
        return FileValidationResult(
          isValid: false,
          errors: ['File does not exist'],
        );
      }

      final errors = <String>[];
      final warnings = <String>[];

      // Check file size
      final size = await file.length();
      if (size >  maxFileSizeBytes) {
        errors.add('File size exceeds maximum limit (${formatFileSize( maxFileSizeBytes)})');
      }

      // Check if file is empty
      if (size == 0) {
        warnings.add('File is empty');
      }

      // Check file extension
      final extension = getFileExtension(filePath);
      if ( prohibitedExtensions.contains(extension)) {
        errors.add('File type is not allowed for security reasons');
      }

      // Check if file is readable
      try {
        await file.openRead().first;
      } catch (e) {
        errors.add('File is not readable');
      }

      return FileValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
        fileSize: size,
        category: getFileCategory(filePath),
        mimeType: getMimeType(filePath),
      );
    } catch (e) {
      _logger.error('Error validating file $filePath: $e');
      return FileValidationResult(
        isValid: false,
        errors: ['Failed to validate file: $e'],
      );
    }
  }

  /// Calculate MD5 hash of a file
  static Future<String?> calculateFileHash(String filePath, {String algorithm = 'md5'}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.warning('File does not exist: $filePath');
        return null;
      }

      final stream = file.openRead();
      late Digest digest;

      switch (algorithm.toLowerCase()) {
        case 'md5':
          digest = await md5.bind(stream).first;
          break;
        case 'sha1':
          digest = await sha1.bind(stream).first;
          break;
        case 'sha256':
          digest = await sha256.bind(stream).first;
          break;
        default:
          digest = await md5.bind(stream).first;
      }

      return digest.toString();
    } catch (e) {
      _logger.error('Error calculating file hash: $e');
      return null;
    }
  }

  /// Format file size in human readable format
  static String formatFileSize(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';

    const List<String> suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Get directory size recursively
  static Future<int> getDirectorySize(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return 0;
      }

      int totalSize = 0;

      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            totalSize += stat.size;
          } catch (e) {
            _logger.debug('Could not get size for file: ${entity.path}');
          }
        }
      }

      return totalSize;
    } catch (e) {
      _logger.error('Error calculating directory size: $e');
      return 0;
    }
  }

  /// Count files in directory
  static Future<int> countFilesInDirectory(String directoryPath, {bool recursive = false}) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return 0;
      }

      int count = 0;

      await for (final entity in directory.list(recursive: recursive)) {
        if (entity is File) {
          count++;
        }
      }

      return count;
    } catch (e) {
      _logger.error('Error counting files in directory: $e');
      return 0;
    }
  }

  /// Count folders in directory
  static Future<int> countFoldersInDirectory(String directoryPath, {bool recursive = false}) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return 0;
      }

      int count = 0;

      await for (final entity in directory.list(recursive: recursive)) {
        if (entity is Directory) {
          count++;
        }
      }

      return count;
    } catch (e) {
      _logger.error('Error counting folders in directory: $e');
      return 0;
    }
  }

  /// Create directory if it doesn't exist
  static Future<bool> createDirectoryIfNotExists(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        _logger.debug('Created directory: $directoryPath');
      }
      return true;
    } catch (e) {
      _logger.error('Error creating directory $directoryPath: $e');
      return false;
    }
  }

  /// Check if path is safe (no directory traversal)
  static bool isSafePath(String filePath) {
    // Normalize the path
    final normalized = path.normalize(filePath);
    
    // Check for directory traversal patterns
    if (normalized.contains('../') || normalized.contains('..\\')) {
      return false;
    }

    // Check for absolute paths on Unix-like systems
    if (normalized.startsWith('/')) {
      return false;
    }

    // Check for drive letters and UNC paths on Windows
    if (RegExp(r'^[a-zA-Z]:|^\\\\')).hasMatch(normalized)) {
      return false;
    }

    return true;
  }

  /// Generate unique filename if file already exists
  static String generateUniqueFilename(String directoryPath, String filename) {
    final file = File(path.join(directoryPath, filename));
    if (!file.existsSync()) {
      return filename;
    }

    final extension = getFileExtension(filename);
    final nameWithoutExt = getFileNameWithoutExtension(filename);
    int counter = 1;

    while (true) {
      final newFilename = extension.isNotEmpty
          ? '$nameWithoutExt ($counter)$extension'
          : '$nameWithoutExt ($counter)';
      
      final newFile = File(path.join(directoryPath, newFilename));
      if (!newFile.existsSync()) {
        return newFilename;
      }
      counter++;
    }
  }

  /// Copy file with progress callback
  static Future<bool> copyFileWithProgress(
    String sourcePath,
    String destinationPath, {
    Function(int bytesTransferred, int totalBytes)? onProgress,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);

      if (!await sourceFile.exists()) {
        _logger.error('Source file does not exist: $sourcePath');
        return false;
      }

      // Create destination directory if needed
      final destinationDir = Directory(path.dirname(destinationPath));
      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
      }

      final totalBytes = await sourceFile.length();
      int bytesTransferred = 0;

      final source = sourceFile.openRead();
      final sink = destinationFile.openWrite();

      await for (final chunk in source) {
        sink.add(chunk);
        bytesTransferred += chunk.length;
        onProgress?.call(bytesTransferred, totalBytes);
      }

      await sink.close();
      _logger.debug('File copied successfully: $sourcePath -> $destinationPath');
      return true;
    } catch (e) {
      _logger.error('Error copying file: $e');
      return false;
    }
  }

  /// Move file to new location
  static Future<bool> moveFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        _logger.error('Source file does not exist: $sourcePath');
        return false;
      }

      // Create destination directory if needed
      final destinationDir = Directory(path.dirname(destinationPath));
      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
      }

      await sourceFile.rename(destinationPath);
      _logger.debug('File moved successfully: $sourcePath -> $destinationPath');
      return true;
    } catch (e) {
      _logger.error('Error moving file: $e');
      return false;
    }
  }

  /// Delete file safely
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _logger.debug('File deleted successfully: $filePath');
        return true;
      } else {
        _logger.warning('File does not exist: $filePath');
        return false;
      }
    } catch (e) {
      _logger.error('Error deleting file: $e');
      return false;
    }
  }

  /// Delete directory recursively
  static Future<bool> deleteDirectory(String directoryPath, {bool recursive = true}) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        await directory.delete(recursive: recursive);
        _logger.debug('Directory deleted successfully: $directoryPath');
        return true;
      } else {
        _logger.warning('Directory does not exist: $directoryPath');
        return false;
      }
    } catch (e) {
      _logger.error('Error deleting directory: $e');
      return false;
    }
  }

  /// Get file creation and modification dates
  static Future<FileDates?> getFileDates(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final stat = await file.stat();
      return FileDates(
        created: stat.accessed, // Unix limitation - using accessed as created
        modified: stat.modified,
        accessed: stat.accessed,
      );
    } catch (e) {
      _logger.error('Error getting file dates: $e');
      return null;
    }
  }

  /// Check if file is hidden
  static bool isHiddenFile(String filePath) {
    final fileName = getFileName(filePath);
    return fileName.startsWith('.');
  }

  /// Get file permissions
  static Future<FilePermissions?> getFilePermissions(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final stat = await file.stat();
      final mode = stat.mode;

      return FilePermissions(
        readable: (mode & 0x100) != 0, // Owner read
        writable: (mode & 0x80) != 0,  // Owner write
        executable: (mode & 0x40) != 0, // Owner execute
        mode: mode,
      );
    } catch (e) {
      _logger.error('Error getting file permissions: $e');
      return null;
    }
  }

  /// Create temporary file with unique name
  static Future<String?> createTempFile({String? prefix, String? suffix}) async {
    try {
      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${prefix ?? 'temp'}_$timestamp${suffix ?? '.tmp'}';
      final tempFilePath = path.join(tempDir.path, filename);
      
      final tempFile = File(tempFilePath);
      await tempFile.create();
      
      _logger.debug('Created temporary file: $tempFilePath');
      return tempFilePath;
    } catch (e) {
      _logger.error('Error creating temporary file: $e');
      return null;
    }
  }

  /// Clean up old temporary files
  static Future<void> cleanupTempFiles({Duration maxAge = const Duration(hours: 24)}) async {
    try {
      final tempDir = Directory.systemTemp;
      final cutoffTime = DateTime.now().subtract(maxAge);

      await for (final entity in tempDir.list()) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            if (stat.modified.isBefore(cutoffTime)) {
              await entity.delete();
              _logger.debug('Deleted old temp file: ${entity.path}');
            }
          } catch (e) {
            // Continue with next file if we can't process this one
            _logger.debug('Could not process temp file: ${entity.path}');
          }
        }
      }
    } catch (e) {
      _logger.error('Error cleaning up temp files: $e');
    }
  }

  /// Get relative path from base directory
  static String getRelativePath(String filePath, String basePath) {
    return path.relative(filePath, from: basePath);
  }

  /// Join paths safely
  static String joinPaths(List<String> paths) {
    return path.joinAll(paths);
  }

  /// Normalize path separators for current platform
  static String normalizePath(String filePath) {
    return path.normalize(filePath);
  }

  /// Check if path exists (file or directory)
  static Future<bool> pathExists(String path) async {
    try {
      final type = await FileSystemEntity.type(path);
      return type != FileSystemEntityType.notFound;
    } catch (e) {
      return false;
    }
  }

  /// Get file type (file, directory, link, etc.)
  static Future<FileSystemEntityType> getFileType(String path) async {
    try {
      return await FileSystemEntity.type(path);
    } catch (e) {
      return FileSystemEntityType.notFound;
    }
  }

  /// Read file as string with encoding
  static Future<String?> readFileAsString(String filePath, {Encoding encoding = utf8}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      return await file.readAsString(encoding: encoding);
    } catch (e) {
      _logger.error('Error reading file as string: $e');
      return null;
    }
  }

  /// Write string to file
  static Future<bool> writeStringToFile(String filePath, String content, {Encoding encoding = utf8}) async {
    try {
      final file = File(filePath);
      
      // Create directory if needed
      final directory = Directory(path.dirname(filePath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      await file.writeAsString(content, encoding: encoding);
      _logger.debug('File written successfully: $filePath');
      return true;
    } catch (e) {
      _logger.error('Error writing file: $e');
      return false;
    }
  }
}

/// File validation result
class FileValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final int? fileSize;
  final  FileCategory? category;
  final String? mimeType;

  const FileValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.fileSize,
    this.category,
    this.mimeType,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
}

/// File dates information
class FileDates {
  final DateTime created;
  final DateTime modified;
  final DateTime accessed;

  const FileDates({
    required this.created,
    required this.modified,
    required this.accessed,
  });
}

/// File permissions information
class FilePermissions {
  final bool readable;
  final bool writable;
  final bool executable;
  final int mode;

  const FilePermissions({
    required this.readable,
    required this.writable,
    required this.executable,
    required this.mode,
  });

  bool get isReadOnly => readable && !writable;
}