import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/screens/social/chat_screen.dart';
import 'package:jumpup_app/presentation/screens/social/community_screen.dart';
import 'package:jumpup_app/presentation/screens/social/live_sessions_screen.dart';
import 'package:jumpup_app/presentation/screens/social/notifications_screen.dart';
import 'package:jumpup_app/presentation/screens/social/search_screen.dart';
import 'package:jumpup_app/presentation/screens/social/social_feed_screen.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';

class SocialMediaShell extends ConsumerStatefulWidget {
  const SocialMediaShell({super.key});

  @override
  ConsumerState<SocialMediaShell> createState() => _SocialMediaShellState();
}

class _SocialMediaShellState extends ConsumerState<SocialMediaShell>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _blobController;

  static const _tabs = [
    _TabDef(icon: Icons.auto_awesome_mosaic_rounded, label: 'Muro'),
    _TabDef(icon: Icons.chat_bubble_rounded, label: 'Chats'),
    _TabDef(icon: Icons.explore_rounded, label: 'Buscar'),
    _TabDef(icon: Icons.forum_rounded, label: 'Foros'),
    _TabDef(icon: Icons.play_circle_fill_rounded, label: 'Clases'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadAsync = ref.watch(unreadNotificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.white70 : Colors.black54;
    const accentColor = Color(0xFF6A11CB);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Animated Background Blobs
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -80 + (40 * _blobController.value),
                    left: -60 + (20 * _blobController.value),
                    child: _BlurBlob(
                      color: const Color(0xFF6A11CB).withValues(alpha: isDark ? 0.15 : 0.08),
                      size: 280,
                    ),
                  ),
                  Positioned(
                    bottom: 150 - (30 * _blobController.value),
                    right: -70 + (30 * _blobController.value),
                    child: _BlurBlob(
                      color: const Color(0xFF2575FC).withValues(alpha: isDark ? 0.12 : 0.06),
                      size: 250,
                    ),
                  ),
                ],
              );
            },
          ),

          Column(
            children: [
              // Glass Header
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.4 : 0.7),
                      border: Border(
                        bottom: BorderSide(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                'JumpUp Social',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: titleColor,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(Icons.refresh_rounded, color: iconColor, size: 22),
                                onPressed: () {
                                  ref.invalidate(socialFeedProvider);
                                  ref.invalidate(chatThreadsProvider);
                                  ref.invalidate(unreadNotificationsProvider);
                                },
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.notifications_rounded, color: iconColor, size: 22),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const NotificationsScreen()),
                                      );
                                    },
                                  ),
                                  unreadAsync.when(
                                    data: (count) => count > 0
                                        ? Positioned(
                                            right: 8,
                                            top: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: AppColors.error,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 16,
                                                minHeight: 16,
                                              ),
                                              child: Text(
                                                count > 9 ? '9+' : '$count',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    loading: () => const SizedBox.shrink(),
                                    error: (_, __) => const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Glassy TabBar
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: accentColor,
                          unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
                          indicatorColor: accentColor,
                          indicatorWeight: 3,
                          indicatorSize: TabBarIndicatorSize.label,
                          dividerColor: Colors.transparent,
                          tabAlignment: TabAlignment.start,
                          labelStyle: AppTextStyles.labelMedium
                              .copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.2),
                          tabs: _tabs
                              .map((t) => Tab(
                                    height: 44,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(t.icon, size: 18),
                                        const SizedBox(width: 8),
                                        Text(t.label),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    SocialFeedScreen(),
                    ChatScreen(),
                    SearchScreen(),
                    CommunityScreen(),
                    LiveSessionsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 100,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}


class _TabDef {
  const _TabDef({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
