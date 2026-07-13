import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/presentation/screens/common/live_session_join_screen.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

/// Tokens de estilo centralizados para mantener una paleta coherente.
class _LiveTokens {
  static const Color brand = Color(0xFF7C4DFF);
  static const Color brandAlt = Color(0xFF5B8DEF);
  static const Color live = Color(0xFFFF4D6D);
  static const Color liveAlt = Color(0xFFFF8A5B);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [brand, brandAlt],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient liveGradient = LinearGradient(
    colors: [live, liveAlt],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color textPrimary(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF14162B);
  static Color textSecondary(bool isDark) =>
      isDark ? Colors.white70 : const Color(0xFF565973);
  static Color textMuted(bool isDark) =>
      isDark ? Colors.white38 : const Color(0xFF9A9DB4);
}

class LiveSessionsScreen extends ConsumerStatefulWidget {
  const LiveSessionsScreen({super.key});

  @override
  ConsumerState<LiveSessionsScreen> createState() => _LiveSessionsScreenState();
}

class _LiveSessionsScreenState extends ConsumerState<LiveSessionsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final liveAsync = ref.watch(liveSessionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: liveAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _LiveTokens.brand),
        ),
        error: (e, _) => _buildError(ref, isDark),
        data: (sessions) {
          if (sessions.isEmpty) return _buildEmpty(isDark);
          final live = sessions.where((s) => s.isLive).toList();
          final upcoming = sessions.where((s) => s.isScheduled).toList();
          final ended = sessions.where((s) => s.isEnded).toList();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(liveSessionsProvider.future),
            color: _LiveTokens.brand,
            backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              physics: const BouncingScrollPhysics(),
              children: [
                _OverviewBanner(
                  liveCount: live.length,
                  upcomingCount: upcoming.length,
                  isDark: isDark,
                ),
                const SizedBox(height: 24),
                if (live.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'EN VIVO AHORA',
                    count: live.length,
                    gradient: _LiveTokens.liveGradient,
                    color: _LiveTokens.live,
                    isDark: isDark,
                    pulse: true,
                  ),
                  ...live.map((s) => _SessionCard(session: s)),
                  const SizedBox(height: 20),
                ],
                if (upcoming.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'PRÓXIMAS SESIONES',
                    count: upcoming.length,
                    gradient: _LiveTokens.brandGradient,
                    color: _LiveTokens.brand,
                    isDark: isDark,
                  ),
                  ...upcoming.map((s) => _SessionCard(session: s)),
                  const SizedBox(height: 20),
                ],
                if (ended.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'SESIONES PASADAS',
                    count: ended.length,
                    gradient: LinearGradient(colors: [
                      _LiveTokens.textMuted(isDark),
                      _LiveTokens.textMuted(isDark),
                    ]),
                    color: _LiveTokens.textMuted(isDark),
                    isDark: isDark,
                  ),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _LiveTokens.live.withValues(alpha: 0.08),
            ),
            child: Icon(Icons.wifi_off_rounded,
                size: 52, color: _LiveTokens.live.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 16),
          Text('Error al cargar clases',
              style: AppTextStyles.titleMedium.copyWith(
                  color: _LiveTokens.textPrimary(isDark),
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Revisa tu conexión e inténtalo de nuevo',
              style: AppTextStyles.bodySmall
                  .copyWith(color: _LiveTokens.textSecondary(isDark))),
          const SizedBox(height: 20),
          _GradientButton(
            label: 'Reintentar',
            icon: Icons.refresh_rounded,
            gradient: _LiveTokens.brandGradient,
            glow: _LiveTokens.brand,
            onTap: () => ref.invalidate(liveSessionsProvider),
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
            padding: const EdgeInsets.all(34),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _LiveTokens.brand.withValues(alpha: 0.14),
                  _LiveTokens.brandAlt.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ShaderMask(
              shaderCallback: (b) => _LiveTokens.brandGradient.createShader(b),
              child: const Icon(Icons.videocam_off_rounded,
                  size: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text('No hay clases programadas',
              style: AppTextStyles.titleLarge.copyWith(
                  color: _LiveTokens.textPrimary(isDark),
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text('Vuelve más tarde para unirte a sesiones en vivo',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: _LiveTokens.textSecondary(isDark))),
          ),
        ],
      ),
    );
  }
}

/// Banner superior con resumen (solo presentación, sin lógica de datos nueva).
class _OverviewBanner extends StatelessWidget {
  const _OverviewBanner({
    required this.liveCount,
    required this.upcomingCount,
    required this.isDark,
  });

  final int liveCount;
  final int upcomingCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _LiveTokens.brandGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _LiveTokens.brand.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Clases en directo',
                    style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('Aprende y conecta en tiempo real',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _MiniStat(value: liveCount, label: 'en vivo'),
                    const SizedBox(width: 20),
                    _MiniStat(value: upcomingCount, label: 'próximas'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.live_tv_rounded,
                color: Colors.white, size: 34),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('$value',
            style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white, fontWeight: FontWeight.w900)),
        const SizedBox(width: 5),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(label,
              style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.gradient,
    required this.color,
    required this.isDark,
    this.pulse = false,
  });

  final String label;
  final int count;
  final Gradient gradient;
  final Color color;
  final bool isDark;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 14, top: 4),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 18,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (pulse) ...[
            _PulsingDot(color: color),
            const SizedBox(width: 8),
          ],
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(
                  color: _LiveTokens.textSecondary(isDark),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count',
                style: AppTextStyles.labelSmall.copyWith(
                    color: color, fontWeight: FontWeight.w900, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.6 * (1 - _c.value)),
                blurRadius: 6 + 8 * _c.value,
                spreadRadius: 1 + 3 * _c.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard({required this.session});
  final LiveSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = _LiveTokens.textPrimary(isDark);
    final subtextColor = _LiveTokens.textSecondary(isDark);
    final statColor = _LiveTokens.textMuted(isDark);
    final bool isLive = session.isLive;

    final Color statusColor;
    final Gradient statusGradient;
    final String statusText;
    if (isLive) {
      statusColor = _LiveTokens.live;
      statusGradient = _LiveTokens.liveGradient;
      statusText = 'EN VIVO';
    } else if (session.isScheduled) {
      statusColor = _LiveTokens.brand;
      statusGradient = _LiveTokens.brandGradient;
      statusText = 'PROGRAMADA';
    } else {
      statusColor = statColor;
      statusGradient = LinearGradient(colors: [statColor, statColor]);
      statusText = 'FINALIZADA';
    }

    final bool hasCap = session.maxStudents > 0;
    final double capRatio = hasCap
        ? (session.participantCount / session.maxStudents).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: isLive
              ? [
                  BoxShadow(
                    color: _LiveTokens.live.withValues(alpha: 0.22),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: GlassContainer(
            opacity: isLive ? 0.14 : 0.06,
            blur: 16,
            borderRadius: BorderRadius.circular(26),
            padding: EdgeInsets.zero,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Franja de acento lateral.
                  Container(width: 5, decoration: BoxDecoration(gradient: statusGradient)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _StatusBadge(
                                text: statusText,
                                color: statusColor,
                                gradient: statusGradient,
                                live: isLive,
                              ),
                              const Spacer(),
                              Icon(Icons.people_alt_rounded,
                                  size: 15, color: statColor),
                              const SizedBox(width: 6),
                              Text(
                                '${session.participantCount}${hasCap ? "/${session.maxStudents}" : ""}',
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: statColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(session.title,
                              style: AppTextStyles.titleMedium.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2)),
                          if (session.description != null &&
                              session.description!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(session.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: subtextColor, height: 1.45)),
                          ],
                          if (hasCap) ...[
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: capRatio,
                                minHeight: 5,
                                backgroundColor:
                                    statColor.withValues(alpha: 0.15),
                                valueColor:
                                    AlwaysStoppedAnimation(statusColor),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _HostAvatar(name: session.hostName),
                              const SizedBox(width: 9),
                              Flexible(
                                child: Text(session.hostName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.labelSmall.copyWith(
                                        color: subtextColor,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const Spacer(),
                              if (session.startsAt != null) ...[
                                Icon(Icons.calendar_today_rounded,
                                    size: 13, color: statColor),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('dd MMM, HH:mm')
                                      .format(session.startsAt!.toLocal()),
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: statColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ],
                          ),
                          if (session.isScheduled || isLive) ...[
                            const SizedBox(height: 18),
                            _GradientButton(
                              label: isLive ? 'UNIRSE AHORA' : 'RESERVAR LUGAR',
                              icon: isLive
                                  ? Icons.videocam_rounded
                                  : Icons.event_available_rounded,
                              gradient: statusGradient,
                              glow: statusColor,
                              fullWidth: true,
                              onTap: () async {
                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                try {
                                  await const SocialMediaRepository()
                                      .joinLiveSession(session.id);
                                  if (context.mounted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => LiveSessionJoinScreen(
                                          meetingUrl: session.meetingUrl ?? '',
                                          title: session.title,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (_) {}
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.text,
    required this.color,
    required this.gradient,
    required this.live,
  });

  final String text;
  final Color color;
  final Gradient gradient;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (live) ...[
            _PulsingDot(color: color),
            const SizedBox(width: 7),
          ],
          Text(text,
              style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _HostAvatar extends StatelessWidget {
  const _HostAvatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        gradient: _LiveTokens.brandGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _LiveTokens.brand.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.glow,
    required this.onTap,
    this.fullWidth = false,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color glow;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: fullWidth ? double.infinity : null,
          height: 46,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: glow.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 19),
              const SizedBox(width: 9),
              Text(label,
                  style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
