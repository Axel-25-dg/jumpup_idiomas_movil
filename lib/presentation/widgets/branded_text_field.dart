import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class BrandedTextField extends StatelessWidget {
  const BrandedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
    this.autofillHints,
    this.maxLines = 1,
    this.enabled = true,
    this.textColor,
    this.labelColor,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final bool enabled;
  final Color? textColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    // Detectar si el tema es oscuro para usar colores blancos automáticamente
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final effectiveTextColor = textColor ?? (isDark ? Colors.white : AppColors.textPrimary);
    final effectiveLabelColor = labelColor ?? (isDark ? Colors.white70 : AppColors.textSecondary);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      autofillHints: autofillHints,
      maxLines: maxLines,
      enabled: enabled,
      style: AppTextStyles.bodyMedium.copyWith(
        color: effectiveTextColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: effectiveLabelColor),
        hintStyle: TextStyle(color: effectiveLabelColor),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: effectiveLabelColor)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
