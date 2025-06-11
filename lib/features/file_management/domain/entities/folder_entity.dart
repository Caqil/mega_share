import '../../../../core/constants/file_constants.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../shared/models/base_model.dart';

/// Folder domain entity
class FolderEntity extends BaseEntity with IdentifiableMixin, TimestampMixin {
  @override
  final String id;
  final String name;
  final String path;
  final DateTime dateModified;
  final DateTime dateCreated;
  final bool isHidden;
  final bool isReadOnly;
  final String? parentPath;
  final int fileCount;
  final int folderCount;
  final int totalSize;
  final Map<String, dynamic> metadata;

  const FolderEntity({
    required this.id,
    required this.name,
    required this.path,
    required this.dateModified,
    required this.dateCreated,
    required this.isHidden,
    required this.isReadOnly,
    this.parentPath,
    required this.fileCount,
    required this.folderCount,
    required this.totalSize,
    required this.metadata,
  });

  @override
  DateTime get createdAt => dateCreated;

  @override
  DateTime get updatedAt => dateModified;

  /// Check if folder is empty
  bool get isEmpty => fileCount == 0 && folderCount == 0;

  /// Get total items count
  int get totalItems => fileCount + folderCount;

  /// Get formatted total size
  String get formattedTotalSize {
    return totalSize > 0 ? SizeUtils.formatBytes(totalSize) : '';
  }

  /// Get formatted total size (compact)
  String get formattedTotalSizeCompact {
    return totalSize > 0 ? SizeUtils.formatBytesCompact(totalSize) : '';
  }

  /// Check if folder is recent (modified within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(dateModified);
    return difference.inHours <= 24;
  }

  /// Check if folder is old (modified more than 30 days ago)
  bool get isOld {
    final now = DateTime.now();
    final difference = now.difference(dateModified);
    return difference.inDays > 30;
  }

  /// Check if folder is large (contains more than 1000 items)
  bool get isLarge => totalItems > 1000;

  /// Check if folder has significant size (> 100MB)
  bool get hasSignificantSize => totalSize > 100 * 1024 * 1024;

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

  /// Get parent directory name
  String? get parentDirectoryName {
    return parentPath != null ? FileUtils.getFileName(parentPath!) : null;
  }

  /// Get folder summary text
  String get summaryText {
    if (isEmpty) return 'Empty folder';

    final parts = <String>[];
    if (fileCount > 0) {
      parts.add('$fileCount file${fileCount == 1 ? '' : 's'}');
    }
    if (folderCount > 0) {
      parts.add('$folderCount folder${folderCount == 1 ? '' : 's'}');
    }

    String summary = parts.join(', ');
    if (totalSize > 0) {
      summary += ' • ${formattedTotalSizeCompact}';
    }

    return summary;
  }

  /// Check if folder matches search query
  bool matchesSearchQuery(String query) {
    final lowercaseQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowercaseQuery);
  }

  /// Get folder properties for display
  Map<String, String> get properties {
    return {
      'Name': name,
      'Items': '$totalItems (${fileCount} files, ${folderCount} folders)',
      if (totalSize > 0) 'Size': formattedTotalSize,
      'Modified': relativeModificationTime,
      'Path': path,
      if (parentPath != null) 'Location': parentPath!,
      if (isReadOnly) 'Access': 'Read-only',
      if (isHidden) 'Hidden': 'Yes',
    };
  }

  /// Get folder icon name based on content and properties
  String get iconName {
    if (isEmpty) return 'folder_open';
    if (isHidden) return 'folder_special';
    if (hasSignificantSize) return 'folder_zip';
    return 'folder';
  }

  /// Check if folder can be shared (not too large, not system folder)
  bool get canBeShared {
    return !isReadOnly &&
        totalSize <= FileConstants.maxFileSizeBytes &&
        !_isSystemFolder();
  }

  /// Create copy with updated values
  FolderEntity copyWith({
    String? id,
    String? name,
    String? path,
    DateTime? dateModified,
    DateTime? dateCreated,
    bool? isHidden,
    bool? isReadOnly,
    String? parentPath,
    int? fileCount,
    int? folderCount,
    int? totalSize,
    Map<String, dynamic>? metadata,
  }) {
    return FolderEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      dateModified: dateModified ?? this.dateModified,
      dateCreated: dateCreated ?? this.dateCreated,
      isHidden: isHidden ?? this.isHidden,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      parentPath: parentPath ?? this.parentPath,
      fileCount: fileCount ?? this.fileCount,
      folderCount: folderCount ?? this.folderCount,
      totalSize: totalSize ?? this.totalSize,
      metadata: metadata ?? this.metadata,
    );
  }

  bool _isSystemFolder() {
    final lowercasePath = path.toLowerCase();
    final systemFolders = [
      '/system',
      '/proc',
      '/dev',
      '/sys',
      '/root',
      '/boot',
      'android_secure',
      '.android_secure',
    ];

    return systemFolders.any((folder) => lowercasePath.contains(folder));
  }

  @override
  List<Object?> get props => [
    id,
    name,
    path,
    dateModified,
    dateCreated,
    isHidden,
    isReadOnly,
    parentPath,
    fileCount,
    folderCount,
    totalSize,
    metadata,
  ];
}
