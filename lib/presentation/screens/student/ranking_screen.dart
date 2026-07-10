import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(rankingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: rankingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 60),
              const SizedBox(height: 16),
              const Text('No se pudo cargar el ranking', style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(rankingProvider),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        data: (ranking) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header with Podium
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Gradient background
                  Container(
                    height: 380,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A0533), Color(0xFF0F111A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        const Text('🏆 Ranking Global', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text('Los estudiantes más dedicados', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                        const SizedBox(height: 32),
                        if (ranking.length >= 3) _PodiumWidget(ranking: ranking) else const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Ranking list
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final entry = ranking[i + 3 < ranking.length ? i + 3 : i];
                    return _RankingRow(entry: entry, position: i + 4);
                  },
                  childCount: ranking.length > 3 ? ranking.length - 3 : 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodiumWidget extends StatelessWidget {
  final List<dynamic> ranking;
  const _PodiumWidget({required this.ranking});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          _PodiumItem(entry: ranking[1], position: 2, height: 140, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          // 1st place
          _PodiumItem(entry: ranking[0], position: 1, height: 190, color: Colors.amberAccent),
          const SizedBox(width: 8),
          // 3rd place
          _PodiumItem(entry: ranking[2], position: 3, height: 110, color: Colors.brown.shade400),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final dynamic entry;
  final int position;
  final double height;
  final Color color;

  const _PodiumItem({required this.entry, required this.position, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    final medal = position == 1 ? '👑' : position == 2 ? '🥈' : '🥉';
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(medal, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.3),
          child: Text(
            (entry.username ?? entry.fullName ?? '?')[0].toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.username ?? entry.fullName ?? 'Usuario',
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        Text('${entry.totalXp ?? 0} XP', style: TextStyle(color: color, fontSize: 11)),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text('#$position', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
          ),
        ),
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  final dynamic entry;
  final int position;

  const _RankingRow({required this.entry, required this.position});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$position',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blueAccent.withOpacity(0.5), Colors.purpleAccent.withOpacity(0.5)],
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF1A1A2E),
              child: Text(
                (entry.username ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username ?? 'Usuario',
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Nivel ${entry.level ?? 1} • ${_getStatus(position)}',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white38),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${entry.totalXp ?? 0}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatus(int pos) {
    if (pos <= 5) return 'Élite';
    if (pos <= 10) return 'Avanzado';
    return 'Promesa';
  }
}
