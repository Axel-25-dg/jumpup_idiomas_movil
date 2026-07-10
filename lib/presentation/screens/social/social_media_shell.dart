import 'package:flutter/material.dart';
import 'package:jumpup_app/presentation/screens/social/chat_screen.dart';
import 'package:jumpup_app/presentation/screens/social/community_screen.dart';
import 'package:jumpup_app/presentation/screens/social/media_player_screen.dart';
import 'package:jumpup_app/presentation/screens/social/search_screen.dart';
import 'package:jumpup_app/presentation/screens/social/social_feed_screen.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';

class SocialMediaShell extends StatefulWidget {
  const SocialMediaShell({super.key});

  @override
  State<SocialMediaShell> createState() => _SocialMediaShellState();
}

class _SocialMediaShellState extends State<SocialMediaShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const SocialFeedScreen(),
      const ChatScreen(),
      const SearchScreen(),
      const CommunityScreen(),
      const MediaPlayerScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavTab(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  label: 'Feed',
                  isSelected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavTab(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Mensajes',
                  isSelected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavTab(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search_rounded,
                  label: 'Buscar',
                  isSelected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
                _NavTab(
                  icon: Icons.forum_outlined,
                  activeIcon: Icons.forum_rounded,
                  label: 'Foro',
                  isSelected: _index == 3,
                  onTap: () => setState(() => _index = 3),
                ),
                _NavTab(
                  icon: Icons.play_circle_outline_rounded,
                  activeIcon: Icons.play_circle_rounded,
                  label: 'Media',
                  isSelected: _index == 4,
                  onTap: () => setState(() => _index = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
