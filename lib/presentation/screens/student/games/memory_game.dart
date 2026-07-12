import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class MemoryGame extends ConsumerStatefulWidget {
  const MemoryGame({super.key});
  @override
  ConsumerState<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends ConsumerState<MemoryGame> {
  final List<String> _items = ['🍎', '🍌', '🍇', '🍓', '🍒', '🍍', '🥝', '🍉'];
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  int? _firstIndex;
  bool _busy = false;
  int _moves = 0;
  int _matchesFound = 0;
  bool _won = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    _cards = [..._items, ..._items];
    _cards.shuffle();
    _flipped = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    _firstIndex = null;
    _busy = false;
    _moves = 0;
    _matchesFound = 0;
    _won = false;
    _submitting = false;
  }

  void _onCardTap(int index) {
    if (_busy || _flipped[index] || _matched[index]) return;

    HapticFeedback.lightImpact();
    setState(() {
      _flipped[index] = true;
      if (_firstIndex == null) {
        _firstIndex = index;
      } else {
        _moves++;
        _busy = true;
        if (_cards[_firstIndex!] == _cards[index]) {
          _matched[_firstIndex!] = true;
          _matched[index] = true;
          _matchesFound++;
          _firstIndex = null;
          _busy = false;
          if (_matchesFound == _items.length) {
            _won = true;
            _submitScore();
          }
        } else {
          Timer(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() {
                _flipped[_firstIndex!] = false;
                _flipped[index] = false;
                _firstIndex = null;
                _busy = false;
              });
            }
          });
        }
      }
    });
  }

  Future<void> _submitScore() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final xp = (100 - _moves).clamp(20, 80);
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 2,
            status: 'completed',
            score: xp.toDouble(),
          );
      ref.invalidate(userStatsProvider);
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
            Positioned(top: -100, left: -50, child: _BlurBlob(color: const Color(0xFF6A11CB).withValues(alpha: 0.15), size: 300)),
            Positioned(bottom: -50, right: -50, child: _BlurBlob(color: const Color(0xFF2575FC).withValues(alpha: 0.15), size: 250)),
          ],
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, textColor),
                const SizedBox(height: 20),
                _buildStatsRow(isDark, textColor),
                const SizedBox(height: 32),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: _cards.length,
                        itemBuilder: (context, index) => _MemoryCard(
                          emoji: _cards[index],
                          isFlipped: _flipped[index] || _matched[index],
                          isMatched: _matched[index],
                          onTap: () => _onCardTap(index),
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_won) _buildWinOverlay(isDark, textColor)
                else const SizedBox(height: 100),
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
            '🧠 MEMORIA',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          IconButton(
            onPressed: () => setState(_setupGame),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2575FC)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(20),
              child: _StatItem(label: 'MOVIMIENTOS', value: '$_moves', textColor: textColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(20),
              child: _StatItem(label: 'PAREJAS', value: '$_matchesFound/${_items.length}', textColor: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinOverlay(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(24),
        color: Colors.greenAccent.withValues(alpha: 0.1),
        child: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('¡GANASTE!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.greenAccent)),
                  Text('Has ganado ${(100 - _moves).clamp(20, 80)} XP', style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 13)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.studentRanking),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('RANKING', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final String emoji;
  final bool isFlipped;
  final bool isMatched;
  final VoidCallback onTap;
  final bool isDark;

  const _MemoryCard({
    required this.emoji,
    required this.isFlipped,
    required this.isMatched,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isMatched 
            ? Colors.greenAccent.withValues(alpha: 0.2)
            : isFlipped 
              ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white)
              : (isDark ? const Color(0xFF2575FC).withValues(alpha: 0.2) : const Color(0xFF2575FC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMatched 
              ? Colors.greenAccent 
              : isFlipped 
                ? (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1))
                : (isDark ? const Color(0xFF2575FC).withValues(alpha: 0.4) : Colors.blue.shade700),
            width: 2,
          ),
          boxShadow: isFlipped ? null : [
            BoxShadow(
              color: const Color(0xFF2575FC).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isFlipped
                ? Text(emoji, key: ValueKey('emoji_$emoji'), style: const TextStyle(fontSize: 28))
                : Text('?', key: const ValueKey('question'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.8))),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color textColor;
  const _StatItem({required this.label, required this.value, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900)),
      ],
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
