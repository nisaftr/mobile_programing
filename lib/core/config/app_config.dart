import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  static String get apiBaseUrl => _env(
    'API_BASE_URL',
    const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000',
    ),
  );

  static String get websocketUrl => _env(
    'WS_URL',
    const String.fromEnvironment(
      'WS_URL',
      defaultValue: 'ws://10.0.2.2:8000/ws/monitoring',
    ),
  );

  static bool get useMock => _envBool(
    'USE_MOCK',
    const bool.fromEnvironment('USE_MOCK', defaultValue: true),
  );

  static int get mockDelayMs =>
      int.tryParse(_env('MOCK_DELAY_MS', '700')) ?? 700;

  static Duration get mockDelay => Duration(milliseconds: mockDelayMs);

  static String _env(String key, String fallback) {
    if (!dotenv.isInitialized) return fallback;
    final value = dotenv.maybeGet(key);
    return (value == null || value.isEmpty) ? fallback : value;
  }

  static bool _envBool(String key, bool fallback) {
    final value = _env(key, fallback.toString()).toLowerCase();
    return value == 'true' || value == '1';
  }
}
