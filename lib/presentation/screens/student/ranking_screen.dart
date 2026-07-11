import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(rankingProvider);
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
                  onPressed: () => ref.invalidate(rankingProvider),
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
        data: (ranking) => Stack(
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
                          const SizedBox(height: 60),
                          // Title Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.amber.shade600,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Ranking Global',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.amber.shade600,
                                size: 32,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Los estudiantes más dedicados de la semana',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (ranking.length >= 3)
                            _PodiumWidget(ranking: ranking, isDark: isDark)
                          else
                            const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
                // Stats Summary
                if (ranking.length >= 3)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people,
                              label: 'Participantes',
                              value: '${ranking.length}',
                              color: Colors.blueAccent,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.flash_on_rounded,
                              label: 'XP Total',
                              value: '${_calculateTotalXp(ranking)}',
                              color: Colors.amber,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.emoji_events,
                              label: 'Top 3',
                              value: ranking
                                  .sublist(0, 3)
                                  .map((e) => e.username as String? ?? 'N/A')
                                  .join(', '),
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
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.format_list_numbered,
                          color: isDark ? Colors.white54 : Colors.black54,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Todos los participantes',
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
                            '${ranking.length} total',
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Ranking list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final entry = ranking[i + 3];
                        return _RankingRow(
                          entry: entry,
                          position: i + 4,
                          isDark: isDark,
                        );
                      },
                      childCount:
                          ranking.length > 3 ? ranking.length - 3 : 0,
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotalXp(List<dynamic> ranking) {
    return ranking.fold<int>(
        0, (sum, entry) => sum + (entry.totalXp as int? ?? 0));
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.05 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumWidget extends StatelessWidget {
  final List<dynamic> ranking;
  final bool isDark;
  const _PodiumWidget({required this.ranking, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          _PodiumItem(
            entry: ranking[1],
            position: 2,
            height: 130,
            color: Colors.grey.shade300,
            accentColor: Colors.grey.shade600,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          // 1st place
          _PodiumItem(
            entry: ranking[0],
            position: 1,
            height: 180,
            color: Colors.amberAccent,
            accentColor: Colors.amber.shade700,
            isFirst: true,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          // 3rd place
          _PodiumItem(
            entry: ranking[2],
            position: 3,
            height: 100,
            color: Colors.brown.shade300,
            accentColor: Colors.brown.shade700,
            isDark: isDark,
          ),
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
  final Color accentColor;
  final bool isFirst;
  final bool isDark;

  const _PodiumItem({
    required this.entry,
    required this.position,
    required this.height,
    required this.color,
    required this.accentColor,
    this.isFirst = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final initials = (entry.username != null && entry.username!.isNotEmpty)
        ? entry.username![0].toUpperCase()
        : (entry.fullName != null && entry.fullName!.isNotEmpty)
            ? entry.fullName![0].toUpperCase()
            : '?';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Medal icon for first place
        if (isFirst)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: Colors.amber.shade600,
              size: 28,
            ),
          )
        else
          Icon(
            position == 2
                ? Icons.workspace_premium_outlined
                : Icons.emoji_events_outlined,
            color: position == 2 ? Colors.grey.shade400 : Colors.brown.shade400,
            size: 28,
          ),
        const SizedBox(height: 8),
        // Avatar with glow
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: 2,
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
                fontSize: isFirst ? 22 : 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Name
        Container(
          constraints: const BoxConstraints(maxWidth: 80),
          child: Text(
            entry.username ?? entry.fullName ?? 'Usuario',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: isFirst ? 13 : 11,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        // XP Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${entry.totalXp ?? 0} XP',
            style: TextStyle(
              color: isDark ? color : accentColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Podium block
        Container(
          width: isFirst ? 90 : 75,
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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Decorative lines
              Positioned(
                top: 20,
                child: Container(
                  width: 30,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#$position',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: isFirst ? 28 : 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      position == 1 ? 'CAMPEÓN' : 'PUESTO',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  final dynamic entry;
  final int position;
  final bool isDark;

  const _RankingRow({
    required this.entry,
    required this.position,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final level = entry.level ?? 1;
    final xp = entry.totalXp ?? 0;
    final status = _getStatus(position);
    final Color statusColor = _getStatusColor(status);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GlassContainer(
        margin: const EdgeInsets.only(bottom: 12),
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        opacity: isDark ? 0.1 : 0.05,
        child: Row(
          children: [
            // Position number
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getPositionColor(position).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '#$position',
                  style: TextStyle(
                    color: _getPositionColor(position),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Avatar with gradient border
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _getPositionColor(position).withValues(alpha: 0.5),
                    _getPositionColor(position).withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: isDark
                    ? const Color(0xFF1A1A2E)
                    : Colors.grey.shade100,
                child: Text(
                  (entry.username != null && entry.username!.isNotEmpty)
                      ? entry.username![0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.username ?? 'Usuario',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Level
                      Icon(
                        Icons.trending_up,
                        color: isDark ? Colors.white38 : Colors.black38,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Nivel $level',
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // XP container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withValues(alpha: isDark ? 0.15 : 0.08),
                    Colors.purpleAccent.withValues(alpha: isDark ? 0.15 : 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$xp',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    'XP',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
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
    if (pos <= 10) return const Color(0xFFE0E0E0);
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