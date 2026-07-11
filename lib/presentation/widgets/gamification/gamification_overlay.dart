import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/remote/websocket_service.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class GamificationOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const GamificationOverlay({super.key, required this.child});

  @override
  ConsumerState<GamificationOverlay> createState() => _GamificationOverlayState();
}

class _GamificationOverlayState extends ConsumerState<GamificationOverlay> {
  WebSocketService? _notificationWs;
  StreamSubscription? _sub;
  
  final List<Map<String, dynamic>> _queue = [];
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    _initWs();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _notificationWs?.disconnect();
    super.dispose();
  }

  Future<void> _initWs() async {
    // Escuchar cambios de auth para conectar/desconectar
    ref.listenManual(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated && _notificationWs == null) {
        _connect();
      } else if (next.status != AuthStatus.authenticated) {
        _disconnect();
      }
    });

    final auth = ref.read(authProvider);
    if (auth.status == AuthStatus.authenticated) {
      _connect();
    }
  }

  void _connect() async {
    _notificationWs = WebSocketService(path: 'notifications');
    await _notificationWs!.connect();
    _sub = _notificationWs!.messages.listen((data) {
      if (data['type'] == 'new_notification' || data['type'] == 'gamification') {
        _handleEvent(data);
      }
    });
  }

  void _disconnect() {
    _sub?.cancel();
    _notificationWs?.disconnect();
    _notificationWs = null;
  }

  void _handleEvent(Map<String, dynamic> data) {
    // Ejemplo data: { "type": "gamification", "title": "¡Nuevo Logro!", "message": "Completaste tu primera lección", "xp": 50 }
    setState(() {
      _queue.add(data);
    });
    if (!_showing) _showNext();
  }

  void _showNext() async {
    if (_queue.isEmpty) return;
    setState(() => _showing = true);
    
    final item = _queue.removeAt(0);
    
    // Mostrar Overlay nativo o SnackBar personalizado
    if (mounted) {
      _showToast(item);
    }

    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() => _showing = false);
      _showNext();
    }
  }

  void _showToast(Map<String, dynamic> item) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: _GamificationToast(
            title: item['title'] ?? '¡Felicidades!',
            message: item['message'] ?? '',
            xp: item['xp'],
            onDismiss: () => entry.remove(),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _GamificationToast extends StatelessWidget {
  final String title;
  final String message;
  final dynamic xp;
  final VoidCallback onDismiss;

  const _GamificationToast({
    required this.title,
    required this.message,
    this.xp,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.amberAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(message, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          if (xp != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('+$xp XP', style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
