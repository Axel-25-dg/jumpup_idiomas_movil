import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/course_models.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';

/// Pantalla de detalle de un curso.
/// Muestra los módulos, lecciones, XP total y progreso del estudiante.
class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));
    final summaryAsync = ref.watch(courseContentSummaryProvider(courseId));
    final modulesAsync = ref.watch(modulesByCourseProvider(courseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: courseAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: const TextStyle(color: Colors.redAccent)),
        ),
        data: (course) => CustomScrollView(
          slivers: [
            // ── App Bar con gradiente ──────────────────────────────────
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.surface,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  course.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        _levelColor(course.difficultyLevel),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            course.difficultyLevel,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course.languageName,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Estadísticas del curso ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: summaryAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (summary) => Row(
                    children: [
                      _StatBox(
                        icon: Icons.layers_outlined,
                        value: '${summary['total_modules']}',
                        label: 'Módulos',
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        icon: Icons.menu_book_outlined,
                        value: '${summary['total_lessons']}',
                        label: 'Lecciones',
                        color: const Color(0xFF03A9F4),
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        icon: Icons.bolt,
                        value: '${summary['total_xp']}',
                        label: 'XP Total',
                        color: const Color(0xFFFFD700),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Descripción ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Módulos del curso',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Lista de módulos ───────────────────────────────────────
            modulesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: Center(
                  child: Text('Error al cargar módulos',
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ),
              data: (modules) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _ModuleExpansionTile(module: modules[index]),
                  childCount: modules.length,
                ),
              ),
            ),

            // ── Botón de comenzar ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navegar a la primera lección con GoRouter
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, color: AppColors.textPrimary),
                      SizedBox(width: 8),
                      Text(
                        'Comenzar curso',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _levelColor(String level) {
    const colors = {
      'A1': Color(0xFF4CAF50),
      'A2': Color(0xFF8BC34A),
      'B1': Color(0xFF03A9F4),
      'B2': Color(0xFF2196F3),
      'C1': Color(0xFFFF9800),
      'C2': Color(0xFFF44336),
    };
    return colors[level] ?? AppColors.primary;
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ModuleExpansionTile extends ConsumerWidget {
  const _ModuleExpansionTile({required this.module});

  final ModuleModel module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsByModuleProvider(module.id));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${module.order}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          title: Text(
            module.title,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${module.lessonsCount} lecciones',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          iconColor: AppColors.textSecondary,
          collapsedIconColor: AppColors.textSecondary,
          children: [
            lessonsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(color: AppColors.primary),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Error al cargar lecciones',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              ),
              data: (lessons) => Column(
                children: lessons
                    .map((lesson) => _LessonTile(lesson: lesson))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF03A9F4).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(_contentTypeIcon(lesson.contentType),
            color: const Color(0xFF03A9F4), size: 16),
      ),
      title: Text(lesson.title,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '⚡ ${lesson.xpReward}',
            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.lock_outline, color: Colors.white24, size: 16),
        ],
      ),
      onTap: () {
        // TODO: Navegar a la lección con GoRouter
      },
    );
  }

  IconData _contentTypeIcon(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_outline;
      case 'interactive':
        return Icons.touch_app_outlined;
      case 'reading':
        return Icons.article_outlined;
      case 'audio':
        return Icons.headphones;
      default:
        return Icons.menu_book_outlined;
    }
  }
}
