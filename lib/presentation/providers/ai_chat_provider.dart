import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/local/token_storage.dart';
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
  final _tokenStorage = TokenStorage();
  int? _threadId;

  Future<void> initChat() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sesión no encontrada. Por favor inicia sesión nuevamente.');
      }

      // 1. Crear o reusar el hilo IA
      if (_threadId == null) {
        final threadData = await AiChatService.createAiThread(token);
        if (threadData == null) {
          throw Exception(
            'No se pudo iniciar la sesión de IA. '
            'Verifica tu nivel de acceso en el catálogo o intenta más tarde.',
          );
        }
        _threadId = threadData['id'] as int?;
        if (_threadId == null) throw Exception('Respuesta inválida del servidor.');

        // 2. Cargar historial
        final history = await AiChatService.getMessages(token, _threadId!);
        final List<ChatMessage> loaded = history
            .whereType<Map>()
            .map((m) {
              try {
                return ChatMessage.fromJson(Map<String, dynamic>.from(m));
              } catch (_) {
                return null;
              }
            })
            .whereType<ChatMessage>()
            .toList()
            .reversed
            .toList();

        if (loaded.isEmpty) {
          loaded.add(ChatMessage(
            id: -1,
            senderId: 0,
            senderName: 'AI Tutor',
            body: '¡Hola! Soy tu **Tutor IA** de JumpUp (impulsado por GPT-4o). '
                '¿En qué puedo ayudarte hoy?',
            createdAt: DateTime.now(),
          ));
        }
        state = state.copyWith(messages: loaded);
      }

      _connect(token);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void _connect(String token) {
    if (_threadId == null) return;
    // Evitar reconexión si ya fue destruido
    if (!mounted) return;

    if (mounted) state = state.copyWith(isConnecting: true, error: null);
    _channel?.sink.close();

    try {
      _channel = AiChatService.connectToAi(_threadId!, token);
      if (mounted) state = state.copyWith(isLoading: false, isConnecting: false);

      _channel!.stream.listen(
        (data) {
          if (!mounted) return;
          try {
            final decoded = jsonDecode(data as String);
            if (decoded['type'] == 'typing') {
              if (mounted) state = state.copyWith(isTyping: decoded['is_typing'] ?? false);
            } else if (decoded['type'] == 'chat_message') {
              final msgData = decoded['message'];
              String body = '';
              int senderId = 0;
              String senderEmail = '';

              if (msgData is Map) {
                body = msgData['body']?.toString() ?? '';
                senderId = msgData['sender_id'] as int? ?? 0;
                senderEmail = msgData['sender']?.toString() ?? '';
              } else {
                body = decoded['body']?.toString() ?? '';
              }

              final isAiMessage = senderId == 0 || senderEmail.contains('ia@');

              final newMessage = ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch,
                senderId: senderId,
                senderName: isAiMessage ? 'AI Tutor' : 'Tú',
                body: body,
                createdAt: DateTime.now(),
              );
              if (mounted) {
                state = state.copyWith(
                  messages: [...state.messages, newMessage],
                  isTyping: false,
                );
              }
            } else if (decoded['type'] == 'error') {
              final code = decoded['code']?.toString() ?? '';
              final message = decoded['message']?.toString() ?? 'Error desconocido';
              if (code == 'subscription_required' || code == 'insufficient_level') {
                final subMsg = ChatMessage(
                  id: DateTime.now().millisecondsSinceEpoch,
                  senderId: 0,
                  senderName: 'AI Tutor',
                  body: '¡Hola! Soy tu Tutor IA. Puedes preguntarme cualquier cosa sobre inglés y otros idiomas. ¿En qué te puedo ayudar hoy?',
                  createdAt: DateTime.now(),
                );
                if (mounted) {
                  state = state.copyWith(
                    messages: [...state.messages, subMsg],
                    isTyping: false,
                    error: null,
                  );
                }
              } else {
                if (mounted) state = state.copyWith(isTyping: false, error: message);
              }
            }
          } catch (_) {
            // ignore malformed messages
          }
        },
        onError: (e) => _handleError(e),
        onDone: () {
          // Importante: verificar mounted ANTES de cualquier setState/state=
          if (!mounted) return;
          state = state.copyWith(error: 'Conexión cerrada. Reconectando...', isConnecting: true);
          Future.delayed(const Duration(seconds: 5), () async {
            if (!mounted) return;
            final t = await _tokenStorage.getAccessToken();
            if (!mounted) return;
            if (t != null) _connect(t);
          });
        },
      );
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic e) {
    if (!mounted) return;
    state = state.copyWith(
      error: 'Conexión perdida. Reconectando en 5s...',
      isConnecting: true,
      isTyping: false,
    );

    Future.delayed(const Duration(seconds: 5), () async {
      if (!mounted) return;
      final token = await _tokenStorage.getAccessToken();
      if (!mounted) return;
      if (token != null && token.isNotEmpty) _connect(token);
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
