import 'package:flutter/material.dart';
import 'package:jumpup_app/presentation/screens/social/chat_screen.dart';
import 'package:jumpup_app/presentation/screens/social/community_screen.dart';
import 'package:jumpup_app/presentation/screens/social/live_sessions_screen.dart';
import 'package:jumpup_app/presentation/screens/social/media_player_screen.dart';
import 'package:jumpup_app/presentation/screens/social/notifications_screen.dart';
import 'package:jumpup_app/presentation/screens/social/search_screen.dart';
import 'package:jumpup_app/presentation/screens/social/social_feed_screen.dart';
import 'package:jumpup_app/theme/app_theme.dart';

/// Shell del módulo Social con NavigationBar estilo Instagram (7 tabs).
class SocialMediaShell extends StatefulWidget {
  const SocialMediaShell({super.key});

  @override
  State<SocialMediaShell> createState() => _SocialMediaShellState();
}

class _SocialMediaShellState extends State<SocialMediaShell> {
  int _index = 0;

  static const _tabs = [
    _SocialTab(
        icon: Icons.rocket_launch_rounded,
        inactiveIcon: Icons.rocket_launch_outlined,
        label: 'Feed',
        screen: SocialFeedScreen()),
    _SocialTab(
        icon: Icons.chat_bubble_rounded,
        inactiveIcon: Icons.chat_bubble_outline,
        label: 'Mensajes',
        screen: ChatScreen()),
    _SocialTab(
        icon: Icons.search_rounded,
        inactiveIcon: Icons.search_outlined,
        label: 'Buscar',
        screen: SearchScreen()),
    _SocialTab(
        icon: Icons.group_rounded,
        inactiveIcon: Icons.group_outlined,
        label: 'Foro',
        screen: CommunityScreen()),
    _SocialTab(
        icon: Icons.play_circle_rounded,
        inactiveIcon: Icons.play_circle_outline,
        label: 'Media',
        screen: MediaPlayerScreen()),
    _SocialTab(
        icon: Icons.videocam_rounded,
        inactiveIcon: Icons.videocam_outlined,
        label: 'En Vivo',
        screen: LiveSessionsScreen()),
    _SocialTab(
        icon: Icons.notifications_rounded,
        inactiveIcon: Icons.notifications_none,
        label: 'Avisos',
        screen: NotificationsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: _SocialBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        tabs: _tabs,
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _SocialBottomNav extends StatelessWidget {
  const _SocialBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
  });
  final int currentIndex;
  final void Function(int) onTap;
  final List<_SocialTab> tabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final isSelected = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isSelected ? tab.icon : tab.inactiveIcon,
                          key: ValueKey(isSelected),
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Modelo de tab ─────────────────────────────────────────────────────────────

class _SocialTab {
  const _SocialTab({
    required this.icon,
    required this.inactiveIcon,
    required this.label,
    required this.screen,
  });
  final IconData icon;
  final IconData inactiveIcon;
  final String label;
  final Widget screen;
}
