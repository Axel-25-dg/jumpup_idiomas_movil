import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/presentation/screens/admin/create_classroom_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_exercise_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_module_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_lesson_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/manage_classroom_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/resource_library_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/teacher_inbox_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/manage_live_sessions_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/teacher_profile_screen.dart';
import 'package:jumpup_app/presentation/providers/stats_provider.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/data/remote/websocket_service.dart';
import 'package:jumpup_app/presentation/screens/social/social_media_shell.dart';


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
    SocialMediaShell(),
    TeacherProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
      (Icons.forum_rounded, Icons.forum_outlined, 'Social'),
      (Icons.person_rounded, Icons.person_outlined, 'Perfil'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 70,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1828).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
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
                              : Colors.white38,
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
                                : Colors.white38,
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
      ),
    );
  }
}

// ── Tab 0: Inicio (Dashboard) ─────────────────────────────────────────────────

class _TeacherHomeTab extends ConsumerStatefulWidget {
  const _TeacherHomeTab();

  @override
  ConsumerState<_TeacherHomeTab> createState() => _TeacherHomeTabState();
}

class _TeacherHomeTabState extends ConsumerState<_TeacherHomeTab> {
  WebSocketService? _ws;
  final List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _connectWS();
  }

  Future<void> _connectWS() async {
    try {
      _ws = WebSocketService(path: 'monitoring');
      await _ws!.connect();
      _ws!.messages.listen(
        (data) {
          if (mounted) {
            setState(() {
              _logs.insert(0, data);
              if (_logs.length > 20) _logs.removeLast();
            });
          }
        },
        onError: (e) => debugPrint('WS Listen Error: $e'),
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('WS Connection Error: $e');
    }
  }

  @override
  void dispose() {
    _ws?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classroomsAsync = ref.watch(classroomsListProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final coursesAsync = ref.watch(adminCoursesProvider);
    final statsAsync = ref.watch(teacherStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      body: Stack(
        children: [
          // Background Decorative Blobs
          Positioned(
            top: -100,
            right: -100,
            child: _blob(const Color(0xFF7C4DFF), 300),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: _blob(const Color(0xFF00E5FF), 250),
          ),

          RefreshIndicator(
            color: const Color(0xFF7C4DFF),
            backgroundColor: const Color(0xFF1E1E2A),
            onRefresh: () async {
              ref.invalidate(classroomsListProvider);
              ref.invalidate(adminCoursesProvider);
              ref.invalidate(teacherStatsProvider);
              ref.invalidate(userProfileProvider);
              
              // Wait for completion if needed
              await Future.wait([
                ref.read(classroomsListProvider.future),
                ref.read(adminCoursesProvider.notifier).fetchCourses(),
                ref.read(teacherStatsProvider.future),
              ]);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header Premium ──────────────────────────────────────────
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
                                profileAsync.when(
                                  loading: () => Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white10,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF7C4DFF),
                                      ),
                                    ),
                                  ),
                                  error: (error, _) => const CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Colors.white12,
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  data: (p) => Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: const Color(0xFF1E1E2A),
                                  backgroundImage: (p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
                                      ? NetworkImage(p.avatarUrl!)
                                      : null,
                                  onBackgroundImageError: (p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
                                      ? (exception, stackTrace) => debugPrint('Avatar Image Error: $exception')
                                      : null,
                                  child: (p.avatarUrl == null || p.avatarUrl!.isEmpty)
                                          ? Text(
                                              (p.username.isNotEmpty)
                                                  ? p.username[0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Teacher Portal',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      profileAsync.maybeWhen(
                                        data: (p) => Text(
                                          p.username.toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF00E5FF),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        orElse: () => const Text(
                                          'JUMPUP EDUCATOR',
                                          style: TextStyle(
                                            color: Color(0xFF00E5FF),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.logout_rounded,
                                      color: Colors.white38),
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

                // ── Stats (KPIs) con Glassmorphism ───────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: statsAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                      ),
                      error: (e, stack) {
                        debugPrint('Stats Error: $e\n$stack');
                        return _ErrorCard(message: 'Error cargando estadísticas');
                      },
                      data: (stats) => Row(
                        children: [
                          _TeacherStatBadge(
                            icon: Icons.class_rounded,
                            label: 'Classes',
                            value: '${stats.totalAulas}',
                            color: const Color(0xFF7C4DFF),
                          ),
                          const SizedBox(width: 12),
                          _TeacherStatBadge(
                            icon: Icons.people_rounded,
                            label: 'Students',
                            value: '${stats.totalAlumnos}',
                            color: const Color(0xFF00E5FF),
                          ),
                          const SizedBox(width: 12),
                          _TeacherStatBadge(
                            icon: Icons.menu_book_rounded,
                            label: 'Courses',
                            value: coursesAsync.valueOrNull?.length.toString() ?? '0',
                            color: const Color(0xFFFFAB00),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Activity Monitoring Section ──────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Live Activity',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_logs.isEmpty)
                          GlassContainer(
                            padding: const EdgeInsets.all(24),
                            borderRadius: BorderRadius.circular(20),
                            child: const Center(
                              child: Text(
                                'No recent activity monitored.',
                                style: TextStyle(color: Colors.white38, fontSize: 13),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _logs.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                return Container(
                                  width: 220,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: GlassContainer(
                                    padding: const EdgeInsets.all(12),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          log['type']?.toString().toUpperCase() ?? 'EVENT',
                                          style: const TextStyle(
                                            color: Color(0xFF00E5FF),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          log['message'] ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          log['time'] ?? 'Just now',
                                          style: const TextStyle(
                                            color: Colors.white24,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Acciones rápidas ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _TeacherQuickBtn(
                                icon: Icons.add_business_rounded,
                                label: 'New Class',
                                color: const Color(0xFF00E5FF),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const CreateClassroomScreen()),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _TeacherQuickBtn(
                                icon: Icons.quiz_rounded,
                                label: 'Exercise',
                                color: const Color(0xFFFFD54F),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const CreateExerciseScreen()),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _TeacherQuickBtn(
                                icon: Icons.view_module_rounded,
                                label: 'Module',
                                color: const Color(0xFF4FC3F7),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const CreateModuleScreen()),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _TeacherQuickBtn(
                                icon: Icons.play_lesson_rounded,
                                label: 'Lesson',
                                color: const Color(0xFFFF8A65),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const CreateLessonScreen()),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _TeacherQuickBtn(
                                icon: Icons.folder_open_rounded,
                                label: 'Resources',
                                color: const Color(0xFFAB47BC),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const ResourceLibraryScreen()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Classroom Monitoring ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Classroom Management',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CreateClassroomScreen()),
                          ),
                          icon: const Icon(Icons.add,
                              size: 18, color: Color(0xFF7C4DFF)),
                          label: const Text('Create',
                              style: TextStyle(color: Color(0xFF7C4DFF))),
                        ),
                      ],
                    ),
                  ),
                ),

                classroomsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                      ),
                    ),
                  ),
                  error: (e, stack) {
                    debugPrint('Classrooms Error: $e\n$stack');
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _ErrorCard(message: 'No se pudieron cargar las aulas'),
                      ),
                    );
                  },
                  data: (classrooms) {
                    if (classrooms.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GlassContainer(
                            opacity: 0.05,
                            padding: const EdgeInsets.all(32),
                            borderRadius: BorderRadius.circular(24),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.school_outlined,
                                      size: 48, color: Colors.white30),
                                  const SizedBox(height: 12),
                                  const Text('No classes assigned yet',
                                      style: TextStyle(color: Colors.white54)),
                                  const SizedBox(height: 20),
                                  PrimaryButton(
                                    label: 'Create First Class',
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const CreateClassroomScreen()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= classrooms.length) return null;
                            final c = classrooms[index];
                            return _ClassroomTile(
                              classroom: c,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ManageClassroomScreen(classroomId: c.id),
                                ),
                              ),
                            );
                          },
                          childCount: classrooms.length,
                        ),
                      ),
                    );
                  },
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
            content: const Text('¿Estás seguro que deseas salir del portal?', style: TextStyle(color: Colors.white70)),
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

// ── Tab 1: Cursos ─────────────────────────────────────────────────────────────

class _TeacherCoursesTab extends ConsumerWidget {
  const _TeacherCoursesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(adminCoursesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      body: Stack(
        children: [
          // Background Decorative Blobs
          Positioned(
            top: -100,
            left: -100,
            child: _blob(const Color(0xFF7C4DFF), 300),
          ),
          Positioned(
            bottom: 200,
            right: -50,
            child: _blob(const Color(0xFF00E5FF), 250),
          ),

          RefreshIndicator(
            color: const Color(0xFF7C4DFF),
            onRefresh: () async => ref.invalidate(adminCoursesProvider),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    title: const Text(
                      'Mis Cursos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    centerTitle: false,
                  ),
                ),

                // Fast Creation Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push(AppRoutes.adminCreateCourse),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_rounded, color: Color(0xFF00E5FF)),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Crear Nuevo Curso',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),

                coursesAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _ErrorCard(message: e.toString()),
                    ),
                  ),
                  data: (courses) {
                    if (courses.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.library_books_outlined, size: 64, color: Colors.white30),
                              const SizedBox(height: 12),
                              const Text('No tienes cursos creados aún.', style: TextStyle(color: Colors.white54)),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final course = courses[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Icon(Icons.menu_book_rounded, color: Color(0xFF7C4DFF)),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${course.languageName} • ${course.difficultyLevel}',
                                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded, color: Colors.white24),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: courses.length,
                        ),
                      ),
                    );
                  },
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
          color: color.withValues(alpha: 0.05),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 80)],
        ),
      );
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ClassroomTile extends ConsumerWidget {
  const _ClassroomTile({required this.classroom, required this.onTap});
  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(classroomJoinRequestsProvider(classroom.id));
    final pendingCount = requestsAsync.maybeWhen(
      data: (requests) => requests.where((r) => r.status == 'pending').length,
      orElse: () => 0,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Color(0xFF7C4DFF),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classroom.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people_alt_rounded, size: 12, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        '${classroom.studentsCount} ${classroom.studentsCount == 1 ? 'estudiante' : 'estudiantes'}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.key_rounded, size: 12, color: Colors.white38),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Code: ${classroom.accessCode}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (pendingCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pendingCount ${pendingCount == 1 ? 'solicitud' : 'solicitudes'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white24,
                size: 14,
              ),
            ),
          ],
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
