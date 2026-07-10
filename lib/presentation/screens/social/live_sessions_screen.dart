import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveSessionsScreen extends ConsumerWidget {
  const LiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAsync = ref.watch(liveSessionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: liveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (e, _) => _buildError(ref),
        data: (sessions) {
          if (sessions.isEmpty) return _buildEmpty();

          final live = sessions.where((s) => s.isLive).toList();
          final upcoming = sessions.where((s) => s.isScheduled).toList();
          final ended = sessions.where((s) => s.isEnded).toList();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(liveSessionsProvider.future),
            color: const Color(0xFF7C4DFF),
            backgroundColor: const Color(0xFF1A1D2E),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              physics: const BouncingScrollPhysics(),
              children: [
                if (live.isNotEmpty) ...[
                  _SectionHeader(label: 'EN VIVO AHORA', color: const Color(0xFFFF5252)),
                  ...live.map((s) => _SessionCard(session: s)),
                  const SizedBox(height: 16),
                ],
                if (upcoming.isNotEmpty) ...[
                  _SectionHeader(label: 'PRÓXIMAS SESIONES', color: const Color(0xFF7C4DFF)),
                  ...upcoming.map((s) => _SessionCard(session: s)),
                  const SizedBox(height: 16),
                ],
                if (ended.isNotEmpty) ...[
                  _SectionHeader(label: 'SESIONES PASADAS', color: Colors.white24),
                  ...ended.map((s) => _SessionCard(session: s)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.white24),
          const SizedBox(height: 12),
          Text('Error al cargar clases', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => ref.invalidate(liveSessionsProvider),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C4DFF).withOpacity(0.05),
            ),
            child: const Icon(Icons.videocam_off_rounded, size: 64, color: Colors.white24),
          ),
          const SizedBox(height: 24),
          Text('No hay clases programadas',
              style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Vuelve más tarde para unirte a sesiones en vivo',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 0),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white60,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final LiveSession session;

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final String statusText;
    final bool isLive = session.isLive;

    if (isLive) {
      statusColor = const Color(0xFFFF5252);
      statusText = 'EN VIVO';
    } else if (session.isScheduled) {
      statusColor = const Color(0xFF7C4DFF);
      statusText = 'PROGRAMADA';
    } else {
      statusColor = Colors.white24;
      statusText = 'FINALIZADA';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        opacity: isLive ? 0.12 : 0.05,
        blur: 15,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLive) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: Color(0xFFFF5252), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        statusText,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isLive ? const Color(0xFFFF5252) : statusColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(Icons.people_alt_rounded, size: 14, color: Colors.white38),
                const SizedBox(width: 6),
                Text(
                  '${session.participantCount}${session.maxStudents > 0 ? "/${session.maxStudents}" : ""}',
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white54, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              session.title,
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
            ),
            if (session.description != null && session.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                session.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white54, height: 1.4),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.2),
                  child: Text(
                    session.hostName.isNotEmpty ? session.hostName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Color(0xFF7C4DFF), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  session.hostName,
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (session.startsAt != null) ...[
                  const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white38),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM, HH:mm').format(session.startsAt!.toLocal()),
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white38, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
            if (session.isScheduled || isLive) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () async {
                    try {
                      // Usar ref para obtener el repositorio si es posible, o una instancia directa
                      // En un ConsumerWidget usamos el repositorio inyectado si existe
                      await const SocialMediaRepository().joinLiveSession(session.id);
                      if (session.meetingUrl != null && session.meetingUrl!.isNotEmpty) {
                        launchUrl(Uri.parse(session.meetingUrl!));
                      }
                    } catch (_) {}
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: isLive ? const Color(0xFFFF5252) : const Color(0xFF7C4DFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    isLive ? 'UNIRSE AHORA' : 'RESERVAR LUGAR',
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
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
