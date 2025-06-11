
import 'package:flutter/material.dart';
import '../../domain/entities/storage_info_entity.dart';

class StorageIndicator extends StatelessWidget {
  final StorageInfoEntity? storageInfo;
  final bool showDetails;
  final double height;

  const StorageIndicator({
    super.key,
    this.storageInfo,
    this.showDetails = true,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (storageInfo == null) {
      return Container(
        height: height,
        margin: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storage,
                color: theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Storage',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (storageInfo!.overallUsagePercentage > 80)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Low Space',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Storage bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: storageInfo!.overallUsagePercentage / 100,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getUsageColor(storageInfo!.overallUsagePercentage),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Storage details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${storageInfo!.totalUsedSpaceFormatted} used',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '${storageInfo!.totalFreeSpaceFormatted} free',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          
          if (showDetails && storageInfo!.volumes.length > 1) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            
            // Volume breakdown
            ...storageInfo!.volumes.map((volume) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getVolumeColor(volume.type),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        volume.name,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      '${volume.usedSpaceFormatted} / ${volume.totalSpaceFormatted}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Color _getUsageColor(double percentage) {
    if (percentage > 90) return Colors.red;
    if (percentage > 80) return Colors.orange;
    if (percentage > 60) return Colors.yellow[700]!;
    return Colors.green;
  }

  Color _getVolumeColor(StorageType type) {
    switch (type) {
      case StorageType.internal:
        return Colors.blue;
      case StorageType.external:
        return Colors.green;
      case StorageType.usb:
        return Colors.orange;
      case StorageType.network:
        return Colors.purple;
      case StorageType.cloud:
        return Colors.cyan;
    }
  }
}
