import 'dart:io';
import 'dart:typed_data';
import '../constants/file_constants.dart';
import '../utils/file_utils.dart';
import '../utils/size_utils.dart';

/// Extension methods for File class
extension FileExtensions on File {
  /// Get file size in human readable format
  Future<String> get readableSize async {
    try {
      final size = await length();
      return SizeUtils.formatBytes(size);
    } catch (e) {
      return '0 B';
    }
  }

  /// Get file extension
  String get extension {
    return FileUtils.getFileExtension(path);
  }

  /// Get file name without extension
  String get nameWithoutExtension {
    return FileUtils.getFileNameWithoutExtension(path);
  }

  /// Get file name with extension
  String get fileName {
    return FileUtils.getFileName(path);
  }

  /// Get MIME type
  String get mimeType {
    return FileUtils.getMimeType(path);
  }

  /// Get file category
  FileConstants.FileCategory get category {
    return FileUtils.getFileCategory(path);
  }

  /// Check if file is image
  bool get isImage {
    return FileConstants.imageExtensions.contains(extension);
  }

  /// Check if file is video
  bool get isVideo {
    return FileConstants.videoExtensions.contains(extension);
  }

  /// Check if file is audio
  bool get isAudio {
    return FileConstants.audioExtensions.contains(extension);
  }

  /// Check if file is document
  bool get isDocument {
    return FileConstants.documentExtensions.contains(extension);
  }

  /// Check if file is archive
  bool get isArchive {
    return FileConstants.archiveExtensions.contains(extension);
  }

  /// Check if file is code
  bool get isCode {
    return FileConstants.codeExtensions.contains(extension);
  }

  /// Check if file size exceeds limit
  Future<bool> exceedsSize(int maxBytes) async {
    try {
      final size = await length();
      return size > maxBytes;
    } catch (e) {
      return false;
    }
  }

  /// Get file size category
  Future<SizeUtils.FileSizeCategory> get sizeCategory async {
    try {
      final size = await length();
      return SizeUtils.getFileSizeCategory(size);
    } catch (e) {
      return SizeUtils.FileSizeCategory.tiny;
    }
  }

  /// Calculate MD5 hash
  Future<String?> get md5Hash async {
    return await FileUtils.calculateFileHash(path);
  }

  /// Check if file is empty
  Future<bool> get isEmpty async {
    try {
      final size = await length();
      return size == 0;
    } catch (e) {
      return true;
    }
  }

  /// Check if file is readable
  Future<bool> get isReadable async {
    try {
      await openRead().first;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file age
  Future<Duration> get age async {
    try {
      final stat = await this.stat();
      return DateTime.now().difference(stat.modified);
    } catch (e) {
      return Duration.zero;
    }
  }

  /// Copy file with progress callback
  Future<File> copyWithProgress(
    String destinationPath, {
    Function(int, int)? onProgress,
  }) async {
    final source = openRead();
    final destination = File(destinationPath).openWrite();

    int totalBytes = 0;
    int copiedBytes = 0;

    try {
      totalBytes = await length();
    } catch (e) {
      totalBytes = 0;
    }

    await for (final chunk in source) {
      destination.add(chunk);
      copiedBytes += chunk.length;
      onProgress?.call(copiedBytes, totalBytes);
    }

    await destination.close();
    return File(destinationPath);
  }

  /// Read file as chunks for streaming
  Stream<Uint8List> readAsChunks({int chunkSize = 64 * 1024}) {
    return openRead().map((chunk) => Uint8List.fromList(chunk));
  }

  /// Get optimal chunk size for this file
  Future<int> get optimalChunkSize async {
    try {
      final size = await length();
      return SizeUtils.getOptimalChunkSize(size);
    } catch (e) {
      return 64 * 1024; // Default 64KB
    }
  }

  /// Check if file is safe to transfer
  Future<bool> get isSafeToTransfer async {
    final validation = await FileUtils.validateFile(path);
    return validation.isValid;
  }

  /// Get file info summary
  Future<FileInfo> get info async {
    try {
      final stat = await this.stat();
      final size = stat.size;

      return FileInfo(
        name: fileName,
        path: path,
        size: size,
        sizeFormatted: SizeUtils.formatBytes(size),
        extension: extension,
        mimeType: mimeType,
        category: category,
        modified: stat.modified,
        isReadOnly: stat.mode & 0x80 == 0, // Check read-only bit
      );
    } catch (e) {
      return FileInfo(
        name: fileName,
        path: path,
        size: 0,
        sizeFormatted: '0 B',
        extension: extension,
        mimeType: mimeType,
        category: category,
        modified: DateTime.now(),
        isReadOnly: false,
      );
    }
  }

  /// Create backup copy
  Future<File?> createBackup({String suffix = '.bak'}) async {
    try {
      final backupPath = '$path$suffix';
      return await copy(backupPath);
    } catch (e) {
      return null;
    }
  }

  /// Move to trash/delete safely
  Future<bool> moveToTrash() async {
    try {
      // In a real app, you might move to a trash folder first
      await delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// File information data class
class FileInfo {
  final String name;
  final String path;
  final int size;
  final String sizeFormatted;
  final String extension;
  final String mimeType;
  final FileConstants.FileCategory category;
  final DateTime modified;
  final bool isReadOnly;

  const FileInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.sizeFormatted,
    required this.extension,
    required this.mimeType,
    required this.category,
    required this.modified,
    required this.isReadOnly,
  });

  @override
  String toString() {
    return 'FileInfo(name: $name, size: $sizeFormatted, category: $category)';
  }
}
