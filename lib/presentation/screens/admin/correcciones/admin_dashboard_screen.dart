import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/correcciones/stats_provider.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/announcements_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/classrooms_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/courses_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/exercises_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/languages_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/reports_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/suscription_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/users_screen.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      body: Stack(
        children: [
          // Background Decorative Blobs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E1E2A),
                          const Color(0xFF0F0E1A).withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            GlassContainer(
                              borderRadius: BorderRadius.circular(15),
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Color(0xFF00E5FF),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Admin Panel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    authState.user?.email ?? 'admin@jumpup.com',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white70,
                              ),
                              tooltip: 'Cerrar sesión',
                              onPressed: () => _confirmLogout(context, ref),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Cuerpo ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: RefreshIndicator(
                  color: const Color(0xFF7C4DFF),
                  onRefresh: () async {
                    ref.invalidate(adminStatsProvider);
                    await ref.read(adminStatsProvider.future);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Métricas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Platform Overview',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => ref.invalidate(adminStatsProvider),
                              child: const Text('Refresh', style: TextStyle(color: Color(0xFF00E5FF))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        statsAsync.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                            ),
                          ),
                          error: (e, _) => _ErrorCard(message: e.toString()),
                          data: (stats) => GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.5,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _MetricCard(
                                title: 'Total Users',
                                value: stats.totalUsers,
                                icon: Icons.people_alt_rounded,
                                accentColor: const Color(0xFF7C4DFF),
                              ),
                              _MetricCard(
                                title: 'Teachers',
                                value: stats.teachers,
                                icon: Icons.school_rounded,
                                accentColor: const Color(0xFF00E5FF),
                              ),
                              _MetricCard(
                                title: 'Students',
                                value: stats.students,
                                icon: Icons.person_rounded,
                                accentColor: const Color(0xFFFF4081),
                              ),
                              _MetricCard(
                                title: 'Courses',
                                value: stats.courses,
                                icon: Icons.menu_book_rounded,
                                accentColor: const Color(0xFF00C853),
                              ),
                              _MetricCard(
                                title: 'Classrooms',
                                value: stats.classrooms,
                                icon: Icons.class_rounded,
                                accentColor: const Color(0xFFFFD600),
                              ),
                              _MetricCard(
                                title: 'Subscriptions',
                                value: stats.subscriptions,
                                icon: Icons.workspace_premium_rounded,
                                accentColor: const Color(0xFFAA00FF),
                              ),
                              _MetricCard(
                                title: 'Payments',
                                value: stats.payments,
                                icon: Icons.payment_rounded,
                                accentColor: const Color(0xFF00B0FF),
                              ),
                              _MetricCard(
                                title: 'Certificates',
                                value: stats.certificates,
                                icon: Icons.verified_rounded,
                                accentColor: const Color(0xFF64DD17),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Gestión ──────────────────────────────────────
                        const Text(
                          'Management',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _ActionCard(
                          icon: Icons.people_alt_rounded,
                          title: 'User Management',
                          subtitle: 'Manage roles and account status',
                          accentColor: const Color(0xFF7C4DFF),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const UsersScreen()),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.menu_book_rounded,
                          title: 'Courses & Lessons',
                          subtitle: 'Create and edit educational content',
                          accentColor: const Color(0xFF00C853),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CoursesScreen()),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.translate_rounded,
                          title: 'Language Assets',
                          subtitle: 'Manage platform supported languages',
                          accentColor: const Color(0xFF00E5FF),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LanguagesScreen()),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.class_rounded,
                          title: 'Virtual Classrooms',
                          subtitle: 'Monitor and manage active groups',
                          accentColor: const Color(0xFFFFD600),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ClassroomsScreen()),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.edit_note_rounded,
                          title: 'Exercise Bank',
                          subtitle: 'Review and update exercise modules',
                          accentColor: const Color(0xFFAA00FF),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ExercisesScreen()),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.campaign_rounded,
                          title: 'Announcements',
                          subtitle: 'Push global platform updates',
                          accentColor: const Color(0xFFFF6D00),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.flag_rounded,
                          title: 'Content Reports',
                          subtitle: 'Moderate forum and social reports',
                          accentColor: const Color(0xFFFF5252),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ReportsScreen()),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.workspace_premium_rounded,
                          title: 'Billing & Plans',
                          subtitle: 'Premium subscriptions and revenue',
                          accentColor: const Color(0xFF00B0FF),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to exit the admin panel?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: accentColor, size: 24),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                  boxShadow: [
                    BoxShadow(color: accentColor.withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 1),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white24,
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFFF5252), size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Sync Error',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  message,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
