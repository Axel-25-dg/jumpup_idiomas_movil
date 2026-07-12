// lib/presentation/screens/admin/courses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/course_provider.dart';
import 'package:jumpup_app/presentation/providers/correcciones/language_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';

import 'package:jumpup_app/widgets/glass_container.dart';

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
      backgroundColor: const Color(0xFF0F0E1A),
      body: Stack(
        children: [
          // Background Decorative Blobs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: const Text(
                    'Educational Content',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E1E2A),
                          const Color(0xFF0F0E1A).withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: Color(0xFF00E5FF)),
                    onPressed: () => _showAddEditDialog(context, languagesAsync),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                    onPressed: () => notifier.refresh(),
                  ),
                ],
              ),
              SliverFillRemaining(
                child: RefreshIndicator(
                  color: const Color(0xFF7C4DFF),
                  onRefresh: () => notifier.refresh(),
                  child: coursesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildErrorView(error, notifier),
                    ),
                    data: (courses) {
                      if (courses.isEmpty) {
                        return EmptyState(
                          title: 'No courses found',
                          subtitle: 'Create your first course to begin',
                          icon: Icons.menu_book_rounded,
                          buttonText: 'Create Course',
                          onButtonPressed: () =>
                              _showAddEditDialog(context, languagesAsync),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
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
              ),
            ],
          ),
        ],
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
          Text('Error al cargar cursos',
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
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
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(course != null ? 'Editar curso' : 'Agregar curso',
            style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Idioma
                  languagesAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error al cargar idiomas',
                        style: TextStyle(color: Colors.red)),
                    data: (languages) => DropdownButtonFormField<int>(
                      dropdownColor: const Color(0xFF1E1E2A),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Idioma',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.language_rounded,
                            color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                      initialValue: _selectedLanguageId,
                      items: languages.map((lang) {
                        return DropdownMenuItem(
                          value: lang.id,
                          child: Text(lang.name),
                        );
                      }).toList(),
                      onChanged: (value) => _selectedLanguageId = value,
                      validator: (value) =>
                          value == null ? 'Selecciona un idioma' : null,
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
                    dropdownColor: const Color(0xFF1E1E2A),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nivel de dificultad',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.signal_cellular_alt_rounded,
                          color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          PrimaryButton(
            label: course != null ? 'Actualizar' : 'Guardar',
            onPressed: () {
              if (_formKey.currentState!.validate() &&
                  _selectedLanguageId != null) {
                final notifier = ref.read(courseNotifierProvider.notifier);

                final data = {
                  'language_id': _selectedLanguageId!,
                  'title': _titleController.text.trim(),
                  'description': _descriptionController.text.trim(),
                  'difficulty_level': _selectedDifficulty ?? 'beginner',
                  'image_url': _imageUrlController.text.trim(),
                };

                if (course != null) {
                  notifier.editCourse(course.id, data);
                } else {
                  notifier.addCourse(data);
                }
                Navigator.pop(ctx);
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
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar curso',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este curso?\n'
          'Esta acción eliminará todos los módulos y lecciones asociadas.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          PrimaryButton(
            label: 'Eliminar',
            onPressed: () {
              notifier.deleteCourse(id);
              Navigator.pop(ctx);
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
    final accentColor = const Color(0xFF7C4DFF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: course.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      course.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.menu_book_rounded,
                        color: accentColor,
                      ),
                    ),
                  )
                : Icon(Icons.menu_book_rounded, color: accentColor),
          ),
          title: Text(
            course.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Idioma: ${course.languageName}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(course.difficultyLevel)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getDifficultyLabel(course.difficultyLevel),
                  style: TextStyle(
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
                color: Colors.white38,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: onDelete,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}