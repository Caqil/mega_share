import 'package:equatable/equatable.dart';

import 'file_entity.dart';

class FolderEntity extends Equatable {
  final String id;
  final String name;
  final String path;
  final DateTime dateCreated;
  final DateTime dateModified;
  final DateTime? dateAccessed;
  final FileSource source;
  final bool isHidden;
  final bool isReadOnly;
  final String? parentPath;
  final int fileCount;
  final int folderCount;
  final int totalSize;
  final bool isFavorite;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final bool hasSubfolders;
  final bool isExpanded;

  const FolderEntity({
    required this.id,
    required this.name,
    required this.path,
    required this.dateCreated,
    required this.dateModified,
    this.dateAccessed,
    required this.source,
    required this.isHidden,
    required this.isReadOnly,
    this.parentPath,
    required this.fileCount,
    required this.folderCount,
    required this.totalSize,
    required this.isFavorite,
    required this.tags,
    required this.metadata,
    required this.hasSubfolders,
    this.isExpanded = false,
  });

  String get displayName => name;
  String get sizeFormatted => _formatBytes(totalSize);
  int get totalItems => fileCount + folderCount;
  bool get isEmpty => totalItems == 0;
  bool get isRoot => parentPath == null;

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

  FolderEntity copyWith({
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
    return FolderEntity(
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

  @override
  List<Object?> get props => [
    id,
    name,
    path,
    dateCreated,
    dateModified,
    dateAccessed,
    source,
    isHidden,
    isReadOnly,
    parentPath,
    fileCount,
    folderCount,
    totalSize,
    isFavorite,
    tags,
    metadata,
    hasSubfolders,
    isExpanded,
  ];
}
