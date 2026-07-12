import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/presentation/providers/service_providers.dart';

import 'package:jumpup_app/presentation/providers/ai_chat_provider.dart';

class AITutorScreen extends ConsumerStatefulWidget {
  const AITutorScreen({super.key});

  @override
  ConsumerState<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends ConsumerState<AITutorScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isListening = false;
  bool _isProcessingOcr = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiChatProvider.notifier).initChat();
      
      // Sincronizar estado de voz con el servicio
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
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? quickText]) {
    final text = quickText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    ref.read(aiChatProvider.notifier).sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
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

  Future<void> _toggleListening() async {
    final speechService = ref.read(speechServiceProvider);

    if (_isListening) {
      await speechService.stopListening();
    } else {
      final available = await speechService.initialize();
      if (available) {
        await speechService.startListening(
          onResult: (text) {
            setState(() => _messageController.text = text);
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reconocimiento de voz no disponible')),
          );
        }
      }
    }
  }

  Future<void> _pickImageAndOcr() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() => _isProcessingOcr = true);
      try {
        final ocrService = ref.read(ocrServiceProvider);
        final text = await ocrService.recognizeText(File(image.path));
        
        if (text.isNotEmpty) {
          setState(() {
            _messageController.text = text;
            _isProcessingOcr = false;
          });
        } else {
          setState(() => _isProcessingOcr = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se detectó texto en la imagen')),
            );
          }
        }
      } catch (e) {
        setState(() => _isProcessingOcr = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al procesar imagen: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(isDark),
      body: Stack(
        children: [
          // Background Gradient
          if (isDark)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.3), blurRadius: 100),
                  ],
                ),
              ),
            ),
          Column(
            children: [
              if (chatState.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: chatState.isConnecting ? Colors.orange.withValues(alpha: 0.2) : Colors.redAccent.withValues(alpha: 0.2),
                  child: Row(
                    children: [
                      Icon(
                        chatState.isConnecting ? Icons.sync : Icons.wifi_off_rounded, 
                        color: chatState.isConnecting ? Colors.orange : Colors.redAccent, 
                        size: 16
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          chatState.error!, 
                          style: TextStyle(
                            color: chatState.isConnecting ? Colors.orange : Colors.redAccent, 
                            fontSize: 12
                          )
                        ),
                      ),
                      if (!chatState.isConnecting)
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.redAccent, size: 16),
                          onPressed: () => ref.read(aiChatProvider.notifier).initChat(),
                        ),
                    ],
                  ),
                ),
              if (chatState.isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),

                    itemBuilder: (context, index) {
                      if (index == chatState.messages.length && chatState.isTyping) {
                        return _TypingIndicator();
                      }
                      final msg = chatState.messages[index];
                      // Determine if it's bot or user based on senderName
                      final isBot = msg.senderName == 'AI Tutor' || msg.senderId == 0;
                      
                      final showQuickReplies = index == 0 && chatState.messages.length == 1 && !chatState.isLoading;
                      return Column(
                        children: [
                          _ChatBubble(isBot: isBot, text: msg.body, timestamp: msg.createdAt),
                          if (showQuickReplies)
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
                enabled: !chatState.isLoading,
                onVoiceToggle: _toggleListening,
                onOcrTap: _pickImageAndOcr,
                isListening: _isListening,
                isProcessingOcr: _isProcessingOcr,
              ),
            ],
          ),
        ],
      ),
    );
  }

  final List<String> _quickReplies = [
    'Ayúdame con la gramática',
    'Practiquemos conversación',
    'Explica los phrasal verbs',
    '¿Podemos hacer un quiz?',
  ];

  AppBar _buildAppBar(bool isDark) {
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
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF1E1E2A),
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Tutor',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 18),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0xFF00C853), blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Online', style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.isBot, required this.text, required this.timestamp});
  final bool isBot;
  final String text;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final botBubbleColor = isDark ? const Color(0xFF1F1F30) : Colors.white;
    final botTextColor = isDark ? Colors.white : Colors.black87;
    final timeColor = isDark ? Colors.white38 : Colors.black38;

    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            if (isBot)
              Container(
                decoration: BoxDecoration(
                  color: botBubbleColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.06)),
                  boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  text,
                  style: TextStyle(color: botTextColor, height: 1.5, fontSize: 15),
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
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2575FC).withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 10, color: timeColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickRepliesRow extends StatelessWidget {
  const _QuickRepliesRow({required this.replies, required this.onTap});
  final List<String> replies;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        children: replies.map((r) => GestureDetector(
          onTap: () => onTap(r),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            borderRadius: BorderRadius.circular(20),
            opacity: isDark ? 0.2 : 0.05,
            child: Text(r, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        )).toList(),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF232336) : Colors.black.withValues(alpha: 0.05);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
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
        decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.enabled,
    required this.onVoiceToggle,
    required this.onOcrTap,
    required this.isListening,
    required this.isProcessingOcr,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  final VoidCallback onVoiceToggle;
  final VoidCallback onOcrTap;
  final bool isListening;
  final bool isProcessingOcr;

  @override
  Widget build(BuildContext context) {
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
                onPressed: enabled ? onOcrTap : null,
                icon: isProcessingOcr 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.camera_alt_rounded),
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              IconButton(
                onPressed: enabled ? onVoiceToggle : null,
                icon: Icon(isListening ? Icons.mic_rounded : Icons.mic_none_rounded),
                color: isListening ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: BorderRadius.circular(25),
                  opacity: isDark ? 0.05 : 0.5,
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    style: TextStyle(color: textColor, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: isListening ? 'Escuchando...' : 'Pregúntale algo...',
                      hintStyle: TextStyle(color: isListening ? Colors.redAccent : hintColor, fontSize: 14),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => onSend(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: enabled ? onSend : null,
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
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
