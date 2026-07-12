import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class SentenceBuilderGame extends ConsumerStatefulWidget {
  const SentenceBuilderGame({super.key});
  @override
  ConsumerState<SentenceBuilderGame> createState() => _SentenceBuilderGameState();
}

class _SentenceBuilderGameState extends ConsumerState<SentenceBuilderGame> {
  final List<Map<String, dynamic>> _sentences = [
    {'correct': 'I love learning new languages', 'words': ['learning', 'I', 'languages', 'love', 'new']},
    {'correct': 'Flutter is great for mobile apps', 'words': ['for', 'great', 'is', 'mobile', 'Flutter', 'apps']},
    {'correct': 'The cat is sitting on the mat', 'words': ['sitting', 'on', 'The', 'is', 'cat', 'the', 'mat']},
    {'correct': 'Practice makes perfect in everything', 'words': ['perfect', 'makes', 'Practice', 'in', 'everything']},
    {'correct': 'She speaks English very fluently', 'words': ['fluently', 'English', 'speaks', 'She', 'very']},
  ];

  late Map<String, dynamic> _currentSentence;
  List<String> _userWords = [];
  List<String> _availableWords = [];
  bool? _isCorrect;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nextSentence();
  }

  void _nextSentence() {
    setState(() {
      _currentSentence = (_sentences..shuffle()).first;
      _availableWords = List.from(_currentSentence['words'])..shuffle();
      _userWords = [];
      _isCorrect = null;
      _submitting = false;
    });
  }

  void _check() {
    final result = _userWords.join(' ') == _currentSentence['correct'];
    setState(() => _isCorrect = result);
    if (result) {
      HapticFeedback.heavyImpact();
      _submitScore();
    } else {
      HapticFeedback.vibrate();
    }
  }

  Future<void> _submitScore() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 4,
            status: 'completed',
            score: 60.0,
          );
      ref.invalidate(userStatsProvider);
      ref.invalidate(progressSummaryProvider);
      ref.invalidate(rankingProvider);
    } catch (e) {
      debugPrint('Error: $e');
    }
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
            Positioned(top: -100, right: -50, child: _BlurBlob(color: const Color(0xFF6A11CB).withValues(alpha: 0.15), size: 300)),
            Positioned(bottom: -50, left: -50, child: _BlurBlob(color: const Color(0xFF2575FC).withValues(alpha: 0.15), size: 250)),
          ],
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, textColor),
                const SizedBox(height: 20),
                _buildProgressIndicator(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ordena la oración:',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildTargetArea(isDark, textColor),
                        const SizedBox(height: 48),
                        _buildWordsSelection(isDark, textColor),
                        const Spacer(),
                        if (_isCorrect == true) _buildSuccessButton()
                        else if (_isCorrect == false) _buildRetryHint(textColor),
                        const SizedBox(height: 20),
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
            '🏗️ CONSTRUCTOR',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: 0.6, // Placeholder
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2575FC)),
          minHeight: 8,
        ),
      ),
    );
  }

  Widget _buildTargetArea(bool isDark, Color textColor) {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isCorrect == true 
            ? Colors.greenAccent 
            : _isCorrect == false 
              ? Colors.redAccent 
              : isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: _userWords.map((w) => _WordChip(
          word: w,
          onTap: () {
            if (_isCorrect == true) return;
            setState(() {
              _userWords.remove(w);
              _availableWords.add(w);
              _isCorrect = null;
            });
          },
          isDark: isDark,
          isActive: true,
        )).toList(),
      ),
    );
  }

  Widget _buildWordsSelection(bool isDark, Color textColor) {
    return Wrap(
      spacing: 12,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: _availableWords.map((w) => _WordChip(
        word: w,
        onTap: () {
          if (_isCorrect == true) return;
          HapticFeedback.lightImpact();
          setState(() {
            _availableWords.remove(w);
            _userWords.add(w);
            if (_availableWords.isEmpty) _check();
          });
        },
        isDark: isDark,
        isActive: false,
      )).toList(),
    );
  }

  Widget _buildSuccessButton() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      color: Colors.greenAccent.withValues(alpha: 0.1),
      child: Column(
        children: [
          const Text('¡Excelente trabajo! +60 XP', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextSentence,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('SIGUIENTE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () => context.push(AppRoutes.studentRanking),
                icon: const Icon(Icons.emoji_events_rounded),
                style: IconButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRetryHint(Color textColor) {
    return Text(
      'Casi... Inténtalo de nuevo',
      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final VoidCallback onTap;
  final bool isDark;
  final bool isActive;

  const _WordChip({
    required this.word,
    required this.onTap,
    required this.isDark,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isActive 
            ? (isDark ? const Color(0xFF2575FC).withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.1))
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive 
              ? const Color(0xFF2575FC) 
              : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          word,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
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
