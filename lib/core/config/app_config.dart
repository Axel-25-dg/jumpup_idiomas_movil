import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';

  static String get appName => 'JumpUp UTE';
  static String get appVersion => '1.0.0';
}
