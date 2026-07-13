import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/progress_models.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(rankingProvider(null));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: rankingAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ShimmerAvatar(isDark: isDark),
              const SizedBox(height: 24),
              Text(
                'Cargando ranking...',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: isDark ? 0.1 : 0.05),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No se pudo cargar el ranking',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verifica tu conexión a internet',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(rankingProvider(null)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Reintentar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (data) => Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header with Podium
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF1A0533),
                                const Color(0xFF0A0E21),
                                theme.scaffoldBackgroundColor,
                              ]
                            : [
                                Colors.blue.shade50,
                                Colors.purple.shade50,
                                theme.scaffoldBackgroundColor,
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // Title Section - Responsive
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emoji_events_rounded,
                                    color: Colors.amber.shade600,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Ranking Global',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.emoji_events_rounded,
                                    color: Colors.amber.shade600,
                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Los estudiantes más dedicados de la semana',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // My position - Compact & Reactive
                          Consumer(
                            builder: (context, ref, _) {
                              final stats = ref.watch(userStatsProvider).valueOrNull;
                              return GlassContainer(
                                margin: const EdgeInsets.symmetric(horizontal: 24),
                                padding: const EdgeInsets.all(12),
                                borderRadius: BorderRadius.circular(16),
                                opacity: isDark ? 0.15 : 0.08,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [Colors.blueAccent, Colors.purpleAccent],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blueAccent.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                          )
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '#${data.myPosition}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tu posición actual',
                                            style: TextStyle(
                                              color: isDark ? Colors.white54 : Colors.black54,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Nivel ${stats?.level ?? data.myLevel} • ${stats?.totalXp ?? data.myXp} XP',
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black87,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.local_fire_department_rounded,
                                                color: Colors.orangeAccent,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Racha: ${stats?.currentStreak ?? 0} días',
                                                style: TextStyle(
                                                  color: isDark ? Colors.white70 : Colors.black54,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.auto_graph_rounded,
                                      color: Colors.blueAccent.withValues(alpha: 0.5),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          if (data.ranking.isNotEmpty)
                            _PodiumWidget(ranking: data.ranking, isDark: isDark)
                          else
                            const SizedBox(
                              height: 200,
                              child: Center(child: Text('No hay suficientes datos para el podio')),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Stats Summary - Responsive Row
                if (data.ranking.length >= 3)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people,
                              label: 'Total',
                              value: '${data.ranking.length}',
                              color: Colors.blueAccent,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.flash_on_rounded,
                              label: 'XP',
                              value: '${_calculateTotalXp(data.ranking)}',
                              color: Colors.amber,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.emoji_events,
                              label: 'Líder',
                              value: data.ranking[0].username ?? 'Top 1',
                              color: Colors.purpleAccent,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.format_list_numbered,
                          color: isDark ? Colors.white54 : Colors.black54,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Clasificación',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Top ${data.ranking.length}',
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Ranking list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final listIndex = i + 3;
                        if (listIndex >= data.ranking.length) return null;
                        
                        final entry = data.ranking[listIndex];
                        return _RankingRow(
                          entry: entry,
                          position: listIndex + 1,
                          isDark: isDark,
                        );
                      },
                      childCount:
                          data.ranking.length > 3 ? data.ranking.length - 3 : 0,
                    ),
                  ),
                ),
              ],
            ),
            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white)
                        .withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotalXp(List<RankingEntryModel> ranking) {
    return ranking.fold<int>(
        0, (sum, entry) => sum + entry.totalXp);
  }
}

class _ShimmerAvatar extends StatefulWidget {
  final bool isDark;
  const _ShimmerAvatar({required this.isDark});

  @override
  State<_ShimmerAvatar> createState() => _ShimmerAvatarState();
}

class _ShimmerAvatarState extends State<_ShimmerAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent.withValues(alpha: 0.1),
                Colors.blueAccent.withValues(alpha: 0.3),
                Colors.blueAccent.withValues(alpha: 0.1),
              ],
              transform: _SlideRotation(_controller.value),
            ),
          ),
        );
      },
    );
  }
}

class _SlideRotation extends GradientTransform {
  const _SlideRotation(this.value);
  final double value;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(value * 200, 0.0, 0.0);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumWidget extends StatelessWidget {
  final List<RankingEntryModel> ranking;
  final bool isDark;
  const _PodiumWidget({required this.ranking, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          Expanded(
            child: ranking.length > 1
                ? _PodiumItem(
                    entry: ranking[1],
                    position: 2,
                    height: 110,
                    color: Colors.grey.shade300,
                    accentColor: Colors.grey.shade600,
                    isDark: isDark,
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 8),
          // 1st place
          Expanded(
            flex: 1,
            child: ranking.isNotEmpty
                ? _PodiumItem(
                    entry: ranking[0],
                    position: 1,
                    height: 160,
                    color: Colors.amberAccent,
                    accentColor: Colors.amber.shade700,
                    isFirst: true,
                    isDark: isDark,
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 8),
          // 3rd place
          Expanded(
            child: ranking.length > 2
                ? _PodiumItem(
                    entry: ranking[2],
                    position: 3,
                    height: 80,
                    color: Colors.brown.shade300,
                    accentColor: Colors.brown.shade700,
                    isDark: isDark,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends ConsumerWidget {
  final RankingEntryModel entry;
  final int position;
  final double height;
  final Color color;
  final Color accentColor;
  final bool isFirst;
  final bool isDark;

  const _PodiumItem({
    super.key,
    required this.entry,
    required this.position,
    required this.height,
    required this.color,
    required this.accentColor,
    this.isFirst = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = entry.isMe ? ref.watch(userStatsProvider).valueOrNull : null;
    final xp = stats?.totalXp ?? entry.totalXp;
    
    final initials = (entry.username.isNotEmpty)
        ? entry.username[0].toUpperCase()
        : '?';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Icon
        Icon(
          isFirst
              ? Icons.workspace_premium_rounded
              : (position == 2
                  ? Icons.workspace_premium_outlined
                  : Icons.emoji_events_outlined),
          color: isFirst
              ? Colors.amber.shade600
              : (position == 2 ? Colors.grey.shade400 : Colors.brown.shade400),
          size: isFirst ? 30 : 24,
        ),
        const SizedBox(height: 6),
        // Avatar with glow
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: isFirst ? 28 : 22,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Text(
              initials,
              style: TextStyle(
                color: isDark ? color : accentColor,
                fontWeight: FontWeight.bold,
                fontSize: isFirst ? 20 : 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Name
        Text(
          entry.isMe ? 'Tú' : entry.username,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: isFirst ? 13 : 11,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
        const SizedBox(height: 4),
        // XP Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, size: 10, color: isDark ? color : accentColor),
              const SizedBox(width: 2),
              Text(
                '$xp XP',
                style: TextStyle(
                  color: isDark ? color : accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Podium block
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.9),
                accentColor.withValues(alpha: 0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$position',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: isFirst ? 24 : 20,
                ),
              ),
              if (isFirst)
                const Text(
                  'TOP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankingRow extends ConsumerWidget {
  final RankingEntryModel entry;
  final int position;
  final bool isDark;

  const _RankingRow({
    super.key,
    required this.entry,
    required this.position,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = entry.isMe ? ref.watch(userStatsProvider).valueOrNull : null;
    final level = stats?.level ?? entry.level;
    final xp = stats?.totalXp ?? entry.totalXp;
    
    final status = _getStatus(position);
    final Color statusColor = _getStatusColor(status);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GlassContainer(
        margin: const EdgeInsets.only(bottom: 8),
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        opacity: isDark ? 0.1 : 0.05,
        child: Row(
          children: [
            // Position number
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getPositionColor(position).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '#$position',
                  style: TextStyle(
                    color: _getPositionColor(position),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: isDark
                  ? const Color(0xFF1A1A2E)
                  : Colors.grey.shade100,
              child: Text(
                (entry.username.isNotEmpty)
                    ? entry.username[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.isMe ? '${entry.username} (Tú)' : entry.username,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber.withValues(alpha: 0.7),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          'Nivel $level',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // XP container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    color: Colors.blueAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$xp',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPositionColor(int pos) {
    if (pos <= 5) return const Color(0xFFFFD700);
    if (pos <= 10) return const Color(0xFF9E9E9E);
    if (pos <= 20) return const Color(0xFFCD7F32);
    return Colors.blueGrey;
  }

  String _getStatus(int pos) {
    if (pos <= 5) return 'Élite';
    if (pos <= 10) return 'Avanzado';
    if (pos <= 25) return 'Promesa';
    return 'Aspirante';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Élite':
        return const Color(0xFFFFD700);
      case 'Avanzado':
        return const Color(0xFF2196F3);
      case 'Promesa':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }
}
