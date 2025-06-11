import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import 'custom_button.dart';

/// Confirmation dialog with customizable actions
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final ButtonVariant confirmVariant;
  final bool barrierDismissible;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
    this.confirmVariant = ButtonVariant.primary,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      title: icon != null
          ? Column(
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: iconColor ?? context.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(title),
              ],
            )
          : Text(title),
      content: Text(message, style: context.textTheme.bodyLarge),
      actions: [
        CustomButton(
          text: cancelText ?? 'Cancel',
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          variant: ButtonVariant.text,
        ),
        CustomButton(
          text: confirmText ?? 'Confirm',
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          variant: confirmVariant,
        ),
      ],
    );
  }

  /// Show confirmation dialog
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
    Color? iconColor,
    ButtonVariant confirmVariant = ButtonVariant.primary,
    bool barrierDismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        confirmVariant: confirmVariant,
        barrierDismissible: barrierDismissible,
      ),
    );
    return result ?? false;
  }
}

/// Delete confirmation dialog
class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String? itemName;
  final VoidCallback? onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    this.title = 'Delete Item',
    this.itemName,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final message = itemName != null
        ? 'Are you sure you want to delete "$itemName"? This action cannot be undone.'
        : 'Are you sure you want to delete this item? This action cannot be undone.';

    return ConfirmationDialog(
      title: title,
      message: message,
      confirmText: 'Delete',
      icon: Icons.delete_outline,
      iconColor: context.colorScheme.error,
      confirmVariant: ButtonVariant.danger,
      onConfirm: onConfirm,
    );
  }

  static Future<bool> show(
    BuildContext context, {
    String title = 'Delete Item',
    String? itemName,
  }) async {
    return await ConfirmationDialog.show(
      context,
      title: title,
      message: itemName != null
          ? 'Are you sure you want to delete "$itemName"? This action cannot be undone.'
          : 'Are you sure you want to delete this item? This action cannot be undone.',
      confirmText: 'Delete',
      icon: Icons.delete_outline,
      iconColor: context.colorScheme.error,
      confirmVariant: ButtonVariant.danger,
    );
  }
}
