import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class HangmanGame extends ConsumerStatefulWidget {
  const HangmanGame({super.key});
  @override
  ConsumerState<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends ConsumerState<HangmanGame> {
  final _words = [
    {'word': 'FLUTTER', 'hint': 'Framework de UI moderna'},
    {'word': 'LANGUAGE', 'hint': 'Sistema de comunicación'},
    {'word': 'COMPUTER', 'hint': 'Máquina para procesar datos'},
    {'word': 'KEYBOARD', 'hint': 'Periférico de entrada con teclas'},
    {'word': 'MORNING', 'hint': 'Primera parte del día'},
    {'word': 'SUCCESS', 'hint': 'Logro de un objetivo'},
    {'word': 'LEARNING', 'hint': 'Proceso de adquirir conocimiento'},
    {'word': 'DEVELOPER', 'hint': 'Persona que escribe código'},
    {'word': 'INTERNET', 'hint': 'Red global de computadoras'},
    {'word': 'MOBILE', 'hint': 'Dispositivo portátil'},
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
      _word = pick['word']!.toUpperCase();
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
    HapticFeedback.lightImpact();
    setState(() {
      _guessed.add(letter);
      if (!_word.contains(letter)) {
        _errors++;
      }
      if (_word.split('').every((l) => _guessed.contains(l) || l == ' ')) {
        _won = true;
        _xpEarned = max(10, 50 - _errors * 5);
        _submitScore();
      }
    });
  }

  Future<void> _submitScore() async {
    setState(() => _submitting = true);
    try {
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 1, 
            status: 'completed',
            score: _xpEarned.toDouble(),
          );
      ref.invalidate(userStatsProvider);
      ref.invalidate(rankingProvider);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D0D15) : Colors.grey[50]!;
    final textColor = isDark ? Colors.white : Colors.black87;
    final lost = _errors >= 6;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Blobs
          if (isDark) ...[
            Positioned(top: -100, left: -50, child: _BlurBlob(color: const Color(0xFF6A11CB).withValues(alpha: 0.15), size: 300)),
            Positioned(bottom: -50, right: -50, child: _BlurBlob(color: const Color(0xFF2575FC).withValues(alpha: 0.15), size: 250)),
          ],
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, textColor, isDark),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        _HangmanDrawing(errors: _errors, isDark: isDark),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            borderRadius: BorderRadius.circular(16),
                            opacity: isDark ? 0.05 : 0.4,
                            child: Text(
                              'Pista: $_hint',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 15, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildWordDisplay(textColor),
                        const SizedBox(height: 40),
                        if (_won || lost) _buildResultOverlay(lost, isDark)
                        else _buildKeyboard(isDark),
                        const SizedBox(height: 40),
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

  Widget _buildAppBar(BuildContext context, Color textColor, bool isDark) {
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
            '🪢 AHORCADO',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          IconButton(
            onPressed: _newWord,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2575FC)),
          ),
        ],
      ),
    );
  }

  Widget _buildWordDisplay(Color textColor) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _word.split('').map((l) {
        if (l == ' ') return const SizedBox(width: 20);
        final guessed = _guessed.contains(l);
        return Container(
          width: 35,
          height: 45,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: textColor.withValues(alpha: 0.3), width: 3)),
          ),
          child: Center(
            child: Text(
              guessed ? l : '',
              style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyboard(bool isDark) {
    final alphabet = 'QWERTYUIOPASDFGHJKLZXCVBNM'.split('');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: alphabet.map((l) {
          final guessed = _guessed.contains(l);
          final isCorrect = guessed && _word.contains(l);
          final isWrong = guessed && !_word.contains(l);
          
          return GestureDetector(
            onTap: () => _guess(l),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 48,
              decoration: BoxDecoration(
                color: isCorrect 
                  ? Colors.greenAccent.withValues(alpha: 0.2)
                  : isWrong 
                    ? Colors.redAccent.withValues(alpha: 0.2)
                    : isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCorrect 
                    ? Colors.greenAccent 
                    : isWrong 
                      ? Colors.redAccent 
                      : isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                boxShadow: guessed ? null : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  l,
                  style: TextStyle(
                    color: isCorrect 
                      ? Colors.greenAccent 
                      : isWrong 
                        ? Colors.redAccent 
                        : isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultOverlay(bool lost, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(24),
        opacity: isDark ? 0.1 : 0.6,
        child: Column(
          children: [
            Icon(
              lost ? Icons.sentiment_very_dissatisfied_rounded : Icons.emoji_events_rounded,
              size: 60,
              color: lost ? Colors.redAccent : Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              lost ? '¡OH NO! PERDISTE' : '¡EXCELENTE!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: lost ? Colors.redAccent : Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lost ? 'La palabra era: $_word' : 'Has ganado $_xpEarned XP',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _newWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A11CB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('JUGAR DE NUEVO', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: () => context.push(AppRoutes.studentRanking),
                    icon: const Icon(Icons.emoji_events_rounded, color: Colors.amber),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ],
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

class _HangmanDrawing extends StatelessWidget {
  final int errors;
  final bool isDark;
  const _HangmanDrawing({required this.errors, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
        shape: BoxShape.circle,
      ),
      child: CustomPaint(painter: _HangmanPainter(errors: errors, isDark: isDark)),
    );
  }
}

class _HangmanPainter extends CustomPainter {
  final int errors;
  final bool isDark;
  const _HangmanPainter({required this.errors, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white70 : Colors.black87
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Base
    canvas.drawLine(Offset(cx - 40, size.height - 30), Offset(cx + 40, size.height - 30), paint);
    canvas.drawLine(Offset(cx - 20, size.height - 30), Offset(cx - 20, 30), paint);
    canvas.drawLine(Offset(cx - 20, 30), Offset(cx + 30, 30), paint);
    canvas.drawLine(Offset(cx + 30, 30), Offset(cx + 30, 50), paint);

    if (errors >= 1) canvas.drawCircle(Offset(cx + 30, 65), 15, paint); // Cabeza
    if (errors >= 2) canvas.drawLine(Offset(cx + 30, 80), Offset(cx + 30, 130), paint); // Cuerpo
    if (errors >= 3) canvas.drawLine(Offset(cx + 30, 90), Offset(cx + 10, 115), paint); // Brazo izq
    if (errors >= 4) canvas.drawLine(Offset(cx + 30, 90), Offset(cx + 50, 115), paint); // Brazo der
    if (errors >= 5) canvas.drawLine(Offset(cx + 30, 130), Offset(cx + 10, 160), paint); // Pierna izq
    if (errors >= 6) {
      canvas.drawLine(Offset(cx + 30, 130), Offset(cx + 50, 160), paint); // Pierna der
      
      // Ojos X_X
      final eyePaint = Paint()
        ..color = isDark ? Colors.redAccent : Colors.red
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(Offset(cx + 25, 60), Offset(cx + 29, 64), eyePaint);
      canvas.drawLine(Offset(cx + 29, 60), Offset(cx + 25, 64), eyePaint);
      
      canvas.drawLine(Offset(cx + 31, 60), Offset(cx + 35, 64), eyePaint);
      canvas.drawLine(Offset(cx + 35, 60), Offset(cx + 31, 64), eyePaint);
    }
  }

  @override
  bool shouldRepaint(_HangmanPainter old) => old.errors != errors || old.isDark != isDark;
}
