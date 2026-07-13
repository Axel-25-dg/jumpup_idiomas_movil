import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

class DailyChallengesScreen extends ConsumerWidget {
  const DailyChallengesScreen({super.key});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'menu_book':
        return Icons.menu_book;
      case 'quiz':
        return Icons.quiz;
      case 'smart_toy':
        return Icons.smart_toy;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(dailyChallengesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Juegos y Retos',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.offline_bolt, color: AppColors.primary),
            tooltip: 'Modo Offline',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Lecciones descargadas y listas para modo offline.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_download,
                      color: AppColors.secondary, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estudia sin conexión',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const Text('Tienes 3 lecciones descargadas.',
                            style:
                                TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Descargando paquete de lecciones de soporte (offline-pack)...')),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Gestionar descargas',
                              style: TextStyle(color: AppColors.secondary)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Retos de hoy',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            const SizedBox(height: 16),
            challengesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'No se pudieron cargar los retos',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(dailyChallengesProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (challenges) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: challenges.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final ch = challenges[i];
                    return _ChallengeCard(
                      title: ch['title']?.toString() ?? '',
                      xpReward: ch['xpReward'] as int? ?? 0,
                      progress: (ch['progress'] as num?)?.toDouble() ?? 0.0,
                      current: ch['current'] as int? ?? 0,
                      target: ch['target'] as int? ?? 1,
                      icon: _getIconData(ch['icon']?.toString() ?? ''),
                      isCompleted: ch['isCompleted'] as bool? ?? false,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF448AFF)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.card_giftcard_rounded, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text('Cofre Diario',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22)),
                  const Text('Completa todos los retos para abrirlo',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text('ABRIR COFRE',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.title,
    required this.xpReward,
    required this.progress,
    required this.current,
    required this.target,
    required this.icon,
    this.isCompleted = false,
  });

  final String title;
  final int xpReward;
  final double progress;
  final int current;
  final int target;
  final IconData icon;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.divider,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isCompleted ? AppColors.success : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isCompleted ? AppColors.success : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.divider,
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.primary,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$current / $target',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$xpReward XP',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
