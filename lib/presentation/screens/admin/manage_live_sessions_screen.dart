import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/domain/model/live_session.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/widgets/neon_button.dart';
import 'package:jumpup_app/presentation/screens/admin/create_live_session_screen.dart';

class ManageLiveSessionsScreen extends ConsumerWidget {
  const ManageLiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAsync = ref.watch(liveSessionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Gestión de Videotutorías',
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => ref.invalidate(liveSessionsProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7C4DFF),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Programar Clase',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateLiveSessionScreen()));
        },
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.05),
              ),
            ),
          ),
          liveAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: GlassContainer(
                  opacity: 0.1,
                  blur: 15,
                  padding: const EdgeInsets.all(24),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text('Error al cargar clases',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      NeonButton(
                        text: 'Reintentar',
                        onPressed: () => ref.invalidate(liveSessionsProvider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (sessions) {
              if (sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.videocam_off_rounded, size: 64, color: Colors.white24),
                      ),
                      const SizedBox(height: 24),
                      Text('Sin clases programadas',
                          style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text('Tus sesiones en vivo aparecerán aquí.',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54), textAlign: TextAlign.center),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return _SessionManagementCard(session: session);
                },
              );
            },
          ),
        ],
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
    final Color statusColor = isLive 
        ? const Color(0xFFFF5252) 
        : (isEnded ? Colors.white24 : const Color(0xFF7C4DFF));

    return GlassContainer(
      opacity: isLive ? 0.12 : 0.08,
      blur: 15,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    if (isLive) ...[
                      const Icon(Icons.circle, color: Color(0xFFFF5252), size: 8),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      session.statusLabel.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isLive ? const Color(0xFFFF5252) : statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.people_alt_rounded, color: Colors.white30, size: 16),
              const SizedBox(width: 6),
              Text('${session.participantCount}', 
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white38, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(session.title,
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
          if (session.description != null && session.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(session.description!, 
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white54, height: 1.4)),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: Color(0xFF7C4DFF), size: 16),
              const SizedBox(width: 8),
              Text(DateFormat('EEEE d MMMM, HH:mm', 'es').format(session.startsAt ?? DateTime.now()),
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white70, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          if (!isEnded)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: NeonButton(
                text: isLive ? 'Finalizar Sesión' : 'Iniciar Directo',
                glowColor: isLive ? const Color(0xFFFF5252) : const Color(0xFF7C4DFF),
                onPressed: () => _handleSessionAction(context, ref, isLive),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSessionAction(BuildContext context, WidgetRef ref, bool isLive) async {
    final repo = ref.read(socialRepositoryProvider);
    try {
      if (isLive) {
        await repo.endLiveSession(session.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sesión finalizada con éxito'), backgroundColor: Colors.black)
          );
        }
      } else {
        await repo.startLiveSession(session.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Directo iniciado. Los alumnos ya pueden unirse.'), backgroundColor: Colors.greenAccent)
          );
        }
      }
      ref.invalidate(liveSessionsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent)
        );
      }
    }
  }
}
