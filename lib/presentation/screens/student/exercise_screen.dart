import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

/// Pantalla de ejercicio interactivo para una lección.
/// Soporta los tipos: multiple_choice, fill_blank, true_false, translate, match, listen.
class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key, required this.lessonId});

  final int lessonId;

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  int _correctCount = 0;
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;

  // Variables de estado para ejercicios tipo Match (emparejamiento)
  String? _selectedLeftMatch;
  String? _selectedRightMatch;
  final Map<String, String> _completedMatches = {};
  final List<String> _leftMatchItems = [];
  final List<String> _rightMatchItems = [];

  // Variables de estado para ejercicios tipo Translate (burbujas de palabras)
  List<String>? _availableTranslateWords;
  List<String>? _selectedTranslateWords;

  // Variables de estado para ejercicios tipo Listen (reproductor de audio)
  bool _isPlayingAudioExercise = false;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _feedbackAnimation = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitAnswer(ExerciseModel exercise) {
    if (_hasAnswered) return;

    // Para el tipo match, la respuesta correcta se compara con 'completed' si el usuario emparejó todas
    bool correct;
    if (exercise.exerciseType == 'match') {
      correct = _selectedAnswer == 'completed';
    } else {
      correct = _selectedAnswer?.toLowerCase().trim() ==
          exercise.correctAnswer.toLowerCase().trim();
    }

    setState(() {
      _hasAnswered = true;
      _isCorrect = correct;
      if (correct) _correctCount++;
    });

    _feedbackController.forward(from: 0);
  }

  void _nextExercise(int total) {
    final currentIndex = ref.read(currentExerciseIndexProvider);
    if (currentIndex < total - 1) {
      ref.read(currentExerciseIndexProvider.notifier).state = currentIndex + 1;
      setState(() {
        _selectedAnswer = null;
        _hasAnswered = false;
        _isCorrect = false;

        // Resetear estados adicionales
        _selectedLeftMatch = null;
        _selectedRightMatch = null;
        _completedMatches.clear();
        _leftMatchItems.clear();
        _rightMatchItems.clear();
        _availableTranslateWords = null;
        _selectedTranslateWords = null;
        _isPlayingAudioExercise = false;
      });
      _feedbackController.reset();
    } else {
      _showCompletionDialog(total);
    }
  }

  void _showCompletionDialog(int total) {
    final xp = _correctCount * 20;

    // Registrar progreso en la API (POST /api/progress/)
    ref.read(progressNotifierProvider.notifier).registerLessonProgress(
          lessonId: widget.lessonId,
          status: 'completed',
          score: (_correctCount / total) * 100,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            const Text(
              '¡Lección completada!',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctCount / $total correctas',
              style: const TextStyle(color: Colors.white60, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
              ),
              child: Text(
                '⚡ +$xp XP ganados',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Volver al curso',
                  style: TextStyle(color: AppColors.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync =
        ref.watch(exercisesByLessonProvider(widget.lessonId));
    final currentIndex = ref.watch(currentExerciseIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Ejercicio', style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: exercisesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: const TextStyle(color: Colors.redAccent)),
        ),
        data: (exercises) {
          if (exercises.isEmpty) {
            return const Center(
              child: Text('Sin ejercicios disponibles',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          final safeIndex = currentIndex.clamp(0, exercises.length - 1);
          final exercise = exercises[safeIndex];

          return Column(
            children: [
              // ── Barra de progreso ──────────────────────────────────
              LinearProgressIndicator(
                value: (safeIndex + 1) / exercises.length,
                backgroundColor: Colors.white12,
                color: AppColors.primary,
                minHeight: 4,
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ejercicio ${safeIndex + 1} de ${exercises.length}',
                      style:
                          const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Color(0xFF4CAF50), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$_correctCount correctas',
                          style: const TextStyle(
                              color: Color(0xFF4CAF50), fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Pregunta ────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          exercise.questionText,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Opciones según tipo ──────────────────────────
                      if (exercise.exerciseType == 'multiple_choice')
                        _buildMultipleChoice(exercise)
                      else if (exercise.exerciseType == 'true_false')
                        _buildTrueFalse(exercise)
                      else if (exercise.exerciseType == 'translate')
                        _buildTranslate(exercise)
                      else if (exercise.exerciseType == 'match')
                        _buildMatch(exercise)
                      else if (exercise.exerciseType == 'listen')
                        _buildListen(exercise)
                      else
                        _buildFillBlank(exercise),

                      // ── Feedback de respuesta ───────────────────────
                      if (_hasAnswered) ...[
                        const SizedBox(height: 20),
                        ScaleTransition(
                          scale: _feedbackAnimation,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _isCorrect
                                  ? const Color(0xFF4CAF50)
                                      .withValues(alpha: 0.15)
                                  : const Color(0xFFF44336)
                                      .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isCorrect
                                    ? const Color(0xFF4CAF50)
                                        .withValues(alpha: 0.5)
                                    : const Color(0xFFF44336)
                                        .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _isCorrect ? '✅ ¡Correcto!' : '❌ Incorrecto',
                                  style: TextStyle(
                                    color: _isCorrect
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFF44336),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (!_isCorrect) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Respuesta correcta: ${exercise.correctAnswer}',
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Botón de acción ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasAnswered
                          ? const Color(0xFF4CAF50)
                          : (_selectedAnswer != null
                              ? AppColors.primary
                              : Colors.white12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _selectedAnswer == null
                        ? null
                        : _hasAnswered
                            ? () => _nextExercise(exercises.length)
                            : () => _submitAnswer(exercise),
                    child: Text(
                      _hasAnswered ? 'Siguiente →' : 'Verificar respuesta',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMultipleChoice(ExerciseModel exercise) {
    // Opciones simuladas — en producción vendrían del backend
    final options = [
      exercise.correctAnswer,
      'Opción B',
      'Opción C',
      'Opción D',
    ]..shuffle();

    return Column(
      children: options.map((option) {
        final isSelected = _selectedAnswer == option;
        final isCorrectOption = option == exercise.correctAnswer;
        Color borderColor = Colors.white12;
        Color bgColor = AppColors.surface;

        if (_hasAnswered) {
          if (isCorrectOption) {
            borderColor = const Color(0xFF4CAF50);
            bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.1);
          } else if (isSelected && !isCorrectOption) {
            borderColor = const Color(0xFFF44336);
            bgColor = const Color(0xFFF44336).withValues(alpha: 0.1);
          }
        } else if (isSelected) {
          borderColor = AppColors.primary;
          bgColor = AppColors.primary.withValues(alpha: 0.1);
        }

        return GestureDetector(
          onTap: _hasAnswered
              ? null
              : () => setState(() => _selectedAnswer = option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(option,
                      style:
                          const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
                ),
                if (_hasAnswered && isCorrectOption)
                  const Icon(Icons.check_circle,
                      color: Color(0xFF4CAF50), size: 20),
                if (_hasAnswered && isSelected && !isCorrectOption)
                  const Icon(Icons.cancel, color: Color(0xFFF44336), size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalse(ExerciseModel exercise) {
    return Row(
      children: ['Verdadero', 'Falso'].map((option) {
        final isSelected = _selectedAnswer == option;
        return Expanded(
          child: GestureDetector(
            onTap: _hasAnswered
                ? null
                : () => setState(() => _selectedAnswer = option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: option == 'Verdadero' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white12,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(option == 'Verdadero' ? '✅' : '❌',
                      style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 8),
                  Text(option,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFillBlank(ExerciseModel exercise) {
    return TextField(
      style: const TextStyle(color: AppColors.textPrimary),
      onChanged: (value) => setState(() => _selectedAnswer = value),
      enabled: !_hasAnswered,
      decoration: InputDecoration(
        hintText: 'Escribe tu respuesta aquí...',
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildTranslate(ExerciseModel exercise) {
    if (_availableTranslateWords == null) {
      final parts = exercise.correctAnswer.split(' ');
      _selectedTranslateWords = [];
      _availableTranslateWords = List<String>.from(parts)
        ..addAll([
          'té',
          'café',
          'vaso',
          'leche',
          'por',
          'favor',
          'mesa',
          'caliente',
          'frío'
        ])
        ..shuffle();
      _availableTranslateWords = _availableTranslateWords!.toSet().toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: _selectedTranslateWords!.isEmpty
              ? const Center(
                  child: Text('Toca las palabras para traducir',
                      style: TextStyle(color: Colors.white38, fontSize: 14)))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTranslateWords!.map((word) {
                    return ActionChip(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.2),
                      side: const BorderSide(color: AppColors.primary),
                      label: Text(word,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold)),
                      onPressed: _hasAnswered
                          ? null
                          : () {
                              setState(() {
                                _selectedTranslateWords!.remove(word);
                                _availableTranslateWords!.add(word);
                                _selectedAnswer =
                                    _selectedTranslateWords!.join(' ');
                              });
                            },
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTranslateWords!.map((word) {
            return ActionChip(
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: Colors.white12),
              label: Text(word, style: const TextStyle(color: AppColors.textPrimary)),
              onPressed: _hasAnswered
                  ? null
                  : () {
                      setState(() {
                        _availableTranslateWords!.remove(word);
                        _selectedTranslateWords!.add(word);
                        _selectedAnswer = _selectedTranslateWords!.join(' ');
                      });
                    },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMatch(ExerciseModel exercise) {
    if (_leftMatchItems.isEmpty) {
      final pairs = exercise.correctAnswer.split(', ');
      for (final pair in pairs) {
        final kv = pair.split('=');
        if (kv.length == 2) {
          _leftMatchItems.add(kv[0].trim());
          _rightMatchItems.add(kv[1].trim());
        }
      }
      _leftMatchItems.shuffle();
      _rightMatchItems.shuffle();
    }

    final correctMap = <String, String>{};
    final pairs = exercise.correctAnswer.split(', ');
    for (final pair in pairs) {
      final kv = pair.split('=');
      if (kv.length == 2) {
        correctMap[kv[0].trim()] = kv[1].trim();
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: _leftMatchItems.map((left) {
              final isCompleted = _completedMatches.containsKey(left);
              final isSelected = _selectedLeftMatch == left;
              Color borderColor = Colors.white12;
              Color bgColor = AppColors.surface;

              if (isCompleted) {
                borderColor = const Color(0xFF4CAF50).withValues(alpha: 0.5);
                bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.1);
              } else if (isSelected) {
                borderColor = AppColors.primary;
                bgColor = AppColors.primary.withValues(alpha: 0.15);
              }

              return GestureDetector(
                onTap: _hasAnswered || isCompleted
                    ? null
                    : () {
                        setState(() {
                          _selectedLeftMatch = left;
                          _checkMatchSelection(correctMap);
                        });
                      },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Text(
                    left,
                    style: TextStyle(
                      color: isCompleted ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: _rightMatchItems.map((right) {
              final isCompleted = _completedMatches.containsValue(right);
              final isSelected = _selectedRightMatch == right;
              Color borderColor = Colors.white12;
              Color bgColor = AppColors.surface;

              if (isCompleted) {
                borderColor = const Color(0xFF4CAF50).withValues(alpha: 0.5);
                bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.1);
              } else if (isSelected) {
                borderColor = AppColors.primary;
                bgColor = AppColors.primary.withValues(alpha: 0.15);
              }

              return GestureDetector(
                onTap: _hasAnswered || isCompleted
                    ? null
                    : () {
                        setState(() {
                          _selectedRightMatch = right;
                          _checkMatchSelection(correctMap);
                        });
                      },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Text(
                    right,
                    style: TextStyle(
                      color: isCompleted ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _checkMatchSelection(Map<String, String> correctMap) {
    if (_selectedLeftMatch != null && _selectedRightMatch != null) {
      if (correctMap[_selectedLeftMatch] == _selectedRightMatch) {
        _completedMatches[_selectedLeftMatch!] = _selectedRightMatch!;
        _selectedLeftMatch = null;
        _selectedRightMatch = null;

        if (_completedMatches.length == _leftMatchItems.length) {
          _selectedAnswer = 'completed';
        }
      } else {
        _selectedLeftMatch = null;
        _selectedRightMatch = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No coinciden. ¡Inténtalo de nuevo!'),
              duration: Duration(milliseconds: 600)),
        );
      }
    }
  }

  Widget _buildListen(ExerciseModel exercise) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _isPlayingAudioExercise = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() => _isPlayingAudioExercise = false);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Icon(
                    _isPlayingAudioExercise
                        ? Icons.volume_up
                        : Icons.play_arrow,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isPlayingAudioExercise
                    ? 'Escuchando...'
                    : 'Toca para reproducir el audio',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFillBlank(exercise),
      ],
    );
  }
}
