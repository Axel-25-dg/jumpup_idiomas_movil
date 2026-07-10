import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(achievementsProvider);
    final myAsync = ref.watch(myAchievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Mis Logros',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    const Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          allAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (e, __) => SliverFillRemaining(
              child: Center(
                child: Text('Error al cargar logros',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
              ),
            ),
            data: (allAchievements) => myAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (myAchievements) {
                final unlockedIds = myAchievements.map((a) => a.achievement.id).toSet();
                final unlocked = allAchievements.where((a) => unlockedIds.contains(a.id)).toList();
                final locked = allAchievements.where((a) => !unlockedIds.contains(a.id)).toList();

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeIn(
                          duration: const Duration(milliseconds: 800),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.stars_rounded,
                                      color: AppColors.primary, size: 32),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Progreso de Colección',
                                        style: AppTextStyles.labelMedium.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${unlocked.length} de ${allAchievements.length} desbloqueados',
                                        style: AppTextStyles.headlineSmall.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      CustomProgressBar(
                                        progress: allAchievements.isEmpty
                                            ? 0
                                            : unlocked.length / allAchievements.length,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (unlocked.isNotEmpty) ...[
                          const SectionHeader(title: 'Desbloqueados'),
                          ...unlocked.asMap().entries.map((entry) => FadeInLeft(
                                delay: Duration(milliseconds: entry.key * 100),
                                child: _AchievementCard(
                                  achievement: entry.value,
                                  isUnlocked: true,
                                  unlockedAt: myAchievements
                                      .firstWhere((ua) => ua.achievement.id == entry.value.id)
                                      .unlockedAt,
                                ),
                              )),
                          const SizedBox(height: 24),
                        ],
                        if (locked.isNotEmpty) ...[
                          const SectionHeader(title: 'Pendientes'),
                          ...locked.asMap().entries.map((entry) => FadeInUp(
                                delay: Duration(milliseconds: entry.key * 50),
                                child: _AchievementCard(
                                  achievement: entry.value,
                                  isUnlocked: false,
                                ),
                              )),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
    this.unlockedAt,
  });

  final dynamic achievement;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  @override
  Widget build(BuildContext context) {
    return StudentCard(
      padding: EdgeInsets.zero,
      color: isUnlocked ? AppColors.white : AppColors.white.withValues(alpha: 0.6),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: isUnlocked
                        ? AppColors.primaryGradient
                        : LinearGradient(colors: [
                            AppColors.textHint.withValues(alpha: 0.2),
                            AppColors.textHint.withValues(alpha: 0.1),
                          ]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isUnlocked ? Icons.emoji_events_rounded : Icons.lock_rounded,
                    color: isUnlocked ? Colors.white : AppColors.textHint,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (isUnlocked && unlockedAt != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Conseguido el ${_formatDate(unlockedAt!)}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
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
                        : AppColors.divider.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${achievement.requiredXp}',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isUnlocked ? AppColors.primary : AppColors.textHint,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'XP',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isUnlocked ? AppColors.primary : AppColors.textHint,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

