import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';

class LiveSessionsScreen extends ConsumerWidget {
  const LiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final liveAsync = ref.watch(liveSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesiones en Vivo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(liveSessionsProvider),
          ),
        ],
      ),
      body: liveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 48,
                    color: theme.colorScheme.error),
                const SizedBox(height: 12),
                Text('Error al cargar sesiones',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(liveSessionsProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (sessions) {
          final live = sessions.where((s) => s.isLive).toList();
          final upcoming = sessions.where((s) => s.isScheduled).toList();
          final ended = sessions.where((s) => s.isEnded).toList();

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_outlined,
                      size: 64,
                      color: theme.colorScheme.primary
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('No hay sesiones',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Próximamente encontrarás clases en vivo aquí',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              if (live.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('En vivo',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                ...live.map((s) => _SessionCard(session: s)),
                const SizedBox(height: 16),
              ],
              if (upcoming.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Programadas',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                ...upcoming.map((s) => _SessionCard(session: s)),
                const SizedBox(height: 16),
              ],
              if (ended.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Finalizadas',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                ...ended.map((s) => _SessionCard(session: s)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final dynamic session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLive = session.isLive;
    final isScheduled = session.isScheduled;

    final Color statusColor;
    final String statusText;
    if (isLive) {
      statusColor = Colors.red;
      statusText = 'En vivo';
    } else if (isScheduled) {
      statusColor = Colors.orange;
      statusText = 'Programada';
    } else {
      statusColor = Colors.grey;
      statusText = 'Finalizada';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLive)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (isLive) const SizedBox(width: 6),
                      Text(statusText,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: statusColor)),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(Icons.people_outline,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${session.participantCount}',
                    style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            Text(session.title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            if (session.description != null) ...[
              const SizedBox(height: 4),
              Text(session.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(session.hostName,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w500)),
                const Spacer(),
                Icon(Icons.schedule, size: 16,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM · HH:mm')
                      .format(session.startsAt.toLocal()),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
