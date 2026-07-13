import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/domain/model/progress_models.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(progressSummaryProvider);
    final statsAsync = ref.watch(userStatsProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(top: -80, right: -80, child: _blob(Colors.purpleAccent, 250)),
          Positioned(bottom: 100, left: -60, child: _blob(const Color(0xFF448AFF), 200)),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: Colors.blueAccent,
              backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
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
                      title: Text('Mi Progreso', style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87, 
                        fontWeight: FontWeight.w900, 
                        fontSize: 22
                      )),
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
                          data: (stats) => summaryAsync.when(
                            loading: () => const _SkeletonCard(height: 200),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (summary) => _XPCard(stats: stats, summary: summary),
                          ),
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
                          children: [
                            const Icon(Icons.emoji_events_rounded, color: Colors.amberAccent),
                            const SizedBox(width: 8),
                            Text('Mis Logros', style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87, 
                              fontSize: 20, 
                              fontWeight: FontWeight.bold
                            )),
                          ],
                        ),
                        const _AchievementsSection(),
                      ]),
                    ),
                  ),
                ],
              ),
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
  final ProgressSummaryModel summary;
  const _XPCard({required this.stats, required this.summary});

  @override
  Widget build(BuildContext context) {
    final progress = stats.levelProgress.clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GlassContainer(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              // Ring progress indicator with Glow
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>((isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6A11CB)),
                      backgroundColor: Colors.transparent,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${(progress * 100).toInt()}%', 
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('EXP', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.2)),
                      ),
                      child: Text('Nivel ${stats.level}', 
                        style: const TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Text('Maestro de Idiomas', 
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2575FC)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${stats.xpForNextLevel - stats.xpProgress} XP para el siguiente nivel', 
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SmallStat(icon: Icons.star_rounded, label: 'XP Total', value: '${stats.totalXp}', color: Colors.purpleAccent),
              _SmallStat(icon: Icons.local_fire_department_rounded, label: 'Racha', value: '${stats.currentStreak} días', color: Colors.orangeAccent),
              _SmallStat(icon: Icons.emoji_events_rounded, label: 'Logros', value: '${summary.achievementsCount}', color: Colors.amberAccent),
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 10)),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int current, longest;
  const _StreakCard({required this.current, required this.longest});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2575FC).withValues(alpha: 0.3),
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
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$current Días Seguidos', 
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('¡Mantén el fuego encendido! 🔥 Mejor racha: $longest', 
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories_rounded, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text('Estadísticas de Aprendizaje', style: TextStyle(
                color: isDark ? Colors.white : Colors.black87, 
                fontSize: 16, 
                fontWeight: FontWeight.bold
              )),
            ],
          ),
          const SizedBox(height: 20),
          _StatRow(icon: Icons.school_rounded, label: 'Cursos Iniciados', value: '${summary.coursesStarted}', color: Colors.blueAccent),
          Divider(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1), height: 20),
          _StatRow(icon: Icons.check_circle_rounded, label: 'Cursos Completados', value: '${summary.coursesCompleted}', color: Colors.greenAccent),
          Divider(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1), height: 20),
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14))),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

class _AchievementsSection extends ConsumerWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achAsync = ref.watch(myAchievementsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Colors.amberAccent),
                const SizedBox(width: 8),
                Text(
                  'Mis Logros',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.push('/student/achievements'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        achAsync.when(
          loading: () => const _SkeletonCard(height: 100),
          error: (_, __) => const SizedBox.shrink(),
          data: (achievements) {
            if (achievements.isEmpty) {
              return GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                borderRadius: BorderRadius.circular(24),
                child: Center(
                  child: Text(
                    'Completa cursos y juegos para ganar logros 🏅',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: achievements.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final a = achievements[i];
                  return ModernAchievementCard(
                    name: a.achievement.name,
                    description: a.achievement.description,
                    iconUrl: a.achievement.iconUrl,
                    requiredXp: a.achievement.requiredXp,
                    isUnlocked: true,
                    isCompact: true,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;
  const _SkeletonCard({required this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      height: height,
      borderRadius: BorderRadius.circular(24),
      opacity: 0.05,
      child: Center(
        child: CircularProgressIndicator(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
          strokeWidth: 2,
        ),
      ),
    );
  }
}
