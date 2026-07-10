import 'package:flutter/material.dart';

/// Paleta oficial JumpUp — Azul (predominante) / Celeste (secundario) / Blanco
abstract final class AppColors {
  // ── Primarios (AZUL oscuro predominante) ─────────────────────────────────
  static const primary = Color(0xFF1565C0); // Azul profundo
  static const primaryLight = Color(0xFF42A5F5); // Azul medio
  static const primaryDark = Color(0xFF0D47A1); // Azul más oscuro

  // ── Secundarios (CELESTE) ───────────────────────────────────────────────
  static const secondary = Color(0xFF00BFFF); // Celeste
  static const secondaryLight = Color(0xFF66D9FF);
  static const secondaryDark = Color(0xFF008CCC);

  // ── Acento ─────────────────────────────────────────────────────────────
  static const accent = Color(0xFF00BCD4); // Cyan

  // ── Neutros ────────────────────────────────────────────────────────────
  static const white = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8FAFD); // Casi blanco
  static const background = Color(0xFFF0F4F8); // Gris muy claro con tono azul
  static const cardBackground = Color(0xFFFFFFFF);

  // ── Texto ──────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF0D1B2A);
  static const textSecondary = Color(0xFF546E7A);
  static const textHint = Color(0xFFB0BEC5);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // ── Estados ────────────────────────────────────────────────────────────
  static const success = Color(0xFF43A047);
  static const warning = Color(0xFFFB8C00);
  static const error = Color(0xFFE53935);
  static const info = Color(0xFF039BE5);

  // ── Sombra / Divisores ─────────────────────────────────────────────────
  static const divider = Color(0xFFDEE6EF);
  static const shadow = Color(0x1A1565C0);

  // ── Gradiente (AZUL → CELESTE) ─────────────────────────────────────────
  static const gradientStart = Color(0xFF0D47A1); // Azul oscuro
  static const gradientMid = Color(0xFF1565C0); // Azul medio
  static const gradientEnd = Color(0xFF42A5F5); // Azul claro → celeste

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMid, gradientEnd],
    stops: [0.0, 0.5, 1.0],
  );

  // ── Gradiente Celeste (para acentos) ───────────────────────────────────
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight, Color(0xFF99E6FF)],
    stops: [0.0, 0.5, 1.0],
  );

  // ── Dark mode ──────────────────────────────────────────────────────────
  static const darkBackground = Color(0xFF0A0E21);
  static const darkSurface = Color(0xFF111B2E);
  static const darkCard = Color(0xFF1A2540);
  static const darkTextPrimary = Color(0xFFE8F0FE);
  static const darkTextSecondary = Color(0xFF8BA3C7);
}
