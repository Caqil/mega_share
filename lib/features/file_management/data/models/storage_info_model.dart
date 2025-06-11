import '../../domain/entities/storage_info_entity.dart';
import '../../domain/entities/file_entity.dart';
import 'file_model.dart';

class StorageVolumeModel extends StorageVolumeEntity {
  const StorageVolumeModel({
    required super.id,
    required super.name,
    required super.path,
    required super.type,
    required super.totalSpace,
    required super.freeSpace,
    required super.usedSpace,
    required super.isRemovable,
    required super.isEmulated,
    required super.isPrimary,
    required super.isWritable,
    required super.isAvailable,
    required super.metadata,
  });

  factory StorageVolumeModel.fromJson(Map<String, dynamic> json) {
    return StorageVolumeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: StorageType.values.firstWhere(
        (e) => e.name == json['type'] as String,
        orElse: () => StorageType.internal,
      ),
      totalSpace: json['totalSpace'] as int,
      freeSpace: json['freeSpace'] as int,
      usedSpace: json['usedSpace'] as int,
      isRemovable: json['isRemovable'] as bool,
      isEmulated: json['isEmulated'] as bool,
      isPrimary: json['isPrimary'] as bool,
      isWritable: json['isWritable'] as bool,
      isAvailable: json['isAvailable'] as bool,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type.name,
      'totalSpace': totalSpace,
      'freeSpace': freeSpace,
      'usedSpace': usedSpace,
      'isRemovable': isRemovable,
      'isEmulated': isEmulated,
      'isPrimary': isPrimary,
      'isWritable': isWritable,
      'isAvailable': isAvailable,
      'metadata': metadata,
    };
  }

  factory StorageVolumeModel.fromEntity(StorageVolumeEntity entity) {
    return StorageVolumeModel(
      id: entity.id,
      name: entity.name,
      path: entity.path,
      type: entity.type,
      totalSpace: entity.totalSpace,
      freeSpace: entity.freeSpace,
      usedSpace: entity.usedSpace,
      isRemovable: entity.isRemovable,
      isEmulated: entity.isEmulated,
      isPrimary: entity.isPrimary,
      isWritable: entity.isWritable,
      isAvailable: entity.isAvailable,
      metadata: entity.metadata,
    );
  }
}

class StorageInfoModel extends StorageInfoEntity {
  const StorageInfoModel({
    required super.volumes,
    required super.primaryStorage,
    required super.totalSpace,
    required super.totalFreeSpace,
    required super.totalUsedSpace,
    required super.fileTypeDistribution,
    required super.largestFolders,
    required super.recentFiles,
    required super.largeFiles,
    required super.lastUpdated,
  });

  factory StorageInfoModel.fromJson(Map<String, dynamic> json) {
    return StorageInfoModel(
      volumes: (json['volumes'] as List)
          .map((e) => StorageVolumeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryStorage: StorageVolumeModel.fromJson(
        json['primaryStorage'] as Map<String, dynamic>,
      ),
      totalSpace: json['totalSpace'] as int,
      totalFreeSpace: json['totalFreeSpace'] as int,
      totalUsedSpace: json['totalUsedSpace'] as int,
      fileTypeDistribution: Map<FileType, int>.fromEntries(
        (json['fileTypeDistribution'] as Map<String, dynamic>).entries.map(
          (e) => MapEntry(
            FileType.values.firstWhere(
              (type) => type.name == e.key,
              orElse: () => FileType.unknown,
            ),
            e.value as int,
          ),
        ),
      ),
      largestFolders: Map<String, int>.from(
        json['largestFolders'] as Map<String, dynamic>,
      ),
      recentFiles: (json['recentFiles'] as List)
          .map((e) => FileModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      largeFiles: (json['largeFiles'] as List)
          .map((e) => FileModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'volumes': volumes
          .map((e) => StorageVolumeModel.fromEntity(e).toJson())
          .toList(),
      'primaryStorage': StorageVolumeModel.fromEntity(primaryStorage).toJson(),
      'totalSpace': totalSpace,
      'totalFreeSpace': totalFreeSpace,
      'totalUsedSpace': totalUsedSpace,
      'fileTypeDistribution': Map<String, int>.fromEntries(
        fileTypeDistribution.entries.map((e) => MapEntry(e.key.name, e.value)),
      ),
      'largestFolders': largestFolders,
      'recentFiles': recentFiles
          .map((e) => FileModel.fromEntity(e).toJson())
          .toList(),
      'largeFiles': largeFiles
          .map((e) => FileModel.fromEntity(e).toJson())
          .toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory StorageInfoModel.fromEntity(StorageInfoEntity entity) {
    return StorageInfoModel(
      volumes: entity.volumes,
      primaryStorage: entity.primaryStorage,
      totalSpace: entity.totalSpace,
      totalFreeSpace: entity.totalFreeSpace,
      totalUsedSpace: entity.totalUsedSpace,
      fileTypeDistribution: entity.fileTypeDistribution,
      largestFolders: entity.largestFolders,
      recentFiles: entity.recentFiles,
      largeFiles: entity.largeFiles,
      lastUpdated: entity.lastUpdated,
    );
  }

  @override
  StorageInfoModel copyWith({
    List<StorageVolumeEntity>? volumes,
    StorageVolumeEntity? primaryStorage,
    int? totalSpace,
    int? totalFreeSpace,
    int? totalUsedSpace,
    Map<FileType, int>? fileTypeDistribution,
    Map<String, int>? largestFolders,
    List<FileEntity>? recentFiles,
    List<FileEntity>? largeFiles,
    DateTime? lastUpdated,
  }) {
    return StorageInfoModel(
      volumes: volumes ?? this.volumes,
      primaryStorage: primaryStorage ?? this.primaryStorage,
      totalSpace: totalSpace ?? this.totalSpace,
      totalFreeSpace: totalFreeSpace ?? this.totalFreeSpace,
      totalUsedSpace: totalUsedSpace ?? this.totalUsedSpace,
      fileTypeDistribution: fileTypeDistribution ?? this.fileTypeDistribution,
      largestFolders: largestFolders ?? this.largestFolders,
      recentFiles: recentFiles ?? this.recentFiles,
      largeFiles: largeFiles ?? this.largeFiles,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
