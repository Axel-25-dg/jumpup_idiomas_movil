import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'text_styles.dart';

final ThemeData darkTheme = _buildDarkTheme();

ThemeData _buildDarkTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF7C4DFF),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF1A1828),
    onPrimaryContainer: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF1A1828),
    onSecondaryContainer: Colors.white,
    tertiary: AppColors.accent,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFF004D57),
    onTertiaryContainer: Color(0xFFB2EBF2),
    error: Color(0xFFEF9A9A),
    onError: Color(0xFFB71C1C),
    errorContainer: Color(0xFFB71C1C),
    onErrorContainer: Color(0xFFFFCDD2),
    surface: Color(0xFF1A1828),
    onSurface: Colors.white,
    surfaceContainerHighest: Color(0xFF1A1828),
    onSurfaceVariant: Colors.white70,
    outline: Color(0xFF2A3A52),
    outlineVariant: Color(0xFF1E2D44),
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
      backgroundColor: const Color(0xFF1A1828),
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: Colors.white,
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
    scaffoldBackgroundColor: const Color(0xFF0F0E1A),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF1A1828),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle:
          AppTextStyles.bodyMedium.copyWith(color: Colors.white38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.primaryLight.withValues(alpha: 0.2),
      elevation: 0,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: const Color(0xFF1A1828),
      selectedTileColor: Colors.white.withValues(alpha: 0.10),
      selectedColor: Colors.white.withValues(alpha: 0.10),
      iconColor: Colors.white70,
      textColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      dense: false,
    ),
    splashColor: Colors.white.withValues(alpha: 0.12),
    highlightColor: Colors.white.withValues(alpha: 0.06),
  );
}
