import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../services/ai_chat_service.dart';

class AiTutorScreen extends StatefulWidget {
  final String token;
  const AiTutorScreen({super.key, required this.token});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  WebSocketChannel? _channel;
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  int? _threadId;
  bool _connected = false;
  bool _aiTyping = false;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    // Crear o buscar hilo del tutor IA
    final thread = await AiChatService.createAiThread(widget.token);
    if (thread == null) return;

    _threadId = thread['id'];

    // Cargar historial
    final history = await AiChatService.getMessages(widget.token, _threadId!);
    setState(() {
      _messages = history.map<Map<String, dynamic>>((m) => {
        'body': m['body'] ?? '',
        'isMe': m['sender'] != null, // tutor_ia tiene sender diferente
        'sender': m['sender_email'] ?? '',
        'created_at': m['created_at'] ?? '',
      }).toList();
    });

    // Conectar WebSocket
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _channel = AiChatService.connectToAi(_threadId!, widget.token);

    _channel!.stream.listen(
      (data) {
        final msg = jsonDecode(data);
        if (msg['type'] == 'chat_message') {
          final message = msg['message'];
          setState(() {
            _aiTyping = false;
            _messages.add({
              'body': message['body'],
              'isMe': false,
              'sender': 'Tutor IA',
              'created_at': message['created_at'],
            });
          });
          _scrollToBottom();
        } else if (msg['type'] == 'typing') {
          setState(() => _aiTyping = msg['is_typing'] == true);
        }
      },
      onDone: () => setState(() => _connected = false),
      onError: (_) => setState(() => _connected = false),
    );

    setState(() => _connected = true);
  }

  void _send() {
    if (_msgCtrl.text.isEmpty || _channel == null) return;

    final text = _msgCtrl.text;
    setState(() {
      _messages.add({
        'body': text,
        'isMe': true,
        'sender': 'Tú',
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    AiChatService.sendMessage(_channel!, text);
    _msgCtrl.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tutor IA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  _connected ? 'En línea' : 'Desconectado',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // MENSAJES
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_aiTyping ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _messages.length && _aiTyping) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Tutor IA está escribiendo...'),
                        ],
                      ),
                    ),
                  );
                }

                final m = _messages[i];
                final isMe = m['isMe'] ?? false;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          const Text('Tutor IA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                        Text(
                          m['body'] ?? '',
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // INPUT
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Pregúntale al tutor...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _send,
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
