import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'text_styles.dart';

final ThemeData lightTheme = _buildLightTheme();

ThemeData _buildLightTheme() {
<<<<<<< HEAD
  const colorScheme = ColorScheme(
=======
const ColorScheme colorScheme = ColorScheme(
>>>>>>> main
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.white,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.primaryDark,
    tertiary: AppColors.accent,
    onTertiary: AppColors.white,
    tertiaryContainer: Color(0xFFB2EBF2),
    onTertiaryContainer: AppColors.primaryDark,
    error: AppColors.error,
    onError: AppColors.white,
    errorContainer: Color(0xFFFFCDD2),
    onErrorContainer: Color(0xFFB71C1C),
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.background,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.divider,
    outlineVariant: Color(0xFFCFD8E3),
    inverseSurface: AppColors.darkBackground,
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.secondaryLight,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),

    // ── AppBar ───────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.white,
        fontSize: 20,
      ),
      iconTheme: const IconThemeData(color: AppColors.white),
    ),

    // ── Botones ──────────────────────────────────────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
        shadowColor: AppColors.shadow,
        textStyle: AppTextStyles.buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: AppTextStyles.buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.buttonText.copyWith(fontSize: 14),
      ),
    ),

    // ── Input ─────────────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textHint,
      ),
      labelStyle: AppTextStyles.inputLabel,
      floatingLabelStyle: AppTextStyles.inputLabel.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      errorStyle: AppTextStyles.errorText,
    ),

    // ── Cards ─────────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.cardBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
    ),

    // ── NavigationBar ─────────────────────────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.primaryLight.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          );
        }
        return AppTextStyles.labelSmall;
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return const IconThemeData(color: AppColors.textSecondary, size: 22);
      }),
      elevation: 8,
      shadowColor: AppColors.shadow,
      surfaceTintColor: Colors.transparent,
    ),

    // ── Chips ─────────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      labelStyle: AppTextStyles.labelMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: AppColors.divider),
    ),

    // ── Divider ───────────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // ── SnackBar ──────────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primaryDark,
      contentTextStyle:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // ── CheckBox ─────────────────────────────────────────────────────────────
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
    ),

    // ── Misc ──────────────────────────────────────────────────────────────────
    scaffoldBackgroundColor: AppColors.background,
    splashColor: AppColors.primaryLight.withValues(alpha: 0.1),
    highlightColor: AppColors.primaryLight.withValues(alpha: 0.05),
  );
}
