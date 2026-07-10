import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:flutter/services.dart';
import 'package:jumpup_app/theme/text_styles.dart';

/// Pantalla del Tutor IA.
///
/// Estado actual: EN CONSTRUCCIÓN 🚧
///
/// Esta pantalla mostrará la interfaz de chat con el Tutor IA una vez que
/// el backend conecte la API de mensajería con un proveedor de IA (OpenAI/Gemini).
/// Por ahora, ofrece un modo demo con respuestas simuladas y un banner informativo.
class AITutorScreen extends StatefulWidget {
  const AITutorScreen({super.key});

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      isBot: true,
      text:
          '¡Hola! 👋 Soy **Tutor JumpUp AI**, tu asistente personal de idiomas.\n\n⚠️ Estoy en modo **demostración** mientras el backend activa la conexión con IA. Mis respuestas actuales son ejemplos estáticos.\n\nEn la versión final podré ayudarte con gramática, pronunciación, vocabulario y mucho más. ¿Sobre qué quieres practicar hoy?',
      timestamp: DateTime.now().subtract(const Duration(seconds: 5)),
      hasQuickReplies: true,
    ),
  ];

  final List<String> _quickReplies = [
    '📚 Gramática básica',
    '🗣️ Conversación',
    '✍️ Escritura',
    '🎧 Comprensión auditiva',
  ];

  // Respuestas demo del bot
  final Map<String, String> _demoReplies = {
    '📚 Gramática básica':
        '¡Excelente elección! 📚\n\nVamos a repasar el presente simple:\n\n• **I speak** English (yo hablo)\n• **She speaks** English (ella habla)\n• **They speak** English (ellos hablan)\n\n¿Notas el cambio? Con he/she/it agregamos **-s** al verbo. ¿Quieres practicar con un ejercicio?',
    '🗣️ Conversación':
        '¡Perfecto para practicar! 🗣️\n\nIntenta responder en inglés:\n\n**"What do you like to do on weekends?"**\n(¿Qué te gusta hacer los fines de semana?)\n\nNo te preocupes por los errores, ¡para eso estoy aquí! 😊',
    '✍️ Escritura':
        '✍️ ¡Vamos a escribir!\n\nEjercicio: Escribe 3 oraciones sobre tu día usando los tiempos:\n1. **Presente**: *"I usually..."*\n2. **Pasado**: *"Yesterday I..."*\n3. **Futuro**: *"Tomorrow I will..."*\n\nPublica tu respuesta y te corrijo con cariño 💙',
    '🎧 Comprensión auditiva':
        '🎧 Comprensión auditiva es clave.\n\nEn la versión completa del Tutor IA podrás escuchar audio y transcribir lo que oyes. Por ahora, te recomiendo:\n\n• 🎬 Ver series en inglés con subtítulos\n• 🎵 Escuchar canciones y leer la letra\n• 📻 Podcasts en inglés para principiantes\n\n¿Quieres que te recomiende recursos específicos?',
  };

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
        hasQuickReplies: false,
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    // Simula tiempo de respuesta del bot
    await Future.delayed(const Duration(milliseconds: 1200));

    final reply = _demoReplies[text] ??
        '¡Interesante pregunta! 🤔\n\nEn la versión completa del Tutor IA (próximamente con GPT-4 / Gemini), podré responder cualquier duda sobre idiomas en tiempo real.\n\nPor ahora, te puedo decir que practicar a diario es la clave del éxito. ¡Sigue así! 💪';

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(
          isBot: true,
          text: reply,
          timestamp: DateTime.now(),
          hasQuickReplies: false,
        ));
      });
      _scrollToBottom();
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
          // ── Banner "En construcción" ─────────────────────────────────
          _ConstructionBanner(),

          // ── Lista de mensajes ────────────────────────────────────────
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

          // ── Input de mensaje ─────────────────────────────────────────
          _ChatInput(
            controller: _messageController,
            onSend: () => _sendMessage(),
            onMic: _onMicPressed,
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
                  'Modo demo · Próximamente con IA real',
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
        IconButton(
          icon: const Icon(Icons.info_outline_rounded,
              color: AppColors.textSecondary),
          onPressed: _showInfoDialog,
        ),
      ],
    );
  }

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
                color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 10),
            Text(
              'Reconocimiento de voz disponible próximamente',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
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
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Icon(Icons.auto_awesome_rounded,
                color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Tutor IA · En construcción',
              style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta función utilizará la API de OpenAI (GPT-4) o Google Gemini para responder tus preguntas sobre idiomas en tiempo real.\n\nEl backend ya tiene la infraestructura de mensajería lista. Solo falta conectar el "cerebro" de IA.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5),
            ),
            const SizedBox(height: 12),
            _FeatureChip(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chat en tiempo real'),
            const SizedBox(height: 8),
            _FeatureChip(
                icon: Icons.mic_rounded, label: 'Dictado por voz'),
            const SizedBox(height: 8),
            _FeatureChip(
                icon: Icons.volume_up_rounded,
                label: 'Pronunciación de respuestas'),
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
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
              color: AppColors.primaryLight.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Función en desarrollo · Las respuestas son ejemplos',
              style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Próximo',
              style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10, color: AppColors.primary),
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
                // Renderiza **negrita** de forma simple
                message.text.replaceAll('**', ''),
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
    required this.onMic,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
            top: BorderSide(color: AppColors.surface)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Micrófono
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.mic_rounded,
                    color: AppColors.textPrimary, size: 20),
                onPressed: onMic,
              ),
            ),
            const SizedBox(width: 10),

            // Campo de texto
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
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

            // Enviar
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
