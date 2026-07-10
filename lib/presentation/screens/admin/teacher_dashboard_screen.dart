import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/domain/model/classroom_model.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/providers/dashboard_teacher_provider.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/widgets/neon_button.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final classroomsAsync = ref.watch(classroomsListProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A), // Dark premium background
      body: Stack(
        children: [
          // Background Blobs for consistency with Student UI
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withValues(alpha: 0.1), blurRadius: 100)],
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
                color: const Color(0xFF00B4DB).withValues(alpha: 0.1),
                boxShadow: [BoxShadow(color: const Color(0xFF00B4DB).withValues(alpha: 0.1), blurRadius: 100)],
              ),
            ),
          ),
          RefreshIndicator(
            color: const Color(0xFF7C4DFF),
            backgroundColor: const Color(0xFF1A1828),
            onRefresh: () async {
              ref.invalidate(statsProvider);
              ref.invalidate(classroomsListProvider);
              ref.invalidate(userProfileProvider);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                // ── Header ───────────────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1A1828), Colors.transparent],
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
                                    backgroundColor: Colors.white12,
                                    child: CircularProgressIndicator(color: Color(0xFF7C4DFF), strokeWidth: 2)),
                                error: (_, __) => const CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white12,
                                    child: Icon(Icons.person_rounded, color: Colors.white)),
                                data: (p) => CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.white12,
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
                                    Text('Portal del Profesor',
                                        style: AppTextStyles.titleLarge.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900)),
                                    profileAsync.maybeWhen(
                                      data: (p) => Text(p.email,
                                          style: AppTextStyles.bodySmall.copyWith(
                                              color: Colors.white54)),
                                      orElse: () => const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout_rounded, color: Colors.white70),
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

                // ── Widget Próxima Clase ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: GlassContainer(
                      blur: 15.0,
                      opacity: 0.1,
                      padding: const EdgeInsets.all(20),
                      borderRadius: BorderRadius.circular(24),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.videocam_rounded, color: Color(0xFF7C4DFF), size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Próxima Clase',
                                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white54)),
                                const SizedBox(height: 4),
                                Text('Inglés B1 - Conversación',
                                    style: AppTextStyles.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                NeonButton(
                                  text: 'Ver Videotutorías',
                                  onPressed: () => context.push(AppRoutes.teacherLiveSessions),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Stats (KPIs) ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: statsAsync.when(
                      loading: () => const Center(
                          child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(color: Color(0xFF7C4DFF)))),
                      error: (e, _) => Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                        ),
                        child: Text('Error al cargar métricas: $e',
                            style: const TextStyle(color: Colors.redAccent)),
                      ),
                      data: (stats) => Row(
                        children: [
                          _TeacherStatBadge(
                            icon: Icons.school_rounded,
                            label: 'Aulas',
                            value: '${stats.totalAulas}',
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _TeacherStatBadge(
                            icon: Icons.people_alt_rounded,
                            label: 'Alumnos',
                            value: '${stats.totalAlumnos}',
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _TeacherStatBadge(
                            icon: Icons.menu_book_rounded,
                            label: 'Cursos',
                            value: '${stats.totalCursos}',
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Acciones rápidas (Grid) ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Accesos Rápidos',
                            style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.1,
                          children: [
                            _TeacherQuickBtn(
                              icon: Icons.add_business_rounded,
                              label: 'Nueva Aula',
                              color: const Color(0xFF00E676),
                              onTap: () => context.push(AppRoutes.teacherCreateClassroom),
                            ),
                            _TeacherQuickBtn(
                              icon: Icons.quiz_rounded,
                              label: 'Ejercicio',
                              color: const Color(0xFFFFD54F),
                              onTap: () => context.push(AppRoutes.teacherCreateExercise),
                            ),
                            _TeacherQuickBtn(
                              icon: Icons.view_module_rounded,
                              label: 'Módulo',
                              color: const Color(0xFF4FC3F7),
                              onTap: () => context.push(AppRoutes.teacherCreateModule),
                            ),
                            _TeacherQuickBtn(
                              icon: Icons.play_lesson_rounded,
                              label: 'Lección',
                              color: const Color(0xFFFF8A65),
                              onTap: () => context.push(AppRoutes.teacherCreateLesson),
                            ),
                            _TeacherQuickBtn(
                              icon: Icons.folder_open_rounded,
                              label: 'Recursos',
                              color: const Color(0xFFAB47BC),
                              onTap: () => context.push(AppRoutes.teacherResources),
                            ),
                            _TeacherQuickBtn(
                              icon: Icons.chat_bubble_rounded,
                              label: 'Mensajes',
                              color: const Color(0xFF66BB6A),
                              onTap: () => context.push(AppRoutes.teacherInbox),
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
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Gestión de Aulas',
                                style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                            TextButton.icon(
                              onPressed: () => context.push(AppRoutes.teacherCreateClassroom),
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF7C4DFF)),
                              label: Text('Crear', style: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF7C4DFF))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        classroomsAsync.when(
                          loading: () => const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(color: Color(0xFF7C4DFF)))),
                          error: (e, _) => GlassContainer(
                            opacity: 0.05,
                            child: Text('Error al cargar aulas: $e', style: const TextStyle(color: Colors.redAccent)),
                          ),
                          data: (classrooms) {
                            if (classrooms.isEmpty) {
                              return GlassContainer(
                                opacity: 0.05,
                                padding: const EdgeInsets.all(32),
                                borderRadius: BorderRadius.circular(24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.school_outlined, size: 48, color: Colors.white30),
                                      const SizedBox(height: 12),
                                      Text('No tienes aulas asignadas',
                                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
                                      const SizedBox(height: 24),
                                      NeonButton(
                                        text: 'Crear Aula',
                                        onPressed: () => context.push(AppRoutes.teacherCreateClassroom),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: classrooms.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final c = classrooms[index];
                                return _ClassroomTile(
                                  classroom: c,
                                  onTap: () => context.push(AppRoutes.teacherManageClassroom.replaceAll(':id', c.id.toString())),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
        backgroundColor: const Color(0xFF1A1D2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Cerrar sesión', style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('¿Seguro que quieres salir del portal?', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: AppTextStyles.labelLarge.copyWith(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Widgets Secundarios ───────────────────────────────────────────────────────

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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white70, fontWeight: FontWeight.bold)),
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
        child: GlassContainer(
          opacity: 0.05,
          blur: 10,
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                      color: color, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassroomTile extends StatelessWidget {
  const _ClassroomTile({required this.classroom, required this.onTap});
  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        opacity: 0.08,
        blur: 8,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.school_rounded, color: Color(0xFF7C4DFF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(classroom.name,
                      style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${classroom.studentsCount} estudiantes',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: classroom.isActive
                    ? const Color(0xFF00E676).withValues(alpha: 0.15)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: classroom.isActive ? const Color(0xFF00E676).withValues(alpha: 0.3) : Colors.white10,
                ),
              ),
              child: Text(
                classroom.isActive ? 'Activa' : 'Inactiva',
                style: AppTextStyles.labelSmall.copyWith(
                  color: classroom.isActive ? const Color(0xFF00E676) : Colors.white38,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
