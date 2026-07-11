import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveSessionsScreen extends ConsumerWidget {
  const LiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAsync = ref.watch(liveSessionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: liveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (e, _) => _buildError(ref, isDark),
        data: (sessions) {
          if (sessions.isEmpty) return _buildEmpty(isDark);
          final live = sessions.where((s) => s.isLive).toList();
          final upcoming = sessions.where((s) => s.isScheduled).toList();
          final ended = sessions.where((s) => s.isEnded).toList();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(liveSessionsProvider.future),
            color: const Color(0xFF7C4DFF),
            backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              physics: const BouncingScrollPhysics(),
              children: [
                if (live.isNotEmpty) ...[
                  _SectionHeader(label: 'EN VIVO AHORA', color: const Color(0xFFFF5252), isDark: isDark),
                  ...live.map((s) => _SessionCard(session: s)),
                  const SizedBox(height: 16),
                ],
                if (upcoming.isNotEmpty) ...[
                  _SectionHeader(label: 'PRÓXIMAS SESIONES', color: const Color(0xFF7C4DFF), isDark: isDark),
                  ...upcoming.map((s) => _SessionCard(session: s)),
                  const SizedBox(height: 16),
                ],
                if (ended.isNotEmpty) ...[
                  _SectionHeader(
                      label: 'SESIONES PASADAS',
                      color: isDark ? Colors.white24 : Colors.black26,
                      isDark: isDark),
                  ...ended.map((s) => _SessionCard(session: s)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(WidgetRef ref, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 60, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 12),
          Text('Error al cargar clases',
              style: AppTextStyles.bodyMedium.copyWith(color: isDark ? Colors.white54 : Colors.black54)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => ref.invalidate(liveSessionsProvider),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.05),
            ),
            child: Icon(Icons.videocam_off_rounded, size: 64,
                color: isDark ? Colors.white24 : Colors.black26),
          ),
          const SizedBox(height: 24),
          Text('No hay clases programadas',
              style: AppTextStyles.titleLarge.copyWith(
                  color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Vuelve más tarde para unirte a sesiones en vivo',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white54 : Colors.black54)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.color, required this.isDark});
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Row(
        children: [
          Container(
            width: 4, height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)],
            ),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black54;
    final statColor = isDark ? Colors.white38 : Colors.black38;
    final statIconColor = isDark ? Colors.white38 : Colors.black38;
    final bool isLive = session.isLive;

    final Color statusColor;
    final String statusText;
    if (isLive) {
      statusColor = const Color(0xFFFF5252);
      statusText = 'EN VIVO';
    } else if (session.isScheduled) {
      statusColor = const Color(0xFF7C4DFF);
      statusText = 'PROGRAMADA';
    } else {
      statusColor = isDark ? Colors.white24 : Colors.black26;
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
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLive) ...[
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFF5252), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(statusText,
                          style: AppTextStyles.labelSmall.copyWith(
                              color: isLive ? const Color(0xFFFF5252) : statusColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 10)),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(Icons.people_alt_rounded, size: 14, color: statIconColor),
                const SizedBox(width: 6),
                Text(
                  '${session.participantCount}${session.maxStudents > 0 ? "/${session.maxStudents}" : ""}',
                  style: AppTextStyles.labelSmall.copyWith(color: statColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(session.title,
                style: AppTextStyles.titleMedium.copyWith(
                    color: textColor, fontWeight: FontWeight.w900)),
            if (session.description != null && session.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(session.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(color: subtextColor, height: 1.4)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                  child: Text(
                    session.hostName.isNotEmpty ? session.hostName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Color(0xFF7C4DFF), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(session.hostName,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (session.startsAt != null) ...[
                  Icon(Icons.calendar_today_rounded, size: 12, color: statIconColor),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM, HH:mm').format(session.startsAt!.toLocal()),
                    style: AppTextStyles.labelSmall.copyWith(
                        color: statColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
            if (session.isScheduled || isLive) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 44,
                child: FilledButton(
                  onPressed: () async {
                    try {
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
                    style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w900),
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
