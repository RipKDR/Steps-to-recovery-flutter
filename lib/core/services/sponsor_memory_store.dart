import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sponsor_models.dart';
import 'encryption_service.dart';

/// Encrypted 3-tier memory store backed by a JSON file in app documents.
/// Falls back to SharedPreferences on web (no file system).
class SponsorMemoryStore {
  static const String _webKey = 'sponsor_memory_json';
  static const String _fileName = 'sponsor_memory.json';
  static const int _maxDigest = 20;
  static const int _maxLongTerm = 50;
  static const int _maxSessionExtractionsPerDigest = 3;

  SponsorMemoryFile _data = SponsorMemoryFile.empty();

  List<SponsorMemory> get session => List.unmodifiable(_data.session);
  List<SponsorMemory> get digest => List.unmodifiable(_data.digest);
  List<SponsorMemory> get longterm => List.unmodifiable(_data.longterm);

  Future<void> initialize() async {
    _data = await _read();
  }

  Future<void> addToSession(SponsorMemory memory) async {
    _data = _data.copyWith(session: [..._data.session, memory]);
    await _write(_data);
  }

  /// Extracts up to [_maxSessionExtractionsPerDigest] entries from session
  /// into digest, then clears session. Enforces max digest size.
  Future<void> digestSession() async {
    if (_data.session.isEmpty) return;

    final extractions =
        _data.session.take(_maxSessionExtractionsPerDigest).toList();

    var newDigest = [..._data.digest, ...extractions];
    if (newDigest.length > _maxDigest) {
      newDigest = newDigest.sublist(newDigest.length - _maxDigest);
    }

    _data = _data.copyWith(session: [], digest: newDigest);
    await _write(_data);
  }

  /// Distills digest into long-term, marks distilledAt, prunes to max.
  Future<void> distillToLongTerm() async {
    if (_data.digest.isEmpty) return;

    final now = DateTime.now();
    final promoted = _data.digest
        .map((m) => SponsorMemory(
              id: m.id,
              category: m.category,
              summary: m.summary,
              createdAt: m.createdAt,
              distilledAt: now,
            ))
        .toList();

    var newLongterm = [..._data.longterm, ...promoted];
    if (newLongterm.length > _maxLongTerm) {
      newLongterm = newLongterm.sublist(newLongterm.length - _maxLongTerm);
    }

    _data = _data.copyWith(digest: [], longterm: newLongterm);
    await _write(_data);
  }

  /// Deletes a memory from any tier by id.
  Future<void> deleteMemory(String id) async {
    _data = _data.copyWith(
      session: _data.session.where((m) => m.id != id).toList(),
      digest: _data.digest.where((m) => m.id != id).toList(),
      longterm: _data.longterm.where((m) => m.id != id).toList(),
    );
    await _write(_data);
  }

  // ── Private ──────────────────────────────────────────────────────────────

  Future<SponsorMemoryFile> _read() async {
    try {
      final raw = await _readRaw();
      if (raw == null || raw.isEmpty) return SponsorMemoryFile.empty();
      final decrypted = EncryptionService().decrypt(raw);
      return SponsorMemoryFile.fromJson(
          jsonDecode(decrypted) as Map<String, dynamic>);
    } catch (_) {
      return SponsorMemoryFile.empty();
    }
  }

  Future<void> _write(SponsorMemoryFile data) async {
    final json = jsonEncode(data.toJson());
    final encrypted = EncryptionService().encrypt(json);
    await _writeRaw(encrypted);
  }

  Future<String?> _readRaw() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_webKey);
    }
    final file = await _file();
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  Future<void> _writeRaw(String content) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_webKey, content);
      return;
    }
    final file = await _file();
    await file.writeAsString(content, flush: true);
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }
}
