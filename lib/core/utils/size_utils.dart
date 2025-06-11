import 'dart:math';
import '../constants/file_constants.dart';

/// Utility class for handling file sizes, transfer speeds, and storage calculations
class SizeUtils {
  /// Format bytes to human readable format (e.g., "1.5 MB", "2.3 GB")
  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    final index = (log(bytes) / log(1024)).floor();
    final size = bytes / pow(1024, index);

    if (index == 0) {
      return '$bytes B'; // No decimals for bytes
    }

    return '${size.toStringAsFixed(decimals)} ${suffixes[index]}';
  }

  /// Format bytes to compact format (e.g., "1.5M", "2.3G")
  static String formatBytesCompact(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0B';

    const suffixes = ['B', 'K', 'M', 'G', 'T', 'P'];
    final index = (log(bytes) / log(1024)).floor();
    final size = bytes / pow(1024, index);

    if (index == 0) {
      return '${bytes}B'; // No decimals for bytes
    }

    return '${size.toStringAsFixed(decimals)}${suffixes[index]}';
  }

  /// Format transfer speed (bytes per second) to human readable format
  static String formatTransferSpeed(double bytesPerSecond) {
    if (bytesPerSecond <= 0) return '0 B/s';

    const suffixes = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
    final index = (log(bytesPerSecond) / log(1024)).floor().clamp(
      0,
      suffixes.length - 1,
    );
    final speed = bytesPerSecond / pow(1024, index);

    if (index == 0) {
      return '${speed.round()} B/s';
    }

    return '${speed.toStringAsFixed(1)} ${suffixes[index]}';
  }

  /// Get file size category for classification
  static FileSizeCategory getFileSizeCategory(int bytes) {
    if (bytes == 0) return FileSizeCategory.empty;
    if (bytes < 1024) return FileSizeCategory.tiny; // < 1 KB
    if (bytes < 1024 * 100) return FileSizeCategory.small; // < 100 KB
    if (bytes < 1024 * 1024) return FileSizeCategory.medium; // < 1 MB
    if (bytes < 1024 * 1024 * 10) return FileSizeCategory.large; // < 10 MB
    if (bytes < 1024 * 1024 * 100)
      return FileSizeCategory.veryLarge; // < 100 MB
    if (bytes < 1024 * 1024 * 1024) return FileSizeCategory.huge; // < 1 GB
    return FileSizeCategory.massive; // >= 1 GB
  }

  /// Get optimal chunk size for file transfers based on file size
  static int getOptimalChunkSize(int fileSize) {
    if (fileSize < 1024 * 1024) {
      // Files < 1 MB: Use small chunks
      return FileConstants.smallFileChunkSize; // 32 KB
    } else if (fileSize < 1024 * 1024 * 100) {
      // Files < 100 MB: Use default chunks
      return FileConstants.defaultChunkSize; // 64 KB
    } else {
      // Large files: Use large chunks
      return FileConstants.largeFileChunkSize; // 1 MB
    }
  }

  /// Calculate compression ratio as percentage saved
  static double calculateCompressionRatio(
    int originalSize,
    int compressedSize,
  ) {
    if (originalSize <= 0 || compressedSize < 0) return 0.0;
    if (compressedSize >= originalSize) return 0.0;

    final saved = originalSize - compressedSize;
    return (saved / originalSize) * 100;
  }

  /// Calculate estimated transfer time
  static Duration calculateTransferTime(int bytes, double bytesPerSecond) {
    if (bytesPerSecond <= 0) return Duration.zero;

    final seconds = (bytes / bytesPerSecond).ceil();
    return Duration(seconds: seconds);
  }

  /// Convert storage units
  static double convertBytes(int bytes, StorageUnit to) {
    switch (to) {
      case StorageUnit.bytes:
        return bytes.toDouble();
      case StorageUnit.kilobytes:
        return bytes / 1024;
      case StorageUnit.megabytes:
        return bytes / (1024 * 1024);
      case StorageUnit.gigabytes:
        return bytes / (1024 * 1024 * 1024);
      case StorageUnit.terabytes:
        return bytes / (1024 * 1024 * 1024 * 1024);
    }
  }

  /// Convert from storage unit to bytes
  static int fromStorageUnit(double value, StorageUnit from) {
    switch (from) {
      case StorageUnit.bytes:
        return value.round();
      case StorageUnit.kilobytes:
        return (value * 1024).round();
      case StorageUnit.megabytes:
        return (value * 1024 * 1024).round();
      case StorageUnit.gigabytes:
        return (value * 1024 * 1024 * 1024).round();
      case StorageUnit.terabytes:
        return (value * 1024 * 1024 * 1024 * 1024).round();
    }
  }

  /// Get readable size with automatic unit selection
  static String getAutoFormattedSize(int bytes, {bool compact = false}) {
    return compact ? formatBytesCompact(bytes) : formatBytes(bytes);
  }

  /// Calculate progress percentage
  static double calculateProgress(int transferred, int total) {
    if (total <= 0) return 0.0;
    return ((transferred / total) * 100).clamp(0.0, 100.0);
  }

  /// Format progress with transferred/total information
  static String formatProgress(
    int transferred,
    int total, {
    bool compact = false,
  }) {
    final transferredText = compact
        ? formatBytesCompact(transferred)
        : formatBytes(transferred);
    final totalText = compact ? formatBytesCompact(total) : formatBytes(total);

    return '$transferredText / $totalText';
  }

  /// Calculate remaining bytes
  static int calculateRemaining(int transferred, int total) {
    return (total - transferred).clamp(0, total);
  }

  /// Format remaining bytes
  static String formatRemaining(
    int transferred,
    int total, {
    bool compact = false,
  }) {
    final remaining = calculateRemaining(transferred, total);
    return compact ? formatBytesCompact(remaining) : formatBytes(remaining);
  }

  /// Validate if file size is within acceptable limits
  static FileSizeValidation validateFileSize(int bytes) {
    if (bytes <= 0) {
      return FileSizeValidation(
        isValid: false,
        reason: 'File is empty',
        maxAllowed: FileConstants.maxFileSizeBytes,
      );
    }

    if (bytes > FileConstants.maxFileSizeBytes) {
      return FileSizeValidation(
        isValid: false,
        reason:
            'File exceeds maximum size limit of ${formatBytes(FileConstants.maxFileSizeBytes)}',
        maxAllowed: FileConstants.maxFileSizeBytes,
      );
    }

    return FileSizeValidation(
      isValid: true,
      reason: 'File size is acceptable',
      maxAllowed: FileConstants.maxFileSizeBytes,
    );
  }

  /// Check if total transfer size is within limits
  static bool isTransferSizeAcceptable(List<int> fileSizes) {
    final totalSize = fileSizes.fold<int>(0, (sum, size) => sum + size);
    return totalSize <= FileConstants.maxTotalTransferSizeBytes &&
        fileSizes.length <= FileConstants.maxFilesPerTransfer;
  }

  /// Get transfer size summary
  static TransferSizeSummary getTransferSummary(List<int> fileSizes) {
    final totalSize = fileSizes.fold<int>(0, (sum, size) => sum + size);
    final fileCount = fileSizes.length;
    final averageSize = fileCount > 0 ? totalSize ~/ fileCount : 0;
    final largestFile = fileSizes.isNotEmpty ? fileSizes.reduce(max) : 0;
    final smallestFile = fileSizes.isNotEmpty ? fileSizes.reduce(min) : 0;

    return TransferSizeSummary(
      totalSize: totalSize,
      fileCount: fileCount,
      averageSize: averageSize,
      largestFile: largestFile,
      smallestFile: smallestFile,
      isWithinLimits: isTransferSizeAcceptable(fileSizes),
    );
  }

  /// Estimate bandwidth based on recent transfer speeds
  static double estimateBandwidth(List<double> recentSpeeds) {
    if (recentSpeeds.isEmpty) return 0.0;

    // Use weighted average with more weight on recent measurements
    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (int i = 0; i < recentSpeeds.length; i++) {
      final weight = (i + 1).toDouble(); // More weight to recent speeds
      weightedSum += recentSpeeds[i] * weight;
      totalWeight += weight;
    }

    return weightedSum / totalWeight;
  }

  /// Format storage capacity with usage information
  static String formatStorageInfo(int used, int total) {
    final usedPercent = total > 0 ? (used / total * 100) : 0.0;
    final free = total - used;

    return '${formatBytes(free)} free of ${formatBytes(total)} (${usedPercent.toStringAsFixed(1)}% used)';
  }

  /// Get storage status based on usage percentage
  static StorageStatus getStorageStatus(int used, int total) {
    if (total <= 0) return StorageStatus.unknown;

    final usagePercent = (used / total) * 100;

    if (usagePercent >= 95) return StorageStatus.critical;
    if (usagePercent >= 85) return StorageStatus.low;
    if (usagePercent >= 70) return StorageStatus.moderate;
    return StorageStatus.good;
  }

  /// Calculate ETA (Estimated Time of Arrival) for transfer
  static Duration? calculateETA(
    int transferred,
    int total,
    double currentSpeed,
  ) {
    if (currentSpeed <= 0 || transferred >= total) return null;

    final remaining = total - transferred;
    final secondsRemaining = (remaining / currentSpeed).ceil();

    return Duration(seconds: secondsRemaining);
  }

  /// Format ETA in human readable format
  static String formatETA(Duration? eta) {
    if (eta == null) return 'Unknown';

    final hours = eta.inHours;
    final minutes = eta.inMinutes % 60;
    final seconds = eta.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Parse human readable size to bytes
  static int? parseSize(String sizeString) {
    final regex = RegExp(
      r'^(\d+(?:\.\d+)?)\s*([KMGT]?B?)$',
      caseSensitive: false,
    );
    final match = regex.firstMatch(sizeString.trim());

    if (match == null) return null;

    final value = double.tryParse(match.group(1) ?? '');
    if (value == null) return null;

    final unit = (match.group(2) ?? 'B').toLowerCase();

    switch (unit) {
      case 'b':
      case '':
        return value.round();
      case 'kb':
      case 'k':
        return (value * 1024).round();
      case 'mb':
      case 'm':
        return (value * 1024 * 1024).round();
      case 'gb':
      case 'g':
        return (value * 1024 * 1024 * 1024).round();
      case 'tb':
      case 't':
        return (value * 1024 * 1024 * 1024 * 1024).round();
      default:
        return null;
    }
  }

  /// Get size comparison text
  static String getSizeComparison(int size1, int size2) {
    if (size1 == size2) return 'Same size';

    final larger = max(size1, size2);
    final smaller = min(size1, size2);
    final ratio = larger / smaller;

    if (ratio < 1.1) return 'Similar size';
    if (ratio < 2) return '${ratio.toStringAsFixed(1)}x larger';
    if (ratio < 10) return '${ratio.toStringAsFixed(0)}x larger';

    return 'Much larger';
  }
}

/// File size categories
enum FileSizeCategory {
  empty, // 0 bytes
  tiny, // < 1 KB
  small, // < 100 KB
  medium, // < 1 MB
  large, // < 10 MB
  veryLarge, // < 100 MB
  huge, // < 1 GB
  massive, // >= 1 GB
}

/// Storage units
enum StorageUnit { bytes, kilobytes, megabytes, gigabytes, terabytes }

/// Storage status
enum StorageStatus {
  good, // < 70% used
  moderate, // 70-85% used
  low, // 85-95% used
  critical, // > 95% used
  unknown, // Cannot determine
}

/// File size validation result
class FileSizeValidation {
  final bool isValid;
  final String reason;
  final int maxAllowed;

  const FileSizeValidation({
    required this.isValid,
    required this.reason,
    required this.maxAllowed,
  });
}

/// Transfer size summary
class TransferSizeSummary {
  final int totalSize;
  final int fileCount;
  final int averageSize;
  final int largestFile;
  final int smallestFile;
  final bool isWithinLimits;

  const TransferSizeSummary({
    required this.totalSize,
    required this.fileCount,
    required this.averageSize,
    required this.largestFile,
    required this.smallestFile,
    required this.isWithinLimits,
  });

  String get formattedTotalSize => SizeUtils.formatBytes(totalSize);
  String get formattedAverageSize => SizeUtils.formatBytes(averageSize);
  String get formattedLargestFile => SizeUtils.formatBytes(largestFile);
  String get formattedSmallestFile => SizeUtils.formatBytes(smallestFile);

  @override
  String toString() {
    return 'TransferSizeSummary(files: $fileCount, total: $formattedTotalSize, avg: $formattedAverageSize)';
  }
}
