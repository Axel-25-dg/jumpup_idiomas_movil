import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/domain/model/dashboard_models.dart';
import 'package:jumpup_app/domain/model/progress_models.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/providers/subscription_providers.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/presentation/widgets/shared/user_avatar.dart';
import 'package:jumpup_app/presentation/widgets/shared/product_image.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';

// Screens for bottom nav tabs
import 'package:jumpup_app/presentation/screens/student/course_list_screen.dart';
import 'package:jumpup_app/presentation/screens/student/progress_screen.dart';
import 'package:jumpup_app/presentation/screens/student/profile_screen.dart';
import 'package:jumpup_app/presentation/screens/social/social_media_shell.dart';

/// Tokens de diseño centralizados para evitar repetir colores/gradientes.
class _DashTokens {
  const _DashTokens._();

  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  static Color surface(BuildContext context) => Theme.of(context).cardColor;

  static const Color primary = Color(0xFF2575FC);
  static const Color secondary = Color(0xFF6A11CB);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color brandGlow = Color(0xFF2575FC);

  /// Superficie tipo "liquid glass": muy translúcida con leve tinte de marca.
  static Color glassFill(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Colors.white.withValues(alpha: isDark ? 0.06 : 0.12);
  }

  static Color glassStroke(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (isDark ? Colors.white : Colors.black)
        .withValues(alpha: isDark ? 0.14 : 0.08);
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    _HomeTab(),
    CourseListScreen(),
    SocialMediaShell(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DashTokens.background(context),
      // La barra flota por encima del contenido (estilo liquid glass).
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _LiquidGlassNav(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.active, this.inactive, this.label);
  final IconData active;
  final IconData inactive;
  final String label;
}

/// Barra inferior flotante con efecto "liquid glass" al estilo del nuevo
/// diseño de WhatsApp: pill translúcida, blur intenso, indicador deslizante.
class _LiquidGlassNav extends StatelessWidget {
  const _LiquidGlassNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  List<_NavItem> _getItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _NavItem(Icons.home_rounded, Icons.home_outlined, l10n.home),
      _NavItem(Icons.school_rounded, Icons.school_outlined, l10n.classrooms),
      _NavItem(Icons.forum_rounded, Icons.forum_outlined, l10n.social),
      _NavItem(Icons.bar_chart_rounded, Icons.bar_chart_outlined, l10n.progress),
      _NavItem(Icons.person_rounded, Icons.person_outlined, l10n.profile),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItems(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double totalWidth = constraints.maxWidth;
            final int count = items.length;
            final double slotWidth = totalWidth / count;

            return ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 68,
                  decoration: BoxDecoration(
                    color: _DashTokens.glassFill(context),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: _DashTokens.glassStroke(context),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.45 : 0.18),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                      // Glow superior sutil que simula reflejo del cristal.
                      BoxShadow(
                        color: Colors.white
                            .withValues(alpha: isDark ? 0.04 : 0.35),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Indicador deslizante (la "gota" de líquido).
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutCubic,
                        left: slotWidth * currentIndex,
                        top: 0,
                        bottom: 0,
                        width: slotWidth,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeOutCubic,
                            width: slotWidth - 14,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: _DashTokens.brandGradient,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: _DashTokens.brandGlow
                                      .withValues(alpha: 0.45),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Expanded(
                              child: _NavButton(
                                item: items[i],
                                isSelected: i == currentIndex,
                                onTap: () => onTap(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color inactiveColor =
        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.45);

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                scale: isSelected ? 1.12 : 1.0,
                child: Icon(
                  isSelected ? item.active : item.inactive,
                  color: isSelected ? Colors.white : inactiveColor,
                  size: 24,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 0.2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> with TickerProviderStateMixin {
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Malla de color de fondo (blobs suaves animados).
        AnimatedBuilder(
          animation: _blobController,
          builder: (context, child) {
            return Stack(
              children: [
                _BackgroundBlob(
                  top: -60 + (30 * _blobController.value),
                  left: -50 + (20 * _blobController.value),
                  size: 300,
                  color: _DashTokens.secondary,
                  opacity: isDark ? 0.15 : 0.08,
                ),
                _BackgroundBlob(
                  bottom: 120 - (40 * _blobController.value),
                  right: -60 + (30 * _blobController.value),
                  size: 280,
                  color: _DashTokens.primary,
                  opacity: isDark ? 0.12 : 0.06,
                ),
              ],
            );
          },
        ),
        RefreshIndicator(
          color: _DashTokens.primary,
          backgroundColor: _DashTokens.surface(context),
          onRefresh: () async {
            ref.invalidate(userProfileProvider);
            ref.invalidate(dashboardSummaryProvider);
            ref.invalidate(userStatsProvider);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _SliverHeader(userAsync: userAsync, statsAsync: statsAsync),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _XPAndStreakBanner(statsAsync: statsAsync),
                    const SizedBox(height: 14),
                    _SectionTitle(AppLocalizations.of(context)!.quickActions),
                    const SizedBox(height: 8),
                    const _QuickActionsGrid(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: _SectionTitle(
                              AppLocalizations.of(context)!.recentProgress),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.studentClassrooms),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.viewVirtualClasses,
                            style: const TextStyle(
                              color: _DashTokens.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _RecentCourseCard(summaryAsync: summaryAsync),
                    const SizedBox(height: 14),
                    const _TutorIABanner(),
                    const SizedBox(height: 14),
                    _SubscriptionBanner(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubscriptionBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mySubAsync = ref.watch(mySubscriptionProvider);
    final isPro = mySubAsync.value?.isActive ?? false;

    if (isPro) return const SizedBox.shrink();

    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      blur: 24,
      opacity: isDark ? 0.06 : 0.08,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amberAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.star_rounded,
                color: Colors.amberAccent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mejora tu Plan',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Accede a todos los cursos y tutor IA.',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => context.push('/student/subscriptions'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text(
              'Ver Planes',
              style: TextStyle(
                color: _DashTokens.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _BackgroundBlob extends StatelessWidget {
  const _BackgroundBlob({
    required this.size,
    required this.color,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.opacity = 0.18,
  });

  final double size;
  final Color color;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: opacity),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: opacity + 0.04),
                blurRadius: 110,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverHeader extends StatelessWidget {
  const _SliverHeader({required this.userAsync, required this.statsAsync});

  final AsyncValue<UserProfileModel> userAsync;
  final AsyncValue<UserStatsModel> statsAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 88,
      pinned: true,
      backgroundColor: _DashTokens.background(context).withValues(alpha: 0.6),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: userAsync.when(
                  data: (user) => Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _DashTokens.brandGradient,
                          boxShadow: [
                            BoxShadow(
                              color: _DashTokens.brandGlow
                                  .withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: UserAvatar(
                          imageUrl:
                              AppConfig.resolveImageUrl(user.avatarUrl),
                          fullName: user.username,
                          radius: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.hello(user.username),
                              style: AppTextStyles.titleMedium.copyWith(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              l10n.readyToLearn,
                              style: AppTextStyles.bodySmall.copyWith(
                                color:
                                    isDark ? Colors.white60 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.home),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(10),
                          borderRadius: BorderRadius.circular(14),
                          opacity: 0.1,
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: Colors.amberAccent,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Center(
                    child:
                        CircularProgressIndicator(color: _DashTokens.primary),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _XPAndStreakBanner extends StatelessWidget {
  const _XPAndStreakBanner({required this.statsAsync});

  final AsyncValue<UserStatsModel> statsAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return statsAsync.when(
      data: (stats) => GlassContainer(
        borderRadius: BorderRadius.circular(24),
        blur: 24,
        opacity: isDark ? 0.06 : 0.08,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatBadgeItem(
                    icon: Icons.local_fire_department_rounded,
                    color: Colors.orangeAccent,
                    value: l10n.streakDays(stats.currentStreak),
                    label: l10n.currentStreak,
                  ),
                ),
                Container(
                  width: 1.5,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Expanded(
                  child: _StatBadgeItem(
                    icon: Icons.star_rounded,
                    color: Colors.purpleAccent,
                    value: l10n.xpAmount(stats.xpProgress),
                    label: l10n.levelLabel(stats.level),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    l10n.levelProgressLabel(stats.level),
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${stats.xpProgress}/${stats.xpForNextLevel} XP',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: stats.levelProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2575FC).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => GlassContainer(
        height: 120,
        blur: 24,
        opacity: isDark ? 0.06 : 0.08,
        borderRadius: BorderRadius.circular(24),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StatBadgeItem extends StatelessWidget {
  const _StatBadgeItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction(this.icon, this.label, this.color, this.route);
  final IconData icon;
  final String label;
  final Color color;
  final String route;
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  List<_QuickAction> _getActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _QuickAction(
        Icons.videocam_rounded,
        l10n.virtualClasses,
        _DashTokens.primary,
        AppRoutes.studentClassrooms,
      ),
      _QuickAction(
        Icons.shopping_bag_rounded,
        l10n.store,
        Colors.greenAccent,
        '/student/catalog',
      ),
      _QuickAction(
        Icons.library_books_rounded,
        'Biblioteca',
        Colors.purpleAccent,
        AppRoutes.studentResources,
      ),
      _QuickAction(
        Icons.videogame_asset_rounded,
        l10n.games,
        Colors.orangeAccent,
        '/student/games',
      ),
      _QuickAction(
        Icons.leaderboard_rounded,
        l10n.ranking,
        Colors.amberAccent,
        AppRoutes.studentRanking,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final actions = _getActions(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.8,
      children: [
        for (final a in actions)
          _QuickActionCard(
            icon: a.icon,
            label: a.label,
            color: a.color,
            route: a.route,
          ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String route;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push(route),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        blur: 24,
        opacity: isDark ? 0.06 : 0.08,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.35),
                    color.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentCourseCard extends ConsumerWidget {
  const _RecentCourseCard({required this.summaryAsync});

  final AsyncValue<DashboardSummaryModel> summaryAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final coursesAsync = ref.watch(coursesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return coursesAsync.when(
      data: (courses) {
        if (courses.isEmpty) {
          return GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                l10n.exploreCourses,
                style:
                    TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          );
        }

        final course = courses.first;
        return GestureDetector(
          onTap: () => context.push(
            AppRoutes.studentCourseDetail
                .replaceAll(':id', course.id.toString()),
          ),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(24),
            blur: 24,
            opacity: isDark ? 0.06 : 0.08,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24)),
                      child: ProductImage(
                        imageUrl: course.imageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Degradado inferior para legibilidad tipo liquid glass.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.45),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  _DashTokens.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course.difficultyLevel.toUpperCase(),
                              style: const TextStyle(
                                color: _DashTokens.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              course.languageName,
                              style: TextStyle(
                                color:
                                    isDark ? Colors.white54 : Colors.black54,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        course.title,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        course.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.play_circle_fill_rounded,
                              color: Colors.purpleAccent, size: 20),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.continueLesson,
                              style: const TextStyle(
                                color: Colors.purpleAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            l10n.lessonsCount(course.lessonsCount),
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const GlassContainer(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TutorIABanner extends StatelessWidget {
  const _TutorIABanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.studentAiTutor),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: _DashTokens.brandGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _DashTokens.brandGlow.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.aiTutorTitle,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.aiTutorSubtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.startSpeaking,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.auto_awesome, size: 56, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
