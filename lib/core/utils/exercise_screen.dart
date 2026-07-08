import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/course_models.dart';
import '../../models/course_providers.dart';

/// Pantalla de ejercicio interactivo para una lección.
/// Soporta los tipos: multiple_choice, fill_blank, true_false.
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
    final correct = _selectedAnswer?.toLowerCase().trim() ==
        exercise.correctAnswer.toLowerCase().trim();

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
      });
      _feedbackController.reset();
    } else {
      _showCompletionDialog(total);
    }
  }

  void _showCompletionDialog(int total) {
    final xp = _correctCount * 20;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1828),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            const Text(
              '¡Lección completada!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
                color: const Color(0xFFFFD700).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
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
                backgroundColor: const Color(0xFF7C4DFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Volver al curso', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesByLessonProvider(widget.lessonId));
    final currentIndex = ref.watch(currentExerciseIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Ejercicio', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent)),
        ),
        data: (exercises) {
          if (exercises.isEmpty) {
            return const Center(
              child: Text('Sin ejercicios disponibles', style: TextStyle(color: Colors.white54)),
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
                color: const Color(0xFF7C4DFF),
                minHeight: 4,
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ejercicio ${safeIndex + 1} de ${exercises.length}',
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$_correctCount correctas',
                          style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 13),
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
                          color: const Color(0xFF1A1828),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          exercise.questionText,
                          style: const TextStyle(
                            color: Colors.white,
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
                                  ? const Color(0xFF4CAF50).withOpacity(0.15)
                                  : const Color(0xFFF44336).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isCorrect
                                    ? const Color(0xFF4CAF50).withOpacity(0.5)
                                    : const Color(0xFFF44336).withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _isCorrect ? '✅ ¡Correcto!' : '❌ Incorrecto',
                                  style: TextStyle(
                                    color: _isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (!_isCorrect) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Respuesta correcta: ${exercise.correctAnswer}',
                                    style: const TextStyle(color: Colors.white60, fontSize: 13),
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
                              ? const Color(0xFF7C4DFF)
                              : Colors.white12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _selectedAnswer == null
                        ? null
                        : _hasAnswered
                            ? () => _nextExercise(exercises.length)
                            : () => _submitAnswer(exercise),
                    child: Text(
                      _hasAnswered ? 'Siguiente →' : 'Verificar respuesta',
                      style: const TextStyle(
                        color: Colors.white,
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
        Color bgColor = const Color(0xFF1A1828);

        if (_hasAnswered) {
          if (isCorrectOption) {
            borderColor = const Color(0xFF4CAF50);
            bgColor = const Color(0xFF4CAF50).withOpacity(0.1);
          } else if (isSelected && !isCorrectOption) {
            borderColor = const Color(0xFFF44336);
            bgColor = const Color(0xFFF44336).withOpacity(0.1);
          }
        } else if (isSelected) {
          borderColor = const Color(0xFF7C4DFF);
          bgColor = const Color(0xFF7C4DFF).withOpacity(0.1);
        }

        return GestureDetector(
          onTap: _hasAnswered ? null : () => setState(() => _selectedAnswer = option),
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
                  child: Text(option, style: const TextStyle(color: Colors.white, fontSize: 15)),
                ),
                if (_hasAnswered && isCorrectOption)
                  const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
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
            onTap: _hasAnswered ? null : () => setState(() => _selectedAnswer = option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: option == 'Verdadero' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF7C4DFF).withOpacity(0.2)
                    : const Color(0xFF1A1828),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? const Color(0xFF7C4DFF) : Colors.white12,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(option == 'Verdadero' ? '✅' : '❌', style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 8),
                  Text(option, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
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
      style: const TextStyle(color: Colors.white),
      onChanged: (value) => setState(() => _selectedAnswer = value),
      enabled: !_hasAnswered,
      decoration: InputDecoration(
        hintText: 'Escribe tu respuesta aquí...',
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1A1828),
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
          borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
        ),
      ),
    );
  }
}
