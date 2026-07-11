import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/domain/model/live_session.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/widgets/neon_button.dart';
import 'package:jumpup_app/presentation/screens/admin/create_live_session_screen.dart';

class ManageLiveSessionsScreen extends ConsumerWidget {
  const ManageLiveSessionsScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAsync = ref.watch(liveSessionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        elevation: 0,
        title: const Text('Gestión de Videotutorías', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(liveSessionsProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C4DFF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateLiveSessionScreen()));
        },
      ),
      body: liveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF)),
                onPressed: () => ref.invalidate(liveSessionsProvider),
                child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_off_outlined, size: 64, color: Colors.white30),
                  SizedBox(height: 12),
                  Text('No hay sesiones programadas', style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Tus sesiones en vivo aparecerán aquí.', style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _SessionManagementCard(session: session);
            },
          );
        },
      ),
    );
  }
}

class _SessionManagementCard extends ConsumerWidget {
  const _SessionManagementCard({required this.session});
  final LiveSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLive = session.isLive;
    final bool isEnded = session.isEnded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        opacity: 0.1,
        blur: 10,
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLive
                        ? Colors.redAccent.withValues(alpha: 0.2)
                        : (isEnded ? Colors.white12 : Colors.blueAccent.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isLive
                            ? Colors.redAccent
                            : (isEnded ? Colors.white30 : Colors.blueAccent)),
                  ),
                  child: Row(
                    children: [
                      if (isLive) ...[
                        const Icon(Icons.circle, color: Colors.redAccent, size: 8),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        session.statusLabel.toUpperCase(),
                        style: TextStyle(
                          color: isLive
                              ? Colors.redAccent
                              : (isEnded ? Colors.white54 : Colors.blueAccent),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.people_outline, color: Colors.white54, size: 16),
                const SizedBox(width: 4),
                Text('${session.participantCount}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text(session.title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            if (session.description != null) ...[
              const SizedBox(height: 4),
              Text(session.description!,
                  style: const TextStyle(color: Colors.white54, fontSize: 14)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: Colors.white54, size: 14),
                const SizedBox(width: 6),
                Text(
                  session.startsAt != null 
                      ? DateFormat('dd MMM yyyy, HH:mm').format(session.startsAt!)
                      : 'Sin fecha',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isEnded)
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: isLive ? 'Finalizar Sesión' : 'Iniciar Sesión',
                  glowColor: isLive ? Colors.redAccent : const Color(0xFF7C4DFF),
                  onPressed: () => _handleSessionAction(context, ref, isLive),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSessionAction(
      BuildContext context, WidgetRef ref, bool isLive) async {
    final repo = ref.read(socialRepositoryProvider);
    try {
      if (isLive) {
        await repo.endLiveSession(session.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Sesión finalizada')));
        }
      } else {
        await repo.startLiveSession(session.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sesión iniciada correctamente')));
        }
      }
      ref.invalidate(liveSessionsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
