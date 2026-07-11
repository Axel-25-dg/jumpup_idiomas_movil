import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final BoxConstraints? constraints;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    this.child,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.margin,
    this.height,
    this.width,
    this.constraints,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // In dark mode: white overlay. In light mode: dark overlay for visibility.
    final overlayColor = isDark
        ? Colors.white.withValues(alpha: opacity)
        : Colors.black.withValues(alpha: opacity * 0.4);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.08);

    Widget content = Container(
      padding: padding,
      margin: margin,
      height: height,
      width: width,
      constraints: constraints,
      decoration: BoxDecoration(
        color: overlayColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );
  }
}
