import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/domain/model/live_session.dart';
import 'package:jumpup_app/presentation/screens/admin/create_live_session_screen.dart';

class ManageLiveSessionsScreen extends ConsumerWidget {
  const ManageLiveSessionsScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAsync = ref.watch(liveSessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Videotutorías',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: !embedded,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => ref.invalidate(liveSessionsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateLiveSessionScreen()));
        },
      ),
      body: liveAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('Error: $e',
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  onPressed: () => ref.invalidate(liveSessionsProvider),
                  child: const Text('Reintentar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_off_outlined,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  const Text('No hay sesiones programadas',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Toca + para programar tu primera videotutoría.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _SessionCard(session: session);
            },
          );
        },
      ),
    );
  }
}

class _SessionCard extends ConsumerStatefulWidget {
  const _SessionCard({required this.session});
  final LiveSession session;

  @override
  ConsumerState<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends ConsumerState<_SessionCard> {
  bool _loading = false;

  Future<void> _handleAction() async {
    final repo = ref.read(socialRepositoryProvider);
    setState(() => _loading = true);
    try {
      if (widget.session.isLive) {
        await repo.endLiveSession(widget.session.id);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sesión finalizada')));
      } else {
        await repo.startLiveSession(widget.session.id);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sesión iniciada')));
      }
      ref.invalidate(liveSessionsProvider);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = widget.session.isLive;
    final isEnded = widget.session.isEnded;
    final statusColor = isLive
        ? AppColors.error
        : isEnded
            ? AppColors.textSecondary
            : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider),
      ),
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    if (isLive) ...[
                      const Icon(Icons.circle,
                          color: AppColors.error, size: 8),
                      const SizedBox(width: 4),
                    ],
                    Text(widget.session.statusLabel.toUpperCase(),
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
                const Spacer(),
                Icon(Icons.people_outline,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${widget.session.participantCount}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.session.title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            if (widget.session.description != null) ...[
              const SizedBox(height: 4),
              Text(widget.session.description!,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                DateFormat('dd MMM yyyy, HH:mm')
                    .format(widget.session.startsAt),
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ]),
            if (!isEnded) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isLive ? AppColors.error : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _loading ? null : _handleAction,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(isLive ? 'Finalizar Sesión' : 'Iniciar Sesión'),
                ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
