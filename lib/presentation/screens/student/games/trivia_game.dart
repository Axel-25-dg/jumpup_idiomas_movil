import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class TriviaGame extends ConsumerStatefulWidget {
  const TriviaGame({super.key});
  @override
  ConsumerState<TriviaGame> createState() => _TriviaGameState();
}

class _TriviaGameState extends ConsumerState<TriviaGame> {
  final Map<int, List<Map<String, dynamic>>> _questionPool = {
    1: [ // Básico
      {'q': 'What is the plural of "child"?', 'options': ['Childs', 'Children', 'Childes', 'Childrens'], 'correct': 1},
      {'q': 'Which is NOT a vowel?', 'options': ['A', 'E', 'R', 'I'], 'correct': 2},
      {'q': '"She ___ to school every day."', 'options': ['go', 'going', 'goes', 'gone'], 'correct': 2},
      {'q': 'Opposite of "Hot" is:', 'options': ['Warm', 'Cold', 'Ice', 'Sun'], 'correct': 1},
      {'q': 'How do you say "Hola" in English?', 'options': ['Bye', 'Hello', 'Please', 'Thanks'], 'correct': 1},
      {'q': 'Which color is a mix of Red and White?', 'options': ['Blue', 'Pink', 'Green', 'Yellow'], 'correct': 1},
      {'q': 'What is the opposite of "Big"?', 'options': ['Large', 'Tall', 'Small', 'High'], 'correct': 2},
    ],
    2: [ // Intermedio
      {'q': 'Which sentence is correct?', 'options': ['I has a car', 'He have a car', 'They has a car', 'She has a car'], 'correct': 3},
      {'q': 'Past tense of "Buy":', 'options': ['Buyed', 'Bought', 'Boughten', 'Buying'], 'correct': 1},
      {'q': 'A person who cooks is a:', 'options': ['Cooker', 'Chef', 'Chicken', 'Kitchen'], 'correct': 1},
      {'q': 'Choose the correct preposition: "I am interested ___ music."', 'options': ['on', 'at', 'in', 'for'], 'correct': 2},
      {'q': 'Identify the adverb: "She ran quickly."', 'options': ['She', 'ran', 'quickly', 'none'], 'correct': 2},
      {'q': 'Which word is a synonym for "Happy"?', 'options': ['Sad', 'Angry', 'Joyful', 'Tired'], 'correct': 2},
    ],
    3: [ // Avanzado
      {'q': 'If I ___ you, I would study more.', 'options': ['was', 'am', 'were', 'be'], 'correct': 2},
      {'q': 'Meaning of "Break a leg":', 'options': ['Get hurt', 'Good luck', 'Dance', 'Fail'], 'correct': 1},
      {'q': 'Which is a synonym of "Fastidious"?', 'options': ['Quick', 'Boring', 'Meticulous', 'Funny'], 'correct': 2},
      {'q': 'Select the correctly spelled word:', 'options': ['Accomodate', 'Acommodate', 'Accommodate', 'Acomodate'], 'correct': 2},
      {'q': 'What does "Call it a day" mean?', 'options': ['Start working', 'Stop working', 'Call someone', 'Have lunch'], 'correct': 1},
      {'q': 'The movie was ___ better than I expected.', 'options': ['far', 'more', 'very', 'too'], 'correct': 0},
    ]
  };

  List<Map<String, dynamic>> _sessionQuestions = [];
  static final Set<String> _usedGlobal = {}; // Evitar repetir en la misma sesión de la app

  int _current = 0;
  int? _selected;
  int _score = 0;
  bool _done = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    final List<Map<String, dynamic>> allAvailable = [];
    
    // Intentar obtener preguntas no usadas globalmente primero
    for (int lvl = 1; lvl <= 3; lvl++) {
      final pool = List<Map<String, dynamic>>.from(_questionPool[lvl]!);
      pool.shuffle();
      
      final unused = pool.where((q) => !_usedGlobal.contains(q['q'])).toList();
      
      if (unused.length < 2) {
        // Si no hay suficientes nuevas, limpiar rastro y usar del pool
        _usedGlobal.removeWhere((q) => pool.any((pq) => pq['q'] == q));
        allAvailable.addAll(pool.take(2));
      } else {
        allAvailable.addAll(unused.take(2));
      }
    }

    _sessionQuestions = allAvailable..shuffle();
    for (var q in _sessionQuestions) {
      _usedGlobal.add(q['q'] as String);
    }
    
    _current = 0;
    _score = 0;
    _done = false;
  }

  void _answer(int idx) {
    if (_selected != null || _submitting) return;
    
    final correct = _sessionQuestions[_current]['correct'] as int;
    setState(() {
      _selected = idx;
      if (idx == correct) {
        HapticFeedback.mediumImpact();
        // Más puntos por niveles altos
        int points = (_current < 2) ? 15 : (_current < 4 ? 25 : 40); // Aumento de puntos
        _score += points;
        _xpEarned += points;
      } else {
        HapticFeedback.vibrate();
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _selected = null;
          if (_current < _sessionQuestions.length - 1) {
            _current++;
          } else {
            _done = true;
            _submitScore();
          }
        });
      }
    });
  }

  int _xpEarned = 0; // Añadir esta variable

  Future<void> _submitScore() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 14, // ID único para Trivia
            status: 'completed',
            score: _xpEarned.toDouble(),
            xpEarned: _xpEarned,
          );

    } catch (e) {
      debugPrint('[Trivia] Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D0D15) : Colors.grey[50]!;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (_done) return _ResultScreen(score: _score, total: _sessionQuestions.length * 20, isSubmitting: _submitting, isDark: isDark);
    
    final q = _sessionQuestions[_current];
    final options = q['options'] as List<String>;
    final correct = q['correct'] as int;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(top: -100, right: -50, child: _BlurBlob(color: const Color(0xFF6A11CB).withValues(alpha: 0.1), size: 300)),
            Positioned(bottom: -50, left: -50, child: _BlurBlob(color: const Color(0xFF2575FC).withValues(alpha: 0.1), size: 250)),
          ],
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, textColor),
                _buildProgressHeader(textColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildQuestionCard(q['q'] as String, isDark, textColor),
                        const SizedBox(height: 40),
                        ...List.generate(options.length, (i) => _buildOptionTile(i, options[i], correct, isDark, textColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: textColor),
          ),
          const Text(
            '❓ TRIVIA QUIZ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PREGUNTA ${_current + 1}/${_sessionQuestions.length}', style: TextStyle(color: textColor.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 12)),
              Text('$_score XP', style: const TextStyle(color: Color(0xFF2575FC), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_current + 1) / _sessionQuestions.length,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2575FC)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String question, bool isDark, Color textColor) {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      borderRadius: BorderRadius.circular(24),
      child: Text(
        question,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildOptionTile(int index, String text, int correctIndex, bool isDark, Color textColor) {
    bool isSelected = _selected == index;
    bool showCorrect = _selected != null && index == correctIndex;
    bool showWrong = _selected == index && index != correctIndex;

    Color borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);
    Color bgColor = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white;

    if (showCorrect) {
      borderColor = Colors.greenAccent;
      bgColor = Colors.greenAccent.withValues(alpha: 0.1);
    } else if (showWrong) {
      borderColor = Colors.redAccent;
      bgColor = Colors.redAccent.withValues(alpha: 0.1);
    } else if (isSelected) {
      borderColor = const Color(0xFF2575FC);
    }

    return GestureDetector(
      onTap: () => _answer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            if (isSelected) BoxShadow(color: borderColor.withValues(alpha: 0.2), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: isSelected ? borderColor : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'ABCD'[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: showCorrect ? Colors.greenAccent : (showWrong ? Colors.redAccent : textColor),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showCorrect) const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
            if (showWrong) const Icon(Icons.cancel_rounded, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  final int score, total;
  final bool isSubmitting;
  final bool isDark;
  const _ResultScreen({required this.score, required this.total, required this.isSubmitting, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final pct = score / total;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D15) : Colors.grey[50]!,
      body: Center(
        child: GlassContainer(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(40),
          borderRadius: BorderRadius.circular(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSubmitting) ...[
                const CircularProgressIndicator(color: Color(0xFF2575FC)),
                const SizedBox(height: 24),
                Text('Sincronizando XP...', style: TextStyle(color: textColor.withValues(alpha: 0.7))),
              ] else ...[
                Text(pct >= 0.8 ? '🏆' : pct >= 0.5 ? '⭐' : '💪', style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                Text('$score / $total XP', style: TextStyle(color: textColor, fontSize: 42, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(
                  pct >= 0.8 ? '¡PERFECTO!' : pct >= 0.5 ? '¡MUY BIEN!' : 'SIGUE ASÍ',
                  style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('FINALIZAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => context.push(AppRoutes.studentRanking),
                  icon: const Icon(Icons.emoji_events_rounded, color: Colors.amber),
                  label: const Text('VER RANKING GLOBAL', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 100,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}
