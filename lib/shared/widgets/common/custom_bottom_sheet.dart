import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';

/// Custom bottom sheet with consistent styling
class CustomBottomSheet extends StatelessWidget {
  final String? title;
  final Widget? child;
  final List<Widget>? children;
  final bool showDragHandle;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final VoidCallback? onClose;

  const CustomBottomSheet({
    super.key,
    this.title,
    this.child,
    this.children,
    this.showDragHandle = true,
    this.isScrollable = true,
    this.padding,
    this.height,
    this.onClose,
  }) : assert(
         child != null || children != null,
         'Either child or children must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final sheetPadding = padding ?? EdgeInsets.all(AppConstants.defaultPadding);

    Widget content =
        child ?? Column(mainAxisSize: MainAxisSize.min, children: children!);

    if (title != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title!,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onClose != null)
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      );
    }

    Widget sheet = Container(
      width: double.infinity,
      constraints: height != null
          ? BoxConstraints(maxHeight: height!)
          : BoxConstraints(maxHeight: context.screenHeight * 0.9),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius * 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          if (isScrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: sheetPadding,
                child: content,
              ),
            )
          else
            Padding(padding: sheetPadding, child: content),
        ],
      ),
    );

    return sheet;
  }

  /// Show bottom sheet
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    Widget? child,
    List<Widget>? children,
    bool showDragHandle = true,
    bool isScrollable = true,
    EdgeInsetsGeometry? padding,
    double? height,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomBottomSheet(
        title: title,
        child: child,
        children: children,
        showDragHandle: showDragHandle,
        isScrollable: isScrollable,
        padding: padding,
        height: height,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Bottom sheet with list options
class OptionsBottomSheet extends StatelessWidget {
  final String? title;
  final List<BottomSheetOption> options;

  const OptionsBottomSheet({super.key, this.title, required this.options});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      title: title,
      children: options.map((option) => _buildOption(context, option)).toList(),
    );
  }

  Widget _buildOption(BuildContext context, BottomSheetOption option) {
    return ListTile(
      leading: option.icon != null
          ? Icon(
              option.icon,
              color: option.iconColor ?? context.colorScheme.onSurface,
            )
          : null,
      title: Text(
        option.title,
        style: context.textTheme.bodyLarge?.copyWith(
          color: option.textColor ?? context.colorScheme.onSurface,
        ),
      ),
      subtitle: option.subtitle != null
          ? Text(
              option.subtitle!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      onTap: () {
        Navigator.of(context).pop();
        option.onTap?.call();
      },
      enabled: option.enabled,
    );
  }

  static Future<void> show(
    BuildContext context, {
    String? title,
    required List<BottomSheetOption> options,
  }) {
    return CustomBottomSheet.show(
      context,
      title: title,
      child: OptionsBottomSheet(title: title, options: options),
    );
  }
}

/// Bottom sheet option model
class BottomSheetOption {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool enabled;

  const BottomSheetOption({
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.textColor,
    this.onTap,
    this.enabled = true,
  });
}
