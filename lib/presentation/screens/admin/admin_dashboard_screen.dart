import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/stats_provider.dart';
import 'package:jumpup_app/presentation/screens/admin/announcements_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/classrooms_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/courses_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/exercises_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/languages_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/reports_screen.dart';

import 'package:jumpup_app/presentation/screens/admin/users_screen.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';

/// Tokens de diseño para el panel de Admin (Premium Dark)
class _AdminTokens {
  const _AdminTokens._();

  static const Color background = Color(0xFF0F0E1A);
  static const Color primary = Color(0xFF7C4DFF);
  static const Color secondary = Color(0xFF00E5FF);
  static const Color accent = Color(0xFFFF4081);
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFD600);
  static const Color info = Color(0xFF00B0FF);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color glassFill(BuildContext context) => Colors.white.withValues(alpha: 0.06);
  static Color glassStroke(BuildContext context) => Colors.white.withValues(alpha: 0.12);
}

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const _AdminHomeTab(),
    const _AdminPeopleTab(),
    const _AdminContentTab(),
    const _AdminOpsTab(),
    const _AdminProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AdminTokens.background,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (Icons.dashboard_rounded, 'Menú'),
      (Icons.people_rounded, l10n.adminPeople),
      (Icons.library_books_rounded, l10n.adminContent),
      (Icons.settings_suggest_rounded, l10n.adminOps),
      (Icons.person_rounded, l10n.profile),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double slotWidth = constraints.maxWidth / items.length;

            return ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: _AdminTokens.glassFill(context),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: _AdminTokens.glassStroke(context),
                      width: 1.2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        left: slotWidth * currentIndex,
                        top: 0,
                        bottom: 0,
                        width: slotWidth,
                        child: Center(
                          child: Container(
                            width: slotWidth - 12,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: _AdminTokens.brandGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: _AdminTokens.primary.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (int i = 0; i < items.length; i++)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => onTap(i),
                                behavior: HitTestBehavior.opaque,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      items[i].$1,
                                      color: i == currentIndex ? Colors.white : Colors.white54,
                                      size: 24,
                                    ),
                                    if (i == currentIndex)
                                      Text(
                                        items[i].$2,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AdminHomeTab extends ConsumerStatefulWidget {
  const _AdminHomeTab();

  @override
  ConsumerState<_AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends ConsumerState<_AdminHomeTab> with TickerProviderStateMixin {
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        _AnimatedBackground(controller: _blobController),
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _AdminSliverHeader(email: authState.user?.email),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.platformOverview,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      IconButton(
                        onPressed: () => ref.invalidate(adminStatsProvider),
                        icon: const Icon(Icons.refresh_rounded, color: _AdminTokens.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  statsAsync.when(
                    loading: () => const _LoadingMetrics(),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                    data: (stats) => GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _MetricCard(
                          title: l10n.totalUsers,
                          value: stats.totalUsers,
                          icon: Icons.people_alt_rounded,
                          color: _AdminTokens.primary,
                        ),
                        _MetricCard(
                          title: l10n.studentCourses,
                          value: stats.courses,
                          icon: Icons.menu_book_rounded,
                          color: _AdminTokens.success,
                        ),
                        _MetricCard(
                          title: l10n.studentCertificates,
                          value: stats.certificates,
                          icon: Icons.verified_rounded,
                          color: _AdminTokens.accent,
                        ),
                        _MetricCard(
                          title: l10n.classrooms,
                          value: stats.classrooms ?? 0,
                          icon: Icons.class_rounded,
                          color: _AdminTokens.info,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.recentActivity,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  _ActionCard(
                    icon: Icons.campaign_rounded,
                    title: l10n.systemAnnouncements,
                    subtitle: l10n.manageAnnouncementsSubtitle,
                    color: _AdminTokens.warning,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen())),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminPeopleTab extends StatelessWidget {
  const _AdminPeopleTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _BaseTab(
      title: l10n.peopleManagement,
      children: [
        _ActionCard(
          icon: Icons.person_search_rounded,
          title: l10n.usersAndRoles,
          subtitle: l10n.manageUsersSubtitle,
          color: _AdminTokens.primary,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersScreen())),
        ),
        _ActionCard(
          icon: Icons.class_rounded,
          title: l10n.classrooms,
          subtitle: l10n.monitorClassroomsSubtitle,
          color: _AdminTokens.warning,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassroomsScreen())),
        ),
        _ActionCard(
          icon: Icons.translate_rounded,
          title: l10n.languageExperts,
          subtitle: l10n.manageLanguagesSubtitle,
          color: _AdminTokens.secondary,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguagesScreen())),
        ),
      ],
    );
  }
}

class _AdminContentTab extends StatelessWidget {
  const _AdminContentTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _BaseTab(
      title: l10n.contentAndCurriculum,
      children: [
        _ActionCard(
          icon: Icons.auto_stories_rounded,
          title: l10n.courseCatalog,
          subtitle: l10n.editCoursesSubtitle,
          color: _AdminTokens.success,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesScreen())),
        ),
        _ActionCard(
          icon: Icons.quiz_rounded,
          title: l10n.exerciseBank,
          subtitle: l10n.manageExercisesSubtitle,
          color: _AdminTokens.accent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExercisesScreen())),
        ),
      ],
    );
  }
}

class _AdminOpsTab extends StatelessWidget {
  const _AdminOpsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _BaseTab(
      title: l10n.adminOps,
      children: [
        _ActionCard(
          icon: Icons.flag_rounded,
          title: l10n.contentReports,
          subtitle: l10n.moderateReportsSubtitle,
          color: Colors.redAccent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
        ),
      ],
    );
  }
}

class _AdminProfileTab extends ConsumerWidget {
  const _AdminProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final l10n = AppLocalizations.of(context)!;

    return _BaseTab(
      title: l10n.adminProfile,
      children: [
        GlassContainer(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: _AdminTokens.primary,
                child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                user?.email ?? l10n.administrator,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                l10n.superAdminAccess,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.security_rounded, color: _AdminTokens.secondary),
                title: Text(l10n.securitySettings, style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: Text(l10n.logout, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                onTap: () => _confirmLogout(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.logout, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(l10n.logoutAdminConfirm, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

class _BaseTab extends StatelessWidget {
  const _BaseTab({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _AnimatedBackground(),
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: _AdminTokens.background.withValues(alpha: 0.8),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                centerTitle: true,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverList(delegate: SliverChildListDelegate(children)),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground({this.controller});
  final AnimationController? controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller ?? AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        final val = controller?.value ?? 0.0;
        return Stack(
          children: [
            _BackgroundBlob(
              top: -100 + (50 * val),
              right: -50 + (30 * val),
              size: 400,
              color: _AdminTokens.primary,
              opacity: 0.1,
            ),
            _BackgroundBlob(
              bottom: 100 - (40 * val),
              left: -80 + (40 * val),
              size: 350,
              color: _AdminTokens.secondary,
              opacity: 0.08,
            ),
          ],
        );
      },
    );
  }
}

class _BackgroundBlob extends StatelessWidget {
  const _BackgroundBlob({required this.size, required this.color, this.top, this.bottom, this.left, this.right, required this.opacity});
  final double size;
  final Color color;
  final double? top, bottom, left, right;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: opacity)),
      ),
    );
  }
}

class _AdminSliverHeader extends StatelessWidget {
  const _AdminSliverHeader({this.email});
  final String? email;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: _AdminTokens.background.withValues(alpha: 0.6),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _AdminTokens.brandGradient,
                      ),
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFF1E1E2A),
                        child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Admin Dashboard',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                          Text(email ?? 'admin@jumpup.com',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 24,
      opacity: 0.08,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Icon(Icons.trending_up, color: Colors.white24, size: 14),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title.toUpperCase(),
            style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        blur: 24,
        opacity: 0.06,
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        ),
      ),
    );
  }
}

class _LoadingMetrics extends StatelessWidget {
  const _LoadingMetrics();
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16, crossAxisSpacing: 16,
      childAspectRatio: 1.5, shrinkWrap: true,
      children: List.generate(4, (index) => GlassContainer(borderRadius: BorderRadius.circular(28), child: const Center(child: CircularProgressIndicator(strokeWidth: 2)))),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }
}
