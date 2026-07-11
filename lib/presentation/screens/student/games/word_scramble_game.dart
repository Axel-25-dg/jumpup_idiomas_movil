import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

class WordScrambleGame extends ConsumerStatefulWidget {
  const WordScrambleGame({super.key});
  @override
  ConsumerState<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends ConsumerState<WordScrambleGame> {
  final List<Map<String, String>> _words = [
    {'word': 'FLUTTER', 'hint': 'Mobile framework'},
    {'word': 'DART', 'hint': 'Programming language'},
    {'word': 'WIDGET', 'hint': 'UI element'},
    {'word': 'SCREEN', 'hint': 'What you are looking at'},
    {'word': 'MOBILE', 'hint': 'Handheld device'},
    {'word': 'KNOWLEDGE', 'hint': 'What you gain by learning'},
  ];

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
    final wordData = _words[random.nextInt(_words.length)];
    _originalWord = wordData['word']!;
    _hint = wordData['hint']!;
    
    List<String> chars = _originalWord.split('')..shuffle();
    while (chars.join() == _originalWord) {
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
    setState(() => _submitting = true);
    try {
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 5, // Placeholder for Scramble
            status: 'completed',
            score: _score.toDouble(),
          );
      ref.invalidate(userStatsProvider);
      ref.invalidate(progressSummaryProvider);
      ref.invalidate(rankingProvider);
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('¡Felicidades!'),
            content: Text('Completaste todos los niveles.\nXP Total: $_score'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Salir'),
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
        title: const Text('🧩 Word Scramble', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _submitting 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Nivel $_currentLevel', style: const TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('XP: $_score', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 40),
                Text(_scrambledWord, style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 5)),
                const SizedBox(height: 10),
                Text('Pista: $_hint', style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
                const SizedBox(height: 40),
                TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Escribe la palabra',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onSubmitted: (_) => _checkWord(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _checkWord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Comprobar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
    );
  }
}
