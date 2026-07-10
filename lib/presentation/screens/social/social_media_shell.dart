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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 56,
        title: Text(
          'JumpUp Social',
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
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
                icon: const Icon(Icons.notifications_rounded,
                    color: Colors.white),
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
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count > 9 ? '9+' : '$count',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: AppTextStyles.labelMedium
              .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
          unselectedLabelStyle: AppTextStyles.labelMedium
              .copyWith(fontWeight: FontWeight.w500, color: Colors.white60),
          tabs: _tabs
              .map((t) => Tab(icon: Icon(t.icon, size: 20), text: t.label))
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
