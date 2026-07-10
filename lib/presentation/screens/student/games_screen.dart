import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F9FF),
      appBar: AppBar(
        backgroundColor: AppTheme.celeste,
        title: const Text('🎮 Juegos de Idiomas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de puntos
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.celeste, Color(0xFF0082C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppTheme.celeste.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))],
              ),
              child: const Row(
                children: [
                  Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 44),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¡Gana XP jugando!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Mejora tu inglés de forma divertida', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Elige un juego', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textoOscuro)),
            const SizedBox(height: 16),
            // Tarjetas de juegos
            _GameCard(
              title: 'Ahorcado',
              subtitle: 'Adivina palabras en inglés',
              icon: Icons.abc_rounded,
              color: const Color(0xFF7B2FBE),
              xp: 50,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HangmanGame())),
            ),
            const SizedBox(height: 14),
            _GameCard(
              title: 'Quiz Relámpago',
              subtitle: '10 preguntas de vocabulario',
              icon: Icons.flash_on_rounded,
              color: const Color(0xFFF4A100),
              xp: 80,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizGame())),
            ),
            const SizedBox(height: 14),
            _GameCard(
              title: 'Encuentra el Par',
              subtitle: 'Relaciona palabras con imágenes',
              icon: Icons.grid_view_rounded,
              color: const Color(0xFF00897B),
              xp: 60,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGame())),
            ),
            const SizedBox(height: 14),
            _GameCard(
              title: 'Ordena la Frase',
              subtitle: 'Construye oraciones correctas',
              icon: Icons.sort_by_alpha_rounded,
              color: const Color(0xFFE53935),
              xp: 70,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Próximamente disponible!'), backgroundColor: AppTheme.celeste),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final int xp;
  final VoidCallback onTap;
  const _GameCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.xp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textoOscuro)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(color: AppTheme.textoClaro, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('+$xp XP', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textoClaro),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// JUEGO 1: AHORCADO
// ────────────────────────────────────────────────────────────────────────────
class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});
  @override
  State<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  final _words = [
    {'word': 'ELEPHANT', 'hint': '🐘 Animal grande con trompa'},
    {'word': 'LIBRARY', 'hint': '📚 Lugar con muchos libros'},
    {'word': 'COMPUTER', 'hint': '💻 Dispositivo electrónico'},
    {'word': 'TEACHER', 'hint': '👩‍🏫 Persona que enseña'},
    {'word': 'LANGUAGE', 'hint': '🗣️ Sistema de comunicación'},
  ];

  late String _word;
  late String _hint;
  late Set<String> _guessed;
  int _errors = 0;
  final int _maxErrors = 6;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    final r = _words[Random().nextInt(_words.length)];
    _word = r['word']!;
    _hint = r['hint']!;
    _guessed = {};
    _errors = 0;
  }

  bool get _won => _word.split('').every((c) => _guessed.contains(c));
  bool get _lost => _errors >= _maxErrors;

  void _guess(String letter) {
    if (_guessed.contains(letter) || _won || _lost) return;
    setState(() {
      _guessed.add(letter);
      if (!_word.contains(letter)) _errors++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F9FF),
      appBar: AppBar(
        backgroundColor: AppTheme.celeste,
        title: const Text('Ahorcado 🎯', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(_newGame),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Vidas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_maxErrors, (i) => Icon(
                i < (_maxErrors - _errors) ? Icons.favorite : Icons.favorite_border,
                color: Colors.red, size: 28,
              )),
            ),
            const SizedBox(height: 20),
            // Hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.celeste.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(_hint, style: const TextStyle(fontSize: 16, color: AppTheme.textoOscuro)),
            ),
            const SizedBox(height: 30),
            // Palabra
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _word.split('').map((c) {
                final revealed = _guessed.contains(c);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: revealed ? AppTheme.celeste : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.celeste),
                  ),
                  child: Text(
                    revealed ? c : '_',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: revealed ? Colors.white : AppTheme.textoOscuro),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            // Resultado
            if (_won) _ResultBanner(won: true, onNext: () => setState(_newGame)),
            if (_lost) _ResultBanner(won: false, word: _word, onNext: () => setState(_newGame)),
            // Teclado
            if (!_won && !_lost)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((c) {
                  final used = _guessed.contains(c);
                  final correct = _word.contains(c) && used;
                  final wrong = !_word.contains(c) && used;
                  return GestureDetector(
                    onTap: () => _guess(c),
                    child: Container(
                      width: 40,
                      height: 44,
                      decoration: BoxDecoration(
                        color: correct ? AppTheme.celeste : wrong ? Colors.red.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: correct ? AppTheme.celeste : wrong ? Colors.red : Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text(c, style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: correct ? Colors.white : wrong ? Colors.red : AppTheme.textoOscuro,
                        )),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final bool won;
  final String? word;
  final VoidCallback onNext;
  const _ResultBanner({required this.won, this.word, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: won ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: won ? Colors.green : Colors.red),
      ),
      child: Column(
        children: [
          Text(won ? '🎉 ¡Ganaste! +50 XP' : '😢 Perdiste. La palabra era: ${word ?? ''}',
              style: TextStyle(fontWeight: FontWeight.bold, color: won ? Colors.green : Colors.red, fontSize: 16)),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.celeste),
            onPressed: onNext,
            child: const Text('Siguiente palabra', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// JUEGO 2: QUIZ RELÁMPAGO
// ────────────────────────────────────────────────────────────────────────────
class QuizGame extends StatefulWidget {
  const QuizGame({super.key});
  @override
  State<QuizGame> createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {
  final _questions = [
    {'q': '¿Cómo se dice "manzana" en inglés?', 'options': ['Orange', 'Apple', 'Banana', 'Grape'], 'answer': 'Apple'},
    {'q': '¿Cómo se dice "perro" en inglés?', 'options': ['Cat', 'Fish', 'Dog', 'Bird'], 'answer': 'Dog'},
    {'q': '¿Qué significa "beautiful"?', 'options': ['Feo', 'Grande', 'Hermoso', 'Pequeño'], 'answer': 'Hermoso'},
    {'q': '¿Qué significa "school"?', 'options': ['Casa', 'Escuela', 'Tienda', 'Parque'], 'answer': 'Escuela'},
    {'q': '¿Cómo se dice "libro" en inglés?', 'options': ['Pencil', 'Book', 'Pen', 'Notebook'], 'answer': 'Book'},
  ];

  int _current = 0;
  int _score = 0;
  String? _selected;
  bool _finished = false;

  void _answer(String opt) {
    if (_selected != null) return;
    setState(() => _selected = opt);
    if (opt == _questions[_current]['answer']) _score++;
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _selected = null;
        if (_current + 1 >= _questions.length) {
          _finished = true;
        } else {
          _current++;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F9FF),
        appBar: AppBar(backgroundColor: AppTheme.celeste, title: const Text('Quiz Relámpago ⚡', style: TextStyle(color: Colors.white))),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 80),
              const SizedBox(height: 16),
              const Text('¡Quiz completado!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textoOscuro)),
              const SizedBox(height: 10),
              Text('Puntaje: $_score/${_questions.length}', style: const TextStyle(fontSize: 20, color: AppTheme.celeste, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.celeste, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Jugar otra vez', style: TextStyle(color: Colors.white)),
                onPressed: () => setState(() { _current = 0; _score = 0; _selected = null; _finished = false; }),
              ),
            ],
          ),
        ),
      );
    }

    final q = _questions[_current];
    final options = q['options'] as List<String>;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F9FF),
      appBar: AppBar(
        backgroundColor: AppTheme.celeste,
        title: Text('Pregunta ${_current + 1}/${_questions.length} ⚡', style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_current + 1) / _questions.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.celeste),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.celeste,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppTheme.celeste.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))],
              ),
              child: Text(q['q'] as String, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            ...options.map((opt) {
              Color bg = Colors.white;
              Color border = Colors.grey.shade300;
              if (_selected != null) {
                if (opt == q['answer']) { bg = Colors.green.shade50; border = Colors.green; }
                else if (opt == _selected) { bg = Colors.red.shade50; border = Colors.red; }
              }
              return GestureDetector(
                onTap: () => _answer(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(color: bg, border: Border.all(color: border, width: 2), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Expanded(child: Text(opt, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textoOscuro))),
                      if (_selected != null && opt == q['answer']) const Icon(Icons.check_circle, color: Colors.green),
                      if (_selected == opt && opt != q['answer']) const Icon(Icons.cancel, color: Colors.red),
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

// ────────────────────────────────────────────────────────────────────────────
// JUEGO 3: MEMORIA / ENCUENTRA EL PAR
// ────────────────────────────────────────────────────────────────────────────
class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});
  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final _pairs = ['🐶 Dog', '🐱 Cat', '🐘 Elephant', '🦁 Lion', '🦊 Fox', '🐧 Penguin'];
  late List<String> _cards;
  List<bool> _flipped = [];
  List<bool> _matched = [];
  int? _firstIndex;
  bool _checking = false;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _cards = [..._pairs, ..._pairs]..shuffle();
    _flipped = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    _firstIndex = null;
    _checking = false;
    _moves = 0;
  }

  void _tap(int i) {
    if (_checking || _flipped[i] || _matched[i]) return;
    setState(() => _flipped[i] = true);
    if (_firstIndex == null) {
      _firstIndex = i;
    } else {
      _moves++;
      _checking = true;
      if (_cards[_firstIndex!] == _cards[i]) {
        setState(() { _matched[_firstIndex!] = true; _matched[i] = true; });
        _firstIndex = null;
        _checking = false;
      } else {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          setState(() { _flipped[_firstIndex!] = false; _flipped[i] = false; });
          _firstIndex = null;
          _checking = false;
        });
      }
    }
  }

  bool get _won => _matched.every((m) => m);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F9FF),
      appBar: AppBar(
        backgroundColor: AppTheme.celeste,
        title: Text('Encuentra el Par 🔍  Movimientos: $_moves', style: const TextStyle(color: Colors.white, fontSize: 15)),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: () => setState(_newGame))],
      ),
      body: _won
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded, size: 80, color: Colors.amber),
                  const Text('¡Ganaste!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.celeste)),
                  Text('Completado en $_moves movimientos', style: const TextStyle(color: AppTheme.textoClaro)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.celeste),
                    onPressed: () => setState(_newGame),
                    child: const Text('Jugar de nuevo', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: _cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemBuilder: (ctx, i) {
                  final show = _flipped[i] || _matched[i];
                  return GestureDetector(
                    onTap: () => _tap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: _matched[i] ? Colors.green.shade100 : show ? Colors.white : AppTheme.celeste,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _matched[i] ? Colors.green : show ? AppTheme.celeste : Colors.transparent, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 6)],
                      ),
                      child: Center(
                        child: show
                            ? Text(_cards[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
                            : const Icon(Icons.help_outline_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
