import 'package:flutter/material.dart';

/// Paleta oficial JumpUp — Azul / Celeste / Blanco
abstract final class AppColors {
  // ── Primarios ──────────────────────────────────────────────────────────────
  static const primary = Color(0xFF1565C0); // Azul JumpUp
  static const primaryLight = Color(0xFF1E88E5); // Azul medio
  static const primaryDark = Color(0xFF0D47A1); // Azul oscuro

  // ── Secundarios ────────────────────────────────────────────────────────────
  static const secondary = Color(0xFF29B6F6); // Celeste
  static const secondaryLight = Color(0xFF81D4FA); // Celeste claro
  static const secondaryDark = Color(0xFF0288D1); // Celeste oscuro

  // ── Acento ─────────────────────────────────────────────────────────────────
  static const accent = Color(0xFF00BCD4); // Cyan

  // ── Neutros ────────────────────────────────────────────────────────────────
  static const white = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F9FF); // Blanco azulado suave
  static const background = Color(0xFFF0F4FF);
  static const cardBackground = Color(0xFFFFFFFF);

  // ── Texto ──────────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF0D1B2A);
  static const textSecondary = Color(0xFF546E7A);
  static const textHint = Color(0xFFB0BEC5);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // ── Estados ────────────────────────────────────────────────────────────────
  static const success = Color(0xFF43A047);
  static const warning = Color(0xFFFB8C00);
  static const error = Color(0xFFE53935);
  static const info = Color(0xFF039BE5);

  // ── Sombra / Divisores ─────────────────────────────────────────────────────
  static const divider = Color(0xFFE3EAF2);
  static const shadow = Color(0x1A1565C0); // primary al 10%

  // ── Gradiente Splash / Login ───────────────────────────────────────────────
  static const gradientStart = Color(0xFF0D47A1);
  static const gradientMid = Color(0xFF1565C0);
  static const gradientEnd = Color(0xFF29B6F6);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMid, gradientEnd],
    stops: [0.0, 0.5, 1.0],
  );

  // ── Dark mode ──────────────────────────────────────────────────────────────
  static const darkBackground = Color(0xFF0A0E21);
  static const darkSurface = Color(0xFF111B2E);
  static const darkCard = Color(0xFF1A2540);
  static const darkTextPrimary = Color(0xFFE8F0FE);
  static const darkTextSecondary = Color(0xFF8BA3C7);
}
