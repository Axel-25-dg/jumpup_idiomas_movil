import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/presentation/screens/student/games/hangman_game.dart';
import 'package:jumpup_app/presentation/screens/student/games/matching_game.dart';
import 'package:jumpup_app/presentation/screens/student/games/trivia_game.dart';
import 'package:jumpup_app/presentation/screens/student/games/word_scramble_game.dart';
import 'package:jumpup_app/presentation/screens/student/games/memory_game.dart';
import 'package:jumpup_app/presentation/screens/student/games/fast_type_game.dart';
import 'package:jumpup_app/presentation/screens/student/games/sentence_builder_game.dart';
import 'package:jumpup_app/presentation/screens/student/games/verb_blitz_game.dart';
import 'package:jumpup_app/presentation/screens/student/games/flashcard_game.dart';
import 'package:jumpup_app/presentation/screens/student/games/image_match_game.dart';

import '../../navigation/app_router.dart';

class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final rankingPositionAsync = ref.watch(myRankingPositionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // En el nuevo sistema, los juegos se desbloquean por nivel o XP
    final isPro = statsAsync.value != null && statsAsync.value!.level >= 2; 

    // Theme-aware colors
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final headerGradient = isDark
        ? const [Color(0xFF1A0533), Color(0xFF0F111A)]
        : [const Color(0xFF1565C0), const Color(0xFF1976D2)];

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Neon background blobs - solo en dark
          if (isDark) ...[
            Positioned(top: -60, left: -60, child: _blob(Colors.orangeAccent, 200)),
            Positioned(bottom: 100, right: -60, child: _blob(Colors.purpleAccent, 180)),
          ],
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 160,
                backgroundColor: isDark ? Colors.transparent : const Color(0xFF1565C0),
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: headerGradient,
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
                    // Stats Banner with real data
                    statsAsync.when(
                      data: (stats) => _StatsBanner(
                        streak: stats.currentStreak.toString(),
                        xp: stats.totalXp.toString(),
                        ranking: rankingPositionAsync.when(
                          data: (pos) => pos != null ? '#$pos' : '--',
                          loading: () => '...',
                          error: (_, __) => '--',
                        ),
                      ),
                      loading: () => const _StatsBanner(streak: '...', xp: '...', ranking: '...'),
                      error: (_, __) => const _StatsBanner(streak: '0', xp: '0', ranking: '--'),
                    ),
                    if (!isPro) ...[
                      const SizedBox(height: 20),
                      _ProBanner(onTap: () => context.push(AppRoutes.studentCatalog)),
                    ],
                    const SizedBox(height: 28),
                    Text('Minijuegos', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
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
                      title: '🧠 Memoria',
                      subtitle: 'Encuentra las parejas',
                      description: 'Entrena tu retentiva visual con emojis coloridos',
                      gradient: const [Color(0xFF6A11CB), Color(0xFFAB47BC)],
                      xp: 40,
                      difficulty: 'Fácil',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGame())),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      title: '⚡ Velocidad',
                      subtitle: 'Escribe rápido y sin errores',
                      description: '¿Qué tan rápido puedes teclear estas palabras?',
                      gradient: const [Color(0xFF00C853), Color(0xFFB2FF59)],
                      xp: 75,
                      difficulty: 'Medio',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FastTypeGame())),
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
                      xp: 100,
                      difficulty: 'Difícil',
                      isLocked: !isPro,
                      onTap: () => _handleGameTap(context, isPro, const TriviaGame()),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      title: '🧩 Word Scramble',
                      subtitle: 'Desordena y reordena',
                      description: 'Ordena las letras para formar la palabra correcta',
                      gradient: const [Color(0xFFC62828), Color(0xFFEF5350)],
                      xp: 90,
                      difficulty: 'Medio',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WordScrambleGame())),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      title: '🏗️ Constructor',
                      subtitle: 'Forma oraciones correctas',
                      description: 'Arrastra las palabras para construir la frase',
                      gradient: const [Color(0xFF00B0FF), Color(0xFF00E5FF)],
                      xp: 120,
                      difficulty: 'Avanzado',
                      isLocked: !isPro,
                      onTap: () => _handleGameTap(context, isPro, const SentenceBuilderGame()),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      title: '⚡ Verb Blitz',
                      subtitle: 'Pasados y participios',
                      description: 'Domina los verbos irregulares a toda velocidad',
                      gradient: const [Color(0xFF6200EA), Color(0xFFD500F9)],
                      xp: 150,
                      difficulty: 'Difícil',
                      isLocked: !isPro,
                      onTap: () => _handleGameTap(context, isPro, const VerbBlitzGame()),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      title: '🃏 Flashcards',
                      subtitle: 'Repaso rápido',
                      description: 'Voltea las tarjetas y comprueba tu conocimiento',
                      gradient: const [Color(0xFF0091EA), Color(0xFF00B8D4)],
                      xp: 35,
                      difficulty: 'Fácil',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardGame())),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      title: '🖼️ Identificar',
                      subtitle: 'Vocabulario visual',
                      description: 'Selecciona el nombre correcto del objeto mostrado',
                      gradient: const [Color(0xFFFF4081), Color(0xFFFF80AB)],
                      xp: 45,
                      difficulty: 'Fácil',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImageMatchGame())),
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

  void _handleGameTap(BuildContext context, bool isPro, Widget game) {
    if (isPro) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => game));
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E2E)
              : Colors.white,
          title: const Text('🚀 Acceso Pro Requerido'),
          content: const Text('Este juego es exclusivo para usuarios de nivel Pro (Nivel 2+). ¡Mejora tu nivel para desbloquear todos los juegos y más!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Después'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Use GoRouter from the root context, not the dialog context
                GoRouter.of(context).push(AppRoutes.studentCatalog);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text('Ver Catálogo', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
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
  final String streak;
  final String xp;
  final String ranking;

  const _StatsBanner({required this.streak, required this.xp, required this.ranking});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MiniStat(icon: '🔥', value: streak, label: 'Racha'),
          _MiniStat(icon: '⭐', value: xp, label: 'XP Total'),
          GestureDetector(
            onTap: () => context.push(AppRoutes.studentRanking),
            child: _MiniStat(icon: '🏆', value: ranking, label: 'Ranking'),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon, value, label;
  const _MiniStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 11)),
        if (label == 'Ranking')
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Ver más 🏆', style: TextStyle(color: Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}

class _ProBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ProBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: const Row(
          children: [
            Text('🚀', style: TextStyle(fontSize: 32)),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Pásate a PRO!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Desbloquea todos los juegos y IA ilimitada', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title, subtitle, description, difficulty;
  final List<Color> gradient;
  final int xp;
  final bool isLocked;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradient,
    required this.xp,
    required this.difficulty,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Stack(
        children: [
          Container(
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
                  decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: Icon(isLocked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          if (isLocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
        ],
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
