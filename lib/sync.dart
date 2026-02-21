import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'models.dart';

class RecoveryDto {
  RecoveryDto({required this.payload});
  final Map<String, dynamic> payload;

  factory RecoveryDto.fromModel(RecoveryData data) => RecoveryDto(payload: data.toJson());
  RecoveryData toModel() => RecoveryData.fromJson(payload);

  String toRawJson() => jsonEncode(payload);
  factory RecoveryDto.fromRawJson(String raw) => RecoveryDto(payload: jsonDecode(raw) as Map<String, dynamic>);
}

abstract class RecoveryRepository {
  Future<RecoveryData?> pull();
  Future<void> push(RecoveryData data);
}

class RecoveryApiClient {
  RecoveryApiClient({required this.baseUrl, this.authToken});

  final String baseUrl;
  final String? authToken;

  Future<void> putRecovery(RecoveryDto dto) async {
    debugPrint('[sync] PUT $baseUrl/recovery payload=${dto.toRawJson()}');
    // TODO: implement real HTTP client + auth headers.
  }

  Future<RecoveryDto?> getRecovery() async {
    debugPrint('[sync] GET $baseUrl/recovery');
    // TODO: implement real HTTP client + DTO decoding.
    return null;
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
