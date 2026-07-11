import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';

import 'package:jumpup_app/widgets/glass_container.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));
    final modulesAsync = ref.watch(modulesByCourseProvider(courseId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: courseAsync.when(
        data: (course) => _CourseDetailBody(course: course, modulesAsync: modulesAsync),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
        error: (err, _) => _ErrorState(onRetry: () => ref.invalidate(courseDetailProvider(courseId))),
      ),
    );
  }
}

class _CourseDetailBody extends StatelessWidget {
  final CourseModel course;
  final AsyncValue<List<ModuleModel>> modulesAsync;

  const _CourseDetailBody({required this.course, required this.modulesAsync});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _SliverHeader(course: course),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Descripción', textColor: Colors.white),
                const SizedBox(height: 8),
                GlassContainer(
                  opacity: 0.1,
                  child: Text(
                    course.description,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70, height: 1.6),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Contenido del curso', textColor: Colors.white),
              ],
            ),
          ),
        ),
        modulesAsync.when(
          data: (modules) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ModuleItem(module: modules[index]),
                childCount: modules.length,
              ),
            ),
          ),
          loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: Colors.blueAccent))),
          error: (_, __) => const SliverToBoxAdapter(child: Center(child: Text('Error al cargar módulos', style: TextStyle(color: Colors.white)))),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _SliverHeader extends StatelessWidget {
  final CourseModel course;
  const _SliverHeader({required this.course});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0F111A),
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A0533), Color(0xFF0F111A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Icon(Icons.language_rounded, size: 300, color: Colors.purpleAccent.withValues(alpha: 0.1)),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DifficultyBadge(level: course.difficultyLevel),
                    const SizedBox(height: 12),
                    Text(
                      course.title,
                      style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _HeaderStat(icon: Icons.layers_outlined, label: '${course.modulesCount} Módulos'),
                        const SizedBox(width: 20),
                        _HeaderStat(icon: Icons.menu_book_outlined, label: '${course.lessonsCount} Lecciones'),
                        const SizedBox(width: 20),
                        _HeaderStat(icon: Icons.stars_rounded, label: '${course.totalXpReward} XP'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeaderStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withValues(alpha: 0.9))),
      ],
    );
  }
}

class _ModuleItem extends ConsumerWidget {
  final ModuleModel module;
  const _ModuleItem({required this.module});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsByModuleProvider(module.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        opacity: 0.1,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            unselectedWidgetColor: Colors.white54,
            colorScheme: const ColorScheme.dark(primary: Colors.blueAccent),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  '${module.order}',
                  style: AppTextStyles.titleMedium.copyWith(color: Colors.blueAccent, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            title: Text(module.title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
            subtitle: Text('${module.lessonsCount} lecciones', style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
            children: [
              lessonsAsync.when(
                data: (lessons) => Column(
                  children: lessons.map((l) => _LessonTile(lesson: l)).toList(),
                ),
                loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Colors.blueAccent)),
                error: (_, __) => const Text('Error al cargar lecciones', style: TextStyle(color: Colors.redAccent)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final LessonModel lesson;
  const _LessonTile({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(_getIcon(lesson.contentType), color: Colors.blueAccent, size: 18),
      ),
      title: Text(lesson.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${lesson.xpReward} XP', 
              style: AppTextStyles.labelSmall.copyWith(color: Colors.blueAccent, fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white24),
        ],
      ),
      onTap: () => context.push(AppRoutes.studentLessonDetail.replaceAll(':id', lesson.id.toString())),
    );
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video': return Icons.play_circle_outline_rounded;
      case 'audio': return Icons.headset_rounded;
      case 'interactive': return Icons.touch_app_rounded;
      default: return Icons.article_rounded;
    }
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error al cargar el curso', style: AppTextStyles.titleLarge),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
