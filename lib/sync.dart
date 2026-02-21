import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class RecoveryDto {
  RecoveryDto({required this.payload});
  final Map<String, dynamic> payload;

  factory RecoveryDto.fromModel(RecoveryData data) =>
      RecoveryDto(payload: data.toJson());
  RecoveryData toModel() => RecoveryData.fromJson(payload);

  String toRawJson() => jsonEncode(payload);
  factory RecoveryDto.fromRawJson(String raw) =>
      RecoveryDto(payload: jsonDecode(raw) as Map<String, dynamic>);
}

enum SyncErrorCode { unauthorized, server, network, unknown }

class SyncException implements Exception {
  SyncException(this.code, this.message);
  final SyncErrorCode code;
  final String message;

  @override
  String toString() => 'SyncException($code): $message';
}

abstract class RecoveryRepository {
  Future<RecoveryData?> pull();
  Future<void> push(RecoveryData data);
}

class RecoveryApiClient {
  RecoveryApiClient({
    required this.baseUrl,
    this.authToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final String? authToken;
  final http.Client _client;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null && authToken!.isNotEmpty)
      'Authorization': 'Bearer $authToken',
  };

  Future<void> putRecovery(RecoveryDto dto) async {
    try {
      final res = await _client.put(
        Uri.parse('$baseUrl/recovery'),
        headers: _headers,
        body: dto.toRawJson(),
      );

      if (res.statusCode == 401 || res.statusCode == 403) {
        throw SyncException(
          SyncErrorCode.unauthorized,
          'Auth failed (${res.statusCode})',
        );
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw SyncException(
          SyncErrorCode.server,
          'Push failed: ${res.statusCode} ${res.body}',
        );
      }
    } on http.ClientException catch (e) {
      throw SyncException(SyncErrorCode.network, e.message);
    }
  }

  Future<RecoveryDto?> getRecovery() async {
    try {
      final res = await _client.get(
        Uri.parse('$baseUrl/recovery'),
        headers: _headers,
      );

      if (res.statusCode == 404) return null;
      if (res.statusCode == 401 || res.statusCode == 403) {
        throw SyncException(
          SyncErrorCode.unauthorized,
          'Auth failed (${res.statusCode})',
        );
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw SyncException(
          SyncErrorCode.server,
          'Pull failed: ${res.statusCode} ${res.body}',
        );
      }

      if (res.body.isEmpty) return null;
      return RecoveryDto.fromRawJson(res.body);
    } on http.ClientException catch (e) {
      throw SyncException(SyncErrorCode.network, e.message);
    }
  }
}

class RemoteRecoveryRepository implements RecoveryRepository {
  RemoteRecoveryRepository(this.client);

  final RecoveryApiClient client;

  @override
  Future<RecoveryData?> pull() async {
    final dto = await client.getRecovery();
    return dto?.toModel();
  }

  @override
  Future<void> push(RecoveryData data) async {
    await client.putRecovery(RecoveryDto.fromModel(data));
  }
}

class PendingSyncQueue {
  static const _queueKey = 'pending_sync_queue_v1';

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_queueKey) ?? <String>[];
  }

  Future<void> save(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_queueKey, items);
  }

  Future<void> enqueue(RecoveryData data) async {
    final list = await load();
    list.add(jsonEncode(data.toJson()));
    await save(list);
  }

  Future<void> clear() => save(<String>[]);
}

Future<T> withRetry<T>(Future<T> Function() task, {int attempts = 3}) async {
  Object? lastError;
  for (var i = 0; i < attempts; i++) {
    try {
      return await task();
    } catch (e) {
      lastError = e;
      await Future<void>.delayed(Duration(milliseconds: 250 * (i + 1)));
    }
  }
  throw lastError ?? Exception('Unknown retry failure');
}
