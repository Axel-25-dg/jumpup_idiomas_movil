import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/domain/model/chat_message.dart';
import 'package:jumpup_app/domain/model/message_thread.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/presentation/providers/service_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class MessageDetailScreen extends ConsumerStatefulWidget {
  const MessageDetailScreen({super.key, required this.thread});

  final MessageThread thread;

  @override
  ConsumerState<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends ConsumerState<MessageDetailScreen> {
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  bool _isTyping = false;
  bool _isListening = false;

  StreamSubscription<ChatMessage>? _messageSub;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    
    // Escuchar cambios en el estado de voz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(speechServiceProvider).isListeningNotifier.addListener(_onSpeechStatusChanged);
    });
  }

  void _onSpeechStatusChanged() {
    if (!mounted) return;
    setState(() {
      _isListening = ref.read(speechServiceProvider).isListeningNotifier.value;
    });
  }

  @override
  void dispose() {
    ref.read(speechServiceProvider).isListeningNotifier.removeListener(_onSpeechStatusChanged);
    _messageSub?.cancel();
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
      final repo = ref.read(chatRepositoryProvider);
      final msgs = await repo.getMessages(widget.thread.id);
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
    final repo = ref.read(chatRepositoryProvider);
    await repo.connectToThread(widget.thread.id);
    _messageSub = repo.messageStream.listen((msg) {
      if (!mounted) return;
      setState(() {
        // Evitar duplicados si ya se agregó de forma optimista
        if (!_messages.any((m) => m.body == msg.body && m.senderId == msg.senderId && (m.id < 0))) {
           _messages = [..._messages, msg];
        } else {
           // Reemplazar el mensaje optimista con el real
           _messages = _messages.map((m) => (m.body == msg.body && m.id < 0) ? msg : m).toList();
        }
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;

    final repo = ref.read(chatRepositoryProvider);

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
      if (repo.isConnected) {
        repo.sendWsMessage(text);
      } else {
        await repo.sendMessage(
          threadId: widget.thread.id,
          body: text,
        );
      }
      ref.invalidate(chatThreadsProvider);
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages = _messages.where((m) => m.id != optimistic.id).toList();
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No se pudo enviar el mensaje'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D0D15) : AppColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isDark),
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(
              top: -80,
              left: -60,
              child: _BlurBlob(
                color: const Color(0xFF6A11CB).withValues(alpha: 0.15),
                size: 280,
              ),
            ),
            Positioned(
              bottom: 150,
              right: -70,
              child: _BlurBlob(
                color: const Color(0xFF2575FC).withValues(alpha: 0.12),
                size: 250,
              ),
            ),
          ],
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(child: _buildMessageList()),
                if (_isTyping) _buildTypingIndicator(),
                _buildInputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    final bgColor = isDark ? const Color(0xFF0D0D15) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textColor),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(color: bgColor.withValues(alpha: 0.7)),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: isDark ? const Color(0xFF1E1E2A) : Colors.white,
              child: Text(
                widget.thread.participantName.isNotEmpty ? widget.thread.participantName[0] : '?',
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF6A11CB), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.thread.subject.isNotEmpty ? widget.thread.subject : widget.thread.participantName,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: ref.watch(chatRepositoryProvider).isConnected ? const Color(0xFF00C853) : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: ref.watch(chatRepositoryProvider).isConnected 
                          ? [const BoxShadow(color: Color(0xFF00C853), blurRadius: 4)]
                          : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ref.watch(chatRepositoryProvider).isConnected ? 'Online' : 'Desconectado',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg.senderId == -1 || msg.senderName == 'Tú';
        return _MessageBubble(message: msg, isMe: isMe);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return _TypingIndicator(participantName: widget.thread.participantName);
  }

  Future<void> _toggleListening() async {
    final speechService = ref.read(speechServiceProvider);

    if (_isListening) {
      await speechService.stopListening();
    } else {
      final available = await speechService.initialize();
      if (available) {
        await speechService.startListening(
          onResult: (text) {
            setState(() {
              _inputController.text = text;
              _inputController.selection = TextSelection.fromPosition(
                TextPosition(offset: _inputController.text.length),
              );
            });
          },
        );
      }
    }
  }

  Widget _buildInputBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? const Color(0xFF0F111A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white38 : Colors.black38;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          decoration: BoxDecoration(
            color: inputBg.withValues(alpha: 0.9),
            border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.08))),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _toggleListening,
                icon: Icon(_isListening ? Icons.mic_rounded : Icons.mic_none_rounded),
                color: _isListening ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: BorderRadius.circular(25),
                  opacity: isDark ? 0.05 : 0.5,
                  child: TextField(
                    controller: _inputController,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(color: textColor, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: _isListening ? 'Escuchando...' : 'Escribe un mensaje...',
                      hintStyle: TextStyle(color: _isListening ? Colors.redAccent : hintColor, fontSize: 14),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _sending ? null : _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2575FC).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _sending
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final botTextColor = isDark ? Colors.white : Colors.black87;
    final timeColor = isDark ? Colors.white38 : Colors.black38;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            if (!isMe)
              GlassContainer(
                opacity: isDark ? 0.08 : 0.05,
                blur: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(4),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  message.body,
                  style: TextStyle(color: botTextColor, height: 1.4, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2575FC).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  message.body,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                DateFormat('HH:mm').format(message.createdAt.toLocal()),
                style: TextStyle(fontSize: 10, color: timeColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 100,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final String participantName;
  const _TypingIndicator({required this.participantName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                '$participantName está escribiendo...',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
            GlassContainer(
              opacity: isDark ? 0.08 : 0.05,
              blur: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Dot(delay: 0),
                  SizedBox(width: 4),
                  _Dot(delay: 200),
                  SizedBox(width: 4),
                  _Dot(delay: 400),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.delay});
  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(color: Color(0xFF2575FC), shape: BoxShape.circle),
      ),
    );
  }
}
