import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/repository/auth/ai_tutor_service.dart';
import '../../services/chat_websocket_service.dart';
import '../../theme/app_theme.dart';

class AITutorScreen extends StatefulWidget {
  final String threadId;

  const AITutorScreen({super.key, required this.threadId});

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final ChatWebSocketService _wsService = ChatWebSocketService();
  final AITutorService _aiService = const AITutorService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _isAITyping = false;
  bool _wsConnected = false;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _initConnection();
  }

  Future<void> _initConnection() async {
    try {
      await _wsService.connect(widget.threadId);
      if (mounted) setState(() => _wsConnected = true);

      _wsService.messageStream?.listen(
        (event) {
          if (!mounted) return;
          try {
            final data = jsonDecode(event as String);
            if (data['type'] == 'chat_message') {
              final msg = data['message'];
              setState(() {
                // Evitar duplicados si el mensaje ya fue añadido localmente
                final senderId = msg['sender_id'];
                // Solo añadir si es respuesta de la IA (sender_id == 0)
                if (senderId == 0) {
                  _messages.add(msg);
                }
                _isAITyping = false;
              });
              _scrollToBottom();
            } else if (data['type'] == 'typing') {
              setState(() => _isAITyping = data['is_typing'] == true);
            }
          } catch (_) {}
        },
        onError: (error) {
          debugPrint('WebSocket Error: $error');
          if (mounted) setState(() => _wsConnected = false);
        },
        onDone: () {
          if (mounted) setState(() => _wsConnected = false);
        },
      );
    } catch (e) {
      debugPrint('WS Connection Error: $e');
      if (mounted) {
        setState(() {
          _wsConnected = false;
          _connectionError = 'Usando modo HTTP';
        });
      }
    }
  }

  /// Envía mensaje. Si WebSocket está conectado lo usa, si no usa REST.
  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    setState(() {
      _messages.add({'body': text, 'sender_id': 1});
      _isAITyping = true;
    });
    _scrollToBottom();

    if (_wsConnected) {
      // Enviar por WebSocket
      _wsService.sendMessage(text);
      // La respuesta llega por el stream (listener arriba)
      // Si en 15 segundos no hay respuesta, fallback a REST
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted && _isAITyping) {
          _sendViaRest(text);
        }
      });
    } else {
      // Fallback directo a REST
      await _sendViaRest(text);
    }
  }

  Future<void> _sendViaRest(String text) async {
    try {
      final result = await _aiService.sendChatMessage(text);
      if (!mounted) return;
      final reply = result['response']?.toString() ??
          result['message']?.toString() ??
          result['reply']?.toString() ??
          'Sin respuesta';
      setState(() {
        _messages.add({'body': reply, 'sender_id': 0});
        _isAITyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'body': 'Lo siento, no pude obtener respuesta. Inténtalo de nuevo.',
          'sender_id': 0,
          'isError': true,
        });
        _isAITyping = false;
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
  void dispose() {
    _wsService.disconnect();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(
        title: const Text('Tutor IA'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              _wsConnected ? Icons.wifi : Icons.wifi_off,
              size: 18,
              color: _wsConnected ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de modo HTTP si el WS no está conectado
          if (!_wsConnected && _connectionError != null)
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Conectado vía HTTP',
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.smart_toy_outlined,
                            size: 64,
                            color: AppTheme.celeste.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          '¡Hola! Soy tu tutor IA.\n¿En qué te puedo ayudar hoy?',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textoClaro, height: 1.6),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['sender_id'] != 0;
                      final isError = msg['isError'] == true;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isError
                                ? Colors.red.shade50
                                : isMe
                                    ? AppTheme.celeste
                                    : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg['body']?.toString() ?? '',
                            style: TextStyle(
                              color: isError
                                  ? Colors.red.shade700
                                  : isMe
                                      ? Colors.white
                                      : AppTheme.textoOscuro,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Indicador de escritura
          if (_isAITyping)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.celeste.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tutor IA está escribiendo...',
                      style: TextStyle(
                          color: AppTheme.textoClaro,
                          fontStyle: FontStyle.italic,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

          // Campo de texto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.grisClaro,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: _isAITyping ? Colors.grey.shade300 : AppTheme.celeste,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _isAITyping ? null : _sendMessage,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.send_rounded,
                          color: Colors.white, size: 22),
                    ),
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
