import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/course_models.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter/services.dart';

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
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => _showExitConfirmation(),
        ),
        title: exercisesAsync.when(
          data: (exercises) => ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: exercises.isEmpty ? 0 : (currentIndex + 1) / exercises.length,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
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
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on_rounded, color: Colors.amberAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_correctCount * 20}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
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
      body: Stack(
        children: [
          Positioned(top: -100, left: -100, child: _blob(Colors.blueAccent, 300)),
          Positioned(bottom: -50, right: -50, child: _blob(Colors.purpleAccent, 250)),
          exercisesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
            error: (err, _) => _ErrorState(onRetry: () => ref.refresh(exercisesByLessonProvider(widget.lessonId))),
            data: (exercises) {
              if (exercises.isEmpty) {
                return const Center(child: Text('No hay ejercicios disponibles.', style: TextStyle(color: Colors.white70)));
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getExerciseTypeLabel(exercise.exerciseType),
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeInDown(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              exercise.questionText,
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
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
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: 0.08),
      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 100)],
    ),
  );

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
        color: const Color(0xFF1E1E2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasAnswered)
            FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (_isCorrect ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (_isCorrect ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: _isCorrect ? Colors.greenAccent : Colors.redAccent,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isCorrect ? '¡Excelente trabajo!' : 'No exactamente',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: _isCorrect ? Colors.greenAccent : Colors.redAccent,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (!_isCorrect)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Respuesta: ${exercise.correctAnswer}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white70,
                                ),
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
                ? (_isCorrect ? Colors.greenAccent : Colors.redAccent)
                : Colors.blueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: Text(
              _hasAnswered ? 'CONTINUAR' : 'VERIFICAR',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
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

    if (correct) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.vibrate();
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
    HapticFeedback.heavyImpact();
    
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
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          borderRadius: BorderRadius.circular(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_tou9dfsq.json', // Trophy
                width: 200,
                height: 200,
                repeat: false,
              ),
              Text(
                '¡Lección Superada!',
                style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                'Has respondido correctamente a\n$_correctCount de $total ejercicios.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on_rounded, color: Colors.amberAccent, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('+$xp', style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                        Text('XP GANADOS', style: AppTextStyles.labelSmall.copyWith(color: Colors.white60)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog
                  Navigator.pop(context); // Screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('CONTINUAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('¿Quieres salir?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Tu progreso en este ejercicio no se guardará.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('SALIR', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassContainer(
            onTap: _hasAnswered ? null : () => setState(() => _selectedAnswer = option),
            opacity: isSelected ? 0.2 : 0.05,
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blueAccent : Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: isSelected 
                    ? const Center(child: Icon(Icons.circle, size: 14, color: Colors.blueAccent))
                    : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blueAccent : Colors.white,
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
        _buildChoiceCard('Verdadero', Icons.check_rounded, Colors.greenAccent),
        const SizedBox(width: 20),
        _buildChoiceCard('Falso', Icons.close_rounded, Colors.redAccent),
      ],
    );
  }

  Widget _buildChoiceCard(String label, IconData icon, Color color) {
    final isSelected = _selectedAnswer == label;
    return Expanded(
      child: GlassContainer(
        onTap: _hasAnswered ? null : () => setState(() => _selectedAnswer = label),
        opacity: isSelected ? 0.2 : 0.05,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white38, size: 48),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? color : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillBlank(ExerciseModel exercise) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(20),
      child: TextField(
        onChanged: (val) => setState(() => _selectedAnswer = val),
        enabled: !_hasAnswered,
        style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Escribe tu respuesta...',
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(24),
        ),
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
        GlassContainer(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 140),
          opacity: 0.05,
          borderRadius: BorderRadius.circular(24),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _selectedTranslateWords!.map((word) => ActionChip(
              label: Text(word, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              onPressed: _hasAnswered ? null : () {
                setState(() {
                  _selectedTranslateWords!.remove(word);
                  _availableTranslateWords!.add(word);
                  _selectedAnswer = _selectedTranslateWords!.join(' ');
                });
              },
              backgroundColor: Colors.blueAccent.withValues(alpha: 0.3),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            )).toList(),
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableTranslateWords!.map((word) => ActionChip(
            label: Text(word, style: const TextStyle(color: Colors.white70)),
            onPressed: _hasAnswered ? null : () {
              setState(() {
                _availableTranslateWords!.remove(word);
                _selectedTranslateWords!.add(word);
                _selectedAnswer = _selectedTranslateWords!.join(' ');
              });
            },
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            side: const BorderSide(color: Colors.white10),
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
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
              boxShadow: [
                BoxShadow(color: const Color(0xFF2575FC).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() => _isPlayingAudioExercise = true);
                Future.delayed(const Duration(seconds: 2), () => setState(() => _isPlayingAudioExercise = false));
              },
              icon: Icon(_isPlayingAudioExercise ? Icons.volume_up_rounded : Icons.play_arrow_rounded, size: 56, color: Colors.white),
            ),
          ),
          const SizedBox(height: 48),
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
          const Icon(Icons.error_outline_rounded, size: 80, color: Colors.redAccent),
          const SizedBox(height: 24),
          const Text('Algo salió mal al cargar los ejercicios', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

