import 'package:flutter/material.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../shared/widgets/animations/slide_animation.dart';
import '../../../../shared/widgets/common/custom_button.dart';
import '../../../../shared/widgets/file/file_icon.dart';
import '../bloc/home_state.dart';

class RecentTransfers extends StatelessWidget {
  final List<RecentTransfer> transfers;
  final Function(RecentTransfer) onTransferTap;
  final VoidCallback onClearHistory;

  const RecentTransfers({
    super.key,
    required this.transfers,
    required this.onTransferTap,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.responsiveHorizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildTransfersList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent Transfers',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (transfers.isNotEmpty)
          TextButton(
            onPressed: () => _showClearDialog(context),
            child: Text(
              'Clear',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransfersList(BuildContext context) {
    if (transfers.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: context.colorScheme.outline.withOpacity(0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transfers.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: context.colorScheme.outline.withOpacity(0.1),
        ),
        itemBuilder: (context, index) {
          return SlideAnimation(
            direction: SlideDirection.right,
            delay: Duration(milliseconds: 50 * index),
            child: _buildTransferItem(context, transfers[index], index),
          );
        },
      ),
    );
  }

  Widget _buildTransferItem(
    BuildContext context,
    RecentTransfer transfer,
    int index,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTransferTap(transfer),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // File icon
              _buildTransferIcon(context, transfer),

              const SizedBox(width: 12),

              // Transfer details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transfer.fileName,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getTransferSubtitle(transfer),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status and time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(context, transfer.status),
                  const SizedBox(height: 2),
                  Text(
                    DateTimeUtils.getTimeSince(transfer.timestamp),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransferIcon(BuildContext context, RecentTransfer transfer) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getDirectionColor(context, transfer.direction).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // File icon
          Center(
            child: FileIcon(
              fileName: transfer.fileName,
              size: 24,
              color: _getDirectionColor(context, transfer.direction),
            ),
          ),

          // Direction indicator
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getDirectionColor(context, transfer.direction),
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colorScheme.surface,
                  width: 1,
                ),
              ),
              child: Icon(
                transfer.direction == TransferDirection.send
                    ? Icons.upload
                    : Icons.download,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, TransferResult status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case TransferResult.success:
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'Success';
        break;
      case TransferResult.failed:
        color = context.colorScheme.error;
        icon = Icons.error;
        text = 'Failed';
        break;
      case TransferResult.cancelled:
        color = Colors.orange;
        icon = Icons.cancel;
        text = 'Cancelled';
        break;
      case TransferResult.inProgress:
        color = context.colorScheme.primary;
        icon = Icons.sync;
        text = 'In Progress';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: context.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: context.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No recent transfers',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transfer history will appear here\nafter you start sharing files',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTransferSubtitle(RecentTransfer transfer) {
    final direction = transfer.direction == TransferDirection.send
        ? 'to'
        : 'from';
    final sizeText = SizeUtils.formatBytes(transfer.fileSize);
    final durationText = transfer.duration != null
        ? ' • ${DateTimeUtils.formatDurationCompact(transfer.duration!)}'
        : '';

    return '$direction ${transfer.deviceName} • $sizeText$durationText';
  }

  Color _getDirectionColor(BuildContext context, TransferDirection direction) {
    switch (direction) {
      case TransferDirection.send:
        return context.colorScheme.primary;
      case TransferDirection.receive:
        return Colors.green;
    }
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Transfer History'),
        content: const Text(
          'Are you sure you want to clear all transfer history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Clear',
            onPressed: () {
              Navigator.of(context).pop();
              onClearHistory();
            },
            variant: ButtonVariant.danger,
          ),
        ],
      ),
    );
  }
}

/// Transfer history statistics widget
class TransferStats extends StatelessWidget {
  final List<RecentTransfer> transfers;

  const TransferStats({super.key, required this.transfers});

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Container(
      margin: context.responsiveHorizontalPadding,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: context.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Statistics',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total',
                  '${stats.totalTransfers}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Success',
                  '${stats.successfulTransfers}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Data',
                  stats.totalDataTransferred,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  TransferStatsData _calculateStats() {
    final successful = transfers
        .where((t) => t.status == TransferResult.success)
        .length;
    final totalBytes = transfers.fold<int>(
      0,
      (sum, transfer) => sum + transfer.fileSize,
    );

    return TransferStatsData(
      totalTransfers: transfers.length,
      successfulTransfers: successful,
      totalDataTransferred: SizeUtils.formatBytes(totalBytes),
    );
  }
}

class TransferStatsData {
  final int totalTransfers;
  final int successfulTransfers;
  final String totalDataTransferred;

  const TransferStatsData({
    required this.totalTransfers,
    required this.successfulTransfers,
    required this.totalDataTransferred,
  });
}
