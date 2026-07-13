// lib/presentation/screens/admin/exercises_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/exercise_provider.dart';
import 'package:jumpup_app/presentation/providers/lesson_provider.dart';
import 'package:jumpup_app/presentation/screens/admin/lesson_screen.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _lessonIdController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _optionsController = TextEditingController();
  String _searchQuery = '';
  String _selectedType = 'multiple_choice';
  int? _selectedLessonId;
  ExerciseModel? _editingExercise;

  final List<Map<String, dynamic>> _exerciseTypes = [
    {'value': 'multiple_choice', 'label': 'Opcion Multiple', 'icon': Icons.list_alt_rounded},
    {'value': 'translate', 'label': 'Traduccion', 'icon': Icons.translate_rounded},
    {'value': 'listen', 'label': 'Audicion', 'icon': Icons.headphones_rounded},
    {'value': 'fill_blank', 'label': 'Completar', 'icon': Icons.text_fields_rounded},
    {'value': 'match', 'label': 'Emparejar', 'icon': Icons.compare_arrows_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseNotifierProvider.notifier).fetchAllExercises();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _lessonIdController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseNotifierProvider);
    final notifier = ref.read(exerciseNotifierProvider.notifier);
    final lessonsAsync = ref.watch(lessonNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        title: const Text(
          'Gestion de Ejercicios',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E2A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF00E5FF)),
            onPressed: () => _showAddEditDialog(context, lessonsAsync),
            tooltip: 'Crear ejercicio',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => notifier.fetchAllExercises(),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: BrandedTextField(
              controller: _searchController,
              label: 'Buscar ejercicio',
              hint: 'ID de leccion o enunciado...',
              prefixIcon: Icons.search_rounded,
            ),
          ),

          // Lista de ejercicios
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.fetchAllExercises(),
              color: const Color(0xFF7C4DFF),
              backgroundColor: const Color(0xFF1E1E2A),
              child: exercisesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                ),
                error: (error, stack) => _buildErrorView(error, notifier),
                data: (exercises) {
                  // Filtrar por ID de leccion o enunciado
                  final filtered = exercises.where((exercise) {
                    if (_searchQuery.isEmpty) return true;
                    return exercise.lesson.toString().contains(_searchQuery) ||
                        exercise.questionText.toLowerCase().contains(_searchQuery) ||
                        exercise.lessonTitle.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(
                      title: _searchQuery.isEmpty
                          ? 'No hay ejercicios creados'
                          : 'No se encontraron ejercicios',
                      subtitle: _searchQuery.isEmpty
                          ? 'Crea tu primer ejercicio para comenzar'
                          : 'Intenta con otro término de búsqueda',
                      icon: Icons.edit_note_rounded,
                      buttonText: _searchQuery.isEmpty ? 'Crear ejercicio' : 'Limpiar búsqueda',
                      onButtonPressed: _searchQuery.isEmpty
                          ? () => _showAddEditDialog(context, lessonsAsync)
                          : () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final exercise = filtered[index];
                      return _ExerciseCard(
                        exercise: exercise,
                        onEdit: () => _showAddEditDialog(
                          context,
                          lessonsAsync,
                          exercise: exercise,
                        ),
                        onDelete: () => _confirmDelete(
                          context,
                          exercise.id,
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
    );
  }

  Widget _buildErrorView(Object error, ExerciseNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF5252)),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar ejercicios',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () => notifier.fetchAllExercises(),
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context,
    AsyncValue<List<LessonModel>> lessonsAsync, {
    ExerciseModel? exercise,
  }) {
    _editingExercise = exercise;
    final isEditing = exercise != null;

    if (isEditing) {
      _questionController.text = exercise.questionText;
      _answerController.text = exercise.correctAnswer;
      _selectedType = exercise.exerciseType;
      _selectedLessonId = exercise.lesson;
      if (exercise.options.isNotEmpty) {
        _optionsController.text = exercise.options.join(', ');
      }
    } else {
      _questionController.clear();
      _answerController.clear();
      _optionsController.clear();
      _selectedType = 'multiple_choice';
      _selectedLessonId = null;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        int? localLessonId = _selectedLessonId;
        String? localType = _selectedType;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2A),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                isEditing ? 'Editar ejercicio' : 'Crear ejercicio',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Selector de leccion
                        lessonsAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                          ),
                          error: (_, __) => const Text(
                            'Error al cargar lecciones',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          data: (lessons) {
                            if (lessons.isEmpty) {
                              return Column(
                                children: [
                                  const Text(
                                    'No hay lecciones disponibles. Crea una lección primero.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 12),
                                  PrimaryButton(
                                    label: 'Ir a Lecciones',
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LessonsScreen(),
                                        ),
                                      );
                                    },
                                    icon: Icons.menu_book_rounded,
                                  ),
                                ],
                              );
                            }
                            return DropdownButtonFormField<int>(
                              dropdownColor: const Color(0xFF1E1E2A),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Leccion',
                                labelStyle: const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(
                                  Icons.book_rounded,
                                  color: Colors.white54,
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              hint: const Text(
                                'Selecciona una leccion',
                                style: TextStyle(color: Colors.white54),
                              ),
                              value: localLessonId,
                              items: lessons.map((lesson) {
                                return DropdownMenuItem(
                                  value: lesson.id,
                                  child: Text(
                                    '${lesson.title} (ID: ${lesson.id})',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                localLessonId = value;
                                setDialogState(() {});
                              },
                              validator: (value) =>
                                  value == null ? 'Selecciona una leccion' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tipo de ejercicio
                        DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFF1E1E2A),
                          style: const TextStyle(color: Colors.white),
                          value: localType,
                          decoration: InputDecoration(
                            labelText: 'Tipo de ejercicio',
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.category_rounded,
                              color: Colors.white54,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: _exerciseTypes.map((type) {
                            return DropdownMenuItem(
                              value: type['value'] as String,
                              child: Row(
                                children: [
                                  Icon(
                                    type['icon'] as IconData,
                                    size: 20,
                                    color: const Color(0xFF7C4DFF),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    type['label'] as String,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              localType = value;
                              setDialogState(() {});
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Enunciado
                        BrandedTextField(
                          controller: _questionController,
                          label: 'Enunciado / Pregunta',
                          prefixIcon: Icons.question_mark_rounded,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El enunciado es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Respuesta correcta
                        BrandedTextField(
                          controller: _answerController,
                          label: 'Respuesta Correcta',
                          prefixIcon: Icons.check_circle_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La respuesta es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Opciones (solo para multiple_choice)
                        if (localType == 'multiple_choice')
                          BrandedTextField(
                            controller: _optionsController,
                            label: 'Opciones (separadas por coma)',
                            hint: 'Ej: Opcion 1, Opcion 2, Opcion 3',
                            prefixIcon: Icons.list_alt_rounded,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
                PrimaryButton(
                  label: isEditing ? 'Actualizar' : 'Guardar',
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && localLessonId != null) {
                      final notifier = ref.read(exerciseNotifierProvider.notifier);

                      final data = <String, dynamic>{
                        'lesson': localLessonId!,
                        'question_text': _questionController.text.trim(),
                        'exercise_type': localType!,
                        'correct_answer': _answerController.text.trim(),
                      };

                      if (localType == 'multiple_choice') {
                        final optionsText = _optionsController.text.trim();
                        if (optionsText.isNotEmpty) {
                          data['options'] = optionsText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                        }
                      }

                      try {
                        if (isEditing) {
                          await notifier.updateExercise(_editingExercise!.id, data);
                        } else {
                          await notifier.createExercise(data);
                        }
                        Navigator.pop(ctx);
                        notifier.fetchAllExercises();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int exerciseId, ExerciseNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Eliminar ejercicio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este ejercicio?\n'
          'Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          PrimaryButton(
            label: 'Eliminar',
            onPressed: () {
              notifier.deleteExercise(exerciseId, exerciseId);
              Navigator.pop(ctx);
              notifier.fetchAllExercises();
            },
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  final ExerciseModel exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _getTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Opcion Multiple';
      case 'translate':
        return 'Traduccion';
      case 'listen':
        return 'Audicion';
      case 'fill_blank':
        return 'Completar';
      case 'match':
        return 'Emparejar';
      default:
        return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'multiple_choice':
        return const Color(0xFF00E5FF);
      case 'translate':
        return const Color(0xFF7C4DFF);
      case 'listen':
        return const Color(0xFF00C853);
      case 'fill_blank':
        return const Color(0xFFFFAB40);
      case 'match':
        return const Color(0xFFFF5252);
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'multiple_choice':
        return Icons.list_alt_rounded;
      case 'translate':
        return Icons.translate_rounded;
      case 'listen':
        return Icons.headphones_rounded;
      case 'fill_blank':
        return Icons.text_fields_rounded;
      case 'match':
        return Icons.compare_arrows_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(exercise.exerciseType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTypeIcon(exercise.exerciseType),
                color: typeColor,
                size: 24,
              ),
            ),
            title: Text(
              exercise.questionText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Leccion: ${exercise.lessonTitle} (ID: ${exercise.lesson})',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildBadge(
                      text: _getTypeLabel(exercise.exerciseType),
                      color: typeColor,
                    ),
                    _buildBadge(
                      text: 'Respuesta: ${exercise.correctAnswer}',
                      color: Colors.green,
                    ),
                  ],
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
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: onDelete,
                  color: Colors.redAccent.withValues(alpha: 0.7),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}