// lib/features/file_management/data/models/file_model.dart
import '../../domain/entities/file_entity.dart';

class FileModel extends FileEntity {
  const FileModel({
    required super.id,
    required super.name,
    required super.path,
    required super.extension,
    required super.size,
    required super.dateCreated,
    required super.dateModified,
    super.dateAccessed,
    required super.type,
    required super.source,
    required super.mimeType,
    required super.isHidden,
    required super.isReadOnly,
    required super.isDirectory,
    super.thumbnailPath,
    required super.metadata,
    super.parentPath,
    required super.isFavorite,
    required super.accessCount,
    required super.tags,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      extension: json['extension'] as String,
      size: json['size'] as int,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      dateModified: DateTime.parse(json['dateModified'] as String),
      dateAccessed: json['dateAccessed'] != null
          ? DateTime.parse(json['dateAccessed'] as String)
          : null,
      type: FileType.values.firstWhere(
        (e) => e.name == json['type'] as String,
        orElse: () => FileType.unknown,
      ),
      source: FileSource.values.firstWhere(
        (e) => e.name == json['source'] as String,
        orElse: () => FileSource.internal,
      ),
      mimeType: json['mimeType'] as String,
      isHidden: json['isHidden'] as bool,
      isReadOnly: json['isReadOnly'] as bool,
      isDirectory: json['isDirectory'] as bool,
      thumbnailPath: json['thumbnailPath'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      parentPath: json['parentPath'] as String?,
      isFavorite: json['isFavorite'] as bool,
      accessCount: json['accessCount'] as int,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'extension': extension,
      'size': size,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified.toIso8601String(),
      'dateAccessed': dateAccessed?.toIso8601String(),
      'type': type.name,
      'source': source.name,
      'mimeType': mimeType,
      'isHidden': isHidden,
      'isReadOnly': isReadOnly,
      'isDirectory': isDirectory,
      'thumbnailPath': thumbnailPath,
      'metadata': metadata,
      'parentPath': parentPath,
      'isFavorite': isFavorite,
      'accessCount': accessCount,
      'tags': tags,
    };
  }

  factory FileModel.fromEntity(FileEntity entity) {
    return FileModel(
      id: entity.id,
      name: entity.name,
      path: entity.path,
      extension: entity.extension,
      size: entity.size,
      dateCreated: entity.dateCreated,
      dateModified: entity.dateModified,
      dateAccessed: entity.dateAccessed,
      type: entity.type,
      source: entity.source,
      mimeType: entity.mimeType,
      isHidden: entity.isHidden,
      isReadOnly: entity.isReadOnly,
      isDirectory: entity.isDirectory,
      thumbnailPath: entity.thumbnailPath,
      metadata: entity.metadata,
      parentPath: entity.parentPath,
      isFavorite: entity.isFavorite,
      accessCount: entity.accessCount,
      tags: entity.tags,
    );
  }

  @override
  FileModel copyWith({
    String? id,
    String? name,
    String? path,
    String? extension,
    int? size,
    DateTime? dateCreated,
    DateTime? dateModified,
    DateTime? dateAccessed,
    FileType? type,
    FileSource? source,
    String? mimeType,
    bool? isHidden,
    bool? isReadOnly,
    bool? isDirectory,
    String? thumbnailPath,
    Map<String, dynamic>? metadata,
    String? parentPath,
    bool? isFavorite,
    int? accessCount,
    List<String>? tags,
  }) {
    return FileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      extension: extension ?? this.extension,
      size: size ?? this.size,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      dateAccessed: dateAccessed ?? this.dateAccessed,
      type: type ?? this.type,
      source: source ?? this.source,
      mimeType: mimeType ?? this.mimeType,
      isHidden: isHidden ?? this.isHidden,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      isDirectory: isDirectory ?? this.isDirectory,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      metadata: metadata ?? this.metadata,
      parentPath: parentPath ?? this.parentPath,
      isFavorite: isFavorite ?? this.isFavorite,
      accessCount: accessCount ?? this.accessCount,
      tags: tags ?? this.tags,
    );
  }
}
