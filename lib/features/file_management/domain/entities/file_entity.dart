// lib/features/file_management/domain/entities/file_entity.dart
import 'package:equatable/equatable.dart';

enum FileType {
  image,
  video,
  audio,
  document,
  archive,
  application,
  text,
  unknown,
}

enum FileSource {
  internal,
  external,
  downloads,
  dcim,
  documents,
  music,
  pictures,
  videos,
  custom,
}

class FileEntity extends Equatable {
  final String id;
  final String name;
  final String path;
  final String extension;
  final int size;
  final DateTime dateCreated;
  final DateTime dateModified;
  final DateTime? dateAccessed;
  final FileType type;
  final FileSource source;
  final String mimeType;
  final bool isHidden;
  final bool isReadOnly;
  final bool isDirectory;
  final String? thumbnailPath;
  final Map<String, dynamic> metadata;
  final String? parentPath;
  final bool isFavorite;
  final int accessCount;
  final List<String> tags;

  const FileEntity({
    required this.id,
    required this.name,
    required this.path,
    required this.extension,
    required this.size,
    required this.dateCreated,
    required this.dateModified,
    this.dateAccessed,
    required this.type,
    required this.source,
    required this.mimeType,
    required this.isHidden,
    required this.isReadOnly,
    required this.isDirectory,
    this.thumbnailPath,
    required this.metadata,
    this.parentPath,
    required this.isFavorite,
    required this.accessCount,
    required this.tags,
  });

  String get displayName => name;
  String get sizeFormatted => _formatBytes(size);
  bool get isImage => type == FileType.image;
  bool get isVideo => type == FileType.video;
  bool get isAudio => type == FileType.audio;
  bool get isDocument => type == FileType.document;
  bool get canPreview => isImage || isVideo || isAudio || type == FileType.text;
  
  Duration? get duration {
    if (type == FileType.video || type == FileType.audio) {
      final durationMs = metadata['duration_ms'] as int?;
      return durationMs != null ? Duration(milliseconds: durationMs) : null;
    }
    return null;
  }

  String? get resolution {
    if (type == FileType.image || type == FileType.video) {
      final width = metadata['width'] as int?;
      final height = metadata['height'] as int?;
      if (width != null && height != null) {
        return '${width}x$height';
      }
    }
    return null;
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  FileEntity copyWith({
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
    return FileEntity(
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

  @override
  List<Object?> get props => [
        id,
        name,
        path,
        extension,
        size,
        dateCreated,
        dateModified,
        dateAccessed,
        type,
        source,
        mimeType,
        isHidden,
        isReadOnly,
        isDirectory,
        thumbnailPath,
        metadata,
        parentPath,
        isFavorite,
        accessCount,
        tags,
      ];
}
