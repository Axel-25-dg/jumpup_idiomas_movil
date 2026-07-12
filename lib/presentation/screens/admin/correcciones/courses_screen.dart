// lib/presentation/screens/admin/courses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/providers/language_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  int? _selectedLanguageId;
  String? _selectedDifficulty;

  final List<Map<String, String>> _difficultyLevels = [
    {'value': 'beginner', 'label': 'Principiante'},
    {'value': 'intermediate', 'label': 'Intermedio'},
    {'value': 'advanced', 'label': 'Avanzado'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(courseNotifierProvider);
    final notifier = ref.read(courseNotifierProvider.notifier);
    final languagesAsync = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Cursos'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddEditDialog(context, languagesAsync),
            tooltip: 'Agregar curso',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: coursesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorView(error, notifier),
          data: (courses) {
            if (courses.isEmpty) {
              return EmptyState(
                title: 'No hay cursos creados',
                subtitle: 'Crea tu primer curso para comenzar',
                icon: Icons.menu_book_rounded,
                buttonText: 'Crear curso',
                onButtonPressed: () => _showAddEditDialog(context, languagesAsync),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return _CourseCard(
                  course: course,
                  onEdit: () => _showAddEditDialog(
                    context,
                    languagesAsync,
                    course: course,
                  ),
                  onDelete: () => _confirmDelete(
                    context,
                    course.id,
                    notifier,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(Object error, CourseNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error al cargar cursos', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () => notifier.refresh(),
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context,
    AsyncValue<List<Language>> languagesAsync, {
    Course? course,
  }) {
    if (course != null) {
      _titleController.text = course.title;
      _descriptionController.text = course.description;
      _imageUrlController.text = course.imageUrl;
      _selectedLanguageId = course.languageId;
      _selectedDifficulty = course.difficultyLevel;
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
      _selectedLanguageId = null;
      _selectedDifficulty = null;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(course != null ? 'Editar curso' : 'Agregar curso'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Idioma
                languagesAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error al cargar idiomas'),
                  data: (languages) => DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Idioma',
                      prefixIcon: Icon(Icons.language_rounded),
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedLanguageId,
                    items: languages.map((lang) {
                      return DropdownMenuItem(
                        value: lang.id,
                        child: Text(lang.name),
                      );
                    }).toList(),
                    onChanged: (value) => _selectedLanguageId = value,
                    validator: (value) => value == null ? 'Selecciona un idioma' : null,
                  ),
                ),
                const SizedBox(height: 16),
                BrandedTextField(
                  controller: _titleController,
                  label: 'Título del curso',
                  prefixIcon: Icons.title_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El título es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BrandedTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  prefixIcon: Icons.description_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Nivel de dificultad',
                    prefixIcon: Icon(Icons.signal_cellular_alt_rounded),
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedDifficulty,
                  items: _difficultyLevels.map((level) {
                    return DropdownMenuItem(
                      value: level['value'],
                      child: Text(level['label']!),
                    );
                  }).toList(),
                  onChanged: (value) => _selectedDifficulty = value,
                ),
                const SizedBox(height: 16),
                BrandedTextField(
                  controller: _imageUrlController,
                  label: 'URL de la imagen (opcional)',
                  prefixIcon: Icons.image_rounded,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            label: course != null ? 'Actualizar' : 'Guardar',
            onPressed: () async {
              if (_formKey.currentState!.validate() && _selectedLanguageId != null) {
                final notifier = ref.read(courseNotifierProvider.notifier);

                final data = {
                  'language_id': _selectedLanguageId!,
                  'title': _titleController.text.trim(),
                  'description': _descriptionController.text.trim(),
                  'difficulty_level': _selectedDifficulty ?? 'beginner',
                  'image_url': _imageUrlController.text.trim(),
                };

                try {
                  if (course != null) {
                    await notifier.editCourse(course.id, data);
                  } else {
                    await notifier.addCourse(data);
                  }
                  if (!mounted) return;
                  Navigator.pop(ctx);
                } catch (_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo guardar el curso.')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, CourseNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar curso'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este curso?\n'
          'Esta acción eliminará todos los módulos y lecciones asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            label: 'Eliminar',
            onPressed: () async {
              try {
                await notifier.deleteCourse(id);
                if (!context.mounted) return;
                Navigator.pop(ctx);
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No se pudo eliminar el curso.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _getDifficultyLabel(String level) {
    switch (level) {
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      default:
        return level;
    }
  }

  Color _getDifficultyColor(String level) {
    switch (level) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: course.imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    course.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                )
              : const Icon(Icons.menu_book_rounded, color: Color(0xFF2E7D32)),
        ),
        title: Text(
          course.title,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Idioma: ${course.languageName}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getDifficultyColor(course.difficultyLevel).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getDifficultyLabel(course.difficultyLevel),
                style: AppTextStyles.bodySmall.copyWith(
                  color: _getDifficultyColor(course.difficultyLevel),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 20),
              onPressed: onEdit,
              color: AppColors.primary,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              onPressed: onDelete,
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}