import 'package:mega_share/core/utils/file_utils.dart';

import '../../domain/entities/storage_info_entity.dart';
import '../../../../shared/models/base_model.dart';

/// Storage information data model
class StorageInfoModel extends BaseModel {
  final String path;
  final int totalSpace;
  final int freeSpace;
  final int usedSpace;
  final String fileSystemType;
  final bool isRemovable;
  final bool isEmulated;
  final String displayName;
  final Map<String, dynamic> metadata;

  const StorageInfoModel({
    required this.path,
    required this.totalSpace,
    required this.freeSpace,
    required this.usedSpace,
    required this.fileSystemType,
    required this.isRemovable,
    required this.isEmulated,
    required this.displayName,
    required this.metadata,
  });

  factory StorageInfoModel.fromJson(Map<String, dynamic> json) {
    return StorageInfoModel(
      path: json['path'] ?? '',
      totalSpace: json['totalSpace'] ?? 0,
      freeSpace: json['freeSpace'] ?? 0,
      usedSpace: json['usedSpace'] ?? 0,
      fileSystemType: json['fileSystemType'] ?? 'unknown',
      isRemovable: json['isRemovable'] ?? false,
      isEmulated: json['isEmulated'] ?? false,
      displayName: json['displayName'] ?? '',
      metadata: json['metadata']?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'totalSpace': totalSpace,
      'freeSpace': freeSpace,
      'usedSpace': usedSpace,
      'fileSystemType': fileSystemType,
      'isRemovable': isRemovable,
      'isEmulated': isEmulated,
      'displayName': displayName,
      'metadata': metadata,
    };
  }

  /// Convert to domain entity
  StorageInfoEntity toEntity() {
    return StorageInfoEntity(
      path: path,
      totalSpace: totalSpace,
      freeSpace: freeSpace,
      usedSpace: usedSpace,
      fileSystemType: fileSystemType,
      isRemovable: isRemovable,
      isEmulated: isEmulated,
      displayName: displayName,
      metadata: metadata,
    );
  }

  /// Create from domain entity
  factory StorageInfoModel.fromEntity(StorageInfoEntity entity) {
    return StorageInfoModel(
      path: entity.path,
      totalSpace: entity.totalSpace,
      freeSpace: entity.freeSpace,
      usedSpace: entity.usedSpace,
      fileSystemType: entity.fileSystemType,
      isRemovable: entity.isRemovable,
      isEmulated: entity.isEmulated,
      displayName: entity.displayName,
      metadata: entity.metadata,
    );
  }

  /// Get usage percentage
  double get usagePercentage {
    if (totalSpace <= 0) return 0.0;
    return (usedSpace / totalSpace) * 100;
  }

  /// Get free space percentage
  double get freePercentage {
    if (totalSpace <= 0) return 0.0;
    return (freeSpace / totalSpace) * 100;
  }

  /// Check if storage is low (less than 10% free)
  bool get isStorageLow {
    return freePercentage < 10.0;
  }

  /// Check if storage is critical (less than 5% free)
  bool get isStorageCritical {
    return freePercentage < 5.0;
  }

  /// Get formatted total space
  String get formattedTotalSpace {
    return FileUtils.formatFileSize(totalSpace);
  }

  /// Get formatted free space
  String get formattedFreeSpace {
    return FileUtils.formatFileSize(freeSpace);
  }

  /// Get formatted used space
  String get formattedUsedSpace {
    return FileUtils.formatFileSize(usedSpace);
  }

  @override
  List<Object?> get props => [
    path,
    totalSpace,
    freeSpace,
    usedSpace,
    fileSystemType,
    isRemovable,
    isEmulated,
    displayName,
    metadata,
  ];
}
