import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class LocalStore {
  static const _key = 'recovery_data_v1';
  static const _lastSyncAtKey = 'recovery_last_sync_at_v1';
  static const _lastSyncErrorKey = 'recovery_last_sync_error_v1';

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

  Future<void> saveSyncStatus({
    String? lastSyncAtIso,
    String? lastSyncError,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (lastSyncAtIso != null) {
      await prefs.setString(_lastSyncAtKey, lastSyncAtIso);
    }
    if (lastSyncError != null) {
      await prefs.setString(_lastSyncErrorKey, lastSyncError);
    }
  }

  Future<({String? lastSyncAtIso, String? lastSyncError})>
  loadSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      lastSyncAtIso: prefs.getString(_lastSyncAtKey),
      lastSyncError: prefs.getString(_lastSyncErrorKey),
    );
  }
}
