import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

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
    HapticFeedback.lightImpact();
    setState(() => _selEn = word);
    _checkMatch();
  }

  void _selectEs(String word) {
    if (_submitting) return;
    HapticFeedback.lightImpact();
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
            lessonId: 3, 
            status: 'completed',
            score: _xp.toDouble(),
            xpEarned: _xp,
          );
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D0D15) : Colors.grey[50]!;
    final textColor = isDark ? Colors.white : Colors.black87;
    final done = _matched.length == _pairs.length;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(top: -100, left: -50, child: _BlurBlob(color: const Color(0xFFE65100).withValues(alpha: 0.1), size: 300)),
            Positioned(bottom: -50, right: -50, child: _BlurBlob(color: const Color(0xFFFFA726).withValues(alpha: 0.1), size: 250)),
          ],
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, textColor),
                _buildProgressHeader(textColor),
                const SizedBox(height: 20),
                Expanded(
                  child: done 
                    ? _buildResultView(isDark, textColor)
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(child: _WordColumn(words: _en, selected: _selEn, matched: _matched, onTap: _selectEn, isEn: true, isDark: isDark, textColor: textColor)),
                            const SizedBox(width: 16),
                            Expanded(child: _WordColumn(words: _es, selected: _selEs, matched: _matched.map((k) => _pairs[k]!).toSet(), onTap: _selectEs, isEn: false, isDark: isDark, textColor: textColor)),
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
            '🔗 EMPAREJAR',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_matched.length}/${_pairs.length} COMPLETADO', style: TextStyle(color: textColor.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 12)),
              Text('$_xp XP', style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _matched.length / _pairs.length,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE65100)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(bool isDark, Color textColor) {
    return Center(
      child: GlassContainer(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(40),
        borderRadius: BorderRadius.circular(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 80, color: Colors.greenAccent),
            const SizedBox(height: 24),
            Text('¡EXCELENTE!', style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Has emparejado todo correctamente.', style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 16)),
            const SizedBox(height: 32),
            _xpTag('+$_xp XP'),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('FINALIZAR', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xpTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}

class _WordColumn extends StatelessWidget {
  final List<String> words;
  final String? selected;
  final Set<String> matched;
  final void Function(String) onTap;
  final bool isEn;
  final bool isDark;
  final Color textColor;

  const _WordColumn({required this.words, required this.selected, required this.matched, required this.onTap, required this.isEn, required this.isDark, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: words.map((w) {
        final isMatched = matched.contains(w);
        final isSel = selected == w;
        
        return GestureDetector(
          onTap: () => isMatched ? null : onTap(w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: isMatched 
                ? Colors.greenAccent.withValues(alpha: 0.1) 
                : isSel 
                  ? const Color(0xFFE65100).withValues(alpha: 0.2) 
                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isMatched 
                  ? Colors.greenAccent 
                  : isSel 
                    ? const Color(0xFFE65100) 
                    : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                width: 2,
              ),
              boxShadow: isSel || isMatched ? null : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Text(
              w, 
              textAlign: TextAlign.center, 
              style: TextStyle(
                color: isMatched ? Colors.greenAccent : (isSel ? const Color(0xFFE65100) : textColor), 
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
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
