import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAchievementsAsync = ref.watch(achievementsProvider);
    final myAchievementsAsync = ref.watch(myAchievementsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Logros 🏆',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: allAchievementsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (_, __) => const Center(
          child: Text('Error al cargar logros',
              style: TextStyle(color: Colors.redAccent)),
        ),
        data: (allAchievements) => myAchievementsAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
          error: (_, __) => const SizedBox.shrink(),
          data: (myAchievements) {
            final unlockedIds =
                myAchievements.map((a) => a.achievement.id).toSet();
            final unlocked = allAchievements
                .where((a) => unlockedIds.contains(a.id))
                .toList();
            final locked = allAchievements
                .where((a) => !unlockedIds.contains(a.id))
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFD700).withValues(alpha: 0.2),
                          const Color(0xFFFFD700).withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${unlocked.length} de ${allAchievements.length} logros',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Text(
                              '${locked.length} logros por desbloquear',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (unlocked.isNotEmpty) ...[
                    const Text('Desbloqueados',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 12),
                    ...unlocked.map((a) => _AchievementCard(
                          achievement: a,
                          isUnlocked: true,
                          unlockedAt: myAchievements
                              .firstWhere((ua) => ua.achievement.id == a.id)
                              .unlockedAt,
                        )),
                    const SizedBox(height: 20),
                  ],
                  if (locked.isNotEmpty) ...[
                    const Text('Por desbloquear',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 12),
                    ...locked.map((a) => _AchievementCard(
                          achievement: a,
                          isUnlocked: false,
                        )),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
    this.unlockedAt,
  });

  final dynamic achievement;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? const Color(0xFFFFD700).withValues(alpha: 0.05)
            : const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFFFFD700).withValues(alpha: 0.4)
              : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                  : Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                isUnlocked ? '🏆' : '🔒',
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  achievement.description,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                if (isUnlocked && unlockedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Desbloqueado el ${_formatDate(unlockedAt!)}',
                    style:
                        const TextStyle(color: Color(0xFFFFD700), fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                  : Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '⚡ ${achievement.requiredXp}',
              style: TextStyle(
                color: isUnlocked ? const Color(0xFFFFD700) : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
