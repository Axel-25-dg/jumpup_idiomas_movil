import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/domain/model/live_session.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/widgets/neon_button.dart';
import 'package:jumpup_app/presentation/screens/admin/create_live_session_screen.dart';
import 'package:jumpup_app/presentation/screens/common/live_session_join_screen.dart';

class ManageLiveSessionsScreen extends ConsumerWidget {
  const ManageLiveSessionsScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAsync = ref.watch(liveSessionsProvider);

    final content = Stack(
      children: [
        // Decorative Blobs
        if (embedded) ...[
          Positioned(
            top: -100,
            right: -100,
            child: _blob(const Color(0xFF7C4DFF), 300),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: _blob(const Color(0xFF00E5FF), 250),
          ),
        ],

        RefreshIndicator(
          color: const Color(0xFF7C4DFF),
          onRefresh: () async => ref.invalidate(liveSessionsProvider),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              if (embedded)
                const SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    title: Text(
                      'Live Sessions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    centerTitle: false,
                  ),
                ),
              
              liveAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                ),
                error: (e, stack) {
                  debugPrint('Live Sessions Error: $e\n$stack');
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'Error al cargar sesiones en vivo. Por favor, intenta de nuevo.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  );
                },
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam_off_outlined, size: 64, color: Colors.white30),
                            SizedBox(height: 12),
                            Text('No hay sesiones programadas',
                                style: TextStyle(color: Colors.white, fontSize: 18)),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _SessionManagementCard(session: sessions[index]),
                        childCount: sessions.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );

    if (embedded) return content;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        elevation: 0,
        title: const Text('Gestión de Videotutorías', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C4DFF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateLiveSessionScreen()));
        },
      ),
      body: content,
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.05),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 80)],
        ),
      );
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
            if (!isEnded) ...[
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: isLive ? 'Finalizar Sesión' : 'Iniciar Sesión',
                  glowColor: isLive ? Colors.redAccent : const Color(0xFF7C4DFF),
                  onPressed: () => _handleSessionAction(context, ref, isLive),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LiveSessionJoinScreen(
                          meetingUrl: session.meetingUrl ?? '',
                          title: session.title,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.videocam_rounded, size: 18),
                  label: const Text('Entrar a la sala'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF7C4DFF)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
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
