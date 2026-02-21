import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class LocalStore {
  static const _key = 'recovery_data_v1';

  Future<RecoveryData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return RecoveryData.initial();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return RecoveryData.fromJson(json);
    } catch (_) {
      return RecoveryData.initial();
    }
  }

  Future<void> save(RecoveryData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }
}
