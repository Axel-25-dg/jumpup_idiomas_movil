import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

// Re-exportar para que todo el proyecto funcione con un solo import
export 'colors.dart';
export 'text_styles.dart';

class AppTheme {
  // Colores para compatibilidad con pantallas antiguas
  static const Color primary = AppColors.primary;
  static const Color celeste = AppColors.secondary;
  static const Color grisClaro = AppColors.background;
  static const Color textoOscuro = AppColors.textPrimary;
  static const Color textoClaro = AppColors.textSecondary;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.poppins(color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.poppins(color: AppColors.textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}
