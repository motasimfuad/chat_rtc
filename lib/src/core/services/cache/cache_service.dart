import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static SharedPreferences? _cache;

  static Future<void> init() async {
    _cache = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    await _cache?.setString(key, value);
  }

  static String? getString(String key) {
    return _cache?.getString(key);
  }

  static Future<void> remove(String key) async {
    await _cache?.remove(key);
  }

  static Future<void> clear() async {
    await _cache?.clear();
  }
}
