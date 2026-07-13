/*// lib/presentation/screens/admin/exercises_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/exercise_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/loading_overlay.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lessonIdController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  String _selectedType = 'multiple_choice';
  int? _currentLessonId;
  ExerciseModel? _editingExercise;

  final List<Map<String, dynamic>> _exerciseTypes = [
    {'value': 'multiple_choice', 'label': 'Opción Múltiple', 'icon': Icons.list_alt_rounded},
    {'value': 'translate', 'label': 'Traducción', 'icon': Icons.translate_rounded},
    {'value': 'listen', 'label': 'Audición', 'icon': Icons.headphones_rounded},
    {'value': 'fill_blank', 'label': 'Completar', 'icon': Icons.text_fields_rounded},
    {'value': 'match', 'label': 'Emparejar', 'icon': Icons.compare_arrows_rounded},
  ];

  @override
  void dispose() {
    _lessonIdController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    final notifier = ref.read(exerciseNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Ejercicios'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _currentLessonId != null
                ? () => _showAddEditDialog(context)
                : null,
            tooltip: 'Crear ejercicio',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _currentLessonId != null
                ? () => notifier.refresh(_currentLessonId!)
                : null,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro por ID de Lección
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: BrandedTextField(
                    controller: _lessonIdController,
                    label: 'ID de Lección',
                    prefixIcon: Icons.book_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                PrimaryButton(
                  label: 'Buscar',
                  onPressed: () {
                    final id = int.tryParse(_lessonIdController.text);
                    if (id != null && id > 0) {
                      setState(() => _currentLessonId = id);
                      notifier.refresh(id);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ingresa un ID de lección válido'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  icon: Icons.search_rounded,
                ),
              ],
            ),
          ),

          Expanded(
            child: _currentLessonId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_rounded, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Busca una lección para ver sus ejercicios',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ingresa el ID de la lección y presiona Buscar',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : _ExercisesList(
                    lessonId: _currentLessonId!,
                    onEdit: (exercise) => _showAddEditDialog(context, exercise: exercise),
                    onDelete: (exerciseId, lessonId, notifier) => _confirmDelete(context, exerciseId, lessonId, notifier),
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
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error al cargar ejercicios', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () => notifier.refresh(_currentLessonId!),
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {ExerciseModel? exercise}) {
    _editingExercise = exercise;
    final isEditing = exercise != null;

    if (isEditing) {
      _questionController.text = exercise.questionText;
      _answerController.text = exercise.correctAnswer;
      _selectedType = exercise.exerciseType;
    } else {
      _questionController.clear();
      _answerController.clear();
      _selectedType = 'multiple_choice';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Editar ejercicio' : 'Crear ejercicio'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ID de Lección (solo visible en creación)
                if (!isEditing) ...[
                  BrandedTextField(
                    controller: _lessonIdController,
                    label: 'ID de Lección',
                    prefixIcon: Icons.book_rounded,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El ID de lección es obligatorio';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingresa un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Tipo de ejercicio - ✅ CORREGIDO
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de ejercicio',
                    prefixIcon: Icon(Icons.category_rounded),
                    border: OutlineInputBorder(),
                  ),
                  items: _exerciseTypes.map<DropdownMenuItem<String>>((type) {
                    return DropdownMenuItem<String>(
                      value: type['value'] as String,
                      child: Row(
                        children: [
                          Icon(type['icon'] as IconData, size: 20, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(type['label'] as String),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
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
                // Vista previa del tipo seleccionado
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _exerciseTypes.firstWhere(
                          (t) => t['value'] == _selectedType,
                          orElse: () => const {'icon': Icons.help_rounded},
                        )['icon'] as IconData,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tipo seleccionado:',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              _exerciseTypes.firstWhere(
                                (t) => t['value'] == _selectedType,
                                orElse: () => const {'label': 'No definido'},
                              )['label'] as String,
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            label: isEditing ? 'Actualizar' : 'Guardar',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final notifier = ref.read(exerciseNotifierProvider.notifier);

                int lessonId = isEditing
                    ? _editingExercise!.lesson
                    : int.parse(_lessonIdController.text);

                final data = {
                  'lesson': lessonId,
                  'question_text': _questionController.text.trim(),
                  'exercise_type': _selectedType,
                  'correct_answer': _answerController.text.trim(),
                };

                if (isEditing) {
                  notifier.updateExercise(_editingExercise!.id, data);
                } else {
                  notifier.addExercise(data);
                }
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    int exerciseId,
    int lessonId,
    ExerciseNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar ejercicio'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este ejercicio?\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            label: 'Eliminar',
            onPressed: () {
              notifier.deleteExercise(exerciseId, lessonId);
              Navigator.pop(ctx);
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
        return 'Opción Múltiple';
      case 'translate':
        return 'Traducción';
      case 'listen':
        return 'Audición';
      case 'fill_blank':
        return 'Completar';
      case 'match':
        return 'Emparejar';
      default:
        return type;
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'multiple_choice':
        return Colors.blue;
      case 'translate':
        return Colors.purple;
      case 'listen':
        return Colors.green;
      case 'fill_blank':
        return Colors.orange;
      case 'match':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(exercise.exerciseType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
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
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTypeIcon(exercise.exerciseType),
            color: typeColor,
          ),
        ),
        title: Text(
          exercise.questionText,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getTypeLabel(exercise.exerciseType),
                    style: TextStyle(
                      fontSize: 10,
                      color: typeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ID Lección: ${exercise.lesson}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Respuesta: ${exercise.correctAnswer}',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.green,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

class _ExercisesList extends ConsumerWidget {
  const _ExercisesList({
    required this.lessonId,
    required this.onEdit,
    required this.onDelete,
  });

  final int lessonId;
  final void Function(ExerciseModel) onEdit;
  final void Function(int, int, ExerciseNotifier) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesByLessonProvider(lessonId));
    final notifier = ref.read(exerciseNotifierProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(lessonId),
      child: LoadingOverlay(
        isLoading: exercisesAsync.isLoading,
        child: exercisesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error al cargar ejercicios', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Reintentar',
                  onPressed: () => notifier.refresh(lessonId),
                  icon: Icons.refresh_rounded,
                ),
              ],
            ),
          ),
          data: (exercises) {
            if (exercises.isEmpty) {
              return EmptyState(
                title: 'No hay ejercicios',
                subtitle: 'Crea el primer ejercicio para esta lección',
                icon: Icons.edit_note_rounded,
                buttonText: 'Crear ejercicio',
                onButtonPressed: () {}, 
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return _ExerciseCard(
                  exercise: exercise,
                  onEdit: () => onEdit(exercise),
                  onDelete: () => onDelete(exercise.id, lessonId, notifier),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
*/
