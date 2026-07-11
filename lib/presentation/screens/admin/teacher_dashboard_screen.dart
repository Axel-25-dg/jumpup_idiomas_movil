import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/screens/admin/create_classroom_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_exercise_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_module_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_lesson_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/manage_classroom_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/resource_library_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/teacher_inbox_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/manage_live_sessions_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/teacher_profile_screen.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/widgets/neon_button.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  int _currentIndex = 0;

  final _pages = const [
    _TeacherHomeTab(),
    _TeacherCoursesTab(),
    _TeacherSessionsTab(),
    TeacherInboxScreen(),
    TeacherProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _TeacherBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Bottom Navigation Bar ────────────────────────────────────────────────────

class _TeacherBottomNav extends StatelessWidget {
  const _TeacherBottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, Icons.home_outlined, 'Inicio'),
      (Icons.library_books_rounded, Icons.library_books_outlined, 'Cursos'),
      (Icons.videocam_rounded, Icons.videocam_outlined, 'Sesiones'),
      (Icons.chat_rounded, Icons.chat_outlined, 'Mensajes'),
      (Icons.person_rounded, Icons.person_outlined, 'Perfil'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final (activeIcon, inactiveIcon, label) = items[i];
              final isSelected = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? activeIcon : inactiveIcon,
                        color: isSelected
                            ? const Color(0xFF7C4DFF)
                            : const Color(0xFF757575),
                        size: 26,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? const Color(0xFF7C4DFF)
                              : const Color(0xFF757575),
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

// ── Tab 0: Inicio (Dashboard) ─────────────────────────────────────────────────

class _TeacherHomeTab extends ConsumerWidget {
  const _TeacherHomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classroomsAsync = ref.watch(classroomsListProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final coursesAsync = ref.watch(adminCoursesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF1A1828),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1828), Color(0xFF0F0E1A)],
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
                              child: CircularProgressIndicator(
                                  color: Color(0xFF7C4DFF))),
                          error: (error, _) => const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white12,
                              child: Icon(Icons.person, color: Colors.white)),
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
                              const Text('Portal del Profesor',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              profileAsync.maybeWhen(
                                data: (p) => Text(p.email,
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 13)),
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
                      child: const Icon(Icons.videocam_rounded,
                          color: Color(0xFF7C4DFF), size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Próxima Clase',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 13)),
                          const SizedBox(height: 4),
                          const Text('Inglés B1 - Conversación',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          NeonButton(
                            text: 'Ver Videotutorías',
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) =>
                                      const ManageLiveSessionsScreen()));
                            },
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
              child: classroomsAsync.when(
                loading: () => const Center(
                    child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                            color: Color(0xFF7C4DFF)))),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3)),
                  ),
                  child: Text('Error al cargar métricas: $e',
                      style: const TextStyle(color: Colors.redAccent)),
                ),
                data: (classrooms) => Row(
                  children: [
                    _TeacherStatBadge(
                      icon: Icons.class_rounded,
                      label: 'Aulas',
                      value: '${classrooms.length}',
                      gradient: const LinearGradient(
                          colors: [Color(0xFF7C4DFF), Color(0xFF534BAE)]),
                    ),
                    const SizedBox(width: 12),
                    _TeacherStatBadge(
                      icon: Icons.menu_book_rounded,
                      label: 'Cursos',
                      value: coursesAsync.valueOrNull?.length.toString() ?? '0',
                      gradient: const LinearGradient(
                          colors: [Color(0xFFF093FB), Color(0xFFF5576C)]),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Acciones rápidas (Grid) ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Accesos Rápidos',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TeacherQuickBtn(
                          icon: Icons.add_business_rounded,
                          label: 'Nueva Aula',
                          color: const Color(0xFF00E676),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const CreateClassroomScreen())),
                        ),
                        const SizedBox(width: 12),
                        _TeacherQuickBtn(
                          icon: Icons.quiz_rounded,
                          label: 'Ejercicio',
                          color: const Color(0xFFFFD54F),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const CreateExerciseScreen())),
                        ),
                        const SizedBox(width: 12),
                        _TeacherQuickBtn(
                          icon: Icons.view_module_rounded,
                          label: 'Módulo',
                          color: const Color(0xFF4FC3F7),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const CreateModuleScreen())),
                        ),
                        const SizedBox(width: 12),
                        _TeacherQuickBtn(
                          icon: Icons.play_lesson_rounded,
                          label: 'Lección',
                          color: const Color(0xFFFF8A65),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const CreateLessonScreen())),
                        ),
                        const SizedBox(width: 12),
                        _TeacherQuickBtn(
                          icon: Icons.folder_open_rounded,
                          label: 'Recursos',
                          color: const Color(0xFFAB47BC),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ResourceLibraryScreen())),
                        ),
                        const SizedBox(width: 12),
                        _TeacherQuickBtn(
                          icon: Icons.chat_rounded,
                          label: 'Mensajes',
                          color: const Color(0xFF66BB6A),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const TeacherInboxScreen())),
                        ),
                      ],
                    ),
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
                      const Text('Gestión de Aulas',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    const CreateClassroomScreen())),
                        icon: const Icon(Icons.add,
                            size: 18, color: Color(0xFF7C4DFF)),
                        label: const Text('Crear',
                            style: TextStyle(color: Color(0xFF7C4DFF))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  classroomsAsync.when(
                    loading: () => const Center(
                        child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                                color: Color(0xFF7C4DFF)))),
                    error: (e, _) => GlassContainer(
                      opacity: 0.05,
                      child: Text('Error al cargar aulas: $e',
                          style: const TextStyle(color: Colors.redAccent)),
                    ),
                    data: (classrooms) {
                      if (classrooms.isEmpty) {
                        return GlassContainer(
                          opacity: 0.05,
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.school_outlined,
                                    size: 48, color: Colors.white30),
                                const SizedBox(height: 12),
                                const Text('No tienes aulas asignadas',
                                    style:
                                        TextStyle(color: Colors.white54)),
                                const SizedBox(height: 16),
                                NeonButton(
                                  text: 'Crear Aula',
                                  onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const CreateClassroomScreen())),
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

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Cerrar sesión',
            style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres salir del portal?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Tab 1: Cursos ─────────────────────────────────────────────────────────────

class _TeacherCoursesTab extends ConsumerWidget {
  const _TeacherCoursesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(adminCoursesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        elevation: 0,
        title: const Text('Mis Cursos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: coursesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.redAccent))),
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_outlined,
                      size: 64, color: Colors.white30),
                  SizedBox(height: 12),
                  Text('No tienes cursos creados aún.',
                      style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, i) {
              final course = courses[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  opacity: 0.08,
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.menu_book_rounded,
                            color: Color(0xFF7C4DFF)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              '${course.languageName} • ${course.difficultyLevel}',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 16, color: Colors.white38),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Tab 2: Sesiones en Vivo ──────────────────────────────────────────────────

class _TeacherSessionsTab extends StatelessWidget {
  const _TeacherSessionsTab();

  @override
  Widget build(BuildContext context) {
    return const ManageLiveSessionsScreen(embedded: true);
  }
}

// ── Componentes Reutilizables ─────────────────────────────────────────────────

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
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
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
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        opacity: 0.05,
        blur: 10,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
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
                child: const Icon(Icons.class_rounded,
                    color: Color(0xFF7C4DFF), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(classroom.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${classroom.accessCode}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
