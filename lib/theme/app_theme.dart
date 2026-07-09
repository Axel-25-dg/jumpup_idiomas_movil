import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Re-exportar para que todo el proyecto funcione con un solo import
export 'colors.dart';
export 'text_styles.dart';

class AppTheme {
  // Paleta de colores
  static const Color celeste = Color(0xFF00AEEF);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisClaro = Color(0xFFF5F5F5);
  static const Color textoOscuro = Color(0xFF2C3E50);
  static const Color textoClaro = Color(0xFF7F8C8D);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: celeste,
        onPrimary: blanco,
        surface: blanco,
        onSurface: textoOscuro,
        background: grisClaro,
        onBackground: textoOscuro,
      ),
      scaffoldBackgroundColor: grisClaro,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(color: textoOscuro, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.poppins(color: textoOscuro, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.poppins(color: textoOscuro),
        bodyMedium: GoogleFonts.poppins(color: textoOscuro),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: celeste,
        foregroundColor: blanco,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: celeste,
          foregroundColor: blanco,
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
