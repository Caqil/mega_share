import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/extensions/context_extensions.dart';
import 'custom_button.dart';

/// Custom error widget with retry functionality
class CustomErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final Failure? failure;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;
  final bool showRetryButton;
  final Widget? customAction;

  const CustomErrorWidget({
    super.key,
    this.title,
    this.message,
    this.failure,
    this.onRetry,
    this.retryText,
    this.icon,
    this.showRetryButton = true,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    final errorTitle = title ?? _getErrorTitle();
    final errorMessage = message ?? _getErrorMessage();
    final errorIcon = icon ?? _getErrorIcon();

    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(errorIcon, size: 64, color: context.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              errorTitle,
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (customAction != null)
              customAction!
            else if (showRetryButton && onRetry != null)
              CustomButton(
                text: retryText ?? 'Try Again',
                onPressed: onRetry,
                icon: Icons.refresh,
                variant: ButtonVariant.primary,
              ),
          ],
        ),
      ),
    );
  }

  String _getErrorTitle() {
    if (failure == null) return 'Oops! Something went wrong';

    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Connection Problem';
      case PermissionFailure:
        return 'Permission Required';
      case FileSystemFailure:
        return 'File Access Error';
      case TransferFailure:
        return 'Transfer Failed';
      case ConnectionFailure:
        return 'Device Connection Failed';
      default:
        return 'Something went wrong';
    }
  }

  String _getErrorMessage() {
    if (failure != null) {
      return ErrorHandler.getUserFriendlyMessage(failure!);
    }
    return AppConstants.genericErrorMessage;
  }

  IconData _getErrorIcon() {
    if (failure == null) return Icons.error_outline;

    switch (failure.runtimeType) {
      case NetworkFailure:
        return Icons.wifi_off;
      case PermissionFailure:
        return Icons.security;
      case FileSystemFailure:
        return Icons.folder_off;
      case TransferFailure:
        return Icons.sync_problem;
      case ConnectionFailure:
        return Icons.device_unknown;
      case TimeoutFailure:
        return Icons.timer_off;
      default:
        return Icons.error_outline;
    }
  }
}

/// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({super.key, this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'No Internet Connection',
      message:
          message ?? 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryText: 'Retry',
    );
  }
}

/// Permission error widget
class PermissionErrorWidget extends StatelessWidget {
  final String permissionType;
  final VoidCallback? onRequestPermission;
  final VoidCallback? onOpenSettings;

  const PermissionErrorWidget({
    super.key,
    required this.permissionType,
    this.onRequestPermission,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Permission Required',
      message:
          'This app needs $permissionType permission to function properly.',
      icon: Icons.security,
      showRetryButton: false,
      customAction: Column(
        children: [
          if (onRequestPermission != null)
            CustomButton(
              text: 'Grant Permission',
              onPressed: onRequestPermission,
              icon: Icons.check,
              variant: ButtonVariant.primary,
            ),
          if (onRequestPermission != null && onOpenSettings != null)
            const SizedBox(height: 12),
          if (onOpenSettings != null)
            CustomButton(
              text: 'Open Settings',
              onPressed: onOpenSettings,
              icon: Icons.settings,
              variant: ButtonVariant.outline,
            ),
        ],
      ),
    );
  }
}
