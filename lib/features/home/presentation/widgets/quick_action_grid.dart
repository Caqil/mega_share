import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/animations/scale_animation.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class QuickActionGrid extends StatelessWidget {
  final PermissionStatus permissionStatus;
  final Function(QuickActionType) onActionTap;

  const QuickActionGrid({
    super.key,
    required this.permissionStatus,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.responsiveHorizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'Quick Actions',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildActionGrid(context),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = _getQuickActions(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return ScaleAnimation(
          delay: Duration(milliseconds: 100 * index),
          child: _buildActionCard(context, action, index),
        );
      },
    );
  }

  Widget _buildActionCard(BuildContext context, QuickAction action, int index) {
    final isEnabled = _isActionEnabled(action);
    final isHigh = action.priority == ActionPriority.high;

    return GestureDetector(
      onTap: isEnabled ? () => _handleActionTap(action) : null,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        decoration: BoxDecoration(
          gradient: _getActionGradient(context, action, isEnabled),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: isEnabled
                ? (isHigh
                      ? context.colorScheme.primary.withOpacity(0.3)
                      : context.colorScheme.outline.withOpacity(0.2))
                : context.colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: context.colorScheme.shadow.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? () => _handleActionTap(action) : null,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildActionIcon(context, action, isEnabled),
                      const Spacer(),
                      if (!isEnabled)
                        Icon(
                          Icons.lock,
                          size: 16,
                          color: context.colorScheme.onSurfaceVariant
                              .withOpacity(0.5),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    action.title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isEnabled
                          ? _getActionTextColor(context, action)
                          : context.colorScheme.onSurfaceVariant.withOpacity(
                              0.5,
                            ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isEnabled
                          ? _getActionTextColor(
                              context,
                              action,
                            ).withOpacity(0.7)
                          : context.colorScheme.onSurfaceVariant.withOpacity(
                              0.4,
                            ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(
    BuildContext context,
    QuickAction action,
    bool isEnabled,
  ) {
    final iconColor = isEnabled
        ? _getActionIconColor(context, action)
        : context.colorScheme.onSurfaceVariant.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(action.icon, size: 24, color: iconColor),
    );
  }

  LinearGradient _getActionGradient(
    BuildContext context,
    QuickAction action,
    bool isEnabled,
  ) {
    if (!isEnabled) {
      return LinearGradient(
        colors: [
          context.colorScheme.surfaceContainerHighest,
          context.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    switch (action.priority) {
      case ActionPriority.high:
        return LinearGradient(
          colors: [
            context.colorScheme.primaryContainer,
            context.colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ActionPriority.medium:
        return LinearGradient(
          colors: [
            context.colorScheme.secondaryContainer,
            context.colorScheme.secondaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ActionPriority.normal:
        return LinearGradient(
          colors: [
            context.colorScheme.surfaceContainerHighest,
            context.colorScheme.surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getActionTextColor(BuildContext context, QuickAction action) {
    switch (action.priority) {
      case ActionPriority.high:
        return context.colorScheme.onPrimaryContainer;
      case ActionPriority.medium:
        return context.colorScheme.onSecondaryContainer;
      case ActionPriority.normal:
        return context.colorScheme.onSurface;
    }
  }

  Color _getActionIconColor(BuildContext context, QuickAction action) {
    switch (action.priority) {
      case ActionPriority.high:
        return context.colorScheme.primary;
      case ActionPriority.medium:
        return context.colorScheme.secondary;
      case ActionPriority.normal:
        return context.colorScheme.primary;
    }
  }

  List<QuickAction> _getQuickActions(BuildContext context) {
    return [
      QuickAction(
        type: QuickActionType.sendFiles,
        title: 'Send Files',
        subtitle: 'Share files with nearby devices',
        icon: Icons.upload,
        priority: ActionPriority.high,
        requiredPermissions: ['storage'],
      ),
      QuickAction(
        type: QuickActionType.receiveFiles,
        title: 'Receive Files',
        subtitle: 'Accept files from other devices',
        icon: Icons.download,
        priority: ActionPriority.high,
        requiredPermissions: ['storage'],
      ),
      QuickAction(
        type: QuickActionType.scanQR,
        title: 'Scan QR Code',
        subtitle: 'Connect using QR code',
        icon: Icons.qr_code_scanner,
        priority: ActionPriority.medium,
        requiredPermissions: ['camera'],
      ),
      QuickAction(
        type: QuickActionType.openFileManager,
        title: 'File Manager',
        subtitle: 'Browse and manage files',
        icon: Icons.folder,
        priority: ActionPriority.normal,
        requiredPermissions: ['storage'],
      ),
      QuickAction(
        type: QuickActionType.startDiscovery,
        title: 'Find Devices',
        subtitle: 'Discover nearby devices',
        icon: Icons.radar,
        priority: ActionPriority.medium,
        requiredPermissions: ['location'],
      ),
      QuickAction(
        type: QuickActionType.viewHistory,
        title: 'Transfer History',
        subtitle: 'View past transfers',
        icon: Icons.history,
        priority: ActionPriority.normal,
        requiredPermissions: [],
      ),
    ];
  }

  bool _isActionEnabled(QuickAction action) {
    // Check if all required permissions are granted
    for (final permission in action.requiredPermissions) {
      switch (permission) {
        case 'storage':
          if (!permissionStatus.hasStoragePermission) return false;
          break;
        case 'location':
          if (!permissionStatus.hasLocationPermission) return false;
          break;
        case 'camera':
          if (!permissionStatus.hasCameraPermission) return false;
          break;
        case 'notification':
          if (!permissionStatus.hasNotificationPermission) return false;
          break;
      }
    }
    return true;
  }

  void _handleActionTap(QuickAction action) {
    HapticFeedback.lightImpact();
    onActionTap(action.type);
  }
}

class QuickAction {
  final QuickActionType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final ActionPriority priority;
  final List<String> requiredPermissions;

  const QuickAction({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.priority,
    required this.requiredPermissions,
  });
}

enum ActionPriority { high, medium, normal }
