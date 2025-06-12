import 'package:flutter/material.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import 'package:mega_share/shared/widgets/common/empty_state_widget.dart';

class TransferHistoryPage extends StatelessWidget {
  const TransferHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _clearHistory(context),
          ),
        ],
      ),
      body: const EmptyStateWidget(
        variant: EmptyStateVariant.noHistory,
        actionText: 'Start Sharing',
        onAction: null, // TODO: Navigate to file selection
      ),
    );
  }

  void _clearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all transfer history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement clear history logic
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
