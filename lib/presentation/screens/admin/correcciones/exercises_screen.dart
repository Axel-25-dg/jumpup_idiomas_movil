// lib/presentation/screens/admin/exercises_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/correcciones/exercise_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

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
      backgroundColor: const Color(0xFF0F0E1A),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                    blurRadius: 100,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                    blurRadius: 80,
                  )
                ],
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
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: const Text(
                    'Exercise Bank',
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
                  if (_currentLessonId != null) ...[
                    IconButton(
                      icon: const Icon(Icons.add_rounded, color: Color(0xFF00E5FF)),
                      onPressed: () => _showAddEditDialog(context),
                      tooltip: 'Crear ejercicio',
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                      onPressed: () => notifier.refresh(_currentLessonId!),
                      tooltip: 'Refrescar',
                    ),
                  ],
                ],
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filter by Lesson',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: BrandedTextField(
                                controller: _lessonIdController,
                                label: 'Lesson ID',
                                prefixIcon: Icons.book_rounded,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            PrimaryButton(
                              label: 'Search',
                              onPressed: () {
                                final id = int.tryParse(_lessonIdController.text);
                                if (id != null && id > 0) {
                                  setState(() => _currentLessonId = id);
                                  notifier.getExercisesByLesson(id);
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
                      ],
                    ),
                  ),
                ),
              ),

              if (_currentLessonId == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 80, color: Colors.white.withValues(alpha: 0.1)),
                        const SizedBox(height: 16),
                        const Text(
                          'Enter a Lesson ID to manage exercises',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Exercises will appear here once you search',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  sliver: _ExercisesListSliver(
                    lessonId: _currentLessonId!,
                    onEdit: (exercise) =>
                        _showAddEditDialog(context, exercise: exercise),
                    onDelete: (exerciseId, lessonId, notifier) =>
                        _confirmDelete(context, exerciseId, lessonId, notifier),
                  ),
                ),
            ],
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
        backgroundColor: const Color(0xFF1E1E2A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(isEditing ? 'Edit Exercise' : 'Create Exercise',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isEditing) ...[
                    BrandedTextField(
                      controller: _lessonIdController,
                      label: 'Lesson ID',
                      prefixIcon: Icons.book_rounded,
                      keyboardType: TextInputType.number,
                      enabled: false, // Already selected in the screen
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('Exercise Type', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E1E2A),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.category_rounded, color: Color(0xFF7C4DFF)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _exerciseTypes.map<DropdownMenuItem<String>>((type) {
                      return DropdownMenuItem<String>(
                        value: type['value'] as String,
                        child: Row(
                          children: [
                            Icon(type['icon'] as IconData,
                                size: 20, color: const Color(0xFF7C4DFF)),
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
                  const SizedBox(height: 20),
                  BrandedTextField(
                    controller: _questionController,
                    label: 'Question / Instruction',
                    prefixIcon: Icons.quiz_rounded,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Question text is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  BrandedTextField(
                    controller: _answerController,
                    label: 'Correct Answer',
                    prefixIcon: Icons.check_circle_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Answer is required';
                      }
                      return null;
                    },
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
                const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          PrimaryButton(
            label: isEditing ? 'Update' : 'Save',
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
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Exercise',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this exercise?\n'
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          PrimaryButton(
            label: 'Delete',
            color: AppColors.error,
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
        return 'Multiple Choice';
      case 'translate':
        return 'Translation';
      case 'listen':
        return 'Listening';
      case 'fill_blank':
        return 'Fill the blank';
      case 'match':
        return 'Matching';
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

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(exercise.exerciseType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: typeColor.withValues(alpha: 0.2)),
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
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTypeLabel(exercise.exerciseType).toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        color: typeColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Correct: ',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    TextSpan(
                      text: exercise.correctAnswer,
                      style: const TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: onDelete,
                color: AppColors.error.withValues(alpha: 0.7),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExercisesListSliver extends ConsumerWidget {
  const _ExercisesListSliver({
    required this.lessonId,
    required this.onEdit,
    required this.onDelete,
  });

  final int lessonId;
  final void Function(ExerciseModel) onEdit;
  final void Function(int, int, ExerciseNotifier) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exerciseNotifierProvider);
    final notifier = ref.read(exerciseNotifierProvider.notifier);

    return exercisesAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
      ),
      error: (error, stack) => SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Error al cargar ejercicios',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Reintentar',
                onPressed: () => notifier.refresh(lessonId),
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
        ),
      ),
      data: (exercises) {
        if (exercises.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              title: 'No exercises found',
              subtitle: 'Create the first exercise for this lesson',
              icon: Icons.note_add_rounded,
              buttonText: 'Create Exercise',
              onButtonPressed: () => onEdit(ExerciseModel(
                id: 0,
                lesson: lessonId,
                lessonTitle: '',
                questionText: '',
                exerciseType: 'multiple_choice',
                correctAnswer: '',
              )), 
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final exercise = exercises[index];
              return _ExerciseCard(
                exercise: exercise,
                onEdit: () => onEdit(exercise),
                onDelete: () => onDelete(exercise.id, lessonId, notifier),
              );
            },
            childCount: exercises.length,
          ),
        );
      },
    );
  }
}