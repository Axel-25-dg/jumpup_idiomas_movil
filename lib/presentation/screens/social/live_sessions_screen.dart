import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveSessionsScreen extends ConsumerWidget {
  const LiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAsync = ref.watch(liveSessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: liveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => _buildError(ref),
        data: (sessions) {
          if (sessions.isEmpty) return _buildEmpty();

          final live = sessions.where((s) => s.isLive).toList();
          final upcoming = sessions.where((s) => s.isScheduled).toList();
          final ended = sessions.where((s) => s.isEnded).toList();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(liveSessionsProvider.future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                if (live.isNotEmpty) ...[
                  _SectionHeader(label: 'En vivo', color: AppColors.error),
                  ...live.map((s) => _SessionCard(session: s)),
                  const SizedBox(height: 16),
                ],
                if (upcoming.isNotEmpty) ...[
                  _SectionHeader(label: 'Programadas', color: AppColors.primary),
                  ...upcoming.map((s) => _SessionCard(session: s)),
                  const SizedBox(height: 16),
                ],
                if (ended.isNotEmpty) ...[
                  _SectionHeader(label: 'Finalizadas', color: AppColors.textSecondary),
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
          const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text('Error al cargar sesiones', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.invalidate(liveSessionsProvider),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Reintentar'),
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
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
            child: Icon(Icons.videocam_outlined, size: 56, color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          Text('No hay sesiones', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Próximamente encontrarás clases en vivo aquí',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
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
    if (session.isLive) {
      statusColor = AppColors.error;
      statusText = 'En vivo';
    } else if (session.isScheduled) {
      statusColor = AppColors.warning;
      statusText = 'Programada';
    } else {
      statusColor = AppColors.textSecondary;
      statusText = 'Finalizada';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (session.isLive)
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                    if (session.isLive) const SizedBox(width: 6),
                    Text(statusText, style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${session.participantCount}', style: AppTextStyles.bodySmall),
              if (session.maxStudents > 0) Text('/${session.maxStudents}', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          Text(session.title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
          if (session.description != null && session.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(session.description!,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(session.hostName, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500)),
              const Spacer(),
              if (session.startsAt != null) ...[
                Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(DateFormat('dd MMM · HH:mm').format(session.startsAt!.toLocal()),
                    style: AppTextStyles.bodySmall),
              ],
            ],
          ),
          if (session.isScheduled || session.isLive) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
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
                  backgroundColor: session.isLive ? AppColors.error : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(session.isLive ? 'Unirse ahora' : 'Inscribirse',
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
