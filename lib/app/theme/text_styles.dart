import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Base font family
  static TextStyle get _baseTextStyle => GoogleFonts.inter();

  // Display Styles
  static TextStyle get displayLarge => _baseTextStyle.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static TextStyle get displayMedium => _baseTextStyle.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static TextStyle get displaySmall => _baseTextStyle.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline Styles
  static TextStyle get headlineLarge => _baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle get headlineMedium => _baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.29,
  );

  static TextStyle get headlineSmall => _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title Styles
  static TextStyle get titleLarge => _baseTextStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static TextStyle get titleMedium => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.50,
  );

  static TextStyle get titleSmall => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Label Styles
  static TextStyle get labelLarge => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle get labelMedium => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle get labelSmall => _baseTextStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // Body Styles
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
  );

  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle get bodySmall => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Custom App-specific Styles
  static TextStyle get appBarTitle =>
      titleLarge.copyWith(fontWeight: FontWeight.w700);

  static TextStyle get cardTitle =>
      titleMedium.copyWith(fontWeight: FontWeight.w700);

  static TextStyle get cardSubtitle =>
      bodyMedium.copyWith(fontWeight: FontWeight.w500);

  static TextStyle get buttonLabel =>
      labelLarge.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get tabLabel =>
      labelMedium.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get fileName =>
      bodyMedium.copyWith(fontWeight: FontWeight.w500);

  static TextStyle get fileSize =>
      bodySmall.copyWith(fontWeight: FontWeight.w400);

  static TextStyle get deviceName =>
      titleSmall.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get statusText =>
      labelSmall.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get transferSpeed => bodySmall.copyWith(
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static TextStyle get storageSize => bodyMedium.copyWith(
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Monospace for technical data
  static TextStyle get monospace => GoogleFonts.jetBrainsMono().copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static TextStyle get pathText => monospace.copyWith(fontSize: 11);
}
