import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jumpup_app/data/remote/websocket_service.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';
import 'package:jumpup_app/domain/model/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
      if (data['type'] == 'notification' && data['notification'] != null) {
        final newNotif = NotificationItem.fromJson(
          data['notification'] as Map<String, dynamic>,
        );
        if (mounted) {
          setState(() {
            _notifications = [newNotif, ..._notifications];
          });
          _showSnackBar('🔔 ${newNotif.title}');
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
            if (n.id == notif.id) {
              return NotificationItem(
                id: n.id,
                title: n.title,
                message: n.message,
                type: n.type,
                isRead: true,
              );
            }
            return n;
          }).toList();
        });
      }
    } catch (_) {}
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
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Actualizar',
        onPressed: _fetchNotifications,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody() {
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
              Text(
                'No se pudieron cargar las notificaciones',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('Sin notificaciones por ahora'),
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
                  'Conectado — recibiendo avisos en tiempo real',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.green.shade800),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
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
    final isUnread = !notification.isRead;

    return Card(
      elevation: isUnread ? 3 : 1,
      color: isUnread
          ? Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.3)
          : null,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _colorForType(notification.type, context),
          child: Icon(
            _iconForType(notification.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(notification.message),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(notification.type),
              padding: EdgeInsets.zero,
              labelStyle: const TextStyle(fontSize: 11),
            ),
            if (isUnread) const Icon(Icons.circle, size: 8, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Color _colorForType(String type, BuildContext context) {
    switch (type) {
      case 'community':
        return Colors.indigo;
      case 'teacher':
        return Colors.teal;
      case 'system':
        return Colors.grey.shade700;
      default:
        return Theme.of(context).colorScheme.primary;
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
