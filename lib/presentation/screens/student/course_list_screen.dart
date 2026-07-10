import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/course_models.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';

/// Pantalla principal que muestra la lista de cursos disponibles.
/// Permite filtrar por idioma, nivel de dificultad y buscar por texto.
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
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Cursos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barra de búsqueda ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar cursos...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),

          // ── Chips de dificultad ────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _difficulties.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _DifficultyChip(
                    label: 'Todos',
                    isSelected: _selectedDifficulty == null,
                    color: Colors.purple,
                    onTap: () {
                      setState(() => _selectedDifficulty = null);
                      _applyFilters();
                    },
                  );
                }
                final level = _difficulties[index - 1];
                return _DifficultyChip(
                  label: level,
                  isSelected: _selectedDifficulty == level,
                  color: _levelColor(level),
                  onTap: () {
                    setState(() => _selectedDifficulty = level);
                    _applyFilters();
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ── Lista de cursos ────────────────────────────────────────────
          Expanded(
            child: coursesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Error al cargar cursos',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(coursesProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (courses) {
                if (courses.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron cursos',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    return _CourseCard(course: courses[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrar por idioma',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, _) {
                  final languagesAsync = ref.watch(languagesProvider);
                  return languagesAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error al cargar idiomas',
                        style: TextStyle(color: Colors.redAccent)),
                    data: (languages) => Wrap(
                      spacing: 8,
                      children: languages.map((lang) {
                        return ActionChip(
                          label: Text(lang.name),
                          backgroundColor: AppColors.primary,
                          labelStyle: const TextStyle(color: AppColors.textPrimary),
                          onPressed: () {
                            ref.read(courseFiltersProvider.notifier).state =
                                CourseFilters(languageId: lang.id);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    ref.read(courseFiltersProvider.notifier).state =
                        const CourseFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar filtros',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ],
          ),
        );
      },
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
    return colors[level] ?? Colors.purple;
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navegar al detalle del curso con GoRouter
            // context.push('/courses/${course.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _levelColor(course.difficultyLevel),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        course.difficultyLevel,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      course.languageName,
                      style:
                          const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      '⚡ ${course.totalXpReward} XP',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Título ───────────────────────────────────────────────
                Text(
                  course.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  course.description,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // ── Stats ────────────────────────────────────────────────
                Row(
                  children: [
                    _StatChip(
                        icon: Icons.layers_outlined,
                        label: '${course.modulesCount} módulos'),
                    const SizedBox(width: 12),
                    _StatChip(
                        icon: Icons.menu_book_outlined,
                        label: '${course.lessonsCount} lecciones'),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white24, size: 14),
                  ],
                ),
              ],
            ),
          ),
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
    return colors[level] ?? Colors.purple;
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
