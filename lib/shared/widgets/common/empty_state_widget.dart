import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import 'custom_button.dart';

/// Empty state widget variants
enum EmptyStateVariant {
  noFiles,
  noDevices,
  noTransfers,
  noSearchResults,
  noHistory,
  custom,
}

/// Custom empty state widget
class EmptyStateWidget extends StatelessWidget {
  final EmptyStateVariant variant;
  final String? title;
  final String? message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? customIcon;
  final Widget? customAction;

  const EmptyStateWidget({
    super.key,
    this.variant = EmptyStateVariant.custom,
    this.title,
    this.message,
    this.icon,
    this.actionText,
    this.onAction,
    this.customIcon,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    final emptyTitle = title ?? _getEmptyTitle();
    final emptyMessage = message ?? _getEmptyMessage();
    final emptyIcon = _getEmptyIcon(context);

    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            emptyIcon,
            const SizedBox(height: 24),
            Text(
              emptyTitle,
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              emptyMessage,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (customAction != null)
              customAction!
            else if (actionText != null && onAction != null)
              CustomButton(
                text: actionText!,
                onPressed: onAction,
                icon: _getActionIcon(),
                variant: ButtonVariant.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _getEmptyIcon(BuildContext context) {
    if (customIcon != null) return customIcon!;

    final iconData = icon ?? _getDefaultIcon();
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        iconData,
        size: 60,
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (variant) {
      case EmptyStateVariant.noFiles:
        return Icons.insert_drive_file_outlined;
      case EmptyStateVariant.noDevices:
        return Icons.devices_outlined;
      case EmptyStateVariant.noTransfers:
        return Icons.swap_horiz_outlined;
      case EmptyStateVariant.noSearchResults:
        return Icons.search_off_outlined;
      case EmptyStateVariant.noHistory:
        return Icons.history_outlined;
      case EmptyStateVariant.custom:
        return Icons.inbox_outlined;
    }
  }

  String _getEmptyTitle() {
    switch (variant) {
      case EmptyStateVariant.noFiles:
        return 'No Files Found';
      case EmptyStateVariant.noDevices:
        return 'No Devices Found';
      case EmptyStateVariant.noTransfers:
        return 'No Active Transfers';
      case EmptyStateVariant.noSearchResults:
        return 'No Results Found';
      case EmptyStateVariant.noHistory:
        return 'No Transfer History';
      case EmptyStateVariant.custom:
        return 'Nothing Here Yet';
    }
  }

  String _getEmptyMessage() {
    switch (variant) {
      case EmptyStateVariant.noFiles:
        return 'No files to display. Try selecting a different folder or file type.';
      case EmptyStateVariant.noDevices:
        return 'Make sure nearby devices have ShareIt running and are discoverable.';
      case EmptyStateVariant.noTransfers:
        return 'No file transfers in progress. Start sharing files with nearby devices.';
      case EmptyStateVariant.noSearchResults:
        return 'Try adjusting your search terms or browse all files.';
      case EmptyStateVariant.noHistory:
        return 'Your transfer history will appear here once you start sharing files.';
      case EmptyStateVariant.custom:
        return 'Content will appear here when available.';
    }
  }

  IconData _getActionIcon() {
    switch (variant) {
      case EmptyStateVariant.noFiles:
        return Icons.folder_open;
      case EmptyStateVariant.noDevices:
        return Icons.refresh;
      case EmptyStateVariant.noTransfers:
        return Icons.send;
      case EmptyStateVariant.noSearchResults:
        return Icons.clear;
      case EmptyStateVariant.noHistory:
        return Icons.share;
      case EmptyStateVariant.custom:
        return Icons.add;
    }
  }
}
