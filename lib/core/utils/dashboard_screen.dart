import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/dashboard_models.dart';
import '../../models/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: profileAsync.when(
          data: (profile) => Text('Hola, ${profile.username} 👋', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          loading: () => const Text('Cargando...', style: TextStyle(color: Colors.white)),
          error: (_, __) => const Text('Dashboard', style: TextStyle(color: Colors.white)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // TODO: context.push('/profile')
            },
          )
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (_, __) => const Center(child: Text('Error al cargar dashboard', style: TextStyle(color: Colors.redAccent))),
        data: (summary) => RefreshIndicator(
          color: const Color(0xFF7C4DFF),
          onRefresh: () async {
            ref.refresh(dashboardSummaryProvider);
            ref.refresh(userProfileProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Progreso de la meta diaria ───────────────────────────
                _DailyGoalCard(progress: summary.todayGoalProgress),
                const SizedBox(height: 16),

                // ── Grid de Estadísticas ─────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'XP Total',
                        value: summary.totalXp.toString(),
                        icon: Icons.bolt,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Racha',
                        value: '${summary.currentStreak} días',
                        icon: Icons.local_fire_department,
                        color: const Color(0xFFFF6D00),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Cursos',
                        value: summary.activeCourses.toString(),
                        icon: Icons.menu_book,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Clases',
                        value: summary.upcomingClasses.toString(),
                        icon: Icons.video_call,
                        color: const Color(0xFF03A9F4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Actividad Reciente ───────────────────────────────────
                const Text('Actividad Reciente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                if (summary.recentActivities.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No hay actividad reciente', style: TextStyle(color: Colors.white54)),
                    ),
                  )
                else
                  ...summary.recentActivities.map((act) => _ActivityTile(activity: act)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Meta Diaria', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).toInt()}% Completado', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              if (progress >= 1.0)
                const Icon(Icons.check_circle, color: Colors.white)
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              color: Colors.white,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});
  final String title;
  final String value;
  final IconData icon;
  final Color color;

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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});
  final ActivityLogModel activity;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (activity.activityType) {
      case 'lesson_completed':
        icon = Icons.check_circle;
        color = const Color(0xFF4CAF50);
        break;
      case 'achievement_unlocked':
        icon = Icons.emoji_events;
        color = const Color(0xFFFFD700);
        break;
      case 'course_started':
        icon = Icons.play_circle_fill;
        color = const Color(0xFF03A9F4);
        break;
      default:
        icon = Icons.notifications;
        color = const Color(0xFF7C4DFF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.description, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 4),
                Text(_formatTimeAgo(activity.createdAt), style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'Hace ${diff.inDays} d';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} h';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} m';
    return 'Justo ahora';
  }
}
