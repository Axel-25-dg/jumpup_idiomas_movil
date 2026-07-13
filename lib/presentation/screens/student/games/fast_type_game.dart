import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class FastTypeGame extends ConsumerStatefulWidget {
  const FastTypeGame({super.key});
  @override
  ConsumerState<FastTypeGame> createState() => _FastTypeGameState();
}

class _FastTypeGameState extends ConsumerState<FastTypeGame> {
  final List<String> _words = ['CHALLENGE', 'LEARNING', 'FUTURE', 'DYNAMIC', 'LANGUAGE', 'CREATIVE', 'EXPLORE', 'JUMPUP', 'FLUTTER', 'DEVELOPER'];
  late String _currentWord;
  final TextEditingController _controller = TextEditingController();
  int _score = 0;
  int _timeLeft = 30;
  Timer? _timer;
  bool _isPlaying = false;
  bool _submitting = false;

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isPlaying = true;
      _submitting = false;
      _nextWord();
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _nextWord() {
    setState(() {
      _currentWord = (_words..shuffle()).first;
      _controller.clear();
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _isPlaying = false);
    _submitScore();
  }

  Future<void> _submitScore() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final xp = _score * 5;
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 3,
            status: 'completed',
            score: xp.toDouble(),
            xpEarned: xp,
          );
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error sumando XP: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D0D15) : Colors.grey[50]!;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(top: -100, left: -50, child: _BlurBlob(color: const Color(0xFF00C853).withValues(alpha: 0.1), size: 300)),
            Positioned(bottom: -50, right: -50, child: _BlurBlob(color: const Color(0xFFB2FF59).withValues(alpha: 0.1), size: 250)),
          ],
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, textColor),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isPlaying) _buildStartView(isDark, textColor)
                        else _buildGameView(isDark, textColor),
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
            '⚡ VELOCIDAD',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStartView(bool isDark, Color textColor) {
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(40),
          borderRadius: BorderRadius.circular(32),
          child: Column(
            children: [
              const Icon(Icons.keyboard_outlined, size: 80, color: Color(0xFF00C853)),
              const SizedBox(height: 24),
              const Text(
                '¿QUÉ TAN RÁPIDO ERES?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                'Escribe las palabras que aparezcan antes de que se acabe el tiempo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor.withValues(alpha: 0.6), height: 1.5),
              ),
              if (_score > 0) ...[
                const SizedBox(height: 24),
                Text('Último Puntaje: $_score palabras (+${_score * 5} XP)', 
                  style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C853),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
          ),
          child: const Text('EMPEZAR DESAFÍO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => context.push(AppRoutes.studentRanking),
          icon: const Icon(Icons.emoji_events_rounded, color: Colors.amber),
          label: const Text('VER RANKING', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildGameView(bool isDark, Color textColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatBox(label: 'TIEMPO', value: '$_timeLeft', color: _timeLeft < 10 ? Colors.redAccent : const Color(0xFF00C853)),
            _StatBox(label: 'XP GANADO', value: '${_score * 5}', color: const Color(0xFFB2FF59)),
          ],
        ),
        const SizedBox(height: 60),
        Text(
          _currentWord,
          style: TextStyle(
            color: textColor,
            fontSize: 48,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            shadows: [
              Shadow(color: const Color(0xFF00C853).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4))
            ]
          ),
        ),
        const SizedBox(height: 40),
        TextField(
          controller: _controller,
          autofocus: true,
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold),
          cursorColor: const Color(0xFF00C853),
          decoration: InputDecoration(
            hintText: 'Escribe aquí...',
            hintStyle: TextStyle(color: textColor.withValues(alpha: 0.2)),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 24),
          ),
          onChanged: (val) {
            if (val.toUpperCase() == _currentWord) {
              HapticFeedback.mediumImpact();
              setState(() => _score++);
              _nextWord();
            }
          },
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
      ],
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
