import 'package:flutter/material.dart';
import 'package:jumpup_app/presentation/screens/social/chat_screen.dart';
import 'package:jumpup_app/presentation/screens/social/community_screen.dart';
import 'package:jumpup_app/presentation/screens/social/live_sessions_screen.dart';
import 'package:jumpup_app/presentation/screens/social/media_player_screen.dart';
import 'package:jumpup_app/presentation/screens/social/notifications_screen.dart';
import 'package:jumpup_app/presentation/screens/social/search_screen.dart';
import 'package:jumpup_app/presentation/screens/social/social_feed_screen.dart';

class SocialMediaShell extends StatefulWidget {
  const SocialMediaShell({super.key});

  @override
  State<SocialMediaShell> createState() => _SocialMediaShellState();
}

class _SocialMediaShellState extends State<SocialMediaShell> {
  int _index = 0;

  final List<_SocialTab> _tabs = const [
    _SocialTab(
        icon: Icons.chat_bubble_outline,
        label: 'Mensajería',
        screen: ChatScreen()),
    _SocialTab(
        icon: Icons.group_outlined,
        label: 'Comunidad',
        screen: CommunityScreen()),
    _SocialTab(
        icon: Icons.play_circle_outline,
        label: 'Media',
        screen: MediaPlayerScreen()),
    _SocialTab(
        icon: Icons.videocam_outlined,
        label: 'En vivo',
        screen: LiveSessionsScreen()),
    _SocialTab(
        icon: Icons.notifications_none,
        label: 'Avisos',
        screen: NotificationsScreen()),
    _SocialTab(icon: Icons.search, label: 'Buscar', screen: SearchScreen()),
    _SocialTab(
        icon: Icons.rocket_launch_outlined,
        label: 'Feed',
        screen: SocialFeedScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunicación y comunidad'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _tabs[_index].screen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: _tabs
            .map(
              (tab) =>
                  NavigationDestination(icon: Icon(tab.icon), label: tab.label),
            )
            .toList(),
      ),
    );
  }
}

class _SocialTab {
  const _SocialTab(
      {required this.icon, required this.label, required this.screen});

  final IconData icon;
  final String label;
  final Widget screen;
}
