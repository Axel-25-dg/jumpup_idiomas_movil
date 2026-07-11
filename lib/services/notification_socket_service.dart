import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationSocketService {
  WebSocketChannel? _channel;

  Future<void> connect(String token) async {
    final wsUrl = AppConfig.buildWsUrl('notifications/', token: token);
    
    debugPrint('[NotificationWS] Conectando a: $wsUrl');
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

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
