import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/providers/dashboard_teacher_provider.dart';
import 'package:jumpup_app/presentation/screens/admin/create_classroom_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_exercise_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/manage_classroom_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/upload_resource_screen.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final classroomsAsync = ref.watch(classroomsListProvider);
    final profileAsync = ref.watch(userProfileProvider);

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
                        profileAsync.when(
                          loading: () => const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white)),
                          error: (_, __) => const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white)),
                          data: (p) => CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white24,
                            backgroundImage: p.avatarUrl != null
                                ? NetworkImage(p.avatarUrl!)
                                : null,
                            child: p.avatarUrl == null
                                ? Text(
                                    p.username.isNotEmpty
                                        ? p.username[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Panel del Profesor',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              profileAsync.maybeWhen(
                                data: (p) => Text(p.email,
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 12)),
                                orElse: () => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              color: Colors.white70),
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
                        child: CircularProgressIndicator())),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text('Error: $e',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error)),
                ),
                data: (stats) => Row(
                  children: [
                    _TeacherStatBadge(
                      icon: Icons.class_rounded,
                      label: 'Mis Aulas',
                      value: '${stats.totalAulas}',
                      gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF29B6F6)]),
                    ),
                    const SizedBox(width: 12),
                    _TeacherStatBadge(
                      icon: Icons.people_rounded,
                      label: 'Estudiantes',
                      value: '${stats.totalAlumnos}',
                      gradient: const LinearGradient(
                          colors: [Color(0xFF00695C), Color(0xFF26A69A)]),
                    ),
                    if (stats.totalCursos > 0) ...[
                      const SizedBox(width: 12),
                      _TeacherStatBadge(
                        icon: Icons.menu_book_rounded,
                        label: 'Cursos',
                        value: '${stats.totalCursos}',
                        gradient: const LinearGradient(
                            colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
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
                  Text('Acciones rápidas',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _TeacherQuickBtn(
                        icon: Icons.add_rounded,
                        label: 'Nueva Aula',
                        color: AppColors.primary,
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CreateClassroomScreen())),
                      ),
                      const SizedBox(width: 10),
                      _TeacherQuickBtn(
                        icon: Icons.quiz_rounded,
                        label: 'Ejercicio',
                        color: const Color(0xFF2E7D32),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CreateExerciseScreen())),
                      ),
                      const SizedBox(width: 10),
                      _TeacherQuickBtn(
                        icon: Icons.upload_file_rounded,
                        label: 'Recurso',
                        color: const Color(0xFFE65100),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const UploadResourceScreen())),
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
                      Text('Mis Aulas',
                          style: AppTextStyles.titleMedium
                              .copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CreateClassroomScreen())),
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
                            child: CircularProgressIndicator())),
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
                        return Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.school_outlined,
                                    size: 48, color: AppColors.textHint),
                                const SizedBox(height: 10),
                                Text('Sin aulas creadas',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 14),
                                FilledButton.icon(
                                  onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const CreateClassroomScreen())),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Crear aula'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: classrooms
                            .map((c) => _ClassroomTile(
                                classroom: c,
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => ManageClassroomScreen(
                                            classroomId: c.id)))))
                            .toList(),
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
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
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
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
              Text(label,
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassroomTile extends StatelessWidget {
  const _ClassroomTile({required this.classroom, required this.onTap});
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
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2)),
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
          child: const Icon(Icons.class_rounded,
              color: AppColors.primary, size: 22),
        ),
        title: Text(classroom.name,
            style:
                AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text('${classroom.totalStudents} estudiantes',
            style: AppTextStyles.bodySmall),
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
