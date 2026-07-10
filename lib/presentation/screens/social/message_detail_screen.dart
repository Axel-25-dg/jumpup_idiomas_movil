import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/data/remote/websocket_service.dart';
import 'package:jumpup_app/domain/model/chat_message.dart';
import 'package:jumpup_app/domain/model/message_thread.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageDetailScreen extends ConsumerStatefulWidget {
  const MessageDetailScreen({super.key, required this.thread});

  final MessageThread thread;

  @override
  ConsumerState<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends ConsumerState<MessageDetailScreen> {
  late final WebSocketService _ws;
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  bool _isTyping = false;

  StreamSubscription<Map<String, dynamic>>? _wsSub;

  @override
  void initState() {
    super.initState();
    _ws = WebSocketService(path: 'chat', roomId: widget.thread.id.toString());
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

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final msgs = await ref.read(socialRepositoryProvider).fetchChatMessages(widget.thread.id);
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
        case 'chat_message':
        case 'message':
          final msgData = data['message'] ?? data;
          if (msgData is Map<String, dynamic>) {
            final msg = ChatMessage.fromJson(msgData);
            setState(() {
              _messages = [..._messages, msg];
              _isTyping = false;
            });
            _scrollToBottom();
          }
        case 'typing':
          setState(() => _isTyping = true);
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _isTyping = false);
          });
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;

    final optimistic = ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch,
      senderId: -1,
      senderName: 'Tú',
      body: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages = [..._messages, optimistic];
      _sending = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      if (_ws.isConnected) {
        _ws.send({'type': 'chat_message', 'body': text});
      }
      await ref.read(socialRepositoryProvider).sendMessage(
            threadId: widget.thread.id,
            body: text,
          );
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.thread.subject.isNotEmpty
                ? widget.thread.subject
                : widget.thread.participantName,
                style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            Text(widget.thread.participantName,
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              _ws.isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: _ws.isConnected ? Colors.greenAccent : Colors.white38,
              size: 18,
            ),
          ),
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
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.error),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loadHistory,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(Icons.chat_bubble_outline_rounded, size: 48,
                  color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 12),
            Text('Sin mensajes aún', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('¡Di algo primero!',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg.senderId == -1 || msg.senderName == 'Tú';
        return _MessageBubble(message: msg, isMe: isMe);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Text('${widget.thread.participantName} está escribiendo...',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _sending ? null : _sendMessage,
              icon: _sending
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});
  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final bgColor = isMe ? AppColors.primary : AppColors.white;
    final textColor = isMe ? Colors.white : AppColors.textPrimary;
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
              child: Text(message.senderName,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
            ),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: radius,
              border: isMe ? null : Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(message.body, style: TextStyle(color: textColor, fontSize: 14)),
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
