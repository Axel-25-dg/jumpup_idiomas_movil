import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatWebSocketService {
  WebSocketChannel? _channel;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Función para conectarse al canal del hilo de mensajes
  Future<void> connect(String threadId) async {
    final token = await _storage.read(key: 'access_token');
    
    if (token == null) {
      throw Exception('Token no encontrado. Debes iniciar sesión.');
    }

    // Usamos el generador centralizado de AppConfig para evitar el error de puerto :0
    final wsUrl = AppConfig.buildWsUrl('chat/$threadId/', token: token);
    debugPrint('[ChatWS] Conectando a: $wsUrl');
    
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
  }

  // Stream para escuchar los mensajes entrantes (incluidos los de la IA)
  Stream<dynamic>? get messageStream => _channel?.stream;

  // Enviar un mensaje al servidor
  void sendMessage(String text) {
    if (_channel != null && text.trim().isNotEmpty) {
      final message = {
        'type': 'chat_message',
        'body': text.trim(),
      };
      _channel!.sink.add(jsonEncode(message));
    }
  }

  // Cerrar la conexión cuando sales de la pantalla
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
