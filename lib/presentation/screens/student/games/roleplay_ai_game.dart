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

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
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
    await ref.read(progressNotifierProvider.notifier).registerLessonProgress(
      lessonId: 12,
      status: 'completed',
      score: 80.0,
      xpEarned: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎭 ROLEPLAY AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final isAi = _messages[i]['role'] == 'ai';
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: GlassContainer(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    color: isAi ? Colors.blue.withOpacity(0.1) : Colors.purple.withOpacity(0.1),
                    child: Text(_messages[i]['content']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Escribe en inglés...'),
                  ),
                ),
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: Colors.blue)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
