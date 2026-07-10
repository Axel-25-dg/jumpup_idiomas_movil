import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/theme/text_styles.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(rankingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: rankingAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text('No se pudo cargar el ranking',
                  style: AppTextStyles.bodyLarge),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(rankingProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        data: (ranking) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 340,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: SafeArea(
                    child: ranking.length >= 3
                        ? Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: _PodiumWidget(
                              first: ranking[0],
                              second: ranking[1],
                              third: ranking[2],
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.emoji_events_rounded,
                                size: 80, color: Colors.white24),
                          ),
                  ),
                ),
                title: Text(
                  'Ranking Global',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                centerTitle: true,
              ),
            ),
            if (ranking.length > 3)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = ranking[index + 3];
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 50),
                        child: _RankingTile(entry: entry),
                      );
                    },
                    childCount: ranking.length - 3,
                  ),
                ),
              )
            else
              const SliverFillRemaining(
                child: Center(
                  child: Text('Explora y gana XP para aparecer aquí'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _PodiumItem(
            entry: second,
            rank: 2,
            height: 100,
            color: const Color(0xFFC0C0C0), // Silver
            animationDelay: 400,
          ),
          const SizedBox(width: 8),
          _PodiumItem(
            entry: first,
            rank: 1,
            height: 140,
            color: const Color(0xFFFFD700), // Gold
            isFirst: true,
            animationDelay: 200,
          ),
          const SizedBox(width: 8),
          _PodiumItem(
            entry: third,
            rank: 3,
            height: 80,
            color: const Color(0xFFCD7F32), // Bronze
            animationDelay: 600,
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.entry,
    required this.rank,
    required this.height,
    required this.color,
    this.isFirst = false,
    required this.animationDelay,
  });

  final dynamic entry;
  final int rank;
  final double height;
  final Color color;
  final bool isFirst;
  final int animationDelay;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FadeInUp(
        delay: Duration(milliseconds: animationDelay),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: isFirst ? 36 : 28,
                    backgroundColor: Colors.white24,
                    child: Text(
                      entry.username.isNotEmpty ? entry.username[0].toUpperCase() : '?',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.username,
              style: TextStyle(
                color: Colors.white,
                fontSize: isFirst ? 14 : 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${entry.totalXp} XP',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: isFirst ? 12 : 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.8),
                    color.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: isFirst
                  ? const Icon(Icons.emoji_events_rounded, color: Colors.white54, size: 40)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({required this.entry});
  final dynamic entry;

  @override
  Widget build(BuildContext context) {
    return StudentCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.centerLeft,
            child: Text(
              '#${entry.position}',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.05),
              child: Text(
                entry.username.isNotEmpty ? entry.username[0].toUpperCase() : '?',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
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
                  entry.username,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      'Racha de ${entry.currentStreak} días',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalXp}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'XP',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

