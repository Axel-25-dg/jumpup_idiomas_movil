import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class CrosswordGame extends ConsumerStatefulWidget {
  const CrosswordGame({super.key});
  @override
  ConsumerState<CrosswordGame> createState() => _CrosswordGameState();
}

class _CrosswordGameState extends ConsumerState<CrosswordGame> {
  final List<Map<String, dynamic>> _words = [
    {'word': 'HELLO', 'clue': 'Saludo básico en inglés', 'row': 0, 'col': 0, 'dir': 'H'},
    {'word': 'HOUSE', 'clue': 'Lugar donde vives', 'row': 0, 'col': 0, 'dir': 'V'},
    {'word': 'DOG', 'clue': 'Mascota que ladra', 'row': 2, 'col': 0, 'dir': 'H'},
  ];

  final Map<String, String> _userAnswers = {};
  bool _submitting = false;

  void _checkSolution() async {
    bool allCorrect = true;
    for (var w in _words) {
      String word = w['word'];
      int r = w['row'];
      int c = w['col'];
      String userWord = '';
      for (int i = 0; i < word.length; i++) {
        userWord += _userAnswers['${w['dir'] == 'H' ? r : r + i}_${w['dir'] == 'H' ? c + i : c}'] ?? '';
      }
      if (userWord.toUpperCase() != word) allCorrect = false;
    }

    if (allCorrect) {
      setState(() => _submitting = true);
      HapticFeedback.mediumImpact();
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
        lessonId: 11,
        status: 'completed',
        score: 60.0,
        xpEarned: 60,
      );
      if (mounted) {
        _showWinDialog();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Casi... revisa algunas letras'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¡Excelente!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 64),
            SizedBox(height: 16),
            Text('Crucigrama completado con éxito.', style: TextStyle(color: Colors.white70)),
            Text('+60 XP', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 24)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            }, 
            child: const Text('CONTINUAR', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        title: const Text('CRUCIGRAMA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, 
                crossAxisSpacing: 8, 
                mainAxisSpacing: 8
              ),
              itemCount: 36,
              itemBuilder: (context, index) {
                int r = index ~/ 6;
                int c = index % 6;
                bool isCell = (r == 0 || (r == 2 && c < 3) || (c == 0 && r < 5));
                if (!isCell) return const SizedBox.shrink();

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blueAccent.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                      ],
                      cursorColor: Colors.blueAccent,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 22,
                      ),
                      decoration: const InputDecoration(
                        counterText: '', 
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: (v) {
                        _userAnswers['${r}_$c'] = v.toUpperCase();
                        if (v.isNotEmpty) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: GlassContainer(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(24),
              opacity: 0.08,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text('PISTAS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: _words.map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                w['dir'],
                                style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                w['clue'],
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _checkSolution,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        _submitting ? 'GUARDANDO...' : 'VERIFICAR SOLUCIÓN',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
