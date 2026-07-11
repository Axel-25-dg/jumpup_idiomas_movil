import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class AiChatService {
  static const String baseUrl = 'https://guaman-idiomas-ute.online/api';
  static const String wsBase = 'wss://guaman-idiomas-ute.online/ws';

  // Crear hilo con el tutor IA (o reusar el existente)
  // El backend activa GPT-4o automáticamente cuando el subject contiene "IA"
  // y el hilo tiene solo 1 participante (el propio usuario).
  static Future<Map?> createAiThread(String token) async {
    try {
      final r = await http.post(
        Uri.parse('$baseUrl/threads/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        // participant_ids: lista vacía = solo el usuario actual → activa Tutor IA
        body: jsonEncode({
          'subject': 'Tutor IA',
          'participant_ids': <int>[],
        }),
      );

      if (r.statusCode == 201 || r.statusCode == 200) {
        final body = jsonDecode(r.body);
        if (body is Map && body['id'] != null) return body;
      }

      // 400 puede significar que ya existe el hilo IA — buscar en la lista
      if (r.statusCode == 400) {
        return await _findExistingAiThread(token);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Busca el primer hilo con subject "Tutor IA" en los hilos del usuario
  static Future<Map?> _findExistingAiThread(String token) async {
    try {
      final r = await http.get(
        Uri.parse('$baseUrl/threads/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (r.statusCode == 200) {
        final body = jsonDecode(r.body);
        final list = body is List ? body : (body['results'] as List? ?? []);
        for (final item in list) {
          if (item is Map) {
            final subject = item['subject']?.toString() ?? '';
            if (subject.contains('IA') || subject.contains('Tutor')) {
              return item;
            }
          }
        }
        // Si no encontramos por subject, devolvemos el primer hilo
        if (list.isNotEmpty && list.first is Map) return list.first as Map;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Conectar WebSocket al chat del tutor — token en query string (única forma fiable en Flutter)
  static WebSocketChannel connectToAi(int threadId, String token) {
    final uri = Uri.parse('$wsBase/chat/$threadId/?token=$token');
    return WebSocketChannel.connect(uri);
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

  // Obtener historial de mensajes — maneja tanto paginado como lista directa
  static Future<List> getMessages(String token, int threadId) async {
    try {
      final r = await http.get(
        Uri.parse('$baseUrl/threads/$threadId/messages/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (r.statusCode == 200) {
        final body = jsonDecode(r.body);
        if (body is List) return body;
        if (body is Map) {
          final results = body['results'];
          if (results is List) return results;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
