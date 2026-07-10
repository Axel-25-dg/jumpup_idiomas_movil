import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: Stack(
        children: [
          // Neon background blobs
          Positioned(top: -60, left: -60, child: _blob(Colors.orangeAccent, 200)),
          Positioned(bottom: 100, right: -60, child: _blob(Colors.purpleAccent, 180)),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 160,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A0533), Color(0xFF0F111A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('🎮 Arena de Juegos', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text('Aprende idiomas jugando • Gana XP', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats Banner
                    _StatsBanner(),
                    const SizedBox(height: 28),
                    const Text('Minijuegos', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _GameCard(
                      title: '🪢 Ahorcado',
                      subtitle: 'Adivina palabras en inglés',
                      description: 'Pon a prueba tu vocabulario antes de agotar tus intentos',
                      gradient: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      xp: 50,
                      difficulty: 'Fácil',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HangmanGame())),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      title: '🃏 Flashcards',
                      subtitle: 'Memoriza vocabulario con tarjetas',
                      description: 'Voltea las tarjetas y refuerza tu memoria visual',
                      gradient: const [Color(0xFF6A11CB), Color(0xFFAB47BC)],
                      xp: 30,
                      difficulty: 'Fácil',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardGame())),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      title: '🔗 Emparejar',
                      subtitle: 'Relaciona palabras con su traducción',
                      description: 'Encuentra todos los pares antes que se acabe el tiempo',
                      gradient: const [Color(0xFFE65100), Color(0xFFFFA726)],
                      xp: 60,
                      difficulty: 'Medio',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchingGame())),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      title: '❓ Trivia',
                      subtitle: 'Quiz de gramática y vocabulario',
                      description: 'Demuestra tus conocimientos respondiendo preguntas',
                      gradient: const [Color(0xFF1B5E20), Color(0xFF66BB6A)],
                      xp: 80,
                      difficulty: 'Difícil',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TriviaGame())),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 80)],
        ),
      );
}

class _StatsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MiniStat(icon: '🔥', value: '7', label: 'Racha'),
          _MiniStat(icon: '⭐', value: '1,250', label: 'XP Total'),
          _MiniStat(icon: '🏆', value: '#12', label: 'Ranking'),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon, value, label;
  const _MiniStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(icon, style: const TextStyle(fontSize: 24)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
    ],
  );
}

class _GameCard extends StatelessWidget {
  final String title, subtitle, description, difficulty;
  final List<Color> gradient;
  final int xp;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradient,
    required this.xp,
    required this.difficulty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: gradient.last.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Tag(label: '+$xp XP', color: Colors.white24),
                      const SizedBox(width: 8),
                      _Tag(label: difficulty, color: Colors.white24),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
  );
}

// ─── Hangman Game ─────────────────────────────────────────────────────────────
class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});
  @override State<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  final _words = [
    {'word': 'FLUTTER', 'hint': 'Framework de UI'},
    {'word': 'LANGUAGE', 'hint': 'Idioma'},
    {'word': 'COMPUTER', 'hint': 'Computadora'},
    {'word': 'KEYBOARD', 'hint': 'Teclado'},
    {'word': 'MORNING', 'hint': 'Buenos días...'},
  ];
  late String _word, _hint;
  Set<String> _guessed = {};
  int _errors = 0;
  bool _won = false;
  int _xpEarned = 0;

  @override
  void initState() {
    super.initState();
    _newWord();
  }

  void _newWord() {
    final pick = _words[Random().nextInt(_words.length)];
    setState(() {
      _word = pick['word']!;
      _hint = pick['hint']!;
      _guessed = {};
      _errors = 0;
      _won = false;
      _xpEarned = 0;
    });
  }

  void _guess(String letter) {
    if (_guessed.contains(letter) || _won || _errors >= 6) return;
    HapticFeedback.selectionClick();
    setState(() {
      _guessed.add(letter);
      if (!_word.contains(letter)) {
        _errors++;
      }
      if (_word.split('').every(_guessed.contains)) {
        _won = true;
        _xpEarned = max(0, 50 - _errors * 5);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayWord = _word.split('').map((l) => _guessed.contains(l) ? l : '_').join(' ');
    final alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    final lost = _errors >= 6;

    if (_won) {
      HapticFeedback.heavyImpact();
    } else if (lost) {
      HapticFeedback.vibrate();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('🪢 Ahorcado', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: _newWord, child: const Text('Nueva', style: TextStyle(color: Colors.orangeAccent))),
        ],
      ),
      body: Column(
        children: [
          // Gallows drawing
          _HangmanDrawing(errors: _errors),
          const SizedBox(height: 16),
          Text('Pista: $_hint', style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 12),
          Text(displayWord, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 8)),
          if (_won || lost)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _won ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(_won ? '¡Ganaste! +$_xpEarned XP' : 'Era: $_word', style: TextStyle(color: _won ? Colors.greenAccent : Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _newWord,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      child: const Text('Jugar de nuevo', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          const Spacer(),
          // Keyboard
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: alphabet.map((l) {
                final guessed = _guessed.contains(l);
                final wrong = guessed && !_word.contains(l);
                return GestureDetector(
                  onTap: () => _guess(l),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: wrong ? Colors.red.withValues(alpha: 0.3) : guessed ? Colors.green.withValues(alpha: 0.3) : const Color(0xFF2A2A3D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(l, style: TextStyle(color: guessed ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HangmanDrawing extends StatelessWidget {
  final int errors;
  const _HangmanDrawing({required this.errors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: CustomPaint(painter: _HangmanPainter(errors: errors)),
    );
  }
}

class _HangmanPainter extends CustomPainter {
  final int errors;
  const _HangmanPainter({required this.errors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white70..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    // Gallows
    canvas.drawLine(Offset(cx - 60, size.height - 10), Offset(cx + 60, size.height - 10), paint);
    canvas.drawLine(Offset(cx, size.height - 10), Offset(cx, 10), paint);
    canvas.drawLine(Offset(cx, 10), Offset(cx + 50, 10), paint);
    canvas.drawLine(Offset(cx + 50, 10), Offset(cx + 50, 30), paint);
    if (errors >= 1) canvas.drawCircle(Offset(cx + 50, 44), 14, paint);
    if (errors >= 2) canvas.drawLine(Offset(cx + 50, 58), Offset(cx + 50, 100), paint);
    if (errors >= 3) canvas.drawLine(Offset(cx + 50, 70), Offset(cx + 30, 90), paint);
    if (errors >= 4) canvas.drawLine(Offset(cx + 50, 70), Offset(cx + 70, 90), paint);
    if (errors >= 5) canvas.drawLine(Offset(cx + 50, 100), Offset(cx + 30, 125), paint);
    if (errors >= 6) canvas.drawLine(Offset(cx + 50, 100), Offset(cx + 70, 125), paint);
  }

  @override
  bool shouldRepaint(_HangmanPainter old) => old.errors != errors;
}

// ─── Flashcard Game ───────────────────────────────────────────────────────────
class FlashcardGame extends StatefulWidget {
  const FlashcardGame({super.key});
  @override State<FlashcardGame> createState() => _FlashcardGameState();
}

class _FlashcardGameState extends State<FlashcardGame> with SingleTickerProviderStateMixin {
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

  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
        _showFlashcardResult();
      }
    });
  }

  void _showFlashcardResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Juego Terminado', style: TextStyle(color: Colors.white)),
        content: Text('Repasaste todas las tarjetas.\nCorrectas: $_correct/${_cards.length}', style: const TextStyle(color: Colors.white70)),
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
      body: Column(
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

// ─── Matching Game ────────────────────────────────────────────────────────────
class MatchingGame extends StatefulWidget {
  const MatchingGame({super.key});
  @override State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  final _pairs = {'Dog': 'Perro', 'House': 'Casa', 'Tree': 'Árbol', 'Sun': 'Sol'};
  List<String> _en = [], _es = [];
  String? _selEn, _selEs;
  final Set<String> _matched = {};
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _en = _pairs.keys.toList()..shuffle();
    _es = _pairs.values.toList()..shuffle();
  }

  void _selectEn(String word) {
    setState(() => _selEn = word);
    _checkMatch();
  }

  void _selectEs(String word) {
    setState(() => _selEs = word);
    _checkMatch();
  }

  void _checkMatch() {
    if (_selEn == null || _selEs == null) return;
    if (_pairs[_selEn] == _selEs) {
      HapticFeedback.heavyImpact();
      setState(() {
        _matched.add(_selEn!);
        _xp += 15;
        _selEn = null;
        _selEs = null;
      });
      if (_matched.length == _pairs.length) {
        // Victoria
      }
    } else {
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() { _selEn = null; _selEs = null; });
      });
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
              child: Text('¡Perfecto! +$_xp XP ganados', style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
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
    return Column(
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

// ─── Trivia Game ──────────────────────────────────────────────────────────────
class TriviaGame extends StatefulWidget {
  const TriviaGame({super.key});
  @override State<TriviaGame> createState() => _TriviaGameState();
}

class _TriviaGameState extends State<TriviaGame> {
  final _questions = [
    {
      'q': 'What is the plural of "child"?',
      'options': ['Childs', 'Children', 'Childes', 'Childrens'],
      'correct': 1,
    },
    {
      'q': '"She ___ to school every day." (go)',
      'options': ['go', 'going', 'goes', 'gone'],
      'correct': 2,
    },
    {
      'q': 'Which is NOT a vowel?',
      'options': ['A', 'E', 'R', 'I'],
      'correct': 2,
    },
    {
      'q': 'The past tense of "run" is:',
      'options': ['Runned', 'Ran', 'Run', 'Running'],
      'correct': 1,
    },
  ];

  int _current = 0;
  int? _selected;
  int _score = 0;
  bool _done = false;

  void _answer(int idx) {
    if (_selected != null) return;
    final correct = _questions[_current]['correct'] as int;
    setState(() {
      _selected = idx;
      if (idx == correct) {
        HapticFeedback.mediumImpact();
        _score += 20;
      } else {
        HapticFeedback.vibrate();
      }
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _selected = null;
          if (_current < _questions.length - 1) {
            _current++;
          } else {
            _done = true;
            if (_score > 0) {
              HapticFeedback.heavyImpact();
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _ResultScreen(score: _score, total: _questions.length * 20);
    final q = _questions[_current];
    final options = q['options'] as List<String>;
    final correct = q['correct'] as int;

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('❓ Trivia ${_current + 1}/${_questions.length}', style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_current + 1) / _questions.length,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3D)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(q['q'] as String, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, height: 1.5)),
            ),
            const SizedBox(height: 32),
            ...List.generate(options.length, (i) {
              Color bg = const Color(0xFF2A2A3D);
              if (_selected != null) {
                if (i == correct) bg = Colors.green.withValues(alpha: 0.4);
                else if (i == _selected) bg = Colors.red.withValues(alpha: 0.4);
              }
              return GestureDetector(
                onTap: () => _answer(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                        child: Center(child: Text('ABCD'[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(width: 14),
                      Text(options[i], style: const TextStyle(color: Colors.white, fontSize: 15)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  final int score, total;
  const _ResultScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = score / total;
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pct >= 0.8 ? '🏆' : pct >= 0.5 ? '⭐' : '💪', style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text('$score / $total XP', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(pct >= 0.8 ? '¡Excelente!' : pct >= 0.5 ? '¡Bien hecho!' : 'Sigue practicando', style: const TextStyle(color: Colors.white70, fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Volver a Juegos', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
