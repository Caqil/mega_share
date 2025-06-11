import '../../domain/entities/file_entity.dart';
import '../../domain/entities/folder_entity.dart';

class FolderModel extends FolderEntity {
  const FolderModel({
    required super.id,
    required super.name,
    required super.path,
    required super.dateCreated,
    required super.dateModified,
    super.dateAccessed,
    required super.source,
    required super.isHidden,
    required super.isReadOnly,
    super.parentPath,
    required super.fileCount,
    required super.folderCount,
    required super.totalSize,
    required super.isFavorite,
    required super.tags,
    required super.metadata,
    required super.hasSubfolders,
    super.isExpanded,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      dateModified: DateTime.parse(json['dateModified'] as String),
      dateAccessed: json['dateAccessed'] != null
          ? DateTime.parse(json['dateAccessed'] as String)
          : null,
      source: FileSource.values.firstWhere(
        (e) => e.name == json['source'] as String,
        orElse: () => FileSource.internal,
      ),
      isHidden: json['isHidden'] as bool,
      isReadOnly: json['isReadOnly'] as bool,
      parentPath: json['parentPath'] as String?,
      fileCount: json['fileCount'] as int,
      folderCount: json['folderCount'] as int,
      totalSize: json['totalSize'] as int,
      isFavorite: json['isFavorite'] as bool,
      tags: List<String>.from(json['tags'] as List),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      hasSubfolders: json['hasSubfolders'] as bool,
      isExpanded: json['isExpanded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified.toIso8601String(),
      'dateAccessed': dateAccessed?.toIso8601String(),
      'source': source.name,
      'isHidden': isHidden,
      'isReadOnly': isReadOnly,
      'parentPath': parentPath,
      'fileCount': fileCount,
      'folderCount': folderCount,
      'totalSize': totalSize,
      'isFavorite': isFavorite,
      'tags': tags,
      'metadata': metadata,
      'hasSubfolders': hasSubfolders,
      'isExpanded': isExpanded,
    };
  }

  factory FolderModel.fromEntity(FolderEntity entity) {
    return FolderModel(
      id: entity.id,
      name: entity.name,
      path: entity.path,
      dateCreated: entity.dateCreated,
      dateModified: entity.dateModified,
      dateAccessed: entity.dateAccessed,
      source: entity.source,
      isHidden: entity.isHidden,
      isReadOnly: entity.isReadOnly,
      parentPath: entity.parentPath,
      fileCount: entity.fileCount,
      folderCount: entity.folderCount,
      totalSize: entity.totalSize,
      isFavorite: entity.isFavorite,
      tags: entity.tags,
      metadata: entity.metadata,
      hasSubfolders: entity.hasSubfolders,
      isExpanded: entity.isExpanded,
    );
  }

  @override
  FolderModel copyWith({
    String? id,
    String? name,
    String? path,
    DateTime? dateCreated,
    DateTime? dateModified,
    DateTime? dateAccessed,
    FileSource? source,
    bool? isHidden,
    bool? isReadOnly,
    String? parentPath,
    int? fileCount,
    int? folderCount,
    int? totalSize,
    bool? isFavorite,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    bool? hasSubfolders,
    bool? isExpanded,
  }) {
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      dateAccessed: dateAccessed ?? this.dateAccessed,
      source: source ?? this.source,
      isHidden: isHidden ?? this.isHidden,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      parentPath: parentPath ?? this.parentPath,
      fileCount: fileCount ?? this.fileCount,
      folderCount: folderCount ?? this.folderCount,
      totalSize: totalSize ?? this.totalSize,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      hasSubfolders: hasSubfolders ?? this.hasSubfolders,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
