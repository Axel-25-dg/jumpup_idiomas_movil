import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

/// Pantalla de tabla de clasificación Top 100 por XP.
class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(rankingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Ranking Global 🏆',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: rankingAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              const Text('No se pudo cargar el ranking',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(rankingProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (ranking) => Column(
          children: [
            // ── Podio Top 3 ───────────────────────────────────────────
            if (ranking.length >= 3)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _PodiumWidget(
                  first: ranking[0],
                  second: ranking[1],
                  third: ranking[2],
                ),
              ),
            const Divider(color: Colors.white12),

            // ── Lista completa ────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: ranking.length > 3 ? ranking.length - 3 : 0,
                itemBuilder: (context, index) {
                  final entry = ranking[index + 3];
                  return _RankingTile(entry: entry);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _PodiumWidget extends StatelessWidget {
  const _PodiumWidget({
    required this.first,
    required this.second,
    required this.third,
  });

  final dynamic first;
  final dynamic second;
  final dynamic third;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── 2do lugar ─────────────────────────────────────────────────
        _PodiumItem(
          entry: second,
          medal: '🥈',
          height: 80,
          color: const Color(0xFFC0C0C0),
        ),
        const SizedBox(width: 8),
        // ── 1er lugar ─────────────────────────────────────────────────
        _PodiumItem(
          entry: first,
          medal: '🥇',
          height: 110,
          color: const Color(0xFFFFD700),
          isFirst: true,
        ),
        const SizedBox(width: 8),
        // ── 3er lugar ─────────────────────────────────────────────────
        _PodiumItem(
          entry: third,
          medal: '🥉',
          height: 65,
          color: const Color(0xFFCD7F32),
        ),
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.entry,
    required this.medal,
    required this.height,
    required this.color,
    this.isFirst = false,
  });

  final dynamic entry;
  final String medal;
  final double height;
  final Color color;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(medal, style: TextStyle(fontSize: isFirst ? 40 : 30)),
          const SizedBox(height: 4),
          CircleAvatar(
            radius: isFirst ? 28 : 22,
            backgroundColor: color.withValues(alpha: 0.3),
            child: Text(
              entry.username.isNotEmpty ? entry.username[0].toUpperCase() : '?',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isFirst ? 22 : 16,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry.username,
            style: TextStyle(
                color: Colors.white,
                fontSize: isFirst ? 13 : 11,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '⚡ ${entry.totalXp} XP',
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                '#${entry.position}',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({required this.entry});
  final dynamic entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // Posición
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.position}',
              style: const TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
            child: Text(
              entry.username.isNotEmpty ? entry.username[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text('Nivel ${entry.level} · 🔥 ${entry.currentStreak} días',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          // XP
          Text(
            '⚡ ${entry.totalXp}',
            style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
        ],
      ),
    );
  }
}
