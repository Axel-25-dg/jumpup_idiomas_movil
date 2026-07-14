import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/providers/classroom_providers.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';
import 'package:jumpup_app/presentation/screens/student/course_visibility_helper.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'dart:ui';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));
    final modulesAsync = ref.watch(modulesByCourseProvider(courseId));
    final myClassroomsAsync = ref.watch(myClassroomsProvider);
    final availableClassroomsAsync = ref.watch(classroomsByCourseProvider(courseId));

    final isEnrolled = myClassroomsAsync.when(
      data: (classrooms) {
        if (courseAsync.valueOrNull != null) {
          return isCourseEnrolled(course: courseAsync.valueOrNull!, classrooms: classrooms);
        }
        return classrooms.any((c) => c.courseId == courseId);
      },
      loading: () => false,
      error: (_, __) => false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: courseAsync.when(
        data: (course) => _CourseDetailBody(
          course: course,
          modulesAsync: modulesAsync,
          isEnrolled: isEnrolled,
          availableClassroomsAsync: availableClassroomsAsync,
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
        error: (err, _) => _ErrorState(onRetry: () => ref.invalidate(courseDetailProvider(courseId))),
      ),
      floatingActionButton: !isEnrolled
          ? FloatingActionButton.extended(
              onPressed: () => _showRequestJoinDialog(context, ref, availableClassroomsAsync),
              label: const Text('Solicitar Acceso'),
              icon: const Icon(Icons.send_rounded),
              backgroundColor: Colors.blueAccent,
            )
          : null,
    );
  }

  void _showRequestJoinDialog(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ClassroomModel>> availableClassroomsAsync,
  ) {
    availableClassroomsAsync.when(
      data: (classrooms) {
        if (classrooms.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay aulas disponibles para este curso actualmente.')),
          );
          return;
        }

        // Si solo hay una, ir directo. Si hay varias, quizás mostrar selector.
        // Por ahora, asumimos la primera o mostramos un modal simple.
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _RequestAccessSheet(classrooms: classrooms),
        );
      },
      loading: () => null,
      error: (_, __) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al verificar disponibilidad de aulas')),
      ),
    );
  }
}

class _CourseDetailBody extends StatelessWidget {
  final CourseModel course;
  final AsyncValue<List<ModuleModel>> modulesAsync;
  final bool isEnrolled;
  final AsyncValue<List<ClassroomModel>> availableClassroomsAsync;

  const _CourseDetailBody({
    required this.course,
    required this.modulesAsync,
    required this.isEnrolled,
    required this.availableClassroomsAsync,
  });

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
                (context, index) => _ModuleItem(module: modules[index], courseId: course.id),
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
  final int courseId;
  const _ModuleItem({required this.module, required this.courseId});

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
                  children: lessons.map((l) => _LessonTile(lesson: l, courseId: courseId)).toList(),
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

class _LessonTile extends ConsumerWidget {
  final LessonModel lesson;
  final int courseId;
  const _LessonTile({required this.lesson, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myClassrooms = ref.watch(myClassroomsProvider).valueOrNull ?? [];
    final classroom = myClassrooms.firstWhere(
      (c) => c.courseId == courseId,
      orElse: () => myClassrooms.firstWhere((c) => c.courseName == lesson.moduleTitle, orElse: () => null as dynamic),
    );
    final classroomId = classroom?.id;

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
      onTap: () {
        final classroomQuery = classroomId != null ? '?classroomId=$classroomId' : '';
        context.push('${AppRoutes.studentLessonDetail.replaceAll(':id', lesson.id.toString())}$classroomQuery');
      },
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

class _RequestAccessSheet extends ConsumerStatefulWidget {
  final List<ClassroomModel> classrooms;
  const _RequestAccessSheet({required this.classrooms});

  @override
  ConsumerState<_RequestAccessSheet> createState() => _RequestAccessSheetState();
}

class _RequestAccessSheetState extends ConsumerState<_RequestAccessSheet> {
  late ClassroomModel selectedClassroom;
  final _messageCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    selectedClassroom = widget.classrooms.first;
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSending = true);
    final success = await ref.read(requestJoinProvider.notifier).requestJoin(
          selectedClassroom.id,
          _messageCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isSending = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud enviada a ${selectedClassroom.teacherName}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = ref.read(requestJoinProvider.notifier).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al enviar solicitud'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
          decoration: BoxDecoration(
            color: const Color(0xFF16161F).withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(
                'Solicitar Acceso',
                style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Elige un profesor y envía un mensaje para unirte al curso.',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              if (widget.classrooms.length > 1) ...[
                Text('Profesor disponible:', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ClassroomModel>(
                      value: selectedClassroom,
                      dropdownColor: const Color(0xFF16161F),
                      items: widget.classrooms
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.teacherName, style: const TextStyle(color: Colors.white)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedClassroom = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GlassContainer(
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, color: Colors.blueAccent),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Profesor:', style: AppTextStyles.labelSmall.copyWith(color: Colors.white54)),
                            Text(selectedClassroom.teacherName, style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              TextField(
                controller: _messageCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Hola, me gustaría unirme a tu clase...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSending ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSending
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Enviar Solicitud', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
