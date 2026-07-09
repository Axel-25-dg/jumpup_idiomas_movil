import 'dart:convert';
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

    // La URL de tu servidor en tiempo real. 
    // Asegúrate de usar 'wss://' para producción o 'ws://' si es local.
    final wsUrl = Uri.parse('wss://guaman-idiomas-ute.online/ws/chat/$threadId/?token=$token');
    
    _channel = WebSocketChannel.connect(wsUrl);
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
