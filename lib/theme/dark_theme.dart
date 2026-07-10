import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'text_styles.dart';

final ThemeData darkTheme = _buildDarkTheme();

ThemeData _buildDarkTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.secondaryLight,
    onPrimary: AppColors.primaryDark,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.secondaryLight,
    secondary: AppColors.secondary,
    onSecondary: AppColors.primaryDark,
    secondaryContainer: AppColors.secondaryDark,
    onSecondaryContainer: AppColors.secondaryLight,
    tertiary: AppColors.accent,
    onTertiary: AppColors.primaryDark,
    tertiaryContainer: const Color(0xFF004D57),
    onTertiaryContainer: const Color(0xFFB2EBF2),
    error: const Color(0xFFEF9A9A),
    onError: const Color(0xFFB71C1C),
    errorContainer: const Color(0xFFB71C1C),
    onErrorContainer: const Color(0xFFFFCDD2),
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerHighest: AppColors.darkCard,
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: const Color(0xFF2A3A52),
    outlineVariant: const Color(0xFF1E2D44),
    inverseSurface: AppColors.surface,
    onInverseSurface: AppColors.textPrimary,
    inversePrimary: AppColors.primary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge:
          AppTextStyles.displayLarge.copyWith(color: AppColors.darkTextPrimary),
      headlineLarge: AppTextStyles.headlineLarge
          .copyWith(color: AppColors.darkTextPrimary),
      headlineMedium: AppTextStyles.headlineMedium
          .copyWith(color: AppColors.darkTextPrimary),
      headlineSmall: AppTextStyles.headlineSmall
          .copyWith(color: AppColors.darkTextPrimary),
      titleLarge:
          AppTextStyles.titleLarge.copyWith(color: AppColors.darkTextPrimary),
      titleMedium:
          AppTextStyles.titleMedium.copyWith(color: AppColors.darkTextPrimary),
      bodyLarge:
          AppTextStyles.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
      bodyMedium:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
      bodySmall:
          AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextSecondary),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: AppTextStyles.buttonText,
      ),
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkCard,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2A3A52), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2A3A52), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2A3A52), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.secondaryLight, width: 2),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.primaryLight.withValues(alpha: 0.2),
      elevation: 0,
    ),
  );
}
