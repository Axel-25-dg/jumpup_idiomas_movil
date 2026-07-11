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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadAsync = ref.watch(unreadNotificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.white70 : Colors.black54;
    const tabColor = Color(0xFF7C4DFF);
    final unselectedTabColor = isDark ? Colors.white30 : Colors.black38;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 56,
        title: Text(
          'JumpUp Social',
          style: AppTextStyles.titleLarge.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: iconColor),
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
                icon: Icon(Icons.notifications_rounded, color: iconColor),
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
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: tabColor,
          unselectedLabelColor: unselectedTabColor,
          indicatorColor: tabColor,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: isDark ? Colors.white10 : Colors.black12,
          labelStyle: AppTextStyles.labelMedium
              .copyWith(fontWeight: FontWeight.w800),
          tabs: _tabs
              .map((t) => Tab(
                height: 40,
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SocialFeedScreen(),
          ChatScreen(),
          SearchScreen(),
          CommunityScreen(),
          LiveSessionsScreen(),
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
