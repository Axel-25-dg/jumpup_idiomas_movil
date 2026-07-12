import 'dart:async';
import 'package:jumpup_app/data/remote/websocket_service.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/chat_message.dart';
import 'package:jumpup_app/domain/model/message_thread.dart';
import 'package:jumpup_app/domain/repository/chat_repository.dart';

class ChatRepositoryImpl extends BaseRepository implements ChatRepository {
  ChatRepositoryImpl();

  WebSocketService? _wsService;
  StreamController<ChatMessage>? _messageController;
  StreamSubscription? _wsSubscription;

  @override
  Future<List<MessageThread>> getThreads() async {
    return getList('threads/', MessageThread.fromJson,
        message: 'No se pudieron cargar las conversaciones');
  }

  @override
  Future<MessageThread> createThread({
    required String subject,
    required List<int> participants,
  }) async {
    return createOne('threads/', MessageThread.fromJson,
        data: {'subject': subject, 'participants': participants},
        message: 'No se pudo crear la conversación');
  }

  @override
  Future<List<ChatMessage>> getMessages(int threadId) async {
    return getList('threads/$threadId/messages/', ChatMessage.fromJson,
        message: 'No se pudo cargar el historial');
  }

  @override
  Future<ChatMessage> sendMessage({
    required int threadId,
    required String body,
  }) async {
    return createOne('threads/$threadId/messages/', ChatMessage.fromJson,
        data: {'body': body},
        message: 'No se pudo enviar el mensaje');
  }

  @override
  Future<void> connectToThread(int threadId) async {
    await disconnect(); // Cerrar previa si existe

    _wsService = WebSocketService(path: 'chat', roomId: threadId.toString());
    _messageController = StreamController<ChatMessage>.broadcast();
    
    await _wsService!.connect();

    _wsSubscription = _wsService!.messages.listen((data) {
      final type = data['type']?.toString() ?? '';
      if (type == 'chat_message' || type == 'message') {
        final msgData = data['message'] ?? data;
        if (msgData is Map<String, dynamic>) {
          try {
            final msg = ChatMessage.fromJson(msgData);
            _messageController?.add(msg);
          } catch (_) {}
        }
      }
    });
  }

  @override
  Stream<ChatMessage> get messageStream => 
      _messageController?.stream ?? const Stream.empty();

  @override
  bool get isConnected => _wsService?.isConnected ?? false;

  @override
  void sendWsMessage(String body) {
    if (isConnected) {
      _wsService!.send({'type': 'chat_message', 'body': body});
    }
  }

  @override
  Future<void> disconnect() async {
    await _wsSubscription?.cancel();
    await _wsService?.disconnect();
    await _messageController?.close();
    
    _wsSubscription = null;
    _wsService = null;
    _messageController = null;
  }
}
