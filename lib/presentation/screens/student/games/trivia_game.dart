import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

class TriviaGame extends ConsumerStatefulWidget {
  const TriviaGame({super.key});
  @override
  ConsumerState<TriviaGame> createState() => _TriviaGameState();
}

class _TriviaGameState extends ConsumerState<TriviaGame> {
  final _questions = [
    {
      'q': 'What is the plural of "child"?',
      'options': ['Childs', 'Children', 'Childes', 'Childrens'],
      'correct': 1,
    },
    {
      'q': '"She ___ to school every day." (go)',
      'options': ['go', 'going', 'goes', 'gone'],
      'correct': 2,
    },
    {
      'q': 'Which is NOT a vowel?',
      'options': ['A', 'E', 'R', 'I'],
      'correct': 2,
    },
    {
      'q': 'The past tense of "run" is:',
      'options': ['Runned', 'Ran', 'Run', 'Running'],
      'correct': 1,
    },
    {
      'q': 'Which word is a synonym of "Happy"?',
      'options': ['Sad', 'Angry', 'Joyful', 'Tired'],
      'correct': 2,
    },
  ];

  int _current = 0;
  int? _selected;
  int _score = 0;
  bool _done = false;
  bool _submitting = false;

  void _answer(int idx) {
    if (_selected != null || _submitting) return;
    
    final correct = _questions[_current]['correct'] as int;
    setState(() {
      _selected = idx;
      if (idx == correct) {
        HapticFeedback.mediumImpact();
        _score += 20;
      } else {
        HapticFeedback.vibrate();
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _selected = null;
          if (_current < _questions.length - 1) {
            _current++;
          } else {
            _done = true;
            _submitScore();
          }
        });
      }
    });
  }

  Future<void> _submitScore() async {
    setState(() => _submitting = true);
    try {
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 4, // Placeholder para Trivia
            status: 'completed',
            score: _score.toDouble(),
          );
      ref.invalidate(userStatsProvider);
      ref.invalidate(progressSummaryProvider);
      ref.invalidate(rankingProvider);
    } catch (e) {
      debugPrint('Error al subir puntuación: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _ResultScreen(score: _score, total: _questions.length * 20, isSubmitting: _submitting);
    
    final q = _questions[_current];
    final options = q['options'] as List<String>;
    final correct = q['correct'] as int;

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('❓ Trivia ${_current + 1}/${_questions.length}', style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_current + 1) / _questions.length,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3D)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(q['q'] as String, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, height: 1.5)),
            ),
            const SizedBox(height: 32),
            ...List.generate(options.length, (i) {
              Color bg = const Color(0xFF2A2A3D);
              if (_selected != null) {
                if (i == correct) {
                  bg = Colors.green.withValues(alpha: 0.4);
                } else if (i == _selected) {
                  bg = Colors.red.withValues(alpha: 0.4);
                }
              }
              return GestureDetector(
                onTap: () => _answer(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                        child: Center(child: Text('ABCD'[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(width: 14),
                      Text(options[i], style: const TextStyle(color: Colors.white, fontSize: 15)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  final int score, total;
  final bool isSubmitting;
  const _ResultScreen({required this.score, required this.total, required this.isSubmitting});

  @override
  Widget build(BuildContext context) {
    final pct = score / total;
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSubmitting) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Guardando progreso...', style: TextStyle(color: Colors.white70)),
            ] else ...[
              Text(pct >= 0.8 ? '🏆' : pct >= 0.5 ? '⭐' : '💪', style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 20),
              Text('$score / $total XP', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(pct >= 0.8 ? '¡Excelente!' : pct >= 0.5 ? '¡Bien hecho!' : 'Sigue practicando', style: const TextStyle(color: Colors.white70, fontSize: 18)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Volver a Juegos', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
