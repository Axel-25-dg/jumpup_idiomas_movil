import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/domain/model/classroom_model.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
<<<<<<< HEAD
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/providers/dashboard_teacher_provider.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/widgets/neon_button.dart';
=======
import 'package:jumpup_app/presentation/providers/correcciones/classroom_provider.dart';
import 'package:jumpup_app/presentation/providers/correcciones/stats_provider.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/classrooms_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/correcciones/exercises_screen.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';
>>>>>>> 787bdcc6a818689e258182d8f7b3b00e6fb7e200

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(teacherStatsProvider);
    final classroomsAsync = ref.watch(classroomsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFF0F111A), // Dark premium background
      body: Stack(
        children: [
          // Background Blobs for consistency with Student UI
          Positioned(top: -100, left: -100, child: _blob(const Color(0xFF7C4DFF), 300)),
          Positioned(bottom: -50, right: -50, child: _blob(const Color(0xFF00B4DB), 250)),
          
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
=======
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
>>>>>>> 787bdcc6a818689e258182d8f7b3b00e6fb7e200
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
<<<<<<< HEAD
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF00B4DB)]),
                                  shape: BoxShape.circle,
                                ),
                                child: profileAsync.when(
                                  loading: () => const CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Color(0xFF1E1E2A),
                                      child: CircularProgressIndicator(color: Color(0xFF7C4DFF), strokeWidth: 2)),
                                  error: (_, __) => const CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Color(0xFF1E1E2A),
                                      child: Icon(Icons.person_rounded, color: Colors.white)),
                                  data: (p) => CircleAvatar(
                                    radius: 24,
                                    backgroundColor: const Color(0xFF1E1E2A),
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
<<<<<<< HEAD
                                const Icon(Icons.school_outlined,
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
=======
                                Text('Próxima Clase',
                                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white54)),
                                const SizedBox(height: 4),
                                Text('Inglés B1 - Conversación',
                                    style: AppTextStyles.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                NeonButton(
                                  text: 'Ver Videotutorías',
                                  onPressed: () => context.push(AppRoutes.teacherLiveSessions),
>>>>>>> main
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
=======
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
>>>>>>> 787bdcc6a818689e258182d8f7b3b00e6fb7e200
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
                            color: const Color(0xFF7C4DFF),
                          ),
                          const SizedBox(width: 12),
                          _TeacherStatBadge(
                            icon: Icons.people_alt_rounded,
                            label: 'Alumnos',
                            value: '${stats.totalAlumnos}',
                            color: const Color(0xFF00B4DB),
                          ),
                          const SizedBox(width: 12),
                          _TeacherStatBadge(
                            icon: Icons.menu_book_rounded,
                            label: 'Cursos',
                            value: '${stats.totalCursos}',
                            color: const Color(0xFFF5576C),
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
<<<<<<< HEAD
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
            title: Text('Cerrar Sesión', style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Text('¿Seguro que quieres salir del portal?', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar', style: AppTextStyles.labelLarge.copyWith(color: Colors.white38))),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF5252), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go(AppRoutes.login);
                },
                child: const Text('Salir'),
              ),
            ],
=======
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
>>>>>>> 787bdcc6a818689e258182d8f7b3b00e6fb7e200
          ),
        ),
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
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
<<<<<<< HEAD
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white54, fontWeight: FontWeight.bold)),
=======
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
>>>>>>> 787bdcc6a818689e258182d8f7b3b00e6fb7e200
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
<<<<<<< HEAD
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                      color: color, fontWeight: FontWeight.w900)),
=======
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
>>>>>>> 787bdcc6a818689e258182d8f7b3b00e6fb7e200
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassroomTile extends StatelessWidget {
<<<<<<< HEAD
  const _ClassroomTile({required this.classroom, required this.onTap});
  final ClassroomModel classroom;
=======
  const _ClassroomTile({
    required this.classroom,
    required this.onTap,
  });
  final dynamic classroom;
>>>>>>> 787bdcc6a818689e258182d8f7b3b00e6fb7e200
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
<<<<<<< HEAD
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
=======
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.school_rounded, color: Color(0xFF7C4DFF), size: 24),
>>>>>>> main
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
