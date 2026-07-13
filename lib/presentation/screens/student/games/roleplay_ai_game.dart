import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class RoleplayAIGame extends ConsumerStatefulWidget {
  const RoleplayAIGame({super.key});
  @override
  ConsumerState<RoleplayAIGame> createState() => _RoleplayAIGameState();
}

class _RoleplayAIGameState extends ConsumerState<RoleplayAIGame> {
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'content': 'Hello! I am your waiter today. Are you ready to order?'}
  ];
  final TextEditingController _controller = TextEditingController();
  int _turnCount = 0;
  bool _submitting = false;

  bool _gameEnded = false;

  void _sendMessage() {
    if (_controller.text.isEmpty || _submitting || _gameEnded) return;
    setState(() {
      _messages.add({'role': 'user', 'content': _controller.text});
      _turnCount++;
      _controller.clear();
      
      // Simulación de respuesta IA
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            if (_turnCount == 1) {
              _messages.add({'role': 'ai', 'content': 'Excellent choice. Would you like anything to drink?'});
            } else if (_turnCount >= 3) {
              _messages.add({'role': 'ai', 'content': 'Perfect! I will bring your order in a moment. You did great! +80 XP'});
              _gameEnded = true;
              _finishGame();
            } else {
              _messages.add({'role': 'ai', 'content': 'I see. Anything else?'});
            }
          });
        }
      });
    });
  }

  Future<void> _finishGame() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
            lessonId: 25, // ID único para Roleplay AI
            status: 'completed',
            score: 80.0,
            xpEarned: 80,
          );
      if (mounted) {
        _showWinDialog();
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¡Excelente!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 64),
            SizedBox(height: 16),
            Text('Conversación completada con éxito.', style: TextStyle(color: Colors.white70, textAlign: TextAlign.center)),
            SizedBox(height: 8),
            Text('+80 XP', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 24)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            }, 
            child: const Text('CONTINUAR', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        title: const Text('ROLEPLAY AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final isAi = _messages[i]['role'] == 'ai';
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isAi ? Colors.white.withValues(alpha: 0.05) : Colors.blueAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isAi ? 0 : 20),
                        bottomRight: Radius.circular(isAi ? 20 : 0),
                      ),
                      border: Border.all(
                        color: isAi ? Colors.white.withValues(alpha: 0.1) : Colors.blueAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _messages[i]['content']!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ESCRIBE EN INGLÉS...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 14, letterSpacing: 1),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
