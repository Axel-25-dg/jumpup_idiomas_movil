import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

class FlashcardGame extends ConsumerStatefulWidget {
  const FlashcardGame({super.key});
  @override
  ConsumerState<FlashcardGame> createState() => _FlashcardGameState();
}

class _FlashcardGameState extends ConsumerState<FlashcardGame> with SingleTickerProviderStateMixin {
  final _cards = [
    {'en': 'Apple', 'es': 'Manzana'},
    {'en': 'Sun', 'es': 'Sol'},
    {'en': 'Dog', 'es': 'Perro'},
    {'en': 'House', 'es': 'Casa'},
    {'en': 'Water', 'es': 'Agua'},
    {'en': 'Book', 'es': 'Libro'},
    {'en': 'Tree', 'es': 'Árbol'},
  ];

  int _current = 0;
  bool _flipped = false;
  int _correct = 0;
  bool _submitting = false;

  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    HapticFeedback.lightImpact();
    if (_ctrl.isCompleted) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
    setState(() => _flipped = !_flipped);
  }

  void _next(bool correct) {
    if (correct) {
      HapticFeedback.mediumImpact();
      setState(() => _correct++);
    } else {
      HapticFeedback.vibrate();
    }
    _ctrl.reset();
    setState(() {
      _flipped = false;
      if (_current < _cards.length - 1) {
        _current++;
      } else {
        _submitResults();
      }
    });
  }

  Future<void> _submitResults() async {
    setState(() => _submitting = true);
    final xpEarned = _correct * 5;
    try {
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 2, // Placeholder para Flashcards
            status: 'completed',
            score: xpEarned.toDouble(),
            xpEarned: xpEarned,
          );
      _showFlashcardResult(xpEarned);
    } catch (e) {
      _showFlashcardResult(xpEarned);
    }
  }

  void _showFlashcardResult(int xp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Juego Terminado', style: TextStyle(color: Colors.white)),
        content: Text('Repasaste todas las tarjetas.\nCorrectas: $_correct/${_cards.length}\nXP Ganada: +$xp', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Salir', style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _current = 0;
                _correct = 0;
                _flipped = false;
                _submitting = false;
              });
            },
            child: const Text('Reiniciar', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _cards[_current];
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Flashcards ${_current + 1}/${_cards.length}', style: const TextStyle(color: Colors.white)),
      ),
      body: _submitting 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('✅ Correctas: $_correct', style: const TextStyle(color: Colors.greenAccent, fontSize: 16)),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _flip,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) {
                    final angle = _anim.value * pi;
                    final isFront = angle < pi / 2;
                    return Transform(
                      transform: Matrix4.rotationY(angle),
                      alignment: Alignment.center,
                      child: Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: isFront
                              ? const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)])
                              : const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Center(
                          child: Text(
                            isFront ? card['en']! : card['es']!,
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text('Toca la tarjeta para ver la traducción', style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 40),
              if (_flipped)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _next(false),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: 0.3)),
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      label: const Text('No sabía', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () => _next(true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.withValues(alpha: 0.3)),
                      icon: const Icon(Icons.check, color: Colors.greenAccent),
                      label: const Text('¡Lo sé!', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
            ],
          ),
    );
  }
}
