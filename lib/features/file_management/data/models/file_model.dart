
import 'dart:io';
import '../../domain/entities/file_entity.dart';
import '../../../../core/constants/file_constants.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../shared/models/base_model.dart';

/// File data model
class FileModel extends BaseModel {
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
  
  const FileModel({
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
  
  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      extension: json['extension'] ?? '',
      size: json['size'] ?? 0,
      dateModified: json['dateModified'] != null 
          ? DateTime.parse(json['dateModified'])
          : DateTime.now(),
      dateCreated: json['dateCreated'] != null 
          ? DateTime.parse(json['dateCreated'])
          : DateTime.now(),
      mimeType: json['mimeType'] ?? 'application/octet-stream',
      isHidden: json['isHidden'] ?? false,
      isReadOnly: json['isReadOnly'] ?? false,
      parentPath: json['parentPath'],
      metadata: json['metadata']?.cast<String, dynamic>() ?? {},
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'extension': extension,
      'size': size,
      'dateModified': dateModified.toIso8601String(),
      'dateCreated': dateCreated.toIso8601String(),
      'mimeType': mimeType,
      'isHidden': isHidden,
      'isReadOnly': isReadOnly,
      'parentPath': parentPath,
      'metadata': metadata,
    };
  }
  
  /// Create from File system entity
  factory FileModel.fromFile(File file, {Map<String, dynamic>? additionalMetadata}) {
    final filePath = file.path;
    final fileName = FileUtils.getFileName(filePath);
    final extension = FileUtils.getFileExtension(filePath);
    final mimeType = FileUtils.getMimeType(filePath);
    
    return FileModel(
      id: filePath.hashCode.toString(),
      name: fileName,
      path: filePath,
      extension: extension,
      size: 0, // Will be populated later
      dateModified: DateTime.now(), // Will be populated later
      dateCreated: DateTime.now(), // Will be populated later
      mimeType: mimeType,
      isHidden: fileName.startsWith('.'),
      isReadOnly: false, // Will be populated later
      parentPath: FileUtils.getParentDirectory(filePath),
      metadata: additionalMetadata ?? {},
    );
  }
  
  /// Create from file with stat information
  factory FileModel.fromFileWithStat(File file, FileStat stat, {Map<String, dynamic>? additionalMetadata}) {
    final filePath = file.path;
    final fileName = FileUtils.getFileName(filePath);
    final extension = FileUtils.getFileExtension(filePath);
    final mimeType = FileUtils.getMimeType(filePath);
    
    return FileModel(
      id: filePath.hashCode.toString(),
      name: fileName,
      path: filePath,
      extension: extension,
      size: stat.size,
      dateModified: stat.modified,
      dateCreated: stat.accessed, // Using accessed as created (Unix limitation)
      mimeType: mimeType,
      isHidden: fileName.startsWith('.'),
      isReadOnly: (stat.mode & 0x80) == 0,
      parentPath: FileUtils.getParentDirectory(filePath),
      metadata: {
        'mode': stat.mode,
        'accessed': stat.accessed.toIso8601String(),
        ...?additionalMetadata,
      },
    );
  }
  
  /// Convert to domain entity
  FileEntity toEntity() {
    return FileEntity(
      id: id,
      name: name,
      path: path,
      extension: extension,
      size: size,
      dateModified: dateModified,
      dateCreated: dateCreated,
      mimeType: mimeType,
      isHidden: isHidden,
      isReadOnly: isReadOnly,
      parentPath: parentPath,
      metadata: metadata,
    );
  }
  
  /// Create from domain entity
  factory FileModel.fromEntity(FileEntity entity) {
    return FileModel(
      id: entity.id,
      name: entity.name,
      path: entity.path,
      extension: entity.extension,
      size: entity.size,
      dateModified: entity.dateModified,
      dateCreated: entity.dateCreated,
      mimeType: entity.mimeType,
      isHidden: entity.isHidden,
      isReadOnly: entity.isReadOnly,
      parentPath: entity.parentPath,
      metadata: entity.metadata,
    );
  }
  
  /// Get file category
  FileCategory get category {
    return FileUtils.getFileCategory(path);
  }
  
  /// Get formatted file size
  String get formattedSize {
    return SizeUtils.formatBytes(size);
  }
  
  /// Check if file is recent (modified within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(dateModified);
    return difference.inHours <= 24;
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
  
  /// Copy with modifications
  FileModel copyWith({
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
    return FileModel(
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
