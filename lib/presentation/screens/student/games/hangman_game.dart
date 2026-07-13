import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class HangmanGame extends ConsumerStatefulWidget {
  const HangmanGame({super.key});
  @override
  ConsumerState<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends ConsumerState<HangmanGame> {
  final Map<int, List<Map<String, String>>> _levelPool = {
    1: [ // Básico: 3-5 letras
      {'word': 'CAT', 'hint': 'Animal que maúlla'},
      {'word': 'DOG', 'hint': 'El mejor amigo del hombre'},
      {'word': 'SUN', 'hint': 'Estrella que nos da calor'},
      {'word': 'BOOK', 'hint': 'Objeto con páginas para leer'},
      {'word': 'RED', 'hint': 'Color de la sangre'},
      {'word': 'BLUE', 'hint': 'Color del cielo despejado'},
      {'word': 'FAST', 'hint': 'Contrario de lento'},
    ],
    2: [ // Intermedio: 6-8 letras
      {'word': 'FLUTTER', 'hint': 'Framework de Google para apps'},
      {'word': 'LANGUAGE', 'hint': 'Sistema de comunicación humana'},
      {'word': 'COMPUTER', 'hint': 'Dispositivo para procesar datos'},
      {'word': 'KEYBOARD', 'hint': 'Periférico con muchas teclas'},
      {'word': 'MORNING', 'hint': 'Cuando sale el sol'},
      {'word': 'SUCCESS', 'hint': 'Logro de un objetivo'},
    ],
    3: [ // Avanzado: 9+ letras o palabras complejas
      {'word': 'DEVELOPER', 'hint': 'Persona que crea software'},
      {'word': 'EXPERIENCE', 'hint': 'Conocimiento ganado con el tiempo'},
      {'word': 'CHALLENGE', 'hint': 'Algo difícil de lograr'},
      {'word': 'KNOWLEDGE', 'hint': 'Información que posees'},
      {'word': 'IMAGINATION', 'hint': 'Capacidad de crear imágenes mentales'},
    ]
  };

  int _currentLevel = 1;
  int _consecutiveWins = 0;
  List<Map<String, String>> _usedWords = [];
  
  late String _word, _hint;
  Set<String> _guessed = {};
  int _errors = 0;
  bool _won = false;
  int _xpEarned = 0;
  bool _submitting = false;

  final List<String> _basicWords = ['CAT', 'DOG', 'SUN', 'BOOK', 'RED', 'BLUE', 'FAST', 'FISH', 'TREE', 'MILK'];
  final List<String> _interWords = ['FLUTTER', 'LANGUAGE', 'COMPUTER', 'KEYBOARD', 'MORNING', 'SUCCESS', 'STUDENT', 'SCHOOL', 'FRIEND'];
  final List<String> _advWords = ['DEVELOPER', 'EXPERIENCE', 'CHALLENGE', 'KNOWLEDGE', 'IMAGINATION', 'ENVIRONMENT', 'EDUCATION'];
  final Map<String, String> _allHints = {
    'CAT': 'Animal que maúlla', 'DOG': 'El mejor amigo del hombre', 'SUN': 'Estrella que nos da calor',
    'BOOK': 'Objeto con páginas para leer', 'RED': 'Color de la sangre', 'BLUE': 'Color del cielo despejado',
    'FAST': 'Contrario de lento', 'FISH': 'Vive en el agua', 'TREE': 'Planta grande con tronco', 'MILK': 'Bebida blanca de la vaca',
    'FLUTTER': 'Framework de Google para apps', 'LANGUAGE': 'Sistema de comunicación humana',
    'COMPUTER': 'Dispositivo para procesar datos', 'KEYBOARD': 'Periférico con muchas teclas',
    'MORNING': 'Cuando sale el sol', 'SUCCESS': 'Logro de un objetivo', 'STUDENT': 'Persona que estudia',
    'SCHOOL': 'Lugar donde se aprende', 'FRIEND': 'Persona de confianza', 'DEVELOPER': 'Persona que crea software',
    'EXPERIENCE': 'Conocimiento ganado con el tiempo', 'CHALLENGE': 'Algo difícil de lograr',
    'KNOWLEDGE': 'Información que posees', 'IMAGINATION': 'Capacidad de crear imágenes mentales',
    'ENVIRONMENT': 'Lo que nos rodea (medio...)', 'EDUCATION': 'Proceso de aprendizaje'
  };

  @override
  void initState() {
    super.initState();
    _newWord();
  }

  void _newWord() {
    List<String> pool;
    if (_currentLevel == 1) pool = _basicWords;
    else if (_currentLevel == 2) pool = _interWords;
    else pool = _advWords;

    final available = pool.where((w) => !_usedWords.any((u) => u['word'] == w)).toList();

    if (available.isEmpty) {
      _usedWords.clear();
      _newWord();
      return;
    }

    final word = (available..shuffle()).first;
    final pick = {'word': word, 'hint': _allHints[word] ?? 'Pista no disponible'};
    _usedWords.add(pick);

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
        _consecutiveWins++;
        
        // Subir de nivel cada 2 victorias consecutivas
        if (_consecutiveWins >= 2 && _currentLevel < 3) {
          _currentLevel++;
          _consecutiveWins = 0;
        }

        // Reduced XP gain as requested
        _xpEarned = (_currentLevel * 5) + max(2, 10 - _errors);
        debugPrint('Victoria! XP ganada: $_xpEarned'); // Debug para verificar XP
        _submitScore(earnXp: true);
      } else if (_errors >= 6) {
        // Lose: subtract small XP
        _xpEarned = -5;
        debugPrint('Pérdida! XP perdida: $_xpEarned');
        _submitScore(earnXp: false);
      }
    });
  }

  Future<void> _submitScore({required bool earnXp}) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      // Usar lessonId 0 o uno específico para juegos si el backend lo permite. 
      // If backend doesn't support negative XP, we still refresh stats
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 13, // ID único para Ahorcado
            status: earnXp ? 'completed' : 'failed',
            score: _xpEarned.toDouble(),
            xpEarned: _xpEarned,
          );
    } catch (e) {
      debugPrint('Error modificando XP: $e');
      // Even if API call fails, refresh stats to show current backend state
      ref.invalidate(userStatsProvider);
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
          width: 40,
          height: 55,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border(bottom: BorderSide(color: guessed ? const Color(0xFF2575FC) : textColor.withValues(alpha: 0.2), width: 4)),
          ),
          child: Center(
            child: Text(
              guessed ? l : '',
              style: TextStyle(color: textColor, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 2),
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
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: alphabet.map((l) {
          final guessed = _guessed.contains(l);
          final isCorrect = guessed && _word.contains(l);
          final isWrong = guessed && !_word.contains(l);
          
          return GestureDetector(
            onTap: () => _guess(l),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 52,
              decoration: BoxDecoration(
                gradient: isCorrect 
                  ? const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF66BB6A)])
                  : isWrong 
                    ? const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFEF5350)])
                    : isDark ? LinearGradient(colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)]) : const LinearGradient(colors: [Colors.white, Color(0xFFF5F5F5)]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect 
                    ? Colors.greenAccent 
                    : isWrong 
                      ? Colors.redAccent 
                      : isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                  width: 1.5,
                ),
                boxShadow: guessed ? null : [
                  BoxShadow(
                    color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  l,
                  style: TextStyle(
                    color: (isCorrect || isWrong) 
                      ? Colors.white
                      : isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
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
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Horca (Estructura con más detalle)
    // Base
    canvas.drawLine(Offset(cx - 60, size.height - 20), Offset(cx + 20, size.height - 20), paint);
    // Poste vertical
    canvas.drawLine(Offset(cx - 40, size.height - 20), Offset(cx - 40, 20), paint);
    // Brazo superior
    canvas.drawLine(Offset(cx - 40, 20), Offset(cx + 30, 20), paint);
    // Cuerda
    final ropePaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx + 30, 20), Offset(cx + 30, 50), ropePaint);

    if (errors >= 1) {
      // Cabeza
      canvas.drawCircle(Offset(cx + 30, 65), 15, paint);
    }
    if (errors >= 2) {
      // Cuerpo
      canvas.drawLine(Offset(cx + 30, 80), Offset(cx + 30, 130), paint);
    }
    if (errors >= 3) {
      // Brazo izq
      canvas.drawLine(Offset(cx + 30, 95), Offset(cx + 10, 115), paint);
    }
    if (errors >= 4) {
      // Brazo der
      canvas.drawLine(Offset(cx + 30, 95), Offset(cx + 50, 115), paint);
    }
    if (errors >= 5) {
      // Pierna izq
      canvas.drawLine(Offset(cx + 30, 130), Offset(cx + 10, 165), paint);
    }
    if (errors >= 6) {
      // Pierna der
      canvas.drawLine(Offset(cx + 30, 130), Offset(cx + 50, 165), paint);
      
      // Ojos X_X con color rojo
      final eyePaint = Paint()
        ..color = Colors.redAccent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      
      // Ojo 1
      canvas.drawLine(Offset(cx + 24, 60), Offset(cx + 28, 64), eyePaint);
      canvas.drawLine(Offset(cx + 28, 60), Offset(cx + 24, 64), eyePaint);
      
      // Ojo 2
      canvas.drawLine(Offset(cx + 32, 60), Offset(cx + 36, 64), eyePaint);
      canvas.drawLine(Offset(cx + 36, 60), Offset(cx + 32, 64), eyePaint);
    }
  }

  @override
  bool shouldRepaint(_HangmanPainter old) => old.errors != errors || old.isDark != isDark;
}
