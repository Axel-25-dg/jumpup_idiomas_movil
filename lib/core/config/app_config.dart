import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    final value = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api/';
    return value.endsWith('/') ? value : '$value/';
  }

  /// Genera la URL base para WebSockets (wss://.../ws)
  /// Esta implementación es extremadamente robusta para evitar el error de puerto :0
  static String get wsBaseUrl {
    final base = baseUrl.trim().toLowerCase();
    
    // 1. Caso de producción: Hardcoded para evitar cualquier error de parseo de Uri
    if (base.contains('guaman-idiomas-ute.online')) {
      return 'wss://guaman-idiomas-ute.online/ws';
    }

    // 2. Caso de emulador Android local
    if (base.contains('10.0.2.2')) {
      return 'ws://10.0.2.2:8000/ws';
    }

    // 3. Caso genérico
    try {
      final uri = Uri.parse(base);
      final isSecure = base.startsWith('https');
      final scheme = isSecure ? 'wss' : 'ws';
      final host = uri.host;
      final port = uri.port;
      
      // Si es producción, forzamos wss y quitamos cualquier puerto accidental
      if (host.contains('guaman-idiomas-ute.online')) {
        return 'wss://$host/ws';
      }

      // Si hay un puerto explícito (como en dev), lo mantenemos
      if (port > 0 && port != 80 && port != 443) {
        return '$scheme://$host:$port/ws';
      }
      return '$scheme://$host/ws';
    } catch (e) {
      // Fallback manual si el parseo falla
      final hostOnly = base
          .replaceFirst('https://', '')
          .replaceFirst('http://', '')
          .split('/')[0];
      final scheme = base.startsWith('https') ? 'wss' : 'ws';
      return '$scheme://$hostOnly/ws';
    }
  }

  /// Construye una URL de WebSocket completa añadiendo el path y manejando el token
  static String buildWsUrl(String path, {String? token}) {
    String base = wsBaseUrl;
    // Limpiamos barras duplicadas entre la base y el path
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    final cleanPath = path.startsWith('/') ? path : '/$path';
    
    String url = '$base$cleanPath';
    
    // Aseguramos que termine en / antes de los query params (importante para Django)
    if (!url.contains('?') && !url.endsWith('/')) {
      url = '$url/';
    } else if (url.contains('?')) {
      final parts = url.split('?');
      if (!parts[0].endsWith('/')) {
        url = '${parts[0]}/?${parts[1]}';
      }
    }

    if (token != null && token.isNotEmpty) {
      final separator = url.contains('?') ? '&' : '?';
      url = '$url${separator}token=$token';
    }
    
    return url;
  }

  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    
    final apiFreeBase = baseUrl.replaceFirst(RegExp(r'/?api/?$'), '');
    final cleanBase = apiFreeBase.endsWith('/')
        ? apiFreeBase.substring(0, apiFreeBase.length - 1)
        : apiFreeBase;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$cleanBase$cleanPath';
  }

  static const String appName = 'JumpUp';
  static const String appVersion = '1.0.0';
  static const String company = 'Universidad UTE';
}
