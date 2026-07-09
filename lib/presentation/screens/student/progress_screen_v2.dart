import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

/// Pantalla de progreso y gamificación del usuario.
/// Muestra: nivel XP, racha, resumen de cursos, logros y acceso al ranking.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(progressSummaryProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Mi Progreso',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard, color: Colors.white),
            tooltip: 'Ver Ranking',
            onPressed: () {
              // TODO: context.push('/ranking')
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF7C4DFF),
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
              // ── Card de nivel y XP ────────────────────────────────────
              statsAsync.when(
                loading: () => const _SkeletonCard(height: 160),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) => _XPLevelCard(stats: stats),
              ),
              const SizedBox(height: 16),

              // ── Racha de días ─────────────────────────────────────────
              summaryAsync.when(
                loading: () => const _SkeletonCard(height: 80),
                error: (_, __) => const SizedBox.shrink(),
                data: (summary) => _StreakCard(
                  currentStreak: summary.currentStreak,
                  longestStreak: summary.longestStreak,
                ),
              ),
              const SizedBox(height: 16),

              // ── Estadísticas de cursos ─────────────────────────────────
              summaryAsync.when(
                loading: () => const _SkeletonCard(height: 120),
                error: (_, __) => const SizedBox.shrink(),
                data: (summary) => _CourseStatsCard(summary: summary),
              ),
              const SizedBox(height: 20),

              // ── Mis logros ────────────────────────────────────────────
              const Text(
                'Mis logros',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) {
                  final achievementsAsync = ref.watch(myAchievementsProvider);
                  return achievementsAsync.when(
                    loading: () => const _SkeletonCard(height: 100),
                    error: (_, __) => const Text('Error al cargar logros',
                        style: TextStyle(color: Colors.redAccent)),
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

              // ── Botón de ver ranking ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: context.push('/ranking')
                  },
                  icon: const Icon(Icons.leaderboard, color: Color(0xFFFFD700)),
                  label: const Text('Ver tabla de clasificación',
                      style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFFFFD700), width: 1.5),
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

// ─── Widgets de Progreso ──────────────────────────────────────────────────────

class _XPLevelCard extends StatelessWidget {
  const _XPLevelCard({required this.stats});
  final dynamic stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
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
                  const Text('Nivel actual',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                child: const Text('⚡', style: TextStyle(fontSize: 28)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stats.totalXp} XP totales',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
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
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak días de racha',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                Text(
                  'Mejor racha: $longestStreak días',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          if (currentStreak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6D00).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFFF6D00).withValues(alpha: 0.5)),
              ),
              child: const Text('¡En racha!',
                  style: TextStyle(
                      color: Color(0xFFFF6D00),
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
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
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen de cursos',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(
                  value: '${summary.lessonsCompleted}',
                  label: 'Completadas',
                  color: const Color(0xFF4CAF50)),
              const SizedBox(width: 12),
              _MiniStat(
                  value: '${summary.lessonsInProgress}',
                  label: 'En progreso',
                  color: const Color(0xFF03A9F4)),
              const SizedBox(width: 12),
              _MiniStat(
                  value: '${summary.coursesCompleted}',
                  label: 'Cursos\nterminados',
                  color: const Color(0xFF7C4DFF)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso total: ${summary.percentage.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '${summary.lessonsCompleted} / ${summary.totalLessons}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: summary.percentage / 100,
              backgroundColor: Colors.white12,
              color: const Color(0xFF4CAF50),
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
                style: const TextStyle(color: Colors.white54, fontSize: 11),
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
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 6),
          Text(
            achievement.achievement.name,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
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
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: const Center(
        child: Text('Completa lecciones para desbloquear logros 🎯',
            style: TextStyle(color: Colors.white54, fontSize: 14)),
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
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
