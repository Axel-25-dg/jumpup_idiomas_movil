import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ImageMatchGame extends ConsumerStatefulWidget {
  const ImageMatchGame({super.key});
  @override
  ConsumerState<ImageMatchGame> createState() => _ImageMatchGameState();
}

class _ImageMatchGameState extends ConsumerState<ImageMatchGame> {
  final List<Map<String, dynamic>> _data = [
    {'word': 'Apple', 'icon': '🍎'},
    {'word': 'Dog', 'icon': '🐶'},
    {'word': 'Car', 'icon': '🚗'},
    {'word': 'House', 'icon': '🏠'},
    {'word': 'Sun', 'icon': '☀️'},
    {'word': 'Book', 'icon': '📖'},
    {'word': 'Water', 'icon': '💧'},
    {'word': 'Tree', 'icon': '🌳'},
  ];

  late Map<String, dynamic> _current;
  late List<String> _options;
  bool? _isCorrect;
  int _score = 0;
  int _round = 0;
  final int _maxRounds = 5;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    if (_round >= _maxRounds) {
      _finishGame();
      return;
    }

    setState(() {
      _current = _data[Random().nextInt(_data.length)];
      _options = [_current['word']];
      while (_options.length < 4) {
        String randomWord = _data[Random().nextInt(_data.length)]['word'];
        if (!_options.contains(randomWord)) {
          _options.add(randomWord);
        }
      }
      _options.shuffle();
      _isCorrect = null;
      _round++;
    });
  }

  void _checkAnswer(String selected) {
    if (_isCorrect != null) return;

    final correct = selected == _current['word'];
    setState(() {
      _isCorrect = correct;
      if (correct) _score += 20;
    });

    if (correct) {
      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 1500), _nextRound);
    } else {
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 1500), _nextRound);
    }
  }

  Future<void> _finishGame() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 21, // ID único para Image Match
            status: 'completed',
            score: _score.toDouble(),
            xpEarned: _score,
          );
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

    if (_round > _maxRounds && _isCorrect == null) {
      return _buildResultScreen(isDark, textColor);
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(top: -50, left: -50, child: _BlurBlob(color: const Color(0xFF6A11CB).withValues(alpha: 0.1), size: 300)),
            Positioned(bottom: -50, right: -50, child: _BlurBlob(color: const Color(0xFF2575FC).withValues(alpha: 0.1), size: 250)),
          ],
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, textColor),
                _buildProgressBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Qué es esto?',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 40),
                        _buildImageCard(isDark),
                        const SizedBox(height: 60),
                        _buildOptionsGrid(isDark, textColor),
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

  Widget _buildHeader(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: textColor),
          ),
          Text(
            'SCORE: $_score',
            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2575FC), fontSize: 18),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: _round / _maxRounds,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2575FC)),
          minHeight: 8,
        ),
      ),
    );
  }

  Widget _buildImageCard(bool isDark) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Center(
        child: Text(
          _current['icon'],
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  Widget _buildOptionsGrid(bool isDark, Color textColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: _options.length,
      itemBuilder: (context, index) {
        final option = _options[index];
        final isSelected = _isCorrect != null && option == _current['word'];
        final isWrong = _isCorrect == false && option != _current['word']; // Simplified for UI

        return GestureDetector(
          onTap: () => _checkAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isSelected 
                ? Colors.greenAccent.withValues(alpha: 0.2) 
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                  ? Colors.greenAccent 
                  : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.greenAccent : textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultScreen(bool isDark, Color textColor) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D15) : Colors.grey[50]!,
      body: Center(
        child: GlassContainer(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          borderRadius: BorderRadius.circular(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              const Text('¡COMPLETADO!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Has ganado $_score XP', style: TextStyle(fontSize: 18, color: textColor.withValues(alpha: 0.7))),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2575FC),
                  foregroundColor: Colors.white,
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
