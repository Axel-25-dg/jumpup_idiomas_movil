import 'dart:math' as math;
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/domain/model/classroom_model.dart';
import 'package:jumpup_app/presentation/providers/virtual_class_providers.dart';
import 'package:jumpup_app/presentation/providers/classroom_providers.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/screens/common/live_session_join_screen.dart';
import 'package:jumpup_app/theme/text_styles.dart';

/// Tokens de diseño centralizados para el módulo de clases virtuales.
class _ClassTokens {
  const _ClassTokens._();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? const Color(0xFF0B0B12) : const Color(0xFFF6F7FB);

  static Color surface(BuildContext context) =>
      isDark(context) ? const Color(0xFF16161F) : Colors.white;

  static Color surfaceAlt(BuildContext context) =>
      isDark(context) ? const Color(0xFF1C1C28) : const Color(0xFFF0F1F7);

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? const Color(0xFFF4F4FA) : const Color(0xFF14141F);

  static Color textSecondary(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.55)
      : const Color(0xFF14141F).withValues(alpha: 0.55);

  static Color hairline(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.black.withValues(alpha: 0.06);

  // Paleta de marca refinada.
  static const Color primary = Color(0xFF5B8DEF);
  static const Color accent = Color(0xFF22D3EE);
  static const Color live = Color(0xFF2DD4A7);
  static const Color danger = Color(0xFFFF6B6B);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF4F7DF0), Color(0xFF29C7E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient liveGradient = LinearGradient(
    colors: [Color(0xFF2DD4A7), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color brandGlow = Color(0xFF4F7DF0);
}

class VirtualClassListScreen extends ConsumerWidget {
  const VirtualClassListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _VirtualClassListBody();
  }
}

class _VirtualClassListBody extends ConsumerWidget {
  const _VirtualClassListBody();

  void _showJoinDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _JoinClassSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myClassroomsAsync = ref.watch(myClassroomsProvider);
    final classesAsync = ref.watch(virtualClassesProvider);
    final coursesAsync = ref.watch(coursesProvider);

    final enrolledCourseIds = myClassroomsAsync.maybeWhen(
      data: (classrooms) => classrooms
          .map((classroom) => classroom.courseId)
          .whereType<int>()
          .toSet(),
      orElse: () => <int>{},
    );

    return Scaffold(
      backgroundColor: _ClassTokens.background(context),
      body: Stack(
        children: [
          // Fondo con malla de color animada.
          const Positioned.fill(child: _AnimatedMeshBackground()),
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myClassroomsProvider);
              ref.invalidate(virtualClassesProvider);
              await Future.wait([
                ref.read(myClassroomsProvider.future),
                ref.read(virtualClassesProvider.future),
              ]);
            },
            backgroundColor: _ClassTokens.surface(context),
            color: _ClassTokens.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                _ClassesSliverAppBar(
                  onAdd: () => _showJoinDialog(context),
                ),
                // Show My Classrooms first
                myClassroomsAsync.when(
                  loading: () => const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(color: _ClassTokens.primary),
                      ),
                    ),
                  ),
                  error: (err, stack) => const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                    sliver: SliverToBoxAdapter(child: SizedBox()),
                  ),
                  data: (classrooms) {
                    if (classrooms.isNotEmpty) {
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final classroom = classrooms[index];
                              return FadeInUp(
                                duration: Duration(milliseconds: 300 + index * 80),
                                child: _MyClassroomCard(classroom: classroom),
                              );
                            },
                            childCount: classrooms.length,
                          ),
                        ),
                      );
                    } else {
                      return const SliverPadding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                        sliver: SliverToBoxAdapter(child: SizedBox()),
                      );
                    }
                  },
                ),
                // Show Available Courses Section
                coursesAsync.when(
                  loading: () => const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(color: _ClassTokens.primary),
                      ),
                    ),
                  ),
                  error: (err, stack) => const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                    sliver: SliverToBoxAdapter(child: SizedBox()),
                  ),
                  data: (courses) {
                    final availableCourses = courses.where((course) => !enrolledCourseIds.contains(course.id)).toList();

                    if (availableCourses.isEmpty) {
                      return const SliverPadding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                        sliver: SliverToBoxAdapter(child: SizedBox()),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'Cursos Disponibles',
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    color: _ClassTokens.textPrimary(context),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }
                            final course = availableCourses[index - 1];
                            return FadeInUp(
                              duration: Duration(milliseconds: 300 + (index * 60)),
                              child: _AvailableCourseCard(
                                course: course,
                                onRequestAccess: () => _showJoinDialog(context),
                              ),
                            );
                          },
                          childCount: availableCourses.length + 1,
                        ),
                      ),
                    );
                  },
                ),
                if (myClassroomsAsync.hasValue)
                  classesAsync.when(
                    loading: () => const SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 120),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(color: _ClassTokens.primary),
                        ),
                      ),
                    ),
                    error: (err, stack) => SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      sliver: SliverToBoxAdapter(
                        child: _ErrorState(
                          onRetry: () => ref.invalidate(virtualClassesProvider),
                        ),
                      ),
                    ),
                    data: (classes) {
                      if (classes.isEmpty) {
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                          sliver: SliverFillRemaining(
                            hasScrollBody: false,
                            child: _EmptyState(
                              onJoin: () => _showJoinDialog(context),
                            ),
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final vClass = classes[index];
                              return FadeInUp(
                                duration: Duration(milliseconds: 400 + (index * 90)),
                                child: _VirtualClassCard(
                                  vClass: vClass,
                                  onJoinPressed: () => _showJoinDialog(context),
                                ),
                              );
                            },
                            childCount: classes.length,
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
}

class _ClassesSliverAppBar extends StatelessWidget {
  const _ClassesSliverAppBar({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final titleColor = _ClassTokens.textPrimary(context);

    const double expandedHeight = 176;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      collapsedHeight: kToolbarHeight,
      floating: false,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: _ClassTokens.background(context).withValues(alpha: 0.72),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double topPadding = MediaQuery.of(context).padding.top;
          final double collapsedHeight = kToolbarHeight + topPadding;
          final double maxHeight = expandedHeight + topPadding;
          // t = 1 expandido -> 0 colapsado.
          final double t = ((constraints.maxHeight - collapsedHeight) /
                  (maxHeight - collapsedHeight))
              .clamp(0.0, 1.0);

          return ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Ícono decorativo (se desvanece al colapsar).
                  Positioned(
                    right: -10,
                    top: topPadding - 6,
                    child: Opacity(
                      opacity: (t * 0.9).clamp(0.0, 1.0),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            _ClassTokens.primary.withValues(alpha: 0.12),
                            _ClassTokens.accent.withValues(alpha: 0.02),
                          ],
                        ).createShader(bounds),
                        child: const Icon(
                          Icons.smart_display_rounded,
                          size: 150,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Título grande + subtítulo (visible expandido).
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 18,
                    child: Opacity(
                      opacity: t,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                _ClassTokens.brandGradient.createShader(bounds),
                            child: Text(
                              'Clases Virtuales',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Aprende en tiempo real',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _ClassTokens.textSecondary(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Título compacto (visible colapsado), alineado tras el back.
                  Positioned(
                    left: 56,
                    right: 120,
                    top: topPadding,
                    height: kToolbarHeight,
                    child: Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ShaderMask(
                          shaderCallback: (bounds) => _ClassTokens.brandGradient
                              .createShader(bounds),
                          child: Text(
                            'Clases Virtuales',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: _ClassTokens.brandGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _ClassTokens.brandGlow.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Unirse',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      // Mantengo el color de título accesible en estado colapsado.
      foregroundColor: titleColor,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onJoin});
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final textColor = _ClassTokens.textPrimary(context);
    final subColor = _ClassTokens.textSecondary(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeIn(
              child: Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _ClassTokens.primary.withValues(alpha: 0.14),
                      _ClassTokens.accent.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: _ClassTokens.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (b) =>
                      _ClassTokens.brandGradient.createShader(b),
                  child: const Icon(
                    Icons.video_library_rounded,
                    size: 68,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'No hay clases activas',
              style: AppTextStyles.titleLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Únete a una clase virtual para comenzar tu aprendizaje',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: subColor),
            ),
            const SizedBox(height: 36),
            _GradientButton(
              label: 'Unirse a una clase',
              icon: Icons.add_rounded,
              onPressed: onJoin,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textColor = _ClassTokens.textPrimary(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _ClassTokens.danger.withValues(alpha: 0.12),
                border: Border.all(
                  color: _ClassTokens.danger.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: _ClassTokens.danger,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Ups! Algo salió mal',
              style: AppTextStyles.titleMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No pudimos cargar tus clases',
              style: TextStyle(color: _ClassTokens.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            _GradientButton(
              label: 'Reintentar',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _MyClassroomCard extends StatelessWidget {
  const _MyClassroomCard({required this.classroom});

  final ClassroomModel classroom;

  @override
  Widget build(BuildContext context) {
    final isDark = _ClassTokens.isDark(context);
    final textPrimary = _ClassTokens.textPrimary(context);
    final textSecondary = _ClassTokens.textSecondary(context);

    return InkWell(
      onTap: () {
        context.pushNamed(
          'studentResources',
          pathParameters: {'classroomId': classroom.id.toString()},
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              _ClassTokens.primary.withValues(alpha: isDark ? 0.25 : 0.12),
              _ClassTokens.accent.withValues(alpha: isDark ? 0.18 : 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: _ClassTokens.primary.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: _ClassTokens.primary.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _ClassTokens.primary.withValues(alpha: 0.25),
                    ),
                    child: const Icon(
                      Icons.class_rounded,
                      color: _ClassTokens.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classroom.name,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                          ),
                        ),
                        if (classroom.courseName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              classroom.courseName!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (classroom.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _ClassTokens.live.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Activo',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _ClassTokens.live,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (classroom.description.isNotEmpty)
                Text(
                  classroom.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    color: textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    classroom.teacherName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.group_outlined,
                    color: textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${classroom.studentsCount} estudiantes',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailableCourseCard extends StatelessWidget {
  const _AvailableCourseCard({
    required this.course,
    required this.onRequestAccess,
  });

  final dynamic course; // CourseModel
  final VoidCallback onRequestAccess;

  @override
  Widget build(BuildContext context) {
    final courseTitle = course.title ?? 'Curso sin título';
    final teacherName = course.teacherName ?? 'Profesor desconocido';
    final difficultyLevel = course.difficultyLevel ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _ClassTokens.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _ClassTokens.hairline(context),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseTitle,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: _ClassTokens.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prof: $teacherName',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _ClassTokens.textSecondary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _ClassTokens.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    difficultyLevel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _ClassTokens.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRequestAccess,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _ClassTokens.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Solicitar Acceso',
                  style: TextStyle(
                    color: _ClassTokens.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VirtualClassCard extends ConsumerWidget {
  const _VirtualClassCard({
    required this.vClass,
    this.onJoinPressed,
  });

  final VirtualClassModel vClass;
  final VoidCallback? onJoinPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinStatus = ref.watch(joinClassNotifierProvider);
    final isFull = vClass.isFull;
    final isOngoing = vClass.isOngoing;
    final canJoin = vClass.canJoin;

    final ratio = vClass.maxParticipants == 0
        ? 0.0
        : (vClass.currentParticipants / vClass.maxParticipants)
            .clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: isOngoing
                ? _ClassTokens.live.withValues(alpha: 0.18)
                : Colors.black.withValues(
                    alpha: _ClassTokens.isDark(context) ? 0.32 : 0.07),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: _ClassTokens.surface(context),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isOngoing
                      ? _ClassTokens.live.withValues(alpha: 0.30)
                      : _ClassTokens.hairline(context),
                ),
              ),
            ),
            // Franja de acento lateral.
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: isOngoing
                      ? _ClassTokens.liveGradient
                      : _ClassTokens.brandGradient,
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: () => _handleJoin(context, ref),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatusBadge(
                            isOngoing: isOngoing,
                            isScheduled: vClass.isScheduled,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_alt_rounded,
                                color: isFull
                                    ? _ClassTokens.danger
                                    : _ClassTokens.textSecondary(context),
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${vClass.currentParticipants}/${vClass.maxParticipants}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isFull
                                      ? _ClassTokens.danger
                                      : _ClassTokens.textSecondary(context),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        vClass.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: _ClassTokens.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vClass.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _ClassTokens.textSecondary(context),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Barra de ocupación.
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          backgroundColor: _ClassTokens.surfaceAlt(context),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isFull
                                ? _ClassTokens.danger
                                : (isOngoing
                                    ? _ClassTokens.live
                                    : _ClassTokens.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _InstructorAvatar(name: vClass.instructorName),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Instructor',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color:
                                        _ClassTokens.textSecondary(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  vClass.instructorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _ClassTokens.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (vClass.status == 'scheduled' || vClass.status == 'ongoing')
                            _ActionButton(
                              canJoin: canJoin,
                              isFull: isFull,
                              isLoading: joinStatus == JoinClassStatus.loading,
                              onPressed: () => _handleJoin(context, ref),
                            ),
                        ],
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

  Future<void> _handleJoin(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (vClass.canJoin) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Redirigiendo a la sala...'),
          backgroundColor: _ClassTokens.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      final result =
          await ref.read(joinClassNotifierProvider.notifier).joinClass(vClass.id);
      if (result != null && result.virtualClass.meetingUrl != null) {
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LiveSessionJoinScreen(
                title: result.virtualClass.title,
                meetingUrl: result.virtualClass.meetingUrl ?? '',
              ),
            ),
          );
        }
      }
    } else {
      final result =
          await ref.read(joinClassNotifierProvider.notifier).joinClass(vClass.id);
      if (result != null) {
        ref.invalidate(virtualClassesProvider);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Inscripción exitosa. Te notificaremos.'),
            backgroundColor: _ClassTokens.live,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final error =
            ref.read(joinClassNotifierProvider.notifier).errorMessage;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(error ?? 'No se pudo reservar la clase'),
            backgroundColor: _ClassTokens.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _InstructorAvatar extends StatelessWidget {
  const _InstructorAvatar({required this.name});
  final String name;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: _ClassTokens.brandGradient,
      ),
      child: Text(
        _initials,
        style: AppTextStyles.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isOngoing,
    required this.isScheduled,
  });

  final bool isOngoing;
  final bool isScheduled;

  @override
  Widget build(BuildContext context) {
    final color = isOngoing
        ? _ClassTokens.live
        : (isScheduled
            ? _ClassTokens.primary
            : _ClassTokens.textSecondary(context));
    final text = isOngoing
        ? 'EN VIVO'
        : (isScheduled ? 'PROGRAMADA' : 'FINALIZADA');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOngoing) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Pulse(
                infinite: true,
                duration: const Duration(milliseconds: 1200),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _ClassTokens.live,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _ClassTokens.live.withValues(alpha: 0.7),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.canJoin,
    required this.isFull,
    required this.isLoading,
    required this.onPressed,
  });

  final bool canJoin;
  final bool isFull;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _ClassTokens.primary,
        ),
      );
    }

    if (isFull && !canJoin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _ClassTokens.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _ClassTokens.danger.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          'Completa',
          style: AppTextStyles.labelMedium.copyWith(
            color: _ClassTokens.danger,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final gradient =
        canJoin ? _ClassTokens.liveGradient : _ClassTokens.brandGradient;
    final glow = canJoin ? _ClassTokens.live : _ClassTokens.brandGlow;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  canJoin ? 'ENTRAR' : 'RESERVAR',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  canJoin
                      ? Icons.arrow_forward_rounded
                      : Icons.bookmark_add_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón con gradiente reutilizable.
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _ClassTokens.brandGradient,
        boxShadow: [
          BoxShadow(
            color: _ClassTokens.brandGlow.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JoinClassSheet extends ConsumerStatefulWidget {
  const _JoinClassSheet();

  @override
  ConsumerState<_JoinClassSheet> createState() => _JoinClassSheetState();
}

class _JoinClassSheetState extends ConsumerState<_JoinClassSheet> {
  final _codeCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _classIdCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _useCode = true;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _messageCtrl.dispose();
    _classIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanQR() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _QRScannerScreen()),
    );

    if (!mounted) return;

    if (result != null && result.isNotEmpty) {
      setState(() {
        _codeCtrl.text = result;
        _useCode = true;
      });
      await _enroll();
    }
  }

  Future<void> _enroll() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

        try {
      if (_useCode) {
        final code = _codeCtrl.text.trim();
        final notifier = ref.read(joinClassroomProvider.notifier);
        final success = await notifier.joinByCode(code);

        if (!mounted) return;

        if (success) {
          ref.invalidate(myClassroomsProvider);
          ref.invalidate(virtualClassesProvider);
          navigator.pop();
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('¡Inscrito al aula con éxito!'),
              backgroundColor: _ClassTokens.live,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(notifier.errorMessage ?? 'Inscripción fallida'),
              backgroundColor: _ClassTokens.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        final classId = int.tryParse(_classIdCtrl.text.trim()) ?? 0;
        final message = _messageCtrl.text.trim();
        final success = await ref
            .read(requestJoinProvider.notifier)
            .requestJoin(classId, message);

        if (!mounted) return;

        if (success) {
          navigator.pop();
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Solicitud enviada al profesor.'),
              backgroundColor: _ClassTokens.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          final error = ref.read(requestJoinProvider.notifier).errorMessage;
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(error ?? 'No se pudo enviar la solicitud'),
              backgroundColor: _ClassTokens.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.of(context).viewInsets.bottom + 40,
          ),
          decoration: BoxDecoration(
            color: _ClassTokens.surface(context),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 6,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: _ClassTokens.textSecondary(context)
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Selector de modo: Código vs Solicitud
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _ClassTokens.surfaceAlt(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _useCode = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _useCode
                                    ? _ClassTokens.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Usar Código',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _useCode
                                      ? Colors.white
                                      : _ClassTokens.textSecondary(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _useCode = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_useCode
                                    ? _ClassTokens.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Solicitar Acceso',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !_useCode
                                      ? Colors.white
                                      : _ClassTokens.textSecondary(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_useCode) ...[
                    // Vista de Código (Existente)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _ClassTokens.brandGradient,
                        ),
                        child: const Icon(
                          Icons.vpn_key_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unirse con Código',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _ClassTokens.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingresa el código de 8 caracteres del aula',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _ClassTokens.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _codeCtrl,
                      maxLength: 8,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      style: AppTextStyles.headlineMedium.copyWith(
                        letterSpacing: 12,
                        fontWeight: FontWeight.w900,
                        color: _ClassTokens.primary,
                      ),
                      validator: (val) {
                        if (_useCode && (val == null || val.trim().length != 8)) {
                          return 'El código debe tener 8 caracteres';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'ABCD1234',
                        hintStyle: TextStyle(
                          color: _ClassTokens.textSecondary(context).withValues(alpha: 0.2),
                          letterSpacing: 12,
                        ),
                        counterText: '',
                        filled: true,
                        fillColor: _ClassTokens.surfaceAlt(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Vista de Solicitud (Nueva)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _ClassTokens.primary.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          size: 32,
                          color: _ClassTokens.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enviar Solicitud',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _ClassTokens.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Indica el ID del aula y un mensaje para el profesor',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _ClassTokens.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _classIdCtrl,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (!_useCode && (val == null || val.isEmpty)) {
                          return 'Ingresa el ID del aula';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'ID del Aula',
                        prefixIcon: const Icon(Icons.tag_rounded),
                        filled: true,
                        fillColor: _ClassTokens.surfaceAlt(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mensaje (opcional)',
                        hintText: '¿Por qué quieres unirte?',
                        prefixIcon: const Icon(Icons.chat_bubble_outline_rounded),
                        filled: true,
                        fillColor: _ClassTokens.surfaceAlt(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: _ClassTokens.brandGradient,
                      boxShadow: [
                        BoxShadow(
                          color: _ClassTokens.brandGlow.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _enroll,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _useCode
                                  ? Icons.check_circle_rounded
                                  : Icons.send_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                      label: Text(
                        _isProcessing
                            ? 'Procesando...'
                            : (_useCode ? 'Unirse Ahora' : 'Enviar Solicitud'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_useCode)
                    OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _scanQR,
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('Escanear Código QR'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        foregroundColor: _ClassTokens.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// QR Scanner — temporalmente deshabilitado mientras mobile_scanner migra a Kotlin.
class _QRScannerScreen extends StatelessWidget {
  const _QRScannerScreen();

  @override
  Widget build(BuildContext context) {
    final textColor = _ClassTokens.textPrimary(context);

    return Scaffold(
      backgroundColor: _ClassTokens.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _ClassTokens.primary.withValues(alpha: 0.14),
                      _ClassTokens.accent.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(
                    color: _ClassTokens.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (b) =>
                      _ClassTokens.brandGradient.createShader(b),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 76,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Escáner QR',
                style: AppTextStyles.titleLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Próximamente disponible',
                style: TextStyle(
                  color: _ClassTokens.textSecondary(context),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Por ahora, ingresa el código manualmente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ClassTokens.textSecondary(context)
                      .withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              _GradientButton(
                label: 'Volver',
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fondo animado con blobs de color suaves (malla).
class _AnimatedMeshBackground extends StatefulWidget {
  const _AnimatedMeshBackground();

  @override
  State<_AnimatedMeshBackground> createState() =>
      _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<_AnimatedMeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _ClassTokens.isDark(context);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value * 2 * math.pi;
          return Stack(
            children: [
              Positioned(
                top: -120 + math.sin(t) * 24,
                right: -80 + math.cos(t) * 24,
                child: _BlurBlob(
                  color: _ClassTokens.primary,
                  opacity: isDark ? 0.16 : 0.14,
                  size: 320,
                ),
              ),
              Positioned(
                bottom: -100 + math.cos(t) * 24,
                left: -80 + math.sin(t) * 24,
                child: _BlurBlob(
                  color: _ClassTokens.accent,
                  opacity: isDark ? 0.12 : 0.10,
                  size: 280,
                ),
              ),
              Positioned(
                top: 260 + math.sin(t + 1) * 20,
                left: -60,
                child: _BlurBlob(
                  color: _ClassTokens.live,
                  opacity: isDark ? 0.08 : 0.06,
                  size: 220,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({
    required this.color,
    required this.size,
    this.opacity = 1.0,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final base = color.withValues(alpha: opacity);
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: base,
          boxShadow: [
            BoxShadow(
              color: base.withValues(alpha: 0.6),
              blurRadius: 110,
              spreadRadius: 55,
            ),
          ],
        ),
      ),
    );
  }
}
