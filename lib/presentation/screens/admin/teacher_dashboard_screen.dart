import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/correcciones/classroom_provider.dart';
import 'package:jumpup_app/presentation/providers/correcciones/stats_provider.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/classrooms_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/exercises_screen.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(teacherStatsProvider);
    final classroomsAsync = ref.watch(classroomsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00695C), Color(0xFF0288D1)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          child: Text(
                            authState.user?.name.isNotEmpty ==
                                    true // ✅ Quitar '?'
                                ? authState.user!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Panel del Profesor',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                authState.user?.email ?? 'profesor@jumpup.com',
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

          // ── Stats ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: statsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Error: $e',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                data: (stats) => Row(
                  children: [
                    _TeacherStatBadge(
                      icon: Icons.class_rounded,
                      label: 'Mis Aulas',
                      value: '${stats.totalAulas}',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF29B6F6)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _TeacherStatBadge(
                      icon: Icons.people_rounded,
                      label: 'Estudiantes',
                      value: '${stats.totalAlumnos}',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00695C), Color(0xFF26A69A)],
                      ),
                    ),
                    if (stats.totalCursos > 0) ...[
                      const SizedBox(width: 12),
                      _TeacherStatBadge(
                        icon: Icons.menu_book_rounded,
                        label: 'Cursos',
                        value: '${stats.totalCursos}',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Acciones rápidas ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acciones rápidas',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _TeacherQuickBtn(
                        icon: Icons.add_rounded,
                        label: 'Nueva Aula',
                        color: AppColors.primary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ClassroomsScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _TeacherQuickBtn(
                        icon: Icons.quiz_rounded,
                        label: 'Ejercicios',
                        color: const Color(0xFF2E7D32),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ExercisesScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _TeacherQuickBtn(
                        icon: Icons.school_rounded,
                        label: 'Mis Aulas',
                        color: const Color(0xFFE65100),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ClassroomsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Mis aulas ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Mis Aulas',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ClassroomsScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nueva'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  classroomsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Error al cargar aulas: $e'),
                    ),
                    data: (classrooms) {
                      if (classrooms.isEmpty) {
                        return EmptyState(
                          title: 'Sin aulas creadas',
                          subtitle: 'Crea tu primera aula para comenzar',
                          icon: Icons.class_rounded,
                          buttonText: 'Crear aula',
                          onButtonPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ClassroomsScreen(),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: classrooms.map((c) {
                          return _ClassroomTile(
                            classroom: c,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ClassroomsScreen(),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
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
          PrimaryButton(
            label: 'Cerrar sesión',
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _TeacherStatBadge extends StatelessWidget {
  const _TeacherStatBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });
  final IconData icon;
  final String label;
  final String value;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherQuickBtn extends StatelessWidget {
  const _TeacherQuickBtn({
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassroomTile extends StatelessWidget {
  const _ClassroomTile({
    required this.classroom,
    required this.onTap,
  });
  final dynamic classroom;
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
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.class_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        title: Text(
          classroom.name,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${classroom.totalStudents} estudiantes',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: classroom.isActive
                ? AppColors.success.withValues(alpha: 0.12)
                : AppColors.textHint.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            classroom.isActive ? 'Activa' : 'Inactiva',
            style: TextStyle(
              color: classroom.isActive
                  ? AppColors.success
                  : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
