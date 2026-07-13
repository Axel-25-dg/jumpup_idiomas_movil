import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';

class VerbBlitzGame extends ConsumerStatefulWidget {
  const VerbBlitzGame({super.key});
  @override
  ConsumerState<VerbBlitzGame> createState() => _VerbBlitzGameState();
}

class _VerbBlitzGameState extends ConsumerState<VerbBlitzGame> {
  final List<Map<String, dynamic>> _verbs = [
    {'inf': 'Be', 'p': 'was/were', 'pp': 'been'},
    {'inf': 'Go', 'p': 'went', 'pp': 'gone'},
    {'inf': 'Eat', 'p': 'ate', 'pp': 'eaten'},
    {'inf': 'Do', 'p': 'did', 'pp': 'done'},
    {'inf': 'See', 'p': 'saw', 'pp': 'seen'},
    {'inf': 'Take', 'p': 'took', 'pp': 'taken'},
    {'inf': 'Write', 'p': 'wrote', 'pp': 'written'},
    {'inf': 'Speak', 'p': 'spoke', 'pp': 'spoken'},
    {'inf': 'Know', 'p': 'knew', 'pp': 'known'},
    {'inf': 'Get', 'p': 'got', 'pp': 'gotten'},
  ];

  late Map<String, dynamic> _current;
  late String _targetType;
  late List<String> _options;
  int _score = 0;
  int _round = 0;
  bool _done = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    if (_round >= 10) {
      _finish();
      return;
    }
    final rand = Random();
    _current = _verbs[rand.nextInt(_verbs.length)];
    _targetType = rand.nextBool() ? 'p' : 'pp';
    
    final correct = _current[_targetType] as String;
    final others = _verbs
        .where((v) => v['inf'] != _current['inf'])
        .map((v) => v[_targetType] as String)
        .toList();
    others.shuffle();
    
    _options = [correct, others[0], others[1], others[2]];
    _options.shuffle();
    
    setState(() {
      _round++;
    });
  }

  void _check(String val) {
    if (_submitting) return;
    if (val == _current[_targetType]) {
      HapticFeedback.mediumImpact();
      _score += 15;
    } else {
      HapticFeedback.vibrate();
    }
    _nextRound();
  }

  Future<void> _finish() async {
    if (_submitting) return;
    setState(() {
      _done = true;
      _submitting = true;
    });
    try {
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 19, // ID único para Verb Blitz
            status: 'completed',
            score: _score.toDouble(),
            xpEarned: _score,
          );
    } catch (_) {}
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_done) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F111A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚡ Verb Blitz', style: TextStyle(color: Colors.blueAccent, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('Puntuación: $_score XP', style: const TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Volver a Juegos', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.push(AppRoutes.studentRanking),
                icon: const Icon(Icons.emoji_events_rounded, color: Colors.amber),
                label: const Text('Ver Ranking Global 🏆', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        title: const Text('⚡ Verb Blitz', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ronda $_round/10', style: const TextStyle(color: Colors.white54)),
                Text('XP: $_score', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 60),
            Text(
              _targetType == 'p' ? 'Pasado Simple de:' : 'Participio Pasado de:',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              '"${_current['inf']}"',
              style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 60),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: _options.map((opt) => ElevatedButton(
                  onPressed: () => _check(opt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E2E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                  ),
                  child: Text(opt, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                )).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
