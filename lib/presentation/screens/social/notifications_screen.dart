import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/remote/websocket_service.dart';
import 'package:jumpup_app/domain/model/notification_item.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Notificaciones',
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Marcar todo leído', style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('No se pudieron cargar las notificaciones',
                  textAlign: TextAlign.center, style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadAndConnect,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
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
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(Icons.notifications_none_rounded, size: 56,
                  color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 16),
            Text('Sin notificaciones por ahora',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_ws.isConnected)
          Container(
            color: AppColors.success.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 10, color: AppColors.success),
                const SizedBox(width: 6),
                Text('Recibiendo notificaciones en tiempo real',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: _notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 2),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.primary.withValues(alpha: 0.04) : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? AppColors.primary.withValues(alpha: 0.2) : AppColors.divider,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _colorForType(notification.type),
          radius: 20,
          child: Icon(_iconForType(notification.type), color: Colors.white, size: 18),
        ),
        title: Text(notification.title,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
            )),
        subtitle: Text(notification.message,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        trailing: isUnread
            ? Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              )
            : null,
      ),
    );
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'community': return Colors.indigo;
      case 'teacher': return AppColors.success;
      case 'system': return AppColors.textSecondary;
      case 'forum': return AppColors.warning;
      case 'chat': return AppColors.secondary;
      default: return AppColors.primary;
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
