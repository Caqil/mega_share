import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';

class StorageAnalyticsPage extends StatelessWidget {
  const StorageAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Storage Overview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.storage,
                      size: 48,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Storage Overview',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Storage Progress
                    LinearProgressIndicator(
                      value: 0.68,
                      backgroundColor:
                          context.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Used: 54.4 GB',
                          style: context.textTheme.bodyMedium,
                        ),
                        Text(
                          'Free: 25.6 GB',
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: 80 GB',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Storage Breakdown
            Text(
              'Storage Breakdown',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildStorageCategory(
              'Photos & Videos',
              '28.5 GB',
              0.52,
              Icons.photo,
            ),
            _buildStorageCategory(
              'Documents',
              '8.2 GB',
              0.15,
              Icons.description,
            ),
            _buildStorageCategory('Apps', '12.7 GB', 0.23, Icons.apps),
            _buildStorageCategory('Music', '3.1 GB', 0.06, Icons.music_note),
            _buildStorageCategory('Other', '1.9 GB', 0.04, Icons.folder),

            const SizedBox(height: 32),

            // Transfer Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transfer Statistics',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow('Files Shared', '247'),
                    _buildStatRow('Data Transferred', '15.6 GB'),
                    _buildStatRow('Average Speed', '8.4 MB/s'),
                    _buildStatRow('Devices Connected', '12'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCategory(
    String name,
    String size,
    double percentage,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(size),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
