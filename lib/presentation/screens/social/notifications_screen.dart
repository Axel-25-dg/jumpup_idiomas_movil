import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/remote/websocket_service.dart';
import 'package:jumpup_app/domain/model/notification_item.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _ws = WebSocketService(path: 'notifications');
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  List<NotificationItem> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAndConnect();
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _ws.disconnect();
    super.dispose();
  }

  Future<void> _loadAndConnect() async {
    await _fetchNotifications();
    await _connectWebSocket();
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(socialRepositoryProvider).fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _connectWebSocket() async {
    await _ws.connect();
    _wsSub = _ws.messages.listen((data) {
      if (data['type'] == 'notification' && data['notification'] != null) {
        final newNotif = NotificationItem.fromJson(
          data['notification'] as Map<String, dynamic>,
        );
        if (mounted) {
          setState(() {
            _notifications = [newNotif, ..._notifications];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(newNotif.title), duration: const Duration(seconds: 3)),
          );
        }
      }
    });
  }

  Future<void> _markRead(NotificationItem notif) async {
    if (notif.isRead) return;
    try {
      await ref.read(socialRepositoryProvider).markNotificationRead(notif.id);
      if (mounted) {
        setState(() {
          _notifications = _notifications.map((n) {
            if (n.id == notif.id) return n.copyWith(isRead: true);
            return n;
          }).toList();
        });
        ref.invalidate(unreadNotificationsProvider);
      }
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      await ref.read(socialRepositoryProvider).markAllNotificationsRead();
      if (mounted) {
        setState(() {
          _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
        });
        ref.invalidate(unreadNotificationsProvider);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notificaciones',
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllRead,
              child: Text('Leído todo',
                  style: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: _fetchNotifications,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B4DB).withOpacity(0.05),
              ),
            ),
          ),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF)));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: GlassContainer(
            opacity: 0.1,
            blur: 15,
            padding: const EdgeInsets.all(24),
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.white24),
                const SizedBox(height: 16),
                Text('¡Vaya! Hubo un problema',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('No pudimos conectar con el centro de notificaciones.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _loadAndConnect,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reintentar conexión'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withOpacity(0.05),
              ),
              child: const Icon(Icons.notifications_none_rounded, size: 64, color: Colors.white24),
            ),
            const SizedBox(height: 24),
            Text('Todo al día por aquí',
                style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Te avisaremos cuando pase algo importante',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_ws.isConnected)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: GlassContainer(
              opacity: 0.05,
              blur: 5,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text('Conectado en tiempo real',
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white60, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: _notifications.length,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = _notifications[index];
              return _NotificationCard(
                notification: notif,
                onTap: () => _markRead(notif),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});
  final NotificationItem notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return GlassContainer(
      opacity: isUnread ? 0.12 : 0.05,
      blur: 10,
      borderRadius: BorderRadius.circular(20),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _colorForType(notification.type).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_iconForType(notification.type),
                      color: _colorForType(notification.type), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: isUnread ? FontWeight.w900 : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF7C4DFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isUnread ? Colors.white70 : Colors.white38,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'community': return const Color(0xFF7C4DFF);
      case 'teacher': return const Color(0xFF00E676);
      case 'system': return const Color(0xFF00B4DB);
      case 'forum': return const Color(0xFFFFD54F);
      case 'chat': return const Color(0xFF00B4DB);
      default: return const Color(0xFF7C4DFF);
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'community': return Icons.group_rounded;
      case 'teacher': return Icons.school_rounded;
      case 'system': return Icons.info_outline_rounded;
      case 'forum': return Icons.forum_rounded;
      case 'chat': return Icons.chat_rounded;
      default: return Icons.notifications_rounded;
    }
  }
}
