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
import 'package:jumpup_app/presentation/widgets/shared/user_avatar.dart';
import 'package:jumpup_app/presentation/widgets/shared/product_image.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

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
    const SocialMediaShell(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A), // Premium Dark
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
    (Icons.school_rounded, Icons.school_outlined, 'Aulas'),
    (Icons.forum_rounded, Icons.forum_outlined, 'Social'),
    (Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Progreso'),
    (Icons.person_rounded, Icons.person_outlined, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_items.length, (i) {
              final (active, inactive, label) = _items[i];
              final isSelected = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent])
                        : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? active : inactive,
                        color: isSelected ? Colors.white : Colors.white54,
                        size: 24,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
    final statsAsync = ref.watch(userStatsProvider);

    return Stack(
      children: [
        // Background Blobs
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purpleAccent.withOpacity(0.15),
              boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.2), blurRadius: 100)],
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withOpacity(0.15),
              boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 100)],
            ),
          ),
        ),
        RefreshIndicator(
          color: Colors.blueAccent,
          backgroundColor: const Color(0xFF1E1E2E),
          onRefresh: () async {
            ref.invalidate(userProfileProvider);
            ref.invalidate(dashboardSummaryProvider);
            ref.invalidate(userStatsProvider);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              _SliverHeader(userAsync: userAsync, statsAsync: statsAsync),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _XPAndStreakBanner(statsAsync: statsAsync),
                    const SizedBox(height: 24),
                    const Text('Acciones Rápidas', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const _QuickActionsGrid(),
                    const SizedBox(height: 32),
                    const Text('Tu Progreso Reciente', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _RecentCourseCard(summaryAsync: summaryAsync),
                    const SizedBox(height: 24),
                    _TutorIABanner(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliverHeader extends StatelessWidget {
  final AsyncValue<UserProfileModel> userAsync;
  final AsyncValue<UserStatsModel> statsAsync;
  
  const _SliverHeader({required this.userAsync, required this.statsAsync});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: userAsync.when(
              data: (user) => Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purpleAccent, width: 2),
                    ),
                    child: UserAvatar(
                      imageUrl: AppConfig.resolveImageUrl(user.avatarUrl),
                      fullName: user.username,
                      radius: 25,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hola, ${user.username} 👋',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        const Text(
                          'Listo para aprender hoy?',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.home), // Ir a Social/Notificaciones
                    child: GlassContainer(
                      padding: const EdgeInsets.all(8),
                      borderRadius: BorderRadius.circular(12),
                      child: const Icon(Icons.notifications_active_rounded, color: Colors.amberAccent),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

class _XPAndStreakBanner extends StatelessWidget {
  final AsyncValue<UserStatsModel> statsAsync;
  const _XPAndStreakBanner({required this.statsAsync});

  @override
  Widget build(BuildContext context) {
    return statsAsync.when(
      data: (stats) => GlassContainer(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatBadgeItem(
                    icon: Icons.local_fire_department_rounded,
                    color: Colors.orangeAccent,
                    value: '${stats.currentStreak} Días',
                    label: 'Racha Actual',
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                Expanded(
                  child: _StatBadgeItem(
                    icon: Icons.star_rounded,
                    color: Colors.purpleAccent,
                    value: '${stats.xpProgress} XP',
                    label: 'Nivel ${stats.level}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progreso Nivel ${stats.level}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text('${stats.xpProgress}/${stats.xpForNextLevel} XP', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: stats.levelProgress,
                backgroundColor: Colors.black26,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
      loading: () => const GlassContainer(height: 120, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StatBadgeItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatBadgeItem({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.school_rounded, 'Aulas', Colors.blueAccent, AppRoutes.studentClassrooms),
      (Icons.shopping_bag_rounded, 'Tienda', Colors.greenAccent, '/student/catalog'),
      (Icons.videogame_asset_rounded, 'Juegos', Colors.orangeAccent, '/student/games'),
      (Icons.leaderboard_rounded, 'Ranking', Colors.amberAccent, AppRoutes.studentRanking),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: actions.map((a) => _QuickActionCard(
        icon: a.$1,
        label: a.$2,
        color: a.$3,
        route: a.$4,
      )).toList(),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _QuickActionCard({required this.icon, required this.label, required this.color, required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
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
          return const GlassContainer(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Explora cursos en la Tienda', style: TextStyle(color: Colors.white))),
          );
        }

        final course = courses.first;
        return GestureDetector(
          onTap: () => context.push(AppRoutes.studentCourseDetail.replaceAll(':id', course.id.toString())),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(24),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: ProductImage(imageUrl: course.imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                            child: Text(course.difficultyLevel.toUpperCase(), style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          Text(course.languageName, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(course.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(course.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.play_circle_fill_rounded, color: Colors.purpleAccent),
                          const SizedBox(width: 8),
                          const Text('Continuar Lección', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text('${course.lessonsCount} Lecciones', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const GlassContainer(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TutorIABanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.studentAiTutor),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Tutor Inteligente', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Practica gramática o conversación con nuestra IA (GPT-4o)', style: TextStyle(color: Colors.white, fontSize: 13)),
                  SizedBox(height: 16),
                  Text('Empezar a hablar ➔', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const Icon(Icons.auto_awesome, size: 60, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
