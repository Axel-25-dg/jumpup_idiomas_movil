import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/admin_stats_provider.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/screens/admin/announcements_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/subscriptions_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/users_list_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_course_screen.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(top: -100, right: -100, child: _blob(const Color(0xFF6A11CB), 300)),
          Positioned(bottom: -50, left: -50, child: _blob(const Color(0xFF2575FC), 250)),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header Premium ──────────────────────────────────────
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                                  shape: BoxShape.circle,
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
                                  children: [
                                    const Text('Panel Admin',
                                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                                    Text(authState.user?.email ?? 'admin@jumpup.com',
                                        style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout_rounded, color: Colors.white38),
                                onPressed: () => _confirmLogout(context, ref),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Métricas con Glassmorphism ────────────────────────────────
              SliverToBoxAdapter(
                child: RefreshIndicator(
                  color: const Color(0xFF2575FC),
                  backgroundColor: const Color(0xFF1E1E2A),
                  onRefresh: () async {
                    ref.invalidate(adminStatsProvider);
                    await ref.read(adminStatsProvider.future);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resumen Global',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        statsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2575FC))),
                          error: (e, _) => _ErrorCard(message: e.toString()),
                          data: (stats) => GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.5,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _MetricCard(title: 'Usuarios', value: stats.totalUsers, icon: Icons.people_rounded, color: const Color(0xFF6A11CB)),
                              _MetricCard(title: 'Profesores', value: stats.teachers, icon: Icons.school_rounded, color: const Color(0xFF2575FC)),
                              _MetricCard(title: 'Cursos', value: stats.courses, icon: Icons.auto_stories_rounded, color: const Color(0xFF00C853)),
                              _MetricCard(title: 'Ingresos', value: stats.payments, icon: Icons.payments_rounded, color: const Color(0xFFFFAB00)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text('Gestión de Plataforma',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _ActionCard(
                          icon: Icons.people_alt_rounded,
                          title: 'Usuarios',
                          subtitle: 'Moderar roles y acceso',
                          color: const Color(0xFF6A11CB),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersListScreen())),
                        ),
                        _ActionCard(
                          icon: Icons.menu_book_rounded,
                          title: 'Catálogo',
                          subtitle: 'Cursos y contenidos',
                          color: const Color(0xFF2575FC),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCourseScreen())),
                        ),
                        _ActionCard(
                          icon: Icons.campaign_rounded,
                          title: 'Comunicación',
                          subtitle: 'Anuncios masivos',
                          color: const Color(0xFFFFAB00),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen())),
                        ),
                        _ActionCard(
                          icon: Icons.workspace_premium_rounded,
                          title: 'Finanzas',
                          subtitle: 'Suscripciones y pagos',
                          color: const Color(0xFF00C853),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen())),
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

  Widget _blob(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: 0.1),
      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 100)],
    ),
  );

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, a1, a2) => Container(),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1E1E2A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            content: const Text('¿Estás seguro que deseas salir?', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white38))),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go(AppRoutes.login);
                },
                child: const Text('Salir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(value.toString(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title,
            style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        subtitle: Text(subtitle,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
=======
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        padding: EdgeInsets.zero,
>>>>>>> main
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
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
