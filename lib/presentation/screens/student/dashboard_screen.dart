import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/screens/student/learning_path_screen.dart';
import 'package:jumpup_app/presentation/screens/student/profile_screen.dart';
import 'package:jumpup_app/presentation/screens/student/progress_screen.dart';
import 'package:jumpup_app/presentation/screens/student/ranking_screen.dart';
import 'package:jumpup_app/presentation/screens/student/achievements_screen.dart';
import 'package:jumpup_app/presentation/screens/student/certificates_screen.dart';
import 'package:jumpup_app/presentation/screens/student/ai_tutor_screen.dart';
import 'package:jumpup_app/presentation/screens/student/daily_challenges_screen.dart';
import 'package:jumpup_app/presentation/screens/student/subscriptions_screen.dart';
import 'package:jumpup_app/presentation/screens/student/settings_screen.dart';
import 'package:jumpup_app/presentation/screens/student/virtual_class_list_screen.dart';
import 'package:jumpup_app/presentation/screens/student/classroom_resources_screen.dart';
import 'package:jumpup_app/presentation/screens/social/social_media_shell.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProfileProvider);
          ref.invalidate(dashboardSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            userAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Card(
                color: colors.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Error: $err')),
                    ],
                  ),
                ),
              ),
              data: (user) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colors.primaryContainer,
                        child: Text(
                          (user.username.isNotEmpty ? user.username.substring(0, 1) : '?')
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Hola, ${user.username.isNotEmpty ? user.username : 'Usuario'}!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.email,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.outline,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        tooltip: 'Configuración',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  summaryAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => const SizedBox.shrink(),
                    data: (summary) => Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _XpStat(
                              label: 'XP Total',
                              value: '${summary.totalXp}',
                              icon: Icons.stars_rounded,
                              color: Colors.amber,
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: colors.outlineVariant,
                            ),
                            _XpStat(
                              label: 'Racha',
                              value: '${summary.currentStreak} días',
                              icon: Icons.local_fire_department_rounded,
                              color: Colors.deepOrange,
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: colors.outlineVariant,
                            ),
                            _XpStat(
                              label: 'Cursos activos',
                              value: '${summary.activeCourses}',
                              icon: Icons.check_circle_rounded,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Explorar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 500 ? 3 : 2;
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.1,
                  children: [
                    _NavCard(
                      icon: Icons.route,
                      label: 'Ruta de aprendizaje',
                      color: colors.primary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LearningPathScreen()),
                      ),
                    ),
                    _NavCard(
                      icon: Icons.bar_chart_rounded,
                      label: 'Progreso',
                      color: colors.secondary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProgressScreen()),
                      ),
                    ),
                    _NavCard(
                      icon: Icons.leaderboard_rounded,
                      label: 'Ranking',
                      color: Colors.amber,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RankingScreen()),
                      ),
                    ),
                    _NavCard(
                      icon: Icons.emoji_events_rounded,
                      label: 'Logros',
                      color: Colors.deepOrange,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                      ),
                    ),
                    _NavCard(
                      icon: Icons.verified_rounded,
                      label: 'Certificados',
                      color: Colors.green,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CertificatesScreen()),
                      ),
                    ),
                    _NavCard(
                      icon: Icons.smart_toy_rounded,
                      label: 'Tutor IA',
                      color: Colors.purple,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AITutorScreen()),
                      ),
                    ),
                    _NavCard(
                      icon: Icons.celebration_rounded,
                      label: 'Retos diarios',
                      color: Colors.pink,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DailyChallengesScreen()),
                      ),
                    ),
                    _NavCard(
                      icon: Icons.school_rounded,
                      label: 'Aulas virtuales',
                      color: Colors.indigo,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VirtualClassListScreen()),
                      ),
                    ),
                    _NavCard(
                      icon: Icons.folder_rounded,
                      label: 'Recursos',
                      color: Colors.teal,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ClassroomResourcesScreen()),
                      ),
                    ),
                    _NavCard(
                      icon: Icons.workspace_premium_rounded,
                      label: 'Suscripciones',
                      color: Colors.blueGrey,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
                      ),
                    ),
                    _NavCard(
                      icon: Icons.forum_rounded,
                      label: 'Red social',
                      color: Colors.lightBlue,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SocialMediaShell()),
                      ),
                    ),
                    _NavCard(
                      icon: Icons.person_rounded,
                      label: 'Mi perfil',
                      color: Colors.brown,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            summaryAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (summary) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actividad reciente',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (summary.recentActivities.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.history, size: 48, color: colors.outline),
                              const SizedBox(height: 8),
                              Text(
                                'No hay actividad reciente',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colors.outline,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '¡Empieza tu ruta de aprendizaje!',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...summary.recentActivities.map(
                      (activity) => Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          leading: Icon(
                            _activityIcon(activity.activityType),
                            color: colors.primary,
                          ),
                          title: Text(activity.description),
                          trailing: Text(
                            _timeAgo(activity.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.outline,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _activityIcon(String type) {
    if (type.contains('lesson') || type.contains('course_started')) {
      return Icons.menu_book;
    } else if (type.contains('achievement')) {
      return Icons.emoji_events;
    } else if (type.contains('certificate')) {
      return Icons.verified;
    }
    return Icons.fitness_center;
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _XpStat extends StatelessWidget {
  const _XpStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
