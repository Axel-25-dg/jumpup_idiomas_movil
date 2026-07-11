import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

class MatchingGame extends ConsumerStatefulWidget {
  const MatchingGame({super.key});
  @override
  ConsumerState<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends ConsumerState<MatchingGame> {
  final _pairs = {
    'Dog': 'Perro',
    'House': 'Casa',
    'Tree': 'Árbol',
    'Sun': 'Sol',
    'Moon': 'Luna',
    'Water': 'Agua',
    'Bread': 'Pan',
    'Milk': 'Leche',
  };
  List<String> _en = [], _es = [];
  String? _selEn, _selEs;
  final Set<String> _matched = {};
  int _xp = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _en = _pairs.keys.toList()..shuffle();
    _es = _pairs.values.toList()..shuffle();
  }

  void _selectEn(String word) {
    if (_submitting) return;
    setState(() => _selEn = word);
    _checkMatch();
  }

  void _selectEs(String word) {
    if (_submitting) return;
    setState(() => _selEs = word);
    _checkMatch();
  }

  void _checkMatch() {
    if (_selEn == null || _selEs == null) return;

    if (_pairs[_selEn] == _selEs) {
      HapticFeedback.heavyImpact();
      setState(() {
        _matched.add(_selEn!);
        _xp += 10;
        _selEn = null;
        _selEs = null;
      });
      if (_matched.length == _pairs.length) {
        _submitScore();
      }
    } else {
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _selEn = null;
            _selEs = null;
          });
        }
      });
    }
  }

  Future<void> _submitScore() async {
    setState(() => _submitting = true);
    try {
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 3, // Placeholder para Matching
            status: 'completed',
            score: _xp.toDouble(),
          );
      ref.invalidate(userStatsProvider);
      ref.invalidate(progressSummaryProvider);
      ref.invalidate(rankingProvider);
    } catch (e) {
      debugPrint('Error al subir puntuación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = _matched.length == _pairs.length;
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('🔗 Emparejar', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.orangeAccent),
                const SizedBox(width: 8),
                Text('$_xp XP', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (done)
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('¡Perfecto! Has emparejado todo.', style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('+$_xp XP ganados', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continuar'),
                  )
                ],
              ),
            )
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(child: _WordColumn(words: _en, selected: _selEn, matched: _matched, onTap: _selectEn, isEn: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _WordColumn(words: _es, selected: _selEs, matched: _matched.map((k) => _pairs[k]!).toSet(), onTap: _selectEs, isEn: false)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WordColumn extends StatelessWidget {
  final List<String> words;
  final String? selected;
  final Set<String> matched;
  final void Function(String) onTap;
  final bool isEn;

  const _WordColumn({required this.words, required this.selected, required this.matched, required this.onTap, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: words.map((w) {
        final isMatched = matched.contains(w);
        final isSel = selected == w;
        return GestureDetector(
          onTap: () => isMatched ? null : onTap(w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isMatched ? Colors.green.withValues(alpha: 0.3) : isSel ? Colors.blueAccent.withValues(alpha: 0.4) : const Color(0xFF2A2A3D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSel ? Colors.blueAccent : Colors.transparent, width: 2),
            ),
            child: Text(w, textAlign: TextAlign.center, style: TextStyle(color: isMatched ? Colors.greenAccent : Colors.white, fontWeight: FontWeight.w600)),
          ),
        );
      }).toList(),
    );
  }
}
