import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/core/network/websocket_service.dart';
import 'package:jumpup_app/features/social_media/data/social_media_repository.dart';
import 'package:jumpup_app/features/social_media/models/chat_message.dart';
import 'package:jumpup_app/features/social_media/models/message_thread.dart';

/// Pantalla de chat individual con historial REST + mensajería en tiempo real
/// a través de WebSocket (wss://.../ws/chat/{threadId}/?token=...).
class MessageDetailScreen extends StatefulWidget {
  const MessageDetailScreen({super.key, required this.thread});

  final MessageThread thread;

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final _repository = SocialMediaRepository();
  late final WebSocketService _ws;

  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  bool _isTyping = false; // el otro usuario está escribiendo

  StreamSubscription<Map<String, dynamic>>? _wsSub;

  // ── Ciclo de vida ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _ws = WebSocketService(path: 'chat', roomId: widget.thread.id);
    _loadHistory();
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _ws.disconnect();
    _scrollController.dispose();
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Lógica ──────────────────────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final msgs = await _repository.fetchChatMessages(widget.thread.id);
      if (mounted) {
        setState(() {
          _messages = msgs;
          _loading = false;
        });
        _scrollToBottom();
        await _connectWebSocket();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _connectWebSocket() async {
    await _ws.connect();
    _wsSub = _ws.messages.listen((data) {
      if (!mounted) return;
      final type = data['type']?.toString() ?? '';

      switch (type) {
        // Mensaje nuevo del otro usuario
        case 'chat_message':
          final msg = ChatMessage.fromJson(
            data['message'] as Map<String, dynamic>,
          );
          setState(() {
            _messages = [..._messages, msg];
            _isTyping = false;
          });
          _scrollToBottom();

        // Indicador de escritura
        case 'typing':
          setState(() => _isTyping = true);
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _isTyping = false);
          });

        // Confirmación de mensaje propio enviado
        case 'message_sent':
          // El mensaje ya fue añadido optimistamente; nada que hacer
          break;
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;

    // Adición optimista: aparece de inmediato en la UI
    final optimistic = ChatMessage(
      id: 'optimistic-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'Tú',
      content: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages = [..._messages, optimistic];
      _sending = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      // Enviar también por WS si está conectado (más rápido)
      if (_ws.isConnected) {
        _ws.send({'type': 'chat_message', 'content': text});
      }
      // Persistir en el servidor vía REST
      await _repository.sendMessage(
        threadId: widget.thread.id,
        content: text,
      );
    } catch (e) {
      // Si falla, elimina el mensaje optimista
      if (mounted) {
        setState(() {
          _messages = _messages.where((m) => m.id != optimistic.id).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo enviar el mensaje'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.thread.title),
            Text(
              widget.thread.participantName,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Icon(
            _ws.isConnected ? Icons.wifi : Icons.wifi_off,
            color: _ws.isConnected ? Colors.greenAccent : Colors.white30,
            size: 18,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loadHistory,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text('Sin mensajes aún. ¡Di algo primero!'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg.senderId == 'me';
        return _MessageBubble(message: msg, isMe: isMe);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Text(
            '${widget.thread.participantName} está escribiendo...',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _sending ? null : _sendMessage,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Burbuja de mensaje ─────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bgColor = isMe ? scheme.primary : scheme.surfaceContainerHighest;
    final textColor = isMe ? scheme.onPrimary : scheme.onSurface;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                message.senderName,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.grey),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: bgColor, borderRadius: radius),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(message.content, style: TextStyle(color: textColor)),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(message.createdAt.toLocal()),
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
