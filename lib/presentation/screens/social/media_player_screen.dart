import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';

class MediaPlayerScreen extends StatelessWidget {
  const MediaPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Multimedia',
            style: AppTextStyles.titleLarge
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Featured media
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15)),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_circle_fill_rounded,
                        size: 72, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reproductor Multimedia',
                          style: AppTextStyles.titleMedium
                              .copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Accede a tus lecciones en video y audio',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: 0.35,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('15:30', style: AppTextStyles.bodySmall),
                          Text('42:10', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Controles',
              style: AppTextStyles.titleSmall
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _ControlButton(
                  icon: Icons.skip_previous_rounded, label: 'Anterior'),
              _ControlButton(
                  icon: Icons.play_circle_fill_rounded,
                  label: 'Reproducir',
                  isPrimary: true),
              _ControlButton(
                  icon: Icons.skip_next_rounded, label: 'Siguiente'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Opciones',
              style: AppTextStyles.titleSmall
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _OptionChip(label: 'Subtítulos', isSelected: true),
              _OptionChip(label: '1.0x', isSelected: false),
              _OptionChip(label: 'Loop', isSelected: false),
              _OptionChip(label: 'Calidad HD', isSelected: true),
            ],
          ),
          const SizedBox(height: 24),
          Text('Lista de Reproducción',
              style: AppTextStyles.titleSmall
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const _MediaItem(
            title: 'Introducción al curso',
            duration: '10:20',
            isActive: true,
          ),
          const _MediaItem(
            title: 'Vocabulario básico',
            duration: '15:45',
            isActive: false,
          ),
          const _MediaItem(
            title: 'Gramática esencial',
            duration: '12:30',
            isActive: false,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: isPrimary ? null : Border.all(color: AppColors.divider),
          ),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : AppColors.textPrimary,
            size: isPrimary ? 36 : 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          )),
      selected: isSelected,
      onSelected: (_) {},
      backgroundColor: AppColors.white,
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.divider,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _MediaItem extends StatelessWidget {
  const _MediaItem({
    required this.title,
    required this.duration,
    required this.isActive,
  });

  final String title;
  final String duration;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.primary.withValues(alpha: 0.3) : AppColors.divider,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(
          isActive ? Icons.play_circle_filled_rounded : Icons.play_circle_outline_rounded,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(title,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: AppColors.textPrimary,
            )),
        trailing: Text(duration,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            )),
        onTap: () {},
      ),
    );
  }
}
