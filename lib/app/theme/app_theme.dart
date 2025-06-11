import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_schemes.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.lightColorScheme,
      textTheme: _buildTextTheme(AppColorSchemes.lightColorScheme),
      appBarTheme: _buildAppBarTheme(AppColorSchemes.lightColorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(
        AppColorSchemes.lightColorScheme,
      ),
      outlinedButtonTheme: _buildOutlinedButtonTheme(
        AppColorSchemes.lightColorScheme,
      ),
      textButtonTheme: _buildTextButtonTheme(AppColorSchemes.lightColorScheme),
      filledButtonTheme: _buildFilledButtonTheme(
        AppColorSchemes.lightColorScheme,
      ),
      cardTheme: _buildCardTheme(AppColorSchemes.lightColorScheme),
      chipTheme: _buildChipTheme(AppColorSchemes.lightColorScheme),
      tabBarTheme: _buildTabBarTheme(AppColorSchemes.lightColorScheme),
      bottomNavigationBarTheme: _buildBottomNavTheme(
        AppColorSchemes.lightColorScheme,
      ),
      navigationBarTheme: _buildNavigationBarTheme(
        AppColorSchemes.lightColorScheme,
      ),
      inputDecorationTheme: _buildInputDecorationTheme(
        AppColorSchemes.lightColorScheme,
      ),
      dialogTheme: _buildDialogTheme(AppColorSchemes.lightColorScheme),
      snackBarTheme: _buildSnackBarTheme(AppColorSchemes.lightColorScheme),
      floatingActionButtonTheme: _buildFABTheme(
        AppColorSchemes.lightColorScheme,
      ),
      dividerTheme: _buildDividerTheme(AppColorSchemes.lightColorScheme),
      listTileTheme: _buildListTileTheme(AppColorSchemes.lightColorScheme),
      switchTheme: _buildSwitchTheme(AppColorSchemes.lightColorScheme),
      checkboxTheme: _buildCheckboxTheme(AppColorSchemes.lightColorScheme),
      radioTheme: _buildRadioTheme(AppColorSchemes.lightColorScheme),
      sliderTheme: _buildSliderTheme(AppColorSchemes.lightColorScheme),
      progressIndicatorTheme: _buildProgressIndicatorTheme(
        AppColorSchemes.lightColorScheme,
      ),
      bottomSheetTheme: _buildBottomSheetTheme(
        AppColorSchemes.lightColorScheme,
      ),
      expansionTileTheme: _buildExpansionTileTheme(
        AppColorSchemes.lightColorScheme,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.darkColorScheme,
      textTheme: _buildTextTheme(AppColorSchemes.darkColorScheme),
      appBarTheme: _buildAppBarTheme(AppColorSchemes.darkColorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(
        AppColorSchemes.darkColorScheme,
      ),
      outlinedButtonTheme: _buildOutlinedButtonTheme(
        AppColorSchemes.darkColorScheme,
      ),
      textButtonTheme: _buildTextButtonTheme(AppColorSchemes.darkColorScheme),
      filledButtonTheme: _buildFilledButtonTheme(
        AppColorSchemes.darkColorScheme,
      ),
      cardTheme: _buildCardTheme(AppColorSchemes.darkColorScheme),
      chipTheme: _buildChipTheme(AppColorSchemes.darkColorScheme),
      tabBarTheme: _buildTabBarTheme(AppColorSchemes.darkColorScheme),
      bottomNavigationBarTheme: _buildBottomNavTheme(
        AppColorSchemes.darkColorScheme,
      ),
      navigationBarTheme: _buildNavigationBarTheme(
        AppColorSchemes.darkColorScheme,
      ),
      inputDecorationTheme: _buildInputDecorationTheme(
        AppColorSchemes.darkColorScheme,
      ),
      dialogTheme: _buildDialogTheme(AppColorSchemes.darkColorScheme),
      snackBarTheme: _buildSnackBarTheme(AppColorSchemes.darkColorScheme),
      floatingActionButtonTheme: _buildFABTheme(
        AppColorSchemes.darkColorScheme,
      ),
      dividerTheme: _buildDividerTheme(AppColorSchemes.darkColorScheme),
      listTileTheme: _buildListTileTheme(AppColorSchemes.darkColorScheme),
      switchTheme: _buildSwitchTheme(AppColorSchemes.darkColorScheme),
      checkboxTheme: _buildCheckboxTheme(AppColorSchemes.darkColorScheme),
      radioTheme: _buildRadioTheme(AppColorSchemes.darkColorScheme),
      sliderTheme: _buildSliderTheme(AppColorSchemes.darkColorScheme),
      progressIndicatorTheme: _buildProgressIndicatorTheme(
        AppColorSchemes.darkColorScheme,
      ),
      bottomSheetTheme: _buildBottomSheetTheme(AppColorSchemes.darkColorScheme),
      expansionTileTheme: _buildExpansionTileTheme(
        AppColorSchemes.darkColorScheme,
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      titleSmall: AppTextStyles.titleSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurface),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
      titleTextStyle: AppTextStyles.appBarTitle.copyWith(
        color: colorScheme.onSurface,
      ),
      toolbarTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
      systemOverlayStyle: colorScheme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        textStyle: AppTextStyles.buttonLabel,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline),
        textStyle: AppTextStyles.buttonLabel,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: AppTextStyles.buttonLabel,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static FilledButtonThemeData _buildFilledButtonTheme(
    ColorScheme colorScheme,
  ) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: AppTextStyles.buttonLabel,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static CardThemeData _buildCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 2,
      shadowColor: colorScheme.shadow,
      surfaceTintColor: colorScheme.surfaceTint,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    );
  }

  static ChipThemeData _buildChipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceVariant,
      deleteIconColor: colorScheme.onSurfaceVariant,
      disabledColor: colorScheme.onSurface.withOpacity(0.12),
      selectedColor: colorScheme.secondaryContainer,
      checkmarkColor: colorScheme.onSecondaryContainer,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
        color: colorScheme.onSecondaryContainer,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  static TabBarThemeData _buildTabBarTheme(ColorScheme colorScheme) {
    return TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      labelStyle: AppTextStyles.tabLabel,
      unselectedLabelStyle: AppTextStyles.tabLabel,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavTheme(
    ColorScheme colorScheme,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  static NavigationBarThemeData _buildNavigationBarTheme(
    ColorScheme colorScheme,
  ) {
    return NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurface,
          );
        }
        return AppTextStyles.labelSmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: colorScheme.onSecondaryContainer);
        }
        return IconThemeData(color: colorScheme.onSurfaceVariant);
      }),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static DialogThemeData _buildDialogTheme(ColorScheme colorScheme) {
    return DialogThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 6,
      shadowColor: colorScheme.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: AppTextStyles.headlineSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onInverseSurface,
      ),
      actionTextColor: colorScheme.inversePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    );
  }

  static FloatingActionButtonThemeData _buildFABTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  static DividerThemeData _buildDividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    );
  }

  static ListTileThemeData _buildListTileTheme(ColorScheme colorScheme) {
    return ListTileThemeData(
      textColor: colorScheme.onSurface,
      iconColor: colorScheme.onSurfaceVariant,
      titleTextStyle: AppTextStyles.bodyLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      leadingAndTrailingTextStyle: AppTextStyles.labelMedium.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  static SwitchThemeData _buildSwitchTheme(ColorScheme colorScheme) {
    return SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return colorScheme.onPrimary;
        }
        return colorScheme.outline;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.surfaceVariant;
      }),
    );
  }

  static CheckboxThemeData _buildCheckboxTheme(ColorScheme colorScheme) {
    return CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return colorScheme.primary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(colorScheme.onPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  static RadioThemeData _buildRadioTheme(ColorScheme colorScheme) {
    return RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.onSurfaceVariant;
      }),
    );
  }

  static SliderThemeData _buildSliderTheme(ColorScheme colorScheme) {
    return SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.surfaceVariant,
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withOpacity(0.12),
      valueIndicatorColor: colorScheme.inverseSurface,
      valueIndicatorTextStyle: AppTextStyles.labelSmall.copyWith(
        color: colorScheme.onInverseSurface,
      ),
    );
  }

  static ProgressIndicatorThemeData _buildProgressIndicatorTheme(
    ColorScheme colorScheme,
  ) {
    return ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.surfaceVariant,
      circularTrackColor: colorScheme.surfaceVariant,
    );
  }

  static BottomSheetThemeData _buildBottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  static ExpansionTileThemeData _buildExpansionTileTheme(
    ColorScheme colorScheme,
  ) {
    return ExpansionTileThemeData(
      backgroundColor: colorScheme.surface,
      collapsedBackgroundColor: colorScheme.surface,
      textColor: colorScheme.onSurface,
      collapsedTextColor: colorScheme.onSurface,
      iconColor: colorScheme.onSurfaceVariant,
      collapsedIconColor: colorScheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
