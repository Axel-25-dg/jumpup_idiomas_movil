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

import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/presentation/widgets/gamification/gamification_overlay.dart';
import 'package:jumpup_app/presentation/widgets/shared/user_avatar.dart';
import 'package:jumpup_app/presentation/widgets/shared/product_image.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';

// Screens for bottom nav tabs
import 'package:jumpup_app/presentation/screens/student/course_list_screen.dart';
import 'package:jumpup_app/presentation/screens/student/progress_screen.dart';
import 'package:jumpup_app/presentation/screens/student/profile_screen.dart';
import 'package:jumpup_app/presentation/screens/social/social_media_shell.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';
import 'package:jumpup_app/presentation/providers/cart/cart_provider.dart';

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

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black87;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white60
          : Colors.black54;
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
    return GamificationOverlay(
      child: Scaffold(
        backgroundColor: _DashTokens.background(context),
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: _LiquidGlassNav(
          currentIndex: _currentIndex,
          onTap: _onTabTap,
        ),
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

/// Barra inferior flotante con efecto "liquid glass".
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double totalWidth = constraints.maxWidth;
            final int count = items.length;
            final double slotWidth = totalWidth / count;

            return ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 74,
                  decoration: BoxDecoration(
                    color: _DashTokens.glassFill(context),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: _DashTokens.glassStroke(context),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.5 : 0.2),
                        blurRadius: 36,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: Colors.white
                            .withValues(alpha: isDark ? 0.05 : 0.4),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        left: slotWidth * currentIndex,
                        top: 0,
                        bottom: 0,
                        width: slotWidth,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            width: slotWidth - 18,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: _DashTokens.brandGradient,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: _DashTokens.brandGlow
                                      .withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                scale: isSelected ? 1.14 : 1.0,
                child: Padding(
                  padding: EdgeInsets.only(bottom: isSelected ? 12 : 0),
                  child: Icon(
                    isSelected ? item.active : item.inactive,
                    color: isSelected ? Colors.white : inactiveColor,
                    size: 24,
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  bottom: 12,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isSelected ? 1.0 : 0.0,
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
                  ),
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

class _HomeTabState extends ConsumerState<_HomeTab>
    with TickerProviderStateMixin {
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
        AnimatedBuilder(
          animation: _blobController,
          builder: (context, child) {
            return Stack(
              children: [
                _BackgroundBlob(
                  top: -60 + (30 * _blobController.value),
                  left: -50 + (20 * _blobController.value),
                  size: 320,
                  color: _DashTokens.secondary,
                  opacity: isDark ? 0.16 : 0.08,
                ),
                _BackgroundBlob(
                  bottom: 120 - (40 * _blobController.value),
                  right: -60 + (30 * _blobController.value),
                  size: 300,
                  color: _DashTokens.primary,
                  opacity: isDark ? 0.13 : 0.06,
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
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 130),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _XPAndStreakBanner(statsAsync: statsAsync),
                    const SizedBox(height: 40),
                    _SectionTitle(
                      AppLocalizations.of(context)!.quickActions,
                    ),
                    const SizedBox(height: 18),
                    const _QuickActionsGrid(),
                    const SizedBox(height: 44),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
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
                    const SizedBox(height: 16),
                    _RecentCourseCard(summaryAsync: summaryAsync),
                    const SizedBox(height: 44),
                    const _AchievementsSection(),
                    const SizedBox(height: 44),
                    const _TutorIABanner(),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            gradient: _DashTokens.brandGradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: _DashTokens.textPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
                blurRadius: 120,
                spreadRadius: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverHeader extends ConsumerWidget {
  const _SliverHeader({required this.userAsync, required this.statsAsync});

  final AsyncValue<UserProfileModel> userAsync;
  final AsyncValue<UserStatsModel> statsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cartCount = ref.watch(cartProvider).when(
      data: (cart) => cart.items.fold(0, (sum, item) => sum + item.cantidad),
      loading: () => 0,
      error: (_, __) => 0,
    );

    return SliverAppBar(
      expandedHeight: 104,
      pinned: true,
      backgroundColor: _DashTokens.background(context).withValues(alpha: 0.6),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
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
                          radius: 23,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.hello(user.username),
                              style: AppTextStyles.titleMedium.copyWith(
                                color: _DashTokens.textPrimary(context),
                                fontWeight: FontWeight.w900,
                                fontSize: 19,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              l10n.readyToLearn,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _DashTokens.textSecondary(context),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.home),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(11),
                          borderRadius: BorderRadius.circular(16),
                          opacity: 0.1,
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: Colors.amberAccent,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.studentCart),
                            child: GlassContainer(
                              padding: const EdgeInsets.all(11),
                              borderRadius: BorderRadius.circular(16),
                              opacity: 0.1,
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          if (cartCount > 0)
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: const BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                    minWidth: 18, minHeight: 18),
                                child: Text(
                                  '$cartCount',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
        borderRadius: BorderRadius.circular(30),
        blur: 24,
        opacity: isDark ? 0.06 : 0.08,
        padding: const EdgeInsets.all(26),
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
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.15),
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
            const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    l10n.levelProgressLabel(stats.level),
                    style: TextStyle(
                      color: _DashTokens.textSecondary(context),
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
                    color: _DashTokens.textPrimary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
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
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                            const Color(0xFF2575FC).withValues(alpha: 0.3),
                            blurRadius: 6,
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
        height: 150,
        blur: 24,
        opacity: isDark ? 0.06 : 0.08,
        borderRadius: BorderRadius.circular(30),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
          ),
          child: Center(child: Icon(icon, color: color, size: 24)),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            color: _DashTokens.textPrimary(context),
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
            color: _DashTokens.textSecondary(context),
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
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
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
        borderRadius: BorderRadius.circular(24),
        blur: 24,
        opacity: isDark ? 0.06 : 0.08,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
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
                border:
                Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
              ),
              child: Center(child: Icon(icon, color: color, size: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  color: _DashTokens.textPrimary(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
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
            padding: const EdgeInsets.all(30),
            borderRadius: BorderRadius.circular(30),
            child: Center(
              child: Text(
                l10n.exploreCourses,
                style: TextStyle(color: _DashTokens.textPrimary(context)),
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
            borderRadius: BorderRadius.circular(30),
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
                          top: Radius.circular(30)),
                      child: ProductImage(
                        imageUrl: course.imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                              _DashTokens.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              course.difficultyLevel.toUpperCase(),
                              style: const TextStyle(
                                color: _DashTokens.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              course.languageName,
                              style: TextStyle(
                                color: _DashTokens.textSecondary(context),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        course.title,
                        style: TextStyle(
                          color: _DashTokens.textPrimary(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        course.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _DashTokens.textSecondary(context),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.play_circle_fill_rounded,
                              color: Colors.purpleAccent, size: 22),
                          const SizedBox(width: 8),
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
                              color: _DashTokens.textSecondary(context),
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
        height: 230,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AchievementsSection extends ConsumerWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(myAchievementsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionTitle('Mis Logros'),
            TextButton(
              onPressed: () => context.push('/student/achievements'),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  color: _DashTokens.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        achievementsAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                borderRadius: BorderRadius.circular(24),
                child: Center(
                  child: Text(
                    '¡Aprende y desbloquea logros!',
                    style: TextStyle(
                      color: _DashTokens.textSecondary(context),
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }
            return SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final userAch = list[index];
                  return ModernAchievementCard(
                    name: userAch.achievement.name,
                    description: userAch.achievement.description,
                    iconUrl: userAch.achievement.iconUrl,
                    requiredXp: userAch.achievement.requiredXp,
                    isUnlocked: true,
                    isCompact: true,
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
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
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: _DashTokens.brandGradient,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _DashTokens.brandGlow.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 14),
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
                      fontSize: 21,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.aiTutorSubtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 22),
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
            const SizedBox(width: 18),
            const Icon(Icons.auto_awesome, size: 60, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}