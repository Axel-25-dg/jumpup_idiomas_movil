import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/course_models.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:lottie/lottie.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key, required this.lessonId});

  final int lessonId;

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> with SingleTickerProviderStateMixin {
  String? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  int _correctCount = 0;
  
  // Variables de estado adicionales
  String? _selectedLeftMatch;
  String? _selectedRightMatch;
  final Map<String, String> _completedMatches = {};
  final List<String> _leftMatchItems = [];
  final List<String> _rightMatchItems = [];
  List<String>? _availableTranslateWords;
  List<String>? _selectedTranslateWords;
  bool _isPlayingAudioExercise = false;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesByLessonProvider(widget.lessonId));
    final currentIndex = ref.watch(currentExerciseIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => _showExitConfirmation(),
        ),
        title: exercisesAsync.when(
          data: (exercises) => ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: exercises.isEmpty ? 0 : (currentIndex + 1) / exercises.length,
              minHeight: 10,
              backgroundColor: AppColors.divider.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_correctCount * 20}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => _ErrorState(onRetry: () => ref.refresh(exercisesByLessonProvider(widget.lessonId))),
        data: (exercises) {
          if (exercises.isEmpty) {
            return const Center(child: Text('No hay ejercicios disponibles para esta lección.'));
          }

          final exercise = exercises[currentIndex.clamp(0, exercises.length - 1)];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          _getExerciseTypeLabel(exercise.exerciseType),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          exercise.questionText,
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      _buildExerciseContent(exercise),
                    ],
                  ),
                ),
              ),
              _buildBottomAction(exercise, exercises.length),
            ],
          );
        },
      ),
    );
  }

  String _getExerciseTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice': return 'OPCIÓN MÚLTIPLE';
      case 'true_false': return 'VERDADERO O FALSO';
      case 'translate': return 'TRADUCCIÓN';
      case 'match': return 'EMPAREJAMIENTO';
      case 'listen': return 'COMPRENSIÓN AUDITIVA';
      case 'fill_blank': return 'COMPLETAR';
      default: return 'EJERCICIO';
    }
  }

  Widget _buildExerciseContent(ExerciseModel exercise) {
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: switch (exercise.exerciseType) {
        'multiple_choice' => _buildMultipleChoice(exercise),
        'true_false' => _buildTrueFalse(exercise),
        'translate' => _buildTranslate(exercise),
        'match' => _buildMatch(exercise),
        'listen' => _buildListen(exercise),
        _ => _buildFillBlank(exercise),
      },
    );
  }

  Widget _buildBottomAction(ExerciseModel exercise, int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasAnswered)
            FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (_isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (_isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: _isCorrect ? AppColors.success : AppColors.error,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isCorrect ? '¡Excelente trabajo!' : 'No exactamente',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: _isCorrect ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (!_isCorrect)
                            Text(
                              'Respuesta: ${exercise.correctAnswer}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          ElevatedButton(
            onPressed: _selectedAnswer == null && !_hasAnswered
                ? null 
                : () => _hasAnswered ? _nextExercise(total) : _submitAnswer(exercise),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasAnswered 
                ? (_isCorrect ? AppColors.success : AppColors.error)
                : AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              _hasAnswered ? 'CONTINUAR' : 'VERIFICAR',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitAnswer(ExerciseModel exercise) {
    bool correct;
    if (exercise.exerciseType == 'match') {
      correct = _selectedAnswer == 'completed';
    } else {
      correct = _selectedAnswer?.toLowerCase().trim() == exercise.correctAnswer.toLowerCase().trim();
    }

    setState(() {
      _hasAnswered = true;
      _isCorrect = correct;
      if (correct) _correctCount++;
    });

    // Submit to backend for XP tracking (fire and forget)
    if (_selectedAnswer != null) {
      ref.read(exerciseSubmitNotifierProvider.notifier).submitExercise(
            exerciseId: exercise.id,
            answer: _selectedAnswer!,
          );
    }
  }

  void _nextExercise(int total) {
    final currentIndex = ref.read(currentExerciseIndexProvider);
    if (currentIndex < total - 1) {
      ref.read(currentExerciseIndexProvider.notifier).state = currentIndex + 1;
      setState(() {
        _selectedAnswer = null;
        _hasAnswered = false;
        _isCorrect = false;
        _selectedLeftMatch = null;
        _selectedRightMatch = null;
        _completedMatches.clear();
        _leftMatchItems.clear();
        _rightMatchItems.clear();
        _availableTranslateWords = null;
        _selectedTranslateWords = null;
        _isPlayingAudioExercise = false;
      });
    } else {
      _showCompletionDialog(total);
    }
  }

  void _showCompletionDialog(int total) {
    final xp = _correctCount * 20;
    
    ref.read(progressNotifierProvider.notifier).registerLessonProgress(
      lessonId: widget.lessonId,
      status: 'completed',
      score: (_correctCount / total) * 100,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_tou9dfsq.json', // Trophy
                width: 180,
                height: 180,
                repeat: false,
              ),
              Text(
                '¡Lección Superada!',
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Has respondido correctamente a\n$_correctCount de $total ejercicios.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              StatBadge(
                icon: Icons.flash_on_rounded,
                value: '+$xp',
                label: 'XP GANADOS',
                color: Colors.orange,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog
                  Navigator.pop(context); // Screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('CONTINUAR', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Quieres salir?'),
        content: const Text('Tu progreso en este ejercicio no se guardará.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('SALIR', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoice(ExerciseModel exercise) {
    // In a real app, options would come from the model
    final options = [exercise.correctAnswer, 'Opción Incorrecta 1', 'Opción Incorrecta 2', 'Opción Incorrecta 3']..shuffle();

    return Column(
      children: options.map((option) {
        final isSelected = _selectedAnswer == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StudentCard(
            onTap: _hasAnswered ? null : () => setState(() => _selectedAnswer = option),
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
            borderRadius: 16,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: isSelected 
                    ? const Center(child: Icon(Icons.circle, size: 12, color: AppColors.primary))
                    : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalse(ExerciseModel exercise) {
    return Row(
      children: [
        _buildChoiceCard('Verdadero', Icons.check_rounded, AppColors.success),
        const SizedBox(width: 16),
        _buildChoiceCard('Falso', Icons.close_rounded, AppColors.error),
      ],
    );
  }

  Widget _buildChoiceCard(String label, IconData icon, Color color) {
    final isSelected = _selectedAnswer == label;
    return Expanded(
      child: StudentCard(
        onTap: _hasAnswered ? null : () => setState(() => _selectedAnswer = label),
        color: isSelected ? color.withValues(alpha: 0.1) : AppColors.white,
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textHint, size: 40),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? color : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillBlank(ExerciseModel exercise) {
    return TextField(
      onChanged: (val) => setState(() => _selectedAnswer = val),
      enabled: !_hasAnswered,
      style: AppTextStyles.titleMedium,
      decoration: InputDecoration(
        hintText: 'Escribe tu respuesta...',
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildTranslate(ExerciseModel exercise) {
    if (_availableTranslateWords == null) {
      final parts = exercise.correctAnswer.split(' ');
      _selectedTranslateWords = [];
      _availableTranslateWords = List<String>.from(parts)..addAll(['the', 'and', 'but', 'not', 'very'])..shuffle();
      _availableTranslateWords = _availableTranslateWords!.toSet().toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTranslateWords!.map((word) => ActionChip(
              label: Text(word, style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _hasAnswered ? null : () {
                setState(() {
                  _selectedTranslateWords!.remove(word);
                  _availableTranslateWords!.add(word);
                  _selectedAnswer = _selectedTranslateWords!.join(' ');
                });
              },
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            )).toList(),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableTranslateWords!.map((word) => ActionChip(
            label: Text(word),
            onPressed: _hasAnswered ? null : () {
              setState(() {
                _availableTranslateWords!.remove(word);
                _selectedTranslateWords!.add(word);
                _selectedAnswer = _selectedTranslateWords!.join(' ');
              });
            },
            backgroundColor: AppColors.white,
            side: const BorderSide(color: AppColors.divider),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMatch(ExerciseModel exercise) {
    // Similar to existing logic but styled
    return const Center(child: Text('Implementación de Match con diseño premium'));
  }

  Widget _buildListen(ExerciseModel exercise) {
    return Center(
      child: Column(
        children: [
          IconButton.filled(
            onPressed: () {
              setState(() => _isPlayingAudioExercise = true);
              Future.delayed(const Duration(seconds: 2), () => setState(() => _isPlayingAudioExercise = false));
            },
            icon: Icon(_isPlayingAudioExercise ? Icons.volume_up_rounded : Icons.play_arrow_rounded, size: 48),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(100, 100),
            ),
          ),
          const SizedBox(height: 32),
          _buildFillBlank(exercise),
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
          const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          const Text('Error al cargar ejercicios'),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

