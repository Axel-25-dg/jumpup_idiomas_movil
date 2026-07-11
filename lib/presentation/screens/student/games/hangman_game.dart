import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

class HangmanGame extends ConsumerStatefulWidget {
  const HangmanGame({super.key});
  @override
  ConsumerState<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends ConsumerState<HangmanGame> {
  final _words = [
    {'word': 'FLUTTER', 'hint': 'Framework de UI'},
    {'word': 'LANGUAGE', 'hint': 'Idioma'},
    {'word': 'COMPUTER', 'hint': 'Computadora'},
    {'word': 'KEYBOARD', 'hint': 'Teclado'},
    {'word': 'MORNING', 'hint': 'Buenos días...'},
    {'word': 'SUCCESS', 'hint': 'Éxito'},
    {'word': 'LEARNING', 'hint': 'Aprendizaje'},
  ];
  late String _word, _hint;
  Set<String> _guessed = {};
  int _errors = 0;
  bool _won = false;
  int _xpEarned = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _newWord();
  }

  void _newWord() {
    final pick = _words[Random().nextInt(_words.length)];
    setState(() {
      _word = pick['word']!;
      _hint = pick['hint']!;
      _guessed = {};
      _errors = 0;
      _won = false;
      _xpEarned = 0;
      _submitting = false;
    });
  }

  void _guess(String letter) {
    if (_guessed.contains(letter) || _won || _errors >= 6 || _submitting) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _guessed.add(letter);
      if (!_word.contains(letter)) {
        _errors++;
      }
      if (_word.split('').every(_guessed.contains)) {
        _won = true;
        _xpEarned = max(10, 50 - _errors * 5);
        _submitScore();
      }
    });
  }

  Future<void> _submitScore() async {
    setState(() => _submitting = true);
    try {
      // Usamos el notifier de progreso para registrar la victoria
      // En un caso real, podríamos tener un lessonId específico para juegos o un endpoint dedicado
      // Por ahora usamos el progreso general
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 1, // Placeholder
            status: 'completed',
            score: _xpEarned.toDouble(),
          );
      // Refrescar estadísticas para ver el cambio en el banner
      ref.invalidate(userStatsProvider);
      ref.invalidate(progressSummaryProvider);
      ref.invalidate(rankingProvider);
    } catch (e) {
      debugPrint('Error al subir puntuación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayWord = _word.split('').map((l) => _guessed.contains(l) ? l : '_').join(' ');
    final alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    final lost = _errors >= 6;

    if (_won) {
      HapticFeedback.heavyImpact();
    } else if (lost) {
      HapticFeedback.vibrate();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('🪢 Ahorcado', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: _newWord, child: const Text('Nueva', style: TextStyle(color: Colors.orangeAccent))),
        ],
      ),
      body: Column(
        children: [
          _HangmanDrawing(errors: _errors),
          const SizedBox(height: 16),
          Text('Pista: $_hint', style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 12),
          Text(displayWord, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 8)),
          if (_won || lost)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _won ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(_won ? '¡Ganaste! +$_xpEarned XP' : 'Era: $_word', style: TextStyle(color: _won ? Colors.greenAccent : Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _newWord,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      child: const Text('Jugar de nuevo', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: alphabet.map((l) {
                final guessed = _guessed.contains(l);
                final wrong = guessed && !_word.contains(l);
                return GestureDetector(
                  onTap: () => _guess(l),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: wrong ? Colors.red.withValues(alpha: 0.3) : guessed ? Colors.green.withValues(alpha: 0.3) : const Color(0xFF2A2A3D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(l, style: TextStyle(color: guessed ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HangmanDrawing extends StatelessWidget {
  final int errors;
  const _HangmanDrawing({required this.errors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: CustomPaint(painter: _HangmanPainter(errors: errors)),
    );
  }
}

class _HangmanPainter extends CustomPainter {
  final int errors;
  const _HangmanPainter({required this.errors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white70..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    canvas.drawLine(Offset(cx - 60, size.height - 10), Offset(cx + 60, size.height - 10), paint);
    canvas.drawLine(Offset(cx, size.height - 10), Offset(cx, 10), paint);
    canvas.drawLine(Offset(cx, 10), Offset(cx + 50, 10), paint);
    canvas.drawLine(Offset(cx + 50, 10), Offset(cx + 50, 30), paint);
    if (errors >= 1) canvas.drawCircle(Offset(cx + 50, 44), 14, paint);
    if (errors >= 2) canvas.drawLine(Offset(cx + 50, 58), Offset(cx + 50, 100), paint);
    if (errors >= 3) canvas.drawLine(Offset(cx + 50, 70), Offset(cx + 30, 90), paint);
    if (errors >= 4) canvas.drawLine(Offset(cx + 50, 70), Offset(cx + 70, 90), paint);
    if (errors >= 5) canvas.drawLine(Offset(cx + 50, 100), Offset(cx + 30, 125), paint);
    if (errors >= 6) canvas.drawLine(Offset(cx + 50, 100), Offset(cx + 70, 125), paint);
  }

  @override
  bool shouldRepaint(_HangmanPainter old) => old.errors != errors;
}
