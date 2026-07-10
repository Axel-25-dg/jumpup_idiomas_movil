import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/domain/model/course_models.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));
    final modulesAsync = ref.watch(modulesByCourseProvider(courseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: courseAsync.when(
        data: (course) => _CourseDetailBody(course: course, modulesAsync: modulesAsync),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
                const SectionHeader(title: 'Descripción'),
                Text(
                  course.description,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.6),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Contenido del curso'),
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
          loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SliverToBoxAdapter(child: Center(child: Text('Error al cargar módulos'))),
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
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
            Positioned(
              right: -50,
              top: -50,
              child: Icon(Icons.language_rounded, size: 300, color: Colors.white.withValues(alpha: 0.05)),
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
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${module.order}',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          title: Text(module.title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          subtitle: Text('${module.lessonsCount} lecciones', style: AppTextStyles.bodySmall),
          children: [
            lessonsAsync.when(
              data: (lessons) => Column(
                children: lessons.map((l) => _LessonTile(lesson: l)).toList(),
              ),
              loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error al cargar lecciones'),
            ),
            const SizedBox(height: 8),
          ],
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
          color: AppColors.secondary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(_getIcon(lesson.contentType), color: AppColors.secondary, size: 18),
      ),
      title: Text(lesson.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${lesson.xpReward} XP', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
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
