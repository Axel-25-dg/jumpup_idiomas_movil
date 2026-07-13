import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:jumpup_app/core/config/app_config.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                if (allAchievements.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events_outlined, size: 80, color: isDark ? Colors.white24 : Colors.black12),
                            const SizedBox(height: 20),
                            Text(
                              'Aún no hay logros configurados en el sistema.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
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
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                              ),
                              boxShadow: isDark ? [] : [
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
                                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${unlocked.length} de ${allAchievements.length} desbloqueados',
                                        style: AppTextStyles.headlineSmall.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? Colors.white : AppColors.textPrimary,
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
                                child: ModernAchievementCard(
                                  name: entry.value.name,
                                  description: entry.value.description,
                                  iconUrl: entry.value.iconUrl,
                                  requiredXp: entry.value.requiredXp,
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
                                child: ModernAchievementCard(
                                  name: entry.value.name,
                                  description: entry.value.description,
                                  iconUrl: entry.value.iconUrl,
                                  requiredXp: entry.value.requiredXp,
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

