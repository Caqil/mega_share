import 'package:equatable/equatable.dart';
import 'package:mega_share/features/file_management/domain/entities/file_entity.dart';

enum StorageType { internal, external, usb, network, cloud }

class StorageVolumeEntity extends Equatable {
  final String id;
  final String name;
  final String path;
  final StorageType type;
  final int totalSpace;
  final int freeSpace;
  final int usedSpace;
  final bool isRemovable;
  final bool isEmulated;
  final bool isPrimary;
  final bool isWritable;
  final bool isAvailable;
  final Map<String, dynamic> metadata;

  const StorageVolumeEntity({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.totalSpace,
    required this.freeSpace,
    required this.usedSpace,
    required this.isRemovable,
    required this.isEmulated,
    required this.isPrimary,
    required this.isWritable,
    required this.isAvailable,
    required this.metadata,
  });

  double get usagePercentage =>
      totalSpace > 0 ? (usedSpace / totalSpace) * 100 : 0;
  String get totalSpaceFormatted => _formatBytes(totalSpace);
  String get freeSpaceFormatted => _formatBytes(freeSpace);
  String get usedSpaceFormatted => _formatBytes(usedSpace);
  bool get isAlmostFull => usagePercentage > 90;
  bool get isLowSpace => usagePercentage > 80;

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

  @override
  List<Object?> get props => [
    id,
    name,
    path,
    type,
    totalSpace,
    freeSpace,
    usedSpace,
    isRemovable,
    isEmulated,
    isPrimary,
    isWritable,
    isAvailable,
    metadata,
  ];
}

class StorageInfoEntity extends Equatable {
  final List<StorageVolumeEntity> volumes;
  final StorageVolumeEntity primaryStorage;
  final int totalSpace;
  final int totalFreeSpace;
  final int totalUsedSpace;
  final Map<FileType, int> fileTypeDistribution;
  final Map<String, int> largestFolders;
  final List<FileEntity> recentFiles;
  final List<FileEntity> largeFiles;
  final DateTime lastUpdated;

  const StorageInfoEntity({
    required this.volumes,
    required this.primaryStorage,
    required this.totalSpace,
    required this.totalFreeSpace,
    required this.totalUsedSpace,
    required this.fileTypeDistribution,
    required this.largestFolders,
    required this.recentFiles,
    required this.largeFiles,
    required this.lastUpdated,
  });

  double get overallUsagePercentage =>
      totalSpace > 0 ? (totalUsedSpace / totalSpace) * 100 : 0;

  String get totalSpaceFormatted => _formatBytes(totalSpace);
  String get totalFreeSpaceFormatted => _formatBytes(totalFreeSpace);
  String get totalUsedSpaceFormatted => _formatBytes(totalUsedSpace);

  bool get hasExternalStorage =>
      volumes.any((v) => v.type == StorageType.external);
  bool get hasRemovableStorage => volumes.any((v) => v.isRemovable);

  List<StorageVolumeEntity> get availableVolumes =>
      volumes.where((v) => v.isAvailable).toList();

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

  StorageInfoEntity copyWith({
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
    return StorageInfoEntity(
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

  @override
  List<Object?> get props => [
    volumes,
    primaryStorage,
    totalSpace,
    totalFreeSpace,
    totalUsedSpace,
    fileTypeDistribution,
    largestFolders,
    recentFiles,
    largeFiles,
    lastUpdated,
  ];
}
