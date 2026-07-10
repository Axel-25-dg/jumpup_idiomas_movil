import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:jumpup_app/services/ai_chat_service.dart';
import 'package:jumpup_app/domain/model/chat_message.dart';

class AiChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isTyping;
  final String? error;
  final bool isConnecting;

  AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.error,
    this.isConnecting = false,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isTyping,
    String? error,
    bool? isConnecting,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: error,
      isConnecting: isConnecting ?? this.isConnecting,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  AiChatNotifier() : super(AiChatState());

  WebSocketChannel? _channel;
  final _storage = const FlutterSecureStorage();
  int? _threadId;

  Future<void> initChat() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) throw Exception('No session token found');

      // 1. Create thread if not exists
      if (_threadId == null) {
        final threadData = await AiChatService.createAiThread(token);
        if (threadData == null) throw Exception('Could not create AI session');
        _threadId = threadData['id'];

        // 2. Load History
        final history = await AiChatService.getMessages(token, _threadId!);
        final List<ChatMessage> loadedMessages = history.reversed.map((m) => ChatMessage.fromJson(m)).toList();
        
        if (loadedMessages.isEmpty) {
          loadedMessages.add(ChatMessage(
            id: -1,
            senderId: 0,
            senderName: 'AI Tutor',
            body: '¡Hola! Soy tu Tutor IA. ¿En qué puedo ayudarte hoy?',
            createdAt: DateTime.now(),
          ));
        }
        state = state.copyWith(messages: loadedMessages);
      }

      _connect(token);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _connect(String token) {
    if (_threadId == null) return;

    state = state.copyWith(isConnecting: true);
    _channel?.sink.close();
    
    _channel = AiChatService.connectToAi(_threadId!, token);
    state = state.copyWith(isLoading: false, isConnecting: false);

    _channel!.stream.listen(
      (data) {
        final decoded = jsonDecode(data);
        if (decoded['type'] == 'typing') {
          state = state.copyWith(isTyping: decoded['is_typing'] ?? false);
        } else if (decoded['type'] == 'chat_message') {
          final newMessage = ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch,
            senderId: 0,
            senderName: 'AI Tutor',
            body: decoded['body'] ?? '',
            createdAt: DateTime.now(),
          );
          state = state.copyWith(
            messages: [...state.messages, newMessage],
            isTyping: false,
          );
        }
      },
      onError: (e) => _handleError(e),
      onDone: () => _handleError('Socket closed'),
    );
  }

  void _handleError(dynamic e) {
    if (!mounted) return;
    state = state.copyWith(error: 'Conexión perdida. Reconectando...', isConnecting: true);
    
    // Retry connection after 5 seconds
    Future.delayed(const Duration(seconds: 5), () async {
      if (!mounted) return;
      final token = await _storage.read(key: 'access_token');
      if (token != null) _connect(token);
    });
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: 1, // Current user
      senderName: 'Tú',
      body: text,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    if (_channel == null) {
      _handleError('No connection');
      return;
    }

    AiChatService.sendMessage(_channel!, text);
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  return AiChatNotifier();
});
