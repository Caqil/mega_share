import 'dart:io';
import '../../domain/entities/file_entity.dart';
import '../../domain/entities/folder_entity.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../shared/models/base_model.dart';

/// Folder data model
class FolderModel extends BaseModel {
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

  const FolderModel({
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

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'])
          : DateTime.now(),
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'])
          : DateTime.now(),
      isHidden: json['isHidden'] ?? false,
      isReadOnly: json['isReadOnly'] ?? false,
      parentPath: json['parentPath'],
      fileCount: json['fileCount'] ?? 0,
      folderCount: json['folderCount'] ?? 0,
      totalSize: json['totalSize'] ?? 0,
      metadata: json['metadata']?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'dateModified': dateModified.toIso8601String(),
      'dateCreated': dateCreated.toIso8601String(),
      'isHidden': isHidden,
      'isReadOnly': isReadOnly,
      'parentPath': parentPath,
      'fileCount': fileCount,
      'folderCount': folderCount,
      'totalSize': totalSize,
      'metadata': metadata,
    };
  }

  /// Create from Directory system entity
  factory FolderModel.fromDirectory(
    Directory directory, {
    Map<String, dynamic>? additionalMetadata,
  }) {
    final dirPath = directory.path;
    final dirName = FileUtils.getFileName(dirPath);

    return FolderModel(
      id: dirPath.hashCode.toString(),
      name: dirName,
      path: dirPath,
      dateModified: DateTime.now(), // Will be populated later
      dateCreated: DateTime.now(), // Will be populated later
      isHidden: dirName.startsWith('.'),
      isReadOnly: false, // Will be populated later
      parentPath: FileUtils.getParentDirectory(dirPath),
      fileCount: 0, // Will be populated later
      folderCount: 0, // Will be populated later
      totalSize: 0, // Will be populated later
      metadata: additionalMetadata ?? {},
    );
  }

  /// Create from directory with stat information
  factory FolderModel.fromDirectoryWithStat(
    Directory directory,
    FileStat stat, {
    int fileCount = 0,
    int folderCount = 0,
    int totalSize = 0,
    Map<String, dynamic>? additionalMetadata,
  }) {
    final dirPath = directory.path;
    final dirName = FileUtils.getFileName(dirPath);

    return FolderModel(
      id: dirPath.hashCode.toString(),
      name: dirName,
      path: dirPath,
      dateModified: stat.modified,
      dateCreated: stat.accessed, // Using accessed as created
      isHidden: dirName.startsWith('.'),
      isReadOnly: (stat.mode & 0x80) == 0,
      parentPath: FileUtils.getParentDirectory(dirPath),
      fileCount: fileCount,
      folderCount: folderCount,
      totalSize: totalSize,
      metadata: {
        'mode': stat.mode,
        'accessed': stat.accessed.toIso8601String(),
        ...?additionalMetadata,
      },
    );
  }

  /// Convert to domain entity
  FolderEntity toEntity() {
    return FolderEntity(
      id: id,
      name: name,
      path: path,
      dateModified: dateModified,
      dateCreated: dateCreated,
      isHidden: isHidden,
      isReadOnly: isReadOnly,
      parentPath: parentPath,
      fileCount: fileCount,
      folderCount: folderCount,
      totalSize: totalSize,
      metadata: metadata,
    );
  }

  /// Create from domain entity
  factory FolderModel.fromEntity(FolderEntity entity) {
    return FolderModel(
      id: entity.id,
      name: entity.name,
      path: entity.path,
      dateModified: entity.dateModified,
      dateCreated: entity.dateCreated,
      isHidden: entity.isHidden,
      isReadOnly: entity.isReadOnly,
      parentPath: entity.parentPath,
      fileCount: entity.fileCount,
      folderCount: entity.folderCount,
      totalSize: entity.totalSize,
      metadata: entity.metadata,
    );
  }

  /// Check if folder is empty
  bool get isEmpty => fileCount == 0 && folderCount == 0;

  /// Get total items count
  int get totalItems => fileCount + folderCount;

  /// Get formatted total size
  String get formattedTotalSize {
    return totalSize > 0 ? FileUtils.formatFileSize(totalSize) : '';
  }

  /// Check if folder is recent (modified within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(dateModified);
    return difference.inHours <= 24;
  }

  /// Copy with modifications
  FolderModel copyWith({
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
    return FolderModel(
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
