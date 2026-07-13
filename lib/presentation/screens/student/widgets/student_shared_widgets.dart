import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';

class ModernAchievementCard extends StatelessWidget {
  final String name;
  final String description;
  final String? iconUrl;
  final int requiredXp;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final bool isCompact;

  const ModernAchievementCard({
    super.key,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.requiredXp,
    this.isUnlocked = false,
    this.unlockedAt,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;

    if (isCompact) {
      return Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked
                ? AppColors.primary.withValues(alpha: 0.3)
                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(size: 40),
            const SizedBox(height: 8),
            Text(
              name,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: isUnlocked ? (isDark ? Colors.white : AppColors.textPrimary) : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUnlocked
              ? AppColors.primary.withValues(alpha: 0.2)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
      ),
      child: Row(
        children: [
          _buildIcon(size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isUnlocked ? (isDark ? Colors.white : AppColors.textPrimary) : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white38 : Colors.black45,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isUnlocked && unlockedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Completado',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$requiredXp',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: isUnlocked ? AppColors.primary : Colors.grey,
                  ),
                ),
                Text(
                  'XP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                    color: isUnlocked ? AppColors.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon({required double size}) {
    final bool isEmoji = iconUrl == null || iconUrl!.isEmpty || (!iconUrl!.startsWith('http') && !iconUrl!.contains('/'));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: isUnlocked ? AppColors.primaryGradient : null,
        color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.3),
        child: isEmoji
            ? Center(
                child: Text(
                  iconUrl ?? '🏆',
                  style: TextStyle(fontSize: size * 0.5),
                ),
              )
            : Padding(
                padding: EdgeInsets.all(size * 0.15), // Añadimos padding para que no toque los bordes
                child: CachedNetworkImage(
                  imageUrl: AppConfig.resolveImageUrl(iconUrl!),
                  fit: BoxFit.contain, // Cambiado de cover a contain para ver la imagen completa
                  placeholder: (context, url) => Icon(Icons.emoji_events_rounded, color: isUnlocked ? Colors.white : Colors.grey, size: size * 0.5),
                  errorWidget: (context, url, error) => Icon(Icons.emoji_events_rounded, color: isUnlocked ? Colors.white : Colors.grey, size: size * 0.5),
                ),
              ),
      ),
    );
  }
}


class StudentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double borderRadius;
  final bool hasBorder;

  const StudentCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius = 16,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color ?? (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.white),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: hasBorder ? Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.divider.withValues(alpha: 0.5)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class DifficultyBadge extends StatelessWidget {
  final String level;
  const DifficultyBadge({super.key, required this.level});

  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1': return const Color(0xFF43A047);
      case 'A2': return const Color(0xFF66BB6A);
      case 'B1': return const Color(0xFF00BFFF);
      case 'B2': return const Color(0xFF1565C0);
      case 'C1': return const Color(0xFFFB8C00);
      case 'C2': return const Color(0xFFE53935);
      default: return const Color(0xFF1565C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getLevelColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class CustomProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final double height;

  const CustomProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : AppColors.divider.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

class StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatBadge({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isDark ? Colors.white54 : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Color? textColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor ?? (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionLabel!,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
