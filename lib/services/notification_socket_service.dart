import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationSocketService {
  WebSocketChannel? _channel;

  Future<void> connect(String token) async {
    // La URL de tu consumer de notificaciones
    final wsUrl = Uri.parse('wss://guaman-idiomas-ute.online/ws/notifications/?token=$token');
    _channel = WebSocketChannel.connect(wsUrl);

    _channel?.stream.listen((message) {
      // Cuando Django envía una notificación en tiempo real
      final data = jsonDecode(message);
      debugPrint("¡Nueva notificación en tiempo real!: ${data['message']}");
    }, onError: (error) {
      debugPrint('WebSocket Notification Error: $error');
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
