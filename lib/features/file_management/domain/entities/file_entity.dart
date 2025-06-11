// lib/features/file_management/domain/entities/file_entity.dart
import '../../../../core/constants/file_constants.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../shared/models/base_model.dart';
import 'package:mega_share/core/utils/file_utils.dart';
/// File domain entity
class FileEntity extends BaseEntity with IdentifiableMixin, TimestampMixin {
  @override
  final String id;
  final String name;
  final String path;
  final String extension;
  final int size;
  final DateTime dateModified;
  final DateTime dateCreated;
  final String mimeType;
  final bool isHidden;
  final bool isReadOnly;
  final String? parentPath;
  final Map<String, dynamic> metadata;

  const FileEntity({
    required this.id,
    required this.name,
    required this.path,
    required this.extension,
    required this.size,
    required this.dateModified,
    required this.dateCreated,
    required this.mimeType,
    required this.isHidden,
    required this.isReadOnly,
    this.parentPath,
    required this.metadata,
  });

  @override
  DateTime get createdAt => dateCreated;

  @override
  DateTime get updatedAt => dateModified;

  /// Get file category based on extension
  FileCategory get category {
    return FileUtils.getFileCategory(path);
  }

  /// Get formatted file size
  String get formattedSize {
    return SizeUtils.formatBytes(size);
  }

  /// Get formatted file size (compact)
  String get formattedSizeCompact {
    return SizeUtils.formatBytesCompact(size);
  }

  /// Get file size category
  FileSizeCategory get sizeCategory {
    return SizeUtils.getFileSizeCategory(size);
  }

  /// Check if file is empty
  bool get isEmpty => size == 0;

  /// Check if file is large (> 100MB)
  bool get isLarge => size > 100 * 1024 * 1024;

  /// Check if file is huge (> 1GB)
  bool get isHuge => size > 1024 * 1024 * 1024;

  /// Check if file is recent (modified within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(dateModified);
    return difference.inHours <= 24;
  }

  /// Check if file is old (modified more than 30 days ago)
  bool get isOld {
    final now = DateTime.now();
    final difference = now.difference(dateModified);
    return difference.inDays > 30;
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

  /// Check if file is app package
  bool get isApp {
    return extension == '.apk' || extension == '.ipa';
  }

  /// Check if file can be shared
  bool get canBeShared {
    return FileConstants.prohibitedExtensions.contains(extension) &&
        size <= FileConstants.maxFileSizeBytes;
  }

  /// Check if file supports thumbnails
  bool get supportsThumbnails {
    return isImage || isVideo;
  }

  /// Check if file can be previewed
  bool get canBePreviewed {
    return isImage || isDocument || (isVideo && size < 50 * 1024 * 1024);
  }

  /// Get file icon name for UI
  String get iconName {
    switch (category) {
      case FileCategory.image:
        return 'image';
      case FileCategory.video:
        return 'video_file';
      case FileCategory.audio:
        return 'audio_file';
      case FileCategory.document:
        return 'description';
      case FileCategory.archive:
        return 'archive';
      case FileCategory.code:
        return 'code';
      case FileCategory.app:
        return 'android';
      case FileCategory.other:
        return 'insert_drive_file';
    }
  }

  /// Get relative time since modification
  String get relativeModificationTime {
    final now = DateTime.now();
    final difference = now.difference(dateModified);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7}w ago';
    if (difference.inDays < 365) return '${difference.inDays ~/ 30}mo ago';
    return '${difference.inDays ~/ 365}y ago';
  }

  /// Get file name without extension
  String get nameWithoutExtension {
    return FileUtils.getFileNameWithoutExtension(path);
  }

  /// Get parent directory name
  String? get parentDirectoryName {
    return parentPath != null ? FileUtils.getFileName(parentPath!) : null;
  }

  /// Check if file matches search query
  bool matchesSearchQuery(String query) {
    final lowercaseQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowercaseQuery) ||
        nameWithoutExtension.toLowerCase().contains(lowercaseQuery) ||
        extension.toLowerCase().contains(lowercaseQuery);
  }

  /// Get file properties for display
  Map<String, String> get properties {
    return {
      'Name': name,
      'Size': formattedSize,
      'Type': mimeType,
      'Modified': relativeModificationTime,
      'Path': path,
      if (parentPath != null) 'Location': parentPath!,
      'Extension': extension.isNotEmpty ? extension : 'None',
      'Category': category.name,
      if (isReadOnly) 'Access': 'Read-only',
      if (isHidden) 'Hidden': 'Yes',
    };
  }

  /// Create copy with updated values
  FileEntity copyWith({
    String? id,
    String? name,
    String? path,
    String? extension,
    int? size,
    DateTime? dateModified,
    DateTime? dateCreated,
    String? mimeType,
    bool? isHidden,
    bool? isReadOnly,
    String? parentPath,
    Map<String, dynamic>? metadata,
  }) {
    return FileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      extension: extension ?? this.extension,
      size: size ?? this.size,
      dateModified: dateModified ?? this.dateModified,
      dateCreated: dateCreated ?? this.dateCreated,
      mimeType: mimeType ?? this.mimeType,
      isHidden: isHidden ?? this.isHidden,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      parentPath: parentPath ?? this.parentPath,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    path,
    extension,
    size,
    dateModified,
    dateCreated,
    mimeType,
    isHidden,
    isReadOnly,
    parentPath,
    metadata,
  ];
}
