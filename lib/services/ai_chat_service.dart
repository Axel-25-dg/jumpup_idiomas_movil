import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class AiChatService {
  static const String baseUrl = 'https://guaman-idiomas-ute.online/api';
  static const String wsBase = 'wss://guaman-idiomas-ute.online/ws';

  // Crear hilo con el tutor IA
  static Future<Map?> createAiThread(String token) async {
    final r = await http.post(
      Uri.parse('$baseUrl/threads/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      // subject con "IA" activa el bot automáticamente
      body: jsonEncode({'subject': 'Tutor IA - Práctica de idiomas', 'participants': []}),
    );
    if (r.statusCode == 201) return jsonDecode(r.body);
    return null;
  }

  // Conectar WebSocket al chat del tutor
  static WebSocketChannel connectToAi(int threadId, String token) {
    return WebSocketChannel.connect(
      Uri.parse('$wsBase/chat/$threadId/?token=$token'),
    );
  }

  // Enviar mensaje al tutor IA
  static void sendMessage(WebSocketChannel channel, String message) {
    channel.sink.add(jsonEncode({
      'type': 'chat_message',
      'body': message,
    }));
  }

  // Enviar indicador de escritura
  static void sendTyping(WebSocketChannel channel, bool isTyping) {
    channel.sink.add(jsonEncode({
      'type': 'typing',
      'is_typing': isTyping,
    }));
  }

  // Marcar mensaje como leído
  static void markAsRead(WebSocketChannel channel, int messageId) {
    channel.sink.add(jsonEncode({
      'type': 'read_message',
      'message_id': messageId,
    }));
  }

  // Obtener historial de mensajes
  static Future<List> getMessages(String token, int threadId) async {
    final r = await http.get(
      Uri.parse('$baseUrl/threads/$threadId/messages/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (r.statusCode == 200) return jsonDecode(r.body)['results'];
    return [];
  }
}
