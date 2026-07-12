import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/correcciones/stats_provider.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/announcements_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/certificate_admin_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/classrooms_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/courses_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/exercises_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/languages_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/lesson_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/modules_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/reports_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/resources_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/suscription_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/users_screen.dart';
import 'package:jumpup_app/theme/app_theme.dart';


class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Panel de Administración',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                authState.user?.email ?? 'admin@jumpup.com',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
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
              onRefresh: () async {
                ref.invalidate(adminStatsProvider);
                await ref.read(adminStatsProvider.future);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Métricas
                    Text(
                      'Resumen de la plataforma',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    statsAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      ),
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
                            title: 'Total Usuarios',
                            value: stats.totalUsers,
                            icon: Icons.people_alt_rounded,
                            gradient: const LinearGradient(colors: [
                              Color(0xFF1565C0),
                              Color(0xFF1E88E5)
                            ]),
                            subtitle: 'Registrados',
                          ),
                          _MetricCard(
                            title: 'Profesores',
                            value: stats.teachers,
                            icon: Icons.school_rounded,
                            gradient: const LinearGradient(colors: [
                              Color(0xFF00897B),
                              Color(0xFF26A69A)
                            ]),
                            subtitle: 'Activos',
                          ),
                          _MetricCard(
                            title: 'Estudiantes',
                            value: stats.students,
                            icon: Icons.person_rounded,
                            gradient: const LinearGradient(colors: [
                              Color(0xFF5E35B1),
                              Color(0xFF7E57C2)
                            ]),
                            subtitle: 'Inscritos',
                          ),
                          _MetricCard(
                            title: 'Cursos',
                            value: stats.courses,
                            icon: Icons.menu_book_rounded,
                            gradient: const LinearGradient(colors: [
                              Color(0xFF2E7D32),
                              Color(0xFF43A047)
                            ]),
                            subtitle: 'Publicados',
                          ),
                          _MetricCard(
                            title: 'Aulas',
                            value: stats.classrooms,
                            icon: Icons.class_rounded,
                            gradient: const LinearGradient(colors: [
                              Color(0xFFE65100),
                              Color(0xFFFB8C00)
                            ]),
                            subtitle: 'Activas',
                          ),
                          _MetricCard(
                            title: 'Suscripciones',
                            value: stats.subscriptions,
                            icon: Icons.workspace_premium_rounded,
                            gradient: const LinearGradient(colors: [
                              Color(0xFF6A1B9A),
                              Color(0xFFAB47BC)
                            ]),
                            subtitle: 'Premium',
                          ),
                          _MetricCard(
                            title: 'Pagos',
                            value: stats.payments,
                            icon: Icons.payment_rounded,
                            gradient: const LinearGradient(colors: [
                              Color(0xFF00695C),
                              Color(0xFF00ACC1)
                            ]),
                            subtitle: 'Procesados',
                          ),
                          _MetricCard(
                            title: 'Certificados',
                            value: stats.certificates,
                            icon: Icons.verified_rounded,
                            gradient: const LinearGradient(colors: [
                              Color(0xFF283593),
                              Color(0xFF3F51B5)
                            ]),
                            subtitle: 'Emitidos',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Gestión ──────────────────────────────────────
                    Text(
                      'Gestión',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ Usuarios
                    _ActionCard(
                      icon: Icons.people_alt_rounded,
                      title: 'Gestión de Usuarios',
                      subtitle: 'Activar, desactivar y modificar roles',
                      color: AppColors.primary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UsersScreen(),
                        ),
                      ),
                    ),

                    // ✅ Idiomas
                    _ActionCard(
                      icon: Icons.translate_rounded,
                      title: 'Gestión de Idiomas',
                      subtitle: 'Administrar idiomas disponibles',
                      color: const Color(0xFF0D47A1),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LanguagesScreen(),
                        ),
                      ),
                    ),

                    // ✅ Cursos
                    _ActionCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Gestión de Cursos',
                      subtitle: 'Crear y gestionar el catálogo de cursos',
                      color: const Color(0xFF2E7D32),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CoursesScreen(),
                        ),
                      ),
                    ),

                    // ✅ Módulos
                    _ActionCard(
                      icon: Icons.view_module_rounded,
                      title: 'Gestión de Módulos',
                      subtitle: 'Crear y gestionar módulos por curso',
                      color: const Color(0xFF6A1B9A),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ModulesScreen(),
                        ),
                      ),
                    ),

                    // ✅ Lecciones
                    _ActionCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Gestión de Lecciones',
                      subtitle: 'Crear y gestionar lecciones por módulo',
                      color: const Color(0xFF00897B),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LessonsScreen(),
                        ),
                      ),
                    ),

                    // ✅ Ejercicios
                    _ActionCard(
                      icon: Icons.edit_note_rounded,
                      title: 'Gestión de Ejercicios',
                      subtitle: 'Crear y gestionar ejercicios por lección',
                      color: const Color(0xFF7B1FA2),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ExercisesScreen(),
                        ),
                      ),
                    ),

                    // ✅ Aulas
                    _ActionCard(
                      icon: Icons.class_rounded,
                      title: 'Gestión de Aulas',
                      subtitle: 'Crear y gestionar aulas',
                      color: const Color(0xFFE65100),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ClassroomsScreen(),
                        ),
                      ),
                    ),

                    // ✅ Recursos
                    _ActionCard(
                      icon: Icons.folder_rounded,
                      title: 'Gestión de Recursos',
                      subtitle: 'Subir y gestionar materiales didácticos',
                      color: const Color(0xFF00BCD4),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ResourcesScreen(),
                        ),
                      ),
                    ),

                    // ✅ Certificados (NUEVO)
                    _ActionCard(
                      icon: Icons.verified_rounded,
                      title: 'Gestión de Certificados',
                      subtitle: 'Emitir y gestionar certificados MCER',
                      color: const Color(0xFF9C27B0),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CertificatesAdminScreen(),
                        ),
                      ),
                    ),

                    // ✅ Anuncios
                    _ActionCard(
                      icon: Icons.campaign_rounded,
                      title: 'Anuncios y Avisos',
                      subtitle: 'Publicar comunicados a toda la plataforma',
                      color: const Color(0xFFE65100),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AnnouncementsScreen(),
                        ),
                      ),
                    ),

                    // ✅ Reportes
                    _ActionCard(
                      icon: Icons.flag_rounded,
                      title: 'Reportes de Contenido',
                      subtitle: 'Moderar reportes del foro y feed social',
                      color: AppColors.error,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReportsScreen(),
                        ),
                      ),
                    ),

                    // ✅ Suscripciones
                    _ActionCard(
                      icon: Icons.workspace_premium_rounded,
                      title: 'Suscripciones y Pagos',
                      subtitle: 'Gestionar planes premium y facturación',
                      color: const Color(0xFF6A1B9A),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionsScreen(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir del panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.subtitle,
  });

  final String title;
  final int value;
  final IconData icon;
  final LinearGradient gradient;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            offset: Offset(0, 2),
          ),
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
        title: Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: color,
        ),
        onTap: onTap,
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
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}