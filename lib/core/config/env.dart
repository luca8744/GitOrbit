import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static bool _loaded = false;

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
      _loaded = true;
    } catch (e) {
      debugPrint('dotenv: Failed to load .env, trying env.config...');
      try {
        await dotenv.load(fileName: "env.config");
        _loaded = true;
      } catch (e2) {
        debugPrint('dotenv: Failed to load env.config too: $e2');
        _loaded = false;
      }
    }
  }

  static String get apiUrl => _loaded ? (dotenv.env['API_URL'] ?? '') : '';
  static String get apiKey => _loaded ? (dotenv.env['API_KEY'] ?? '') : '';
}
