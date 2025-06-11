import 'package:flutter/material.dart';

class AppColorSchemes {
  // Primary Brand Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFF42A5F5);

  static const Color secondaryTeal = Color(0xFF009688);
  static const Color secondaryTealDark = Color(0xFF00796B);
  static const Color secondaryTealLight = Color(0xFF4DB6AC);

  // Accent Colors
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFF44336);
  static const Color accentPurple = Color(0xFF9C27B0);

  // Neutral Colors
  static const Color neutralGrey50 = Color(0xFFFAFAFA);
  static const Color neutralGrey100 = Color(0xFFF5F5F5);
  static const Color neutralGrey200 = Color(0xFFEEEEEE);
  static const Color neutralGrey300 = Color(0xFFE0E0E0);
  static const Color neutralGrey400 = Color(0xFFBDBDBD);
  static const Color neutralGrey500 = Color(0xFF9E9E9E);
  static const Color neutralGrey600 = Color(0xFF757575);
  static const Color neutralGrey700 = Color(0xFF616161);
  static const Color neutralGrey800 = Color(0xFF424242);
  static const Color neutralGrey900 = Color(0xFF212121);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFE0B2);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFBBDEFB);

  // Light Theme Color Scheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE3F2FD),
    onPrimaryContainer: Color(0xFF0D47A1),
    secondary: secondaryTeal,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE0F2F1),
    onSecondaryContainer: Color(0xFF004D40),
    tertiary: accentOrange,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFE0B2),
    onTertiaryContainer: Color(0xFFE65100),
    error: error,
    onError: Colors.white,
    errorContainer: errorLight,
    onErrorContainer: Color(0xFFB71C1C),
    background: Colors.white,
    onBackground: neutralGrey900,
    surface: Colors.white,
    onSurface: neutralGrey900,
    surfaceVariant: neutralGrey100,
    onSurfaceVariant: neutralGrey700,
    outline: neutralGrey400,
    outlineVariant: neutralGrey200,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: neutralGrey800,
    onInverseSurface: neutralGrey100,
    inversePrimary: primaryBlueLight,
    surfaceTint: primaryBlue,
  );

  // Dark Theme Color Scheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryBlueLight,
    onPrimary: Color(0xFF0D47A1),
    primaryContainer: Color(0xFF1565C0),
    onPrimaryContainer: Color(0xFFE3F2FD),
    secondary: secondaryTealLight,
    onSecondary: Color(0xFF004D40),
    secondaryContainer: Color(0xFF00695C),
    onSecondaryContainer: Color(0xFFE0F2F1),
    tertiary: accentOrange,
    onTertiary: Color(0xFFE65100),
    tertiaryContainer: Color(0xFFF57C00),
    onTertiaryContainer: Color(0xFFFFE0B2),
    error: Color(0xFFEF5350),
    onError: Color(0xFFB71C1C),
    errorContainer: Color(0xFFD32F2F),
    onErrorContainer: errorLight,
    background: Color(0xFF121212),
    onBackground: Colors.white,
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
    surfaceVariant: Color(0xFF2C2C2C),
    onSurfaceVariant: neutralGrey300,
    outline: neutralGrey600,
    outlineVariant: neutralGrey700,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: neutralGrey100,
    onInverseSurface: neutralGrey800,
    inversePrimary: primaryBlue,
    surfaceTint: primaryBlueLight,
  );

  // File Type Colors
  static const Color imageColor = accentGreen;
  static const Color videoColor = accentRed;
  static const Color audioColor = accentPurple;
  static const Color documentColor = primaryBlue;
  static const Color archiveColor = accentOrange;
  static const Color applicationColor = Color(0xFF673AB7);
  static const Color unknownColor = neutralGrey500;

  // Connection Status Colors
  static const Color connectedColor = accentGreen;
  static const Color connectingColor = accentOrange;
  static const Color disconnectedColor = neutralGrey500;
  static const Color errorConnectionColor = accentRed;

  // Transfer Status Colors
  static const Color transferActiveColor = primaryBlue;
  static const Color transferCompleteColor = accentGreen;
  static const Color transferPausedColor = accentOrange;
  static const Color transferFailedColor = accentRed;
  static const Color transferQueuedColor = neutralGrey500;
}
