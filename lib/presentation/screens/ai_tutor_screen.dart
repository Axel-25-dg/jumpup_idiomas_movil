import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/chat_websocket_service.dart';
import '../../theme/app_theme.dart';

class AITutorScreen extends StatefulWidget {
  final String threadId; // ID del hilo donde responde la IA

  const AITutorScreen({super.key, required this.threadId});

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final ChatWebSocketService _wsService = ChatWebSocketService();
  final TextEditingController _msgController = TextEditingController();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isAITyping = false;

  @override
  void initState() {
    super.initState();
    _initConnection();
  }

  Future<void> _initConnection() async {
    try {
      await _wsService.connect(widget.threadId);
      
      // Escuchando los mensajes provenientes del servidor
      _wsService.messageStream?.listen((event) {
        final data = jsonDecode(event);

        if (data['type'] == 'chat_message') {
          setState(() {
            _messages.add(data['message']);
            _isAITyping = false; // La IA dejó de escribir
          });
        } else if (data['type'] == 'typing') {
          setState(() {
            // data['user_id'] == 0 es el bot según nuestro backend
            _isAITyping = data['is_typing'];
          });
        }
      }, onError: (error) {
        debugPrint('WebSocket Error: $error');
      });
    } catch (e) {
      debugPrint('Connection Error: $e');
    }
  }

  void _sendMessage() {
    final text = _msgController.text;
    if (text.trim().isNotEmpty) {
      // Envía el mensaje por el socket a Django
      _wsService.sendMessage(text);
      
      // Añadimos el mensaje localmente de forma rápida
      setState(() {
        _messages.add({
          'body': text,
          'sender_id': 1, // ID distinto de 0 para representar que somos nosotros
        });
        _isAITyping = true; // Asumimos que la IA empezará a escribir
      });

      _msgController.clear();
    }
  }

  @override
  void dispose() {
    _wsService.disconnect();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(title: const Text('Tutor IA')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['sender_id'] != 0; // Si no es 0, soy yo (o un profesor)

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.celeste : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      msg['body'] ?? '',
                      style: TextStyle(color: isMe ? Colors.white : AppTheme.textoOscuro),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Indicador de que la IA está pensando
          if (_isAITyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Tutor IA está escribiendo...', style: TextStyle(color: AppTheme.textoClaro, fontStyle: FontStyle.italic)),
              ),
            ),

          // Campo de texto para enviar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.grisClaro,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.celeste,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
