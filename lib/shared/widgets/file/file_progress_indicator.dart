import 'package:flutter/material.dart';
import '../../../core/utils/size_utils.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/extensions/context_extensions.dart';

/// File transfer progress indicator
class FileProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int? bytesTransferred;
  final int? totalBytes;
  final double? transferSpeed;
  final Duration? estimatedTimeRemaining;
  final bool showPercentage;
  final bool showSpeed;
  final bool showETA;
  final bool showBytes;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;

  const FileProgressIndicator({
    super.key,
    required this.progress,
    this.bytesTransferred,
    this.totalBytes,
    this.transferSpeed,
    this.estimatedTimeRemaining,
    this.showPercentage = true,
    this.showSpeed = true,
    this.showETA = true,
    this.showBytes = true,
    this.progressColor,
    this.backgroundColor,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProgressBar(context),
        if (_shouldShowDetails()) const SizedBox(height: 8),
        if (_shouldShowDetails()) _buildProgressDetails(context),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: backgroundColor ?? context.colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          valueColor: AlwaysStoppedAnimation<Color>(
            progressColor ?? context.colorScheme.primary,
          ),
          backgroundColor: Colors.transparent,
          minHeight: height,
        ),
      ),
    );
  }

  Widget _buildProgressDetails(BuildContext context) {
    final details = <String>[];

    if (showPercentage) {
      final percentage = (progress * 100).clamp(0.0, 100.0);
      details.add('${percentage.toStringAsFixed(1)}%');
    }

    if (showBytes && bytesTransferred != null && totalBytes != null) {
      final transferredText = SizeUtils.formatBytes(bytesTransferred!);
      final totalText = SizeUtils.formatBytes(totalBytes!);
      details.add('$transferredText / $totalText');
    }

    if (showSpeed && transferSpeed != null) {
      final speedText = SizeUtils.formatTransferSpeed(transferSpeed!);
      details.add(speedText);
    }

    if (showETA && estimatedTimeRemaining != null) {
      final etaText = DateTimeUtils.formatDuration(estimatedTimeRemaining!);
      details.add('ETA: $etaText');
    }

    return Wrap(
      spacing: 16,
      children: details
          .map(
            (detail) => Text(
              detail,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          )
          .toList(),
    );
  }

  bool _shouldShowDetails() {
    return showPercentage ||
        (showBytes && bytesTransferred != null && totalBytes != null) ||
        (showSpeed && transferSpeed != null) ||
        (showETA && estimatedTimeRemaining != null);
  }
}

/// Circular progress indicator for files
class CircularFileProgress extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;
  final bool showPercentage;

  const CircularFileProgress({
    super.key,
    required this.progress,
    this.size = 60,
    this.strokeWidth = 4,
    this.progressColor,
    this.backgroundColor,
    this.child,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? context.colorScheme.primary,
            ),
            backgroundColor:
                backgroundColor ?? context.colorScheme.surfaceContainerHighest,
          ),
          if (child != null)
            child!
          else if (showPercentage)
            Text(
              '${(progress * 100).round()}%',
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

/// Progress indicator with pause/resume controls
class ControllableProgressIndicator extends StatelessWidget {
  final double progress;
  final bool isPaused;
  final bool canPause;
  final bool canCancel;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final int? bytesTransferred;
  final int? totalBytes;
  final double? transferSpeed;

  const ControllableProgressIndicator({
    super.key,
    required this.progress,
    this.isPaused = false,
    this.canPause = true,
    this.canCancel = true,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.bytesTransferred,
    this.totalBytes,
    this.transferSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FileProgressIndicator(
          progress: progress,
          bytesTransferred: bytesTransferred,
          totalBytes: totalBytes,
          transferSpeed: transferSpeed,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (canPause)
              IconButton(
                icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                onPressed: isPaused ? onResume : onPause,
                tooltip: isPaused ? 'Resume' : 'Pause',
              ),
            if (canCancel)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onCancel,
                tooltip: 'Cancel',
              ),
          ],
        ),
      ],
    );
  }
}
