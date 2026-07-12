import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/data/local/token_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Servicio genérico para conexiones WebSocket contra el VPS Hetzner.
///
/// Uso — Notificaciones:
///   final ws = WebSocketService(path: 'notifications');
///   await ws.connect();
///   ws.messages.listen((data) { ... });
///
/// Uso — Chat (roomId requerido):
///   final ws = WebSocketService(path: 'chat', roomId: 'room-123');
///   await ws.connect();
///   ws.send({'message': 'Hola!', 'type': 'chat_message'});
///   ws.disconnect();
class WebSocketService {
  WebSocketService({required this.path, this.roomId});

  /// Segmento de ruta → 'notifications', 'chat', etc.
  final String path;

  /// ID de sala/conversación, si aplica.
  final String? roomId;

  final TokenStorage _tokenStorage = TokenStorage();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  StreamController<Map<String, dynamic>>? _controller;

  bool _connected = false;
  bool get isConnected => _connected;

  /// Stream de mensajes JSON decodificados recibidos desde el servidor.
  Stream<Map<String, dynamic>> get messages {
    _controller ??= StreamController<Map<String, dynamic>>.broadcast();
    return _controller!.stream;
  }

  /// Abre la conexión WebSocket autenticada con JWT.
  Future<void> connect() async {
    if (_connected) return;

    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      debugPrint('[WS] Sin token JWT — no se puede conectar a /$path');
      return;
    }

    // URL resultante limpia usando el generador centralizado de AppConfig
    final roomPath = roomId != null ? '$roomId/' : '';
    final fullPath = '$path/$roomPath'.replaceAll('//', '/');
    final wsUrl = AppConfig.buildWsUrl(fullPath, token: token);
    final uri = Uri.parse(wsUrl);

    try {
      debugPrint('[WS] Intentando conectar a: $wsUrl');
      _channel = WebSocketChannel.connect(uri);
      
      // El handshake ocurre aquí. Si falla, lanzará Exception
      await _channel!.ready;
      
      _connected = true;
      debugPrint('[WS] ✓ Conexión establecida con éxito');

      _controller ??= StreamController<Map<String, dynamic>>.broadcast();

      _subscription = _channel!.stream.listen(
        (raw) {
          try {
            final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
            _controller?.add(decoded);
          } catch (e) {
            debugPrint('[WS] Error decodificando mensaje: $e  raw=$raw');
          }
        },
        onError: (dynamic error) {
          debugPrint('[WS] Error en stream /$path: $error');
          _connected = false;
        },
        onDone: () {
          debugPrint('[WS] Conexión cerrada /$path');
          _connected = false;
        },
      );
    } catch (e) {
      debugPrint('[WS] No se pudo conectar a $uri → $e');
      _connected = false;
    }
  }

  /// Envía un mapa JSON al servidor.
  void send(Map<String, dynamic> data) {
    if (!_connected || _channel == null) {
      debugPrint('[WS] send() ignorado — sin conexión activa');
      return;
    }
    _channel!.sink.add(jsonEncode(data));
  }

  /// Cierra la conexión y libera recursos.
  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    await _controller?.close();
    _subscription = null;
    _channel = null;
    _controller = null;
    _connected = false;
    debugPrint('[WS] Desconectado de /$path');
  }
}
