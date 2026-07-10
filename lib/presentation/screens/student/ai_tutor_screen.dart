import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/data/repository/auth/ai_tutor_service.dart';

final aiTutorServiceProvider = Provider<AITutorService>((ref) {
  return const AITutorService();
});

class AITutorScreen extends ConsumerStatefulWidget {
  const AITutorScreen({super.key});

  @override
  ConsumerState<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends ConsumerState<AITutorScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isLoadingHistory = true;
  String? _error;

  final List<_ChatMessage> _messages = [];

  final List<String> _quickReplies = [
    'Gramática básica',
    'Conversación',
    'Escritura',
    'Comprensión auditiva',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final service = ref.read(aiTutorServiceProvider);
      final history = await service.getChatHistory();
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
          for (final msg in history) {
            _messages.add(_ChatMessage(
              isBot: msg['role'] == 'assistant' || msg['role'] == 'bot',
              text: msg['content']?.toString() ?? msg['message']?.toString() ?? '',
              timestamp: DateTime.tryParse(msg['created_at']?.toString() ?? '') ?? DateTime.now(),
            ));
          }
          if (_messages.isEmpty) {
            _messages.add(_ChatMessage(
              isBot: true,
              text: '¡Hola! Soy Tutor JumpUp AI, tu asistente personal de idiomas.\n\nPuedo ayudarte con gramática, pronunciación, vocabulario y mucho más. ¿Sobre qué quieres practicar hoy?',
              timestamp: DateTime.now(),
            ));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
          _messages.add(_ChatMessage(
            isBot: true,
            text: '¡Hola! Soy Tutor JumpUp AI, tu asistente personal de idiomas.\n\nPuedo ayudarte con gramática, pronunciación, vocabulario y mucho más. ¿Sobre qué quieres practicar hoy?',
            timestamp: DateTime.now(),
          ));
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? quickText]) async {
    final text = quickText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    _messageController.clear();

    setState(() {
      _messages.add(_ChatMessage(
        isBot: false,
        text: text,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
      _error = null;
    });

    _scrollToBottom();

    try {
      final service = ref.read(aiTutorServiceProvider);
      final response = await service.sendChatMessage(text);

      final reply = response['response']?.toString() 
          ?? response['message']?.toString() 
          ?? response['answer']?.toString()
          ?? 'No pude generar una respuesta. Intenta de nuevo.';

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            isBot: true,
            text: reply,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _error = 'Error de conexión. Intenta de nuevo.';
          _messages.add(_ChatMessage(
            isBot: true,
            text: 'Lo siento, hubo un error de conexión. Por favor, intenta de nuevo.',
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _clearHistory() async {
    try {
      final service = ref.read(aiTutorServiceProvider);
      await service.clearChatHistory();
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.add(_ChatMessage(
            isBot: true,
            text: 'Historial limpiado. ¿En qué puedo ayudarte?',
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo limpiar el historial'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.error.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _error = null),
                  ),
                ],
              ),
            ),
          if (_isLoadingHistory)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _TypingIndicator();
                  }
                  final msg = _messages[index];
                  return Column(
                    children: [
                      _ChatBubble(message: msg),
                      if (msg.hasQuickReplies)
                        _QuickRepliesRow(
                          replies: _quickReplies,
                          onTap: _sendMessage,
                        ),
                    ],
                  );
                },
              ),
            ),
          _ChatInput(
            controller: _messageController,
            onSend: () => _sendMessage(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leadingWidth: 40,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.smart_toy_rounded,
                    color: AppColors.textPrimary, size: 22),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tutor JumpUp AI',
                  style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  'Asistente de idiomas con IA',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          onSelected: (value) {
            if (value == 'clear') {
              _showClearDialog();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Limpiar historial'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text('¿Estás seguro de que quieres borrar todo el historial de chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _clearHistory();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final bool isBot;
  final String text;
  final DateTime timestamp;
  final bool hasQuickReplies;

  const _ChatMessage({
    required this.isBot,
    required this.text,
    required this.timestamp,
    this.hasQuickReplies = false,
  });
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: message.isBot
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            if (message.isBot)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.smart_toy_rounded,
                          size: 12, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tutor AI',
                      style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isBot
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF29B6F6)],
                      ),
                color: message.isBot
                    ? AppColors.surface
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isBot ? 4 : 18),
                  bottomRight: Radius.circular(message.isBot ? 18 : 4),
                ),
                border: message.isBot
                    ? Border.all(color: AppColors.divider)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: message.isBot
                        ? Colors.black26
                        : AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _QuickRepliesRow extends StatelessWidget {
  const _QuickRepliesRow(
      {required this.replies, required this.onTap});
  final List<String> replies;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: replies
            .map((r) => GestureDetector(
                  onTap: () => onTap(r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      r,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 200),
            const SizedBox(width: 4),
            _Dot(delay: 400),
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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
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
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
            top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider),
                ),
                child: TextField(
                  controller: controller,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Escribe en inglés o español...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13, color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                  onSubmitted: (_) => onSend(),
                  textInputAction: TextInputAction.send,
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF29B6F6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.send_rounded,
                    color: AppColors.textPrimary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
