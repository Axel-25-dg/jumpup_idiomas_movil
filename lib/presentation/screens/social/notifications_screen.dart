import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/remote/websocket_service.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';
import 'package:jumpup_app/domain/model/notification_item.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _repository = SocialMediaRepository();
  final _ws = WebSocketService(path: 'notifications');

  List<NotificationItem> _notifications = [];
  bool _loading = true;
  String? _error;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

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
      final result = await _repository.fetchNotifications();
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
      if (data['type'] == 'notification' &&
          data['notification'] != null) {
        final newNotif = NotificationItem.fromJson(
          data['notification'] as Map<String, dynamic>,
        );
        if (mounted) {
          setState(() {
            _notifications = [newNotif, ..._notifications];
          });
          _showSnackBar(newNotif.title);
        }
      }
    });
  }

  Future<void> _markRead(NotificationItem notif) async {
    if (notif.isRead) return;
    try {
      await _repository.markNotificationRead(notif.id);
      if (mounted) {
        setState(() {
          _notifications = _notifications.map((n) {
            if (n.id == notif.id) return n.copyWith(isRead: true);
            return n;
          }).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    for (final n in _notifications.where((n) => !n.isRead)) {
      await _markRead(n);
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = _notifications.any((n) => !n.isRead);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Leer todo',
                  style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('No se pudieron cargar las notificaciones',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey)),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadAndConnect,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none,
                size: 64,
                color: theme.colorScheme.primary
                    .withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('Sin notificaciones por ahora',
                style: theme.textTheme.titleMedium),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_ws.isConnected)
          Container(
            color: Colors.green.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 10, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Recibiendo notificaciones en tiempo real',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: Colors.green.shade800),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: _notifications.length,
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
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final NotificationItem notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      elevation: isUnread ? 2 : 0,
      color: isUnread
          ? theme.colorScheme.primaryContainer
              .withValues(alpha: 0.2)
          : null,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _colorForType(notification.type, theme),
          child: Icon(
            _iconForType(notification.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(notification.message,
            maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: isUnread
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  Color _colorForType(String type, ThemeData theme) {
    switch (type) {
      case 'community':
        return Colors.indigo;
      case 'teacher':
        return Colors.teal;
      case 'system':
        return Colors.grey.shade700;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'community':
        return Icons.group;
      case 'teacher':
        return Icons.school;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }
}
