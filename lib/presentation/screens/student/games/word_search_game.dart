import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class WordSearchGame extends ConsumerStatefulWidget {
  const WordSearchGame({super.key});
  @override
  ConsumerState<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends ConsumerState<WordSearchGame> {
  final int gridSize = 8;
  final List<String> wordsToFind = ['FLUTTER', 'DART', 'MOBILE', 'CODE', 'APP'];
  late List<List<String>> grid;
  Set<Point<int>> selectedPoints = {};
  Set<String> foundWords = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _generateGrid();
  }

  void _generateGrid() {
    grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => String.fromCharCode(Random().nextInt(26) + 65)));
    for (var word in wordsToFind) {
      _placeWord(word);
    }
  }

  void _placeWord(String word) {
    Random rand = Random();
    bool placed = false;
    while (!placed) {
      int row = rand.nextInt(gridSize);
      int col = rand.nextInt(gridSize - word.length);
      bool canPlace = true;
      for (int i = 0; i < word.length; i++) {
        if (grid[row][col + i].length > 1 && grid[row][col + i] != word[i]) {
          canPlace = false;
          break;
        }
      }
      if (canPlace) {
        for (int i = 0; i < word.length; i++) {
          grid[row][col + i] = word[i];
        }
        placed = true;
      }
    }
  }

  void _onTileTap(int r, int c) {
    setState(() {
      final p = Point(r, c);
      if (selectedPoints.contains(p)) {
        selectedPoints.remove(p);
      } else {
        selectedPoints.add(p);
      }
      _checkWords();
    });
  }

  void _checkWords() {
    String selectedStr = selectedPoints.map((p) => grid[p.x][p.y]).join();
    for (var word in wordsToFind) {
      if (word == selectedStr && !foundWords.contains(word)) {
        foundWords.add(word);
        selectedPoints.clear();
        HapticFeedback.mediumImpact();
        if (foundWords.length == wordsToFind.length) {
          _finishGame();
        }
      }
    }
  }

  Future<void> _finishGame() async {
    setState(() => _submitting = true);
    await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
      lessonId: 10, // ID único para este juego
      status: 'completed',
      score: 50.0,
      xpEarned: 50,
    );
    if (mounted) {
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('¡Ganaste!'),
          content: const Text('Has encontrado todas las palabras. +50 XP'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      ).then((_) => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        title: const Text('SOPA DE LETRAS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: wordsToFind.map((w) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: foundWords.contains(w) 
                      ? Colors.greenAccent.withOpacity(0.2) 
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: foundWords.contains(w) ? Colors.greenAccent : Colors.white10,
                  ),
                ),
                child: Text(
                  w,
                  style: TextStyle(
                    color: foundWords.contains(w) ? Colors.greenAccent : Colors.white60,
                    fontWeight: FontWeight.bold,
                    decoration: foundWords.contains(w) ? TextDecoration.lineThrough : null,
                  ),
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                int r = index ~/ gridSize;
                int c = index % gridSize;
                bool isSelected = selectedPoints.contains(Point(r, c));
                
                return GestureDetector(
                  onTap: () => _onTileTap(r, c),
                  child: GlassContainer(
                    padding: EdgeInsets.zero,
                    opacity: isSelected ? 0.3 : 0.05,
                    color: isSelected ? Colors.blueAccent : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Text(
                        grid[r][c],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_submitting)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
        ],
      ),
    );
  }
}
