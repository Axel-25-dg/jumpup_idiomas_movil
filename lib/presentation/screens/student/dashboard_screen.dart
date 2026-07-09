import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/screens/student/learning_path_screen.dart';
import 'package:jumpup_app/presentation/screens/student/progress_screen.dart';
import 'package:jumpup_app/presentation/screens/student/profile_screen.dart';
import 'package:jumpup_app/presentation/screens/student/course_list_screen.dart';
import 'package:jumpup_app/presentation/screens/social/social_media_shell.dart';
import 'package:jumpup_app/presentation/screens/student/ranking_screen.dart';
import 'package:jumpup_app/presentation/screens/student/achievements_screen.dart';
import 'package:jumpup_app/presentation/screens/student/certificates_screen.dart';
import 'package:jumpup_app/presentation/screens/student/ai_tutor_screen.dart';
import 'package:jumpup_app/presentation/screens/student/daily_challenges_screen.dart';
import 'package:jumpup_app/presentation/screens/student/virtual_class_list_screen.dart';
import 'package:jumpup_app/presentation/screens/student/subscriptions_screen.dart';
import 'package:jumpup_app/theme/app_theme.dart';

// ── Shell principal con NavigationBar estilo Instagram ────────────────────────

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final _pages = const [
    _HomeTab(),
    CourseListScreen(),
    ProgressScreen(),
    SocialMediaShell(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Bottom Navigation Bar estilo Instagram ────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'Inicio'),
      (Icons.menu_book_rounded, Icons.menu_book_outlined, 'Cursos'),
      (Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Progreso'),
      (Icons.forum_rounded, Icons.forum_outlined, 'Social'),
      (Icons.person_rounded, Icons.person_outlined, 'Perfil'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final (activeIcon, inactiveIcon, label) = items[i];
              final isSelected = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? activeIcon : inactiveIcon,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 26,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Tab Home ──────────────────────────────────────────────────────────────────

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProfileProvider);
          ref.invalidate(dashboardSummaryProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Header degradado ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
                child: userAsync.when(
                  loading: () => const _HeaderSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (user) => Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white24,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(
                                user.username.isNotEmpty
                                    ? user.username[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Hola, ${user.username.isNotEmpty ? user.username : 'Usuario'}! 👋',
                              style: AppTextStyles.titleLarge
                                  .copyWith(color: AppColors.textPrimary),
                            ),
                            Text(
                              user.email,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Stats XP/Racha/Cursos ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: summaryAsync.when(
                  loading: () =>
                      const _SkeletonBox(height: 90, width: double.infinity),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (s) => Row(
                    children: [
                      _StatPill(
                          icon: Icons.stars_rounded,
                          label: 'XP',
                          value: '${s.totalXp}',
                          color: Colors.amber),
                      const SizedBox(width: 10),
                      _StatPill(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Racha',
                          value: '${s.currentStreak}d',
                          color: Colors.deepOrange),
                      const SizedBox(width: 10),
                      _StatPill(
                          icon: Icons.check_circle_rounded,
                          label: 'Cursos',
                          value: '${s.activeCourses}',
                          color: Colors.green),
                    ],
                  ),
                ),
              ),
            ),

            // ── Acciones rápidas ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Explorar',
                        style: AppTextStyles.titleMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.95,
                      children: [
                        _QuickCard(
                            icon: Icons.route,
                            label: 'Ruta',
                            color: AppColors.primary,
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const LearningPathScreen()))),
                        _QuickCard(
                            icon: Icons.leaderboard_rounded,
                            label: 'Ranking',
                            color: Colors.amber.shade700,
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const RankingScreen()))),
                        _QuickCard(
                            icon: Icons.emoji_events_rounded,
                            label: 'Logros',
                            color: Colors.deepOrange,
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AchievementsScreen()))),
                        _QuickCard(
                            icon: Icons.verified_rounded,
                            label: 'Certificados',
                            color: Colors.green,
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const CertificatesScreen()))),
                        _QuickCard(
                            icon: Icons.smart_toy_rounded,
                            label: 'Tutor IA',
                            color: Colors.purple,
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const AITutorScreen()))),
                        _QuickCard(
                            icon: Icons.celebration_rounded,
                            label: 'Retos',
                            color: Colors.pink,
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const DailyChallengesScreen()))),
                        _QuickCard(
                            icon: Icons.school_rounded,
                            label: 'Aulas',
                            color: Colors.indigo,
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const VirtualClassListScreen()))),
                        _QuickCard(
                            icon: Icons.workspace_premium_rounded,
                            label: 'Premium',
                            color: Colors.blueGrey,
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SubscriptionsScreen()))),
                        _QuickCard(
                            icon: Icons.forum_rounded,
                            label: 'Social',
                            color: AppColors.secondary,
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const SocialMediaShell()))),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Actividad reciente ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: summaryAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (summary) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Actividad reciente',
                          style: AppTextStyles.titleMedium
                              .copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      if (summary.recentActivities.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.history,
                                    size: 40, color: AppColors.textHint),
                                const SizedBox(height: 8),
                                Text('Sin actividad reciente',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        )
                      else
                        ...summary.recentActivities.map(
                          (a) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(_activityIcon(a.activityType),
                                      color: AppColors.primary, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(a.description,
                                        style: AppTextStyles.bodyMedium)),
                                Text(_timeAgo(a.createdAt),
                                    style: AppTextStyles.labelSmall),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _activityIcon(String type) {
    if (type.contains('lesson') || type.contains('course')) {
      return Icons.menu_book;
    } else if (type.contains('achievement')) {
      return Icons.emoji_events;
    } else if (type.contains('certificate')) {
      return Icons.verified;
    }
    return Icons.fitness_center;
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _QuickCard extends StatelessWidget {
  const _QuickCard({
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
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(value,
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.w700, color: color)),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _SkeletonBox(height: 52, width: 52, radius: 26),
        SizedBox(width: 14),
        Expanded(child: _SkeletonBox(height: 40, width: double.infinity)),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox(
      {required this.height, required this.width, this.radius = 12});
  final double height;
  final double width;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
