import 'package:flutter/material.dart';

/// Extension methods for BuildContext
extension ContextExtensions on BuildContext {
  /// Get theme data
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get device pixel ratio
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// Get view insets (keyboard)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Get view padding (safe area)
  EdgeInsets get viewPadding => mediaQuery.padding;

  /// Get safe area insets
  EdgeInsets get safeAreaInsets => mediaQuery.padding;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Get status bar height
  double get statusBarHeight => mediaQuery.padding.top;

  /// Get navigation bar height
  double get navigationBarHeight => mediaQuery.padding.bottom;

  /// Check if device is in landscape mode
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Check if device is in portrait mode
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Check if device is tablet (width > 600)
  bool get isTablet => screenWidth > 600;

  /// Check if device is phone
  bool get isPhone => !isTablet;

  /// Get responsive breakpoint
  DeviceType get deviceType {
    if (screenWidth < 600) return DeviceType.mobile;
    if (screenWidth < 900) return DeviceType.tablet;
    if (screenWidth < 1200) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  /// Get text scale factor
  double get textScaleFactor => mediaQuery.textScaleFactor;

  /// Check if text scale factor is large
  bool get isLargeTextScale => textScaleFactor > 1.3;

  /// Get brightness (light/dark)
  Brightness get brightness => theme.brightness;

  /// Check if theme is dark
  bool get isDarkMode => brightness == Brightness.dark;

  /// Check if theme is light
  bool get isLightMode => brightness == Brightness.light;

  /// Show snackbar
  void showSnackBar(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: colorScheme.error,
      textColor: colorScheme.onError,
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  /// Show info snackbar
  void showInfoSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: colorScheme.primary,
      textColor: colorScheme.onPrimary,
    );
  }

  /// Show dialog
  Future<T?> showAppDialog<T>(Widget dialog) {
    return showDialog<T>(context: this, builder: (_) => dialog);
  }

  /// Show loading dialog
  void showLoadingDialog({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message ?? 'Loading...')),
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }

  /// Show confirmation dialog
  Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showAppDialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(this).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(this).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Navigate to page
  Future<T?> navigateTo<T>(Widget page) {
    return Navigator.of(this).push<T>(MaterialPageRoute(builder: (_) => page));
  }

  /// Navigate and replace current page
  Future<T?> navigateAndReplace<T>(Widget page) {
    return Navigator.of(
      this,
    ).pushReplacement<T, void>(MaterialPageRoute(builder: (_) => page));
  }

  /// Navigate and clear stack
  Future<T?> navigateAndClearStack<T>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  /// Pop until first route
  void popToFirst() {
    Navigator.of(this).popUntil((route) => route.isFirst);
  }

  /// Focus unfocus (hide keyboard)
  void unfocus() {
    FocusScope.of(this).unfocus();
  }

  /// Get locale
  Locale get locale => Localizations.localeOf(this);

  /// Get directionality
  TextDirection get textDirection => Directionality.of(this);

  /// Check if RTL layout
  bool get isRTL => textDirection == TextDirection.rtl;

  /// Check if LTR layout
  bool get isLTR => textDirection == TextDirection.ltr;

  /// Get responsive padding
  EdgeInsets get responsivePadding {
    if (isTablet) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  /// Get responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding {
    if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }
}

/// Device type enumeration
enum DeviceType { mobile, tablet, desktop, largeDesktop }
