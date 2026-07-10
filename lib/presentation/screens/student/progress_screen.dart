import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/theme/text_styles.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(progressSummaryProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Mi Progreso',
            style: AppTextStyles.titleLarge
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(progressSummaryProvider);
          ref.invalidate(userStatsProvider);
          ref.invalidate(myAchievementsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statsAsync.when(
                loading: () => const _SkeletonCard(height: 160),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) => _XPLevelCard(stats: stats),
              ),
              const SizedBox(height: 16),
              summaryAsync.when(
                loading: () => const _SkeletonCard(height: 80),
                error: (_, __) => const SizedBox.shrink(),
                data: (summary) => _StreakCard(
                  currentStreak: summary.currentStreak,
                  longestStreak: summary.longestStreak,
                ),
              ),
              const SizedBox(height: 16),
              summaryAsync.when(
                loading: () => const _SkeletonCard(height: 120),
                error: (_, __) => const SizedBox.shrink(),
                data: (summary) => _CourseStatsCard(summary: summary),
              ),
              const SizedBox(height: 20),
              Text('Mis logros',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) {
                  final achievementsAsync = ref.watch(myAchievementsProvider);
                  return achievementsAsync.when(
                    loading: () => const _SkeletonCard(height: 100),
                    error: (_, __) => Text('Error al cargar logros',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.error)),
                    data: (achievements) => achievements.isEmpty
                        ? const _EmptyAchievements()
                        : SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: achievements.length,
                              itemBuilder: (_, i) => _AchievementBadge(
                                  achievement: achievements[i]),
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.leaderboard, color: AppColors.primary),
                  label: Text('Ver tabla de clasificacion',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _XPLevelCard extends StatelessWidget {
  const _XPLevelCard({required this.stats});
  final dynamic stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nivel actual',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70)),
                  Text(
                    'Nivel ${stats.level}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('XP', style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stats.totalXp} XP totales',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              ),
              Text(
                '${stats.xpProgress} / ${stats.xpForNextLevel} XP',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stats.levelProgress,
              backgroundColor: Colors.white24,
              color: Colors.white,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.currentStreak, required this.longestStreak});
  final int currentStreak;
  final int longestStreak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_fire_department_rounded,
                color: AppColors.secondary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak dias de racha',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Mejor racha: $longestStreak dias',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (currentStreak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('En racha!',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

class _CourseStatsCard extends StatelessWidget {
  const _CourseStatsCard({required this.summary});
  final dynamic summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen de cursos',
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(
                  value: '${summary.lessonsCompleted}',
                  label: 'Completadas',
                  color: AppColors.success),
              const SizedBox(width: 12),
              _MiniStat(
                  value: '${summary.lessonsInProgress}',
                  label: 'En progreso',
                  color: AppColors.secondary),
              const SizedBox(width: 12),
              _MiniStat(
                  value: '${summary.coursesCompleted}',
                  label: 'Cursos\nterminados',
                  color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso total: ${summary.percentage.toStringAsFixed(1)}%',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                '${summary.lessonsCompleted} / ${summary.totalLessons}',
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: summary.percentage / 100,
              backgroundColor: AppColors.divider,
              color: AppColors.success,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 20)),
            Text(label,
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement});
  final dynamic achievement;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_rounded,
              color: AppColors.primary, size: 32),
          const SizedBox(height: 6),
          Text(
            achievement.achievement.name,
            style: AppTextStyles.labelSmall
                .copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyAchievements extends StatelessWidget {
  const _EmptyAchievements();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Text('Completa lecciones para desbloquear logros',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
