import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_config.dart';

class ChallengeStorage {
  static const _key = 'challenges_v2'; // bump key agar format baru kepakai

  static Future<List<GameConfig>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List list = jsonDecode(raw);
      return list
          .whereType<Map<String, dynamic>>()
          .map<GameConfig>((m) => GameConfig.fromAny(m))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<GameConfig> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toMap()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
