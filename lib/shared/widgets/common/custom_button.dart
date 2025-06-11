import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';

/// Button variants
enum ButtonVariant { primary, secondary, outline, text, danger, success }

/// Button sizes
enum ButtonSize { small, medium, large }

/// Custom button with consistent styling
class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final double? elevation;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.elevation,
  }) : assert(
         text != null || child != null,
         'Either text or child must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final buttonStyle = _getButtonStyle(context, colorScheme);
    final textStyle = _getTextStyle(textTheme);
    final buttonPadding = _getPadding();
    final buttonChild = _buildChild(context);

    Widget button;

    switch (variant) {
      case ButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonVariant.secondary:
        button = FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonVariant.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return null;
              return backgroundColor ?? colorScheme.error;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return null;
              return textColor ?? colorScheme.onError;
            }),
          ),
          child: buttonChild,
        );
        break;
      case ButtonVariant.success:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return null;
              return backgroundColor ?? Colors.green;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return null;
              return textColor ?? Colors.white;
            }),
          ),
          child: buttonChild,
        );
        break;
    }

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  ButtonStyle _getButtonStyle(BuildContext context, ColorScheme colorScheme) {
    return ButtonStyle(
      padding: WidgetStateProperty.all(padding ?? _getPadding()),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppConstants.borderRadius,
          ),
        ),
      ),
      elevation: elevation != null ? WidgetStateProperty.all(elevation) : null,
      backgroundColor: backgroundColor != null
          ? WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return null;
              return backgroundColor;
            })
          : null,
      foregroundColor: textColor != null
          ? WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return null;
              return textColor;
            })
          : null,
    );
  }

  TextStyle _getTextStyle(TextTheme textTheme) {
    switch (size) {
      case ButtonSize.small:
        return textTheme.labelMedium ?? const TextStyle();
      case ButtonSize.medium:
        return textTheme.labelLarge ?? const TextStyle();
      case ButtonSize.large:
        return textTheme.titleMedium ?? const TextStyle();
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: _getLoaderSize(),
        width: _getLoaderSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? context.colorScheme.onPrimary,
          ),
        ),
      );
    }

    final textWidget = child ?? Text(text ?? '');

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          textWidget,
        ],
      );
    }

    return textWidget;
  }

  double _getLoaderSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

/// Icon button with consistent styling
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.size,
    this.padding,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = isLoading
        ? SizedBox(
            width: size ?? 24,
            height: size ?? 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? context.colorScheme.onSurface,
              ),
            ),
          )
        : Icon(
            icon,
            color: color ?? context.colorScheme.onSurface,
            size: size ?? 24,
          );

    return IconButton(
      onPressed: isLoading ? null : onPressed,
      tooltip: tooltip,
      padding: padding ?? const EdgeInsets.all(8),
      style: backgroundColor != null
          ? IconButton.styleFrom(backgroundColor: backgroundColor)
          : null,
      icon: iconWidget,
    );
  }
}

/// Floating action button with custom styling
class CustomFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isExtended;
  final String? label;
  final bool mini;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomFAB({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.isExtended = false,
    this.label,
    this.mini = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        icon: Icon(icon),
        label: Text(label!),
      );
    }

    if (mini) {
      return FloatingActionButton.small(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        child: Icon(icon),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: Icon(icon),
    );
  }
}
