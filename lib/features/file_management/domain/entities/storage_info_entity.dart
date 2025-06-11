import '../../../../core/utils/size_utils.dart';
import '../../../../shared/models/base_model.dart';

/// Storage information domain entity
class StorageInfoEntity extends BaseEntity with IdentifiableMixin {
  @override
  String get id => path;

  final String path;
  final int totalSpace;
  final int freeSpace;
  final int usedSpace;
  final String fileSystemType;
  final bool isRemovable;
  final bool isEmulated;
  final String displayName;
  final Map<String, dynamic> metadata;

  const StorageInfoEntity({
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

  /// Check if storage is almost full (less than 2% free)
  bool get isStorageAlmostFull {
    return freePercentage < 2.0;
  }

  /// Get storage status
  StorageStatus get status {
    if (isStorageAlmostFull) return StorageStatus.almostFull;
    if (isStorageCritical) return StorageStatus.critical;
    if (isStorageLow) return StorageStatus.low;
    return StorageStatus.normal;
  }

  /// Get formatted total space
  String get formattedTotalSpace {
    return SizeUtils.formatBytes(totalSpace);
  }

  /// Get formatted free space
  String get formattedFreeSpace {
    return SizeUtils.formatBytes(freeSpace);
  }

  /// Get formatted used space
  String get formattedUsedSpace {
    return SizeUtils.formatBytes(usedSpace);
  }

  /// Get formatted total space (compact)
  String get formattedTotalSpaceCompact {
    return SizeUtils.formatBytesCompact(totalSpace);
  }

  /// Get formatted free space (compact)
  String get formattedFreeSpaceCompact {
    return SizeUtils.formatBytesCompact(freeSpace);
  }

  /// Get formatted used space (compact)
  String get formattedUsedSpaceCompact {
    return SizeUtils.formatBytesCompact(usedSpace);
  }

  /// Get storage summary text
  String get summaryText {
    return '${formattedFreeSpaceCompact} free of ${formattedTotalSpaceCompact}';
  }

  /// Get detailed storage text
  String get detailedText {
    return '${formattedUsedSpace} used, ${formattedFreeSpace} free of ${formattedTotalSpace}';
  }

  /// Check if storage has enough space for file size
  bool hasSpaceFor(int fileSize) {
    return freeSpace >= fileSize;
  }

  /// Check if storage has enough space for multiple files
  bool hasSpaceForFiles(List<int> fileSizes) {
    final totalSize = fileSizes.fold<int>(0, (sum, size) => sum + size);
    return hasSpaceFor(totalSize);
  }

  /// Get recommended action based on storage status
  String? get recommendedAction {
    switch (status) {
      case StorageStatus.almostFull:
        return 'Storage is almost full. Free up space immediately.';
      case StorageStatus.critical:
        return 'Storage is critically low. Delete files to continue.';
      case StorageStatus.low:
        return 'Storage is running low. Consider freeing up space.';
      case StorageStatus.normal:
        return null;
    }
  }

  /// Get storage icon based on type and status
  String get iconName {
    if (isRemovable) {
      return 'sd_card';
    } else if (isEmulated) {
      return 'phone_android';
    } else {
      return 'storage';
    }
  }

  /// Get storage type display name
  String get typeDisplayName {
    if (isRemovable) {
      return 'Removable Storage';
    } else if (isEmulated) {
      return 'Internal Storage';
    } else {
      return 'System Storage';
    }
  }

  /// Create copy with updated values
  StorageInfoEntity copyWith({
    String? path,
    int? totalSpace,
    int? freeSpace,
    int? usedSpace,
    String? fileSystemType,
    bool? isRemovable,
    bool? isEmulated,
    String? displayName,
    Map<String, dynamic>? metadata,
  }) {
    return StorageInfoEntity(
      path: path ?? this.path,
      totalSpace: totalSpace ?? this.totalSpace,
      freeSpace: freeSpace ?? this.freeSpace,
      usedSpace: usedSpace ?? this.usedSpace,
      fileSystemType: fileSystemType ?? this.fileSystemType,
      isRemovable: isRemovable ?? this.isRemovable,
      isEmulated: isEmulated ?? this.isEmulated,
      displayName: displayName ?? this.displayName,
      metadata: metadata ?? this.metadata,
    );
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

/// Storage status enumeration
enum StorageStatus { normal, low, critical, almostFull }
