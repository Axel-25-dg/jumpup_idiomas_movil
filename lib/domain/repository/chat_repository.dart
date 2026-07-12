import 'package:jumpup_app/domain/model/chat_message.dart';
import 'package:jumpup_app/domain/model/message_thread.dart';

/// Contrato para la gestión de mensajería y chat en tiempo real.
abstract class ChatRepository {
  /// Obtiene la lista de hilos de conversación del usuario.
  Future<List<MessageThread>> getThreads();

  /// Crea un nuevo hilo de conversación.
  Future<MessageThread> createThread({
    required String subject,
    required List<int> participants,
  });

  /// Obtiene el historial de mensajes de un hilo.
  Future<List<ChatMessage>> getMessages(int threadId);

  /// Envía un mensaje a través de REST (como respaldo o mensaje inicial).
  Future<ChatMessage> sendMessage({
    required int threadId,
    required String body,
  });

  /// Conecta al WebSocket de un hilo específico.
  Future<void> connectToThread(int threadId);

  /// Stream de mensajes en tiempo real para el hilo conectado.
  Stream<ChatMessage> get messageStream;

  /// Indica si hay una conexión activa.
  bool get isConnected;

  /// Envía un mensaje a través de WebSocket.
  void sendWsMessage(String body);

  /// Desconecta el WebSocket actual.
  void disconnect();
}
