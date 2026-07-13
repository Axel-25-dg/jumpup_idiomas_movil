import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';

class WordScrambleGame extends ConsumerStatefulWidget {
  const WordScrambleGame({super.key});
  @override
  ConsumerState<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends ConsumerState<WordScrambleGame> {
  final Map<int, List<Map<String, String>>> _levelPool = {
    1: [
      {'word': 'DART', 'hint': 'Language for Flutter'},
      {'word': 'BLUE', 'hint': 'Color of the sky'},
      {'word': 'BOOK', 'hint': 'You read this'},
      {'word': 'EASY', 'hint': 'Not difficult'},
      {'word': 'HOME', 'hint': 'Where you live'},
    ],
    2: [
      {'word': 'FLUTTER', 'hint': 'Mobile framework'},
      {'word': 'SCREEN', 'hint': 'Monitor or display'},
      {'word': 'MOBILE', 'hint': 'Portable phone'},
      {'word': 'SCHOOL', 'hint': 'Place for learning'},
      {'word': 'FRIEND', 'hint': 'A person you like'},
    ],
    3: [
      {'word': 'KNOWLEDGE', 'hint': 'What you gain by learning'},
      {'word': 'PRACTICE', 'hint': 'Doing something repeatedly'},
      {'word': 'DEVELOP', 'hint': 'To create or improve'},
      {'word': 'LANGUAGE', 'hint': 'System of communication'},
      {'word': 'SUCCESS', 'hint': 'Achieving your goals'},
    ]
  };

  static final Set<String> _usedGlobal = {};
  late String _originalWord;
  late String _scrambledWord;
  late String _hint;
  final TextEditingController _controller = TextEditingController();
  int _score = 0;
  int _currentLevel = 1;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadNewWord();
  }

  void _loadNewWord() {
    final random = Random();
    int difficulty = _currentLevel <= 2 ? 1 : (_currentLevel <= 4 ? 2 : 3);
    final pool = _levelPool[difficulty]!;
    
    List<Map<String, String>> available = pool.where((w) => !_usedGlobal.contains(w['word'])).toList();
    if (available.isEmpty) {
      _usedGlobal.removeWhere((w) => pool.any((p) => p['word'] == w));
      available = pool;
    }

    final wordData = available[random.nextInt(available.length)];
    _originalWord = wordData['word']!;
    _hint = wordData['hint']!;
    _usedGlobal.add(_originalWord);
    
    List<String> chars = _originalWord.split('')..shuffle();
    while (chars.join() == _originalWord && _originalWord.length > 1) {
      chars.shuffle();
    }
    _scrambledWord = chars.join();
    _controller.clear();
    setState(() {});
  }

  void _checkWord() {
    if (_controller.text.toUpperCase() == _originalWord) {
      HapticFeedback.heavyImpact();
      _score += 25 * _currentLevel;
      if (_currentLevel < 5) {
        _currentLevel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Correcto! Subiste al nivel $_currentLevel'), backgroundColor: Colors.green),
        );
        _loadNewWord();
      } else {
        _finishGame();
      }
    } else {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intenta de nuevo'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _finishGame() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 20, // ID único para Word Scramble
            status: 'completed',
            score: _score.toDouble(),
            xpEarned: _score,
          );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1D2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('¡Felicidades!', style: TextStyle(color: Colors.white)),
            content: Text('Completaste todos los niveles.\nXP Total: $_score', style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('SALIR', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        title: const Text('WORD SCRAMBLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _submitting 
        ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProgressHeader(),
                const Spacer(),
                Text(_scrambledWord, style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 5)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: Colors.blueAccent, size: 18),
                      const SizedBox(width: 8),
                      Flexible(child: Text(_hint, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic))),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'ESCRIBE AQUÍ',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), letterSpacing: 2),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
                  ),
                  onSubmitted: (_) => _checkWord(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _checkWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text('COMPROBAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('NIVEL $_currentLevel / 5', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 12)),
            Text('$_score XP', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _currentLevel / 5,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
