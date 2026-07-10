import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/domain/model/progress_models.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(progressSummaryProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: Stack(
        children: [
          Positioned(top: -80, right: -80, child: _blob(Colors.purpleAccent, 250)),
          Positioned(bottom: 100, left: -60, child: _blob(const Color(0xFF448AFF), 200)),
          RefreshIndicator(
            color: Colors.blueAccent,
            backgroundColor: const Color(0xFF1E1E2E),
            onRefresh: () async {
              return ref.refresh(progressSummaryProvider.future);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: 80,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: const EdgeInsets.fromLTRB(24, 0, 0, 16),
                    title: const Text('Mi Progreso', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // XP Level Ring + Stats
                      statsAsync.when(
                        loading: () => const _SkeletonCard(height: 200),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (stats) => _XPCard(stats: stats),
                      ),
                      const SizedBox(height: 20),
                      // Streak Card
                      summaryAsync.when(
                        loading: () => const _SkeletonCard(height: 100),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (s) => _StreakCard(current: s.currentStreak, longest: s.longestStreak),
                      ),
                      const SizedBox(height: 20),
                      // Course stats
                      summaryAsync.when(
                        loading: () => const _SkeletonCard(height: 120),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (s) => _CourseStatsCard(summary: s),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: const [
                          Icon(Icons.emoji_events_rounded, color: Colors.amberAccent),
                          SizedBox(width: 8),
                          Text('Mis Logros', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _AchievementsGrid(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 100)],
        ),
      );
}

class _XPCard extends StatelessWidget {
  final UserStatsModel stats;
  const _XPCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final progress = stats.levelProgress.clamp(0.0, 1.0);
    return GlassContainer(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Row(
            children: [
              // Ring progress indicator
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 10,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white12),
                    ),
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                      backgroundColor: Colors.transparent,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('Nivel', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nivel ${stats.level}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('${stats.xpProgress} / ${stats.xpForNextLevel} XP', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${stats.xpForNextLevel - stats.xpProgress} XP para subir de nivel', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SmallStat(icon: Icons.star_rounded, label: 'XP Total', value: '${stats.totalXp}', color: Colors.purpleAccent),
              _SmallStat(icon: Icons.local_fire_department_rounded, label: 'Racha', value: '${stats.currentStreak} días', color: Colors.orangeAccent),
              _SmallStat(icon: Icons.trending_up_rounded, label: 'Mejor', value: '${stats.longestStreak} d', color: Colors.amberAccent),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _SmallStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
    ],
  );
}

class _StreakCard extends StatelessWidget {
  final int current, longest;
  const _StreakCard({required this.current, required this.longest});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE65100), Color(0xFFFFA726)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 48),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$current días seguidos', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('Mejor racha: $longest días', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseStatsCard extends StatelessWidget {
  final ProgressSummaryModel summary;
  const _CourseStatsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_stories_rounded, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('Estadísticas de Aprendizaje', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _StatRow(icon: Icons.school_rounded, label: 'Cursos Iniciados', value: '${summary.coursesStarted}', color: Colors.blueAccent),
          const Divider(color: Colors.white12, height: 20),
          _StatRow(icon: Icons.check_circle_rounded, label: 'Cursos Completados', value: '${summary.coursesCompleted}', color: Colors.greenAccent),
          const Divider(color: Colors.white12, height: 20),
          _StatRow(icon: Icons.play_lesson_rounded, label: 'Lecciones Completas', value: '${summary.lessonsCompleted}', color: Colors.orangeAccent),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _StatRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14))),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
    ],
  );
}

class _AchievementsGrid extends ConsumerWidget {
  const _AchievementsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achAsync = ref.watch(myAchievementsProvider);
    return achAsync.when(
      loading: () => const _SkeletonCard(height: 120),
      error: (_, __) => const SizedBox.shrink(),
      data: (achievements) {
        if (achievements.isEmpty) {
          return GlassContainer(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(24),
            child: const Center(
              child: Text('Completa cursos y juegos para ganar logros 🏅', style: TextStyle(color: Colors.white54), textAlign: TextAlign.center),
            ),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12),
          itemCount: achievements.length,
          itemBuilder: (context, i) {
            final a = achievements[i];
            return GlassContainer(
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(a.achievement.iconUrl ?? '🏅', style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(a.achievement.name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;
  const _SkeletonCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}
