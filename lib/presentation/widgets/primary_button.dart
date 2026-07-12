import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: (backgroundColor != null || color != null || textColor != null)
          ? FilledButton.styleFrom(
              backgroundColor: backgroundColor ?? color,
              foregroundColor: textColor,
            )
          : null,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: AppTextStyles.buttonText.copyWith(
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                )
              : Text(
                  label,
                  style: AppTextStyles.buttonText.copyWith(
                    fontSize: fontSize,
                  ),
                ),
    );
  }
}
