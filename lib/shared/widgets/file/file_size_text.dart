import 'package:flutter/material.dart';
import '../../../core/utils/size_utils.dart';
import '../../../core/extensions/context_extensions.dart';

/// Widget to display file size in human readable format
class FileSizeText extends StatelessWidget {
  final int bytes;
  final TextStyle? style;
  final bool compact;
  final int decimals;
  final Color? color;

  const FileSizeText({
    super.key,
    required this.bytes,
    this.style,
    this.compact = false,
    this.decimals = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final sizeText = compact
        ? SizeUtils.formatBytesCompact(bytes)
        : SizeUtils.formatBytes(bytes, decimals: decimals);

    return Text(
      sizeText,
      style:
          style ??
          context.textTheme.bodySmall?.copyWith(
            color: color ?? context.colorScheme.onSurfaceVariant,
          ),
    );
  }
}

/// Widget to display transfer speed
class TransferSpeedText extends StatelessWidget {
  final double bytesPerSecond;
  final TextStyle? style;
  final Color? color;

  const TransferSpeedText({
    super.key,
    required this.bytesPerSecond,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final speedText = SizeUtils.formatTransferSpeed(bytesPerSecond);

    return Text(
      speedText,
      style:
          style ??
          context.textTheme.bodySmall?.copyWith(
            color: color ?? context.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
    );
  }
}

/// Widget to display file size comparison
class FileSizeComparison extends StatelessWidget {
  final int originalSize;
  final int compressedSize;
  final bool showPercentage;
  final TextStyle? style;

  const FileSizeComparison({
    super.key,
    required this.originalSize,
    required this.compressedSize,
    this.showPercentage = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final originalText = SizeUtils.formatBytes(originalSize);
    final compressedText = SizeUtils.formatBytes(compressedSize);
    final compressionRatio = SizeUtils.calculateCompressionRatio(
      originalSize,
      compressedSize,
    );

    String displayText = '$compressedText (was $originalText)';
    if (showPercentage && compressionRatio > 0) {
      displayText += ' - ${compressionRatio.toStringAsFixed(1)}% saved';
    }

    return Text(
      displayText,
      style:
          style ??
          context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
    );
  }
}
