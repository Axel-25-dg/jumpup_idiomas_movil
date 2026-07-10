import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/domain/model/dashboard_models.dart';
import 'package:jumpup_app/domain/model/progress_models.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';

// Screens for bottom nav tabs
import 'package:jumpup_app/presentation/screens/student/course_list_screen.dart';
import 'package:jumpup_app/presentation/screens/student/progress_screen.dart';
import 'package:jumpup_app/presentation/screens/student/profile_screen.dart';
import 'package:jumpup_app/presentation/screens/social/social_media_shell.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const _HomeTab(),
    const CourseListScreen(),
    const ProgressScreen(),
    const SocialMediaShell(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Inicio'),
    (Icons.menu_book_rounded, Icons.menu_book_outlined, 'Cursos'),
    (Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Progreso'),
    (Icons.forum_rounded, Icons.forum_outlined, 'Social'),
    (Icons.person_rounded, Icons.person_outlined, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final (active, inactive, label) = _items[i];
              final isSelected = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? active : inactive,
                        color: isSelected ? AppColors.primary : AppColors.textHint,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textHint,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(userProfileProvider);
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(userStatsProvider);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _SliverHeader(userAsync: userAsync),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _StatsSection(summaryAsync: summaryAsync),
                  const SectionHeader(title: 'Acciones Rápidas'),
                  const _QuickActionsGrid(),
                  const SectionHeader(title: 'Tu Progreso Reciente'),
                  _RecentCourseCard(summaryAsync: summaryAsync),
                  const SizedBox(height: 24),
                  _TutorIABanner(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverHeader extends ConsumerWidget {
  final AsyncValue<UserProfileModel> userAsync;
  const _SliverHeader({required this.userAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: userAsync.when(
                data: (user) => Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: Builder(
                              builder: (context) {
                                final avatarUrl = _resolveAvatarUrl(user.avatarUrl);
                                if (avatarUrl != null) {
                                  return Image.network(
                                    avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(user.username),
                                  );
                                }
                                return _buildPlaceholder(user.username);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Hola, ${user.username}! 👋',
                                style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '¿Qué aprenderemos hoy?',
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                          onPressed: () => context.push('/cart'),
                        ),
                        _StreakBadge(statsAsync: statsAsync),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _LevelProgressBar(statsAsync: statsAsync),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String name) {
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  String? _resolveAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = AppConfig.baseUrl;
    final apiFreeBase = base.replaceFirst(RegExp(r'/?api/?$'), '');
    final cleanBase = apiFreeBase.endsWith('/') ? apiFreeBase.substring(0, apiFreeBase.length - 1) : apiFreeBase;
    final cleanPath = url.startsWith('/') ? url : '/$url';
    return '$cleanBase$cleanPath';
  }
}

class _LevelProgressBar extends StatelessWidget {
  final AsyncValue<UserStatsModel> statsAsync;
  const _LevelProgressBar({required this.statsAsync});

  @override
  Widget build(BuildContext context) {
    return statsAsync.when(
      data: (stats) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nivel ${stats.level}', style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${stats.xpProgress} / ${stats.xpForNextLevel} XP', style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.9))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: stats.levelProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 8,
            ),
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final AsyncValue<UserStatsModel> statsAsync;
  const _StreakBadge({required this.statsAsync});

  @override
  Widget build(BuildContext context) {
    return statsAsync.when(
      data: (stats) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFFD54F), size: 20),
            const SizedBox(width: 4),
            Text(
              '${stats.currentStreak}',
              style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final AsyncValue<DashboardSummaryModel> summaryAsync;
  const _StatsSection({required this.summaryAsync});

  @override
  Widget build(BuildContext context) {
    return summaryAsync.when(
      data: (s) => Row(
        children: [
          Expanded(
            child: StudentCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: StatBadge(
                icon: Icons.stars_rounded,
                value: '${s.totalXp}',
                label: 'XP Total',
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StudentCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: StatBadge(
                icon: Icons.check_circle_rounded,
                value: '${s.activeCourses}',
                label: 'Cursos',
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StudentCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: StatBadge(
                icon: Icons.emoji_events_rounded,
                value: '${s.recentActivities.length}',
                label: 'Actividad',
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
      loading: () => const _StatsSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.school_rounded, 'Aulas', AppColors.primary, AppRoutes.studentClassrooms),
      (Icons.emoji_events_rounded, 'Logros', AppColors.secondary, AppRoutes.studentAchievements),
      (Icons.workspace_premium_rounded, 'Certificados', AppColors.success, AppRoutes.studentCertificates),
      (Icons.leaderboard_rounded, 'Ranking', AppColors.secondary, AppRoutes.studentRanking),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.8,
      children: actions.map((a) => _QuickActionItem(
        icon: a.$1,
        label: a.$2,
        color: a.$3,
        route: a.$4,
      )).toList(),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCourseCard extends ConsumerWidget {
  final AsyncValue<DashboardSummaryModel> summaryAsync;
  const _RecentCourseCard({required this.summaryAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return coursesAsync.when(
      data: (courses) {
        if (courses.isEmpty) {
          return StudentCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.auto_stories_rounded, size: 48, color: AppColors.primary),
                const SizedBox(height: 12),
                Text('Comienza tu viaje', style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text('Explora nuestros cursos y empieza a aprender hoy mismo.', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          );
        }

        final course = courses.first;
        return StudentCard(
          padding: EdgeInsets.zero,
          onTap: () {
            // Navegar al detalle del curso
            context.push(AppRoutes.studentCourseDetail.replaceAll(':id', course.id.toString()));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (course.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    course.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.image_not_supported_rounded, color: AppColors.primary),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            course.difficultyLevel.toUpperCase(),
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          course.languageName,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.title,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.view_module_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('${course.modulesCount} módulos', style: AppTextStyles.labelSmall),
                        const SizedBox(width: 16),
                        const Icon(Icons.play_lesson_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('${course.lessonsCount} lecciones', style: AppTextStyles.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(height: 200, decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16))),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TutorIABanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2575FC).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Necesitas ayuda?',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Practica con nuestro Tutor IA disponible 24/7',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push(AppRoutes.studentAiTutor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2575FC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Hablar con IA', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Icon(Icons.smart_toy_rounded, size: 80, color: Colors.white24),
        ],
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) => Expanded(
        child: Container(
          height: 90,
          margin: EdgeInsets.only(right: i < 2 ? 12 : 0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      )),
    );
  }
}
