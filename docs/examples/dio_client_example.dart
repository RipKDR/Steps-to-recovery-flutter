// Example: Using Dio for API calls
// Replace or supplement your http package usage

import 'package:dio/dio.dart';
import '../../core/services/logger_service.dart';

/// Dio client for API calls
/// 
/// Usage:
/// ```dart
/// final apiClient = DioClient();
/// final response = await apiClient.get('/users');
/// ```
class DioClient {
  late final Dio _dio;

  DioClient({
    String? baseUrl,
    String? authToken,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'https://api.example.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
    ));

    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => LoggerService().debug('Dio: $obj'),
    ));

    // Add error handling interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (error.type == DioExceptionType.connectionTimeout) {
          LoggerService().error('Connection timeout', error: error);
        } else if (error.type == DioExceptionType.badResponse) {
          LoggerService().error(
            'API Error: ${error.response?.statusCode}',
            error: error,
          );
        }
        return handler.next(error);
      },
    ));
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters, options: options);
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    void Function(int count, int total)? onReceiveProgress,
  }) async {
    return await _dio.download(urlPath, savePath, onReceiveProgress: onReceiveProgress);
  }

  /// Cancel all requests
  void cancelAll() {
    _dio.close();
  }
}

// Example usage in a service:
//
// class MyApiService {
//   final DioClient _client;
//
//   MyApiService() : _client = DioClient(
//     baseUrl: 'https://api.example.com',
//     authToken: 'your_token',
//   );
//
//   Future<List<Meeting>> fetchMeetings() async {
//     try {
//       final response = await _client.get('/meetings');
//       return (response.data as List)
//           .map((json) => Meeting.fromJson(json))
//           .toList();
//     } on DioException catch (e) {
//       LoggerService().error('Failed to fetch meetings', error: e);
//       rethrow;
//     }
//   }
// }
