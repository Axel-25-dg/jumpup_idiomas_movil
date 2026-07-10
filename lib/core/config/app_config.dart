import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    final value = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api/';
    return value.endsWith('/') ? value : '$value/';
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
