import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/domain/model/course_models.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  final _searchController = TextEditingController();
  String? _selectedDifficulty;

  static const _difficulties = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(courseFiltersProvider.notifier).state = CourseFilters(
      difficultyLevel: _selectedDifficulty,
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _SliverAppBar(
            searchController: _searchController,
            onSearchChanged: (_) => _applyFilters(),
            onFilterTap: _showFilterBottomSheet,
          ),
          SliverToBoxAdapter(
            child: _DifficultySelector(
              selectedDifficulty: _selectedDifficulty,
              difficulties: _difficulties,
              onSelect: (level) {
                setState(() => _selectedDifficulty = level);
                _applyFilters();
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: coursesAsync.when(
              data: (courses) {
                if (courses.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyCoursesState(),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _CourseListItem(course: courses[index]),
                    childCount: courses.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (err, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(onRetry: () => ref.invalidate(coursesProvider)),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        onClear: () {
          ref.read(courseFiltersProvider.notifier).state = const CourseFilters();
          setState(() => _selectedDifficulty = null);
          _searchController.clear();
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SliverAppBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;

  const _SliverAppBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      title: Text('Explorar Cursos', style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: '¿Qué quieres aprender?',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  final String? selectedDifficulty;
  final List<String> difficulties;
  final Function(String?) onSelect;

  const _DifficultySelector({
    required this.selectedDifficulty,
    required this.difficulties,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: difficulties.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final level = isAll ? null : difficulties[index - 1];
          final isSelected = selectedDifficulty == level;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(isAll ? 'Todos' : level!),
              selected: isSelected,
              onSelected: (selected) => onSelect(selected ? level : null),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}

class _CourseListItem extends StatelessWidget {
  final CourseModel course;
  const _CourseListItem({required this.course});

  @override
  Widget build(BuildContext context) {
    return StudentCard(
      onTap: () => context.push(AppRoutes.studentCourseDetail.replaceAll(':id', course.id.toString())),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(Icons.language_rounded, size: 140, color: Colors.white.withValues(alpha: 0.1)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DifficultyBadge(level: course.difficultyLevel),
                      const SizedBox(height: 8),
                      Text(
                        course.title,
                        style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.description,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoItem(icon: Icons.layers_outlined, label: '${course.modulesCount} Módulos'),
                    const SizedBox(width: 16),
                    _InfoItem(icon: Icons.menu_book_outlined, label: '${course.lessonsCount} Lecciones'),
                    const Spacer(),
                    Text(
                      '${course.totalXpReward} XP',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _FilterBottomSheet extends ConsumerWidget {
  final VoidCallback onClear;
  const _FilterBottomSheet({required this.onClear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagesAsync = ref.watch(languagesProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filtros Avanzados', style: AppTextStyles.headlineSmall),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Idioma', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          languagesAsync.when(
            data: (langs) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: langs.map((lang) => ChoiceChip(
                label: Text(lang.name),
                selected: ref.watch(courseFiltersProvider).languageId == lang.id,
                onSelected: (selected) {
                  ref.read(courseFiltersProvider.notifier).state = ref.read(courseFiltersProvider).copyWith(languageId: selected ? lang.id : null);
                },
              )).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error al cargar idiomas'),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onClear,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Limpiar Todo'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _EmptyCoursesState extends StatelessWidget {
  const _EmptyCoursesState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('No encontramos cursos', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text('Intenta con otros filtros o términos de búsqueda', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
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
          Text('Algo salió mal', style: AppTextStyles.titleLarge),
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
