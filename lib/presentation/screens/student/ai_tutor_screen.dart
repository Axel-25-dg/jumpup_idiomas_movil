import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/subscription_providers.dart';

import 'package:jumpup_app/presentation/providers/ai_chat_provider.dart';

class AITutorScreen extends ConsumerStatefulWidget {
  const AITutorScreen({super.key});

  @override
  ConsumerState<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends ConsumerState<AITutorScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiChatProvider.notifier).initChat();
    });
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final mySubAsync = ref.watch(mySubscriptionProvider);
    final isPro = mySubAsync.value?.isActive ?? false;
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
              // Subscription required banner
              if (!isPro && mySubAsync.hasValue)
                _SubscriptionBanner(
                  onUpgrade: () => context.push(AppRoutes.studentSubscriptions),
                ),
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
<<<<<<< HEAD
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
=======
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
>>>>>>> main
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
<<<<<<< HEAD

  void _onMicPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.mic_off_rounded,
                color: AppColors.warning, size: 18),
            const SizedBox(width: 10),
            Text(
              'Reconocimiento de voz disponible próximamente',
              style:
                  GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Icon(Icons.construction_rounded,
                color: AppColors.warning, size: 48),
            const SizedBox(height: 16),
            Text(
              'Tutor IA · En construcción',
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta función utilizará la API de OpenAI (GPT-4) o Google Gemini para responder tus preguntas sobre idiomas en tiempo real.\n\nEl backend ya tiene la infraestructura de mensajería lista. Solo falta conectar el "cerebro" de IA.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            const _FeatureChip(icon: Icons.chat_bubble_outline_rounded, label: 'Chat en tiempo real'),
            const SizedBox(height: 8),
            const _FeatureChip(icon: Icons.mic_rounded, label: 'Dictado por voz'),
            const SizedBox(height: 8),
            const _FeatureChip(icon: Icons.volume_up_rounded, label: 'Pronunciación de respuestas'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Componentes de UI ──────────────────────────────────────────────────────────

class _ConstructionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
              color: AppColors.warning.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.construction_rounded,
              color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Función en construcción · Las respuestas son ejemplos estáticos',
              style: GoogleFonts.poppins(
                color: AppColors.warning,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.poppins(
                  color: AppColors.textPrimary, fontSize: 13)),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Próximo',
              style: GoogleFonts.poppins(
                  color: AppColors.warning, fontSize: 10),
            ),
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
    required this.hasQuickReplies,
  });
=======
>>>>>>> main
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
  const _ChatInput({required this.controller, required this.onSend, required this.enabled});
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

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
                      hintText: 'Pregúntale algo al tutor...',
                      hintStyle: TextStyle(color: hintColor, fontSize: 14),
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

/// Banner shown at the top of AI Tutor screen when user has no active subscription
class _SubscriptionBanner extends StatelessWidget {
  final VoidCallback onUpgrade;
  const _SubscriptionBanner({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUpgrade,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: const Row(
          children: [
            Text('🔒', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'El Tutor IA requiere suscripción Pro — Toca para ver planes',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
          ],
        ),
      ),
    );
  }
}
