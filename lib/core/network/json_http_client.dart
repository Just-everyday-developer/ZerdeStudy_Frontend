import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

typedef JsonMap = Map<String, dynamic>;

class JsonHttpClient {
  JsonHttpClient({
    required http.Client client,
    required Uri Function(String path) uriResolver,
    this.onGetFreshToken,
  }) : _client = client,
       _uriResolver = uriResolver;

  final http.Client _client;
  final Uri Function(String path) _uriResolver;

  /// Called on a 401 response. Should refresh the session and return the new
  /// Bearer token value, or null if refresh is not possible.
  final Future<String?> Function()? onGetFreshToken;

  Future<JsonMap> getJson(
    String path, {
    Map<String, String> headers = const <String, String>{},
    Map<String, String>? queryParameters,
  }) async {
    final response = await _sendRetryable(
      factory: (h) => _client.get(
        _resolveUri(path, queryParameters: queryParameters),
        headers: h,
      ),
      headers: headers,
    );
    return _decodeJsonMap(response);
  }

  Future<List<JsonMap>> getJsonList(
    String path, {
    Map<String, String> headers = const <String, String>{},
    Map<String, String>? queryParameters,
  }) async {
    final response = await _sendRetryable(
      factory: (h) => _client.get(
        _resolveUri(path, queryParameters: queryParameters),
        headers: h,
      ),
      headers: headers,
    );
    return _decodeJsonList(response);
  }

  Future<JsonMap> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final encodedBody = jsonEncode(body ?? const <String, dynamic>{});
    final response = await _sendRetryable(
      factory: (h) => _client.post(
        _uriResolver(path),
        headers: <String, String>{'Content-Type': 'application/json', ...h},
        body: encodedBody,
      ),
      headers: headers,
    );
    return _decodeJsonMap(response);
  }

  Future<JsonMap> postMultipart(
    String path, {
    Map<String, String> headers = const <String, String>{},
    Map<String, String> fields = const <String, String>{},
    required String fileField,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final response = await _sendRetryable(
      factory: (h) async {
        final request = http.MultipartRequest('POST', _uriResolver(path));
        request.headers.addAll(h);
        request.fields.addAll(fields);
        request.files.add(
          http.MultipartFile.fromBytes(fileField, fileBytes, filename: fileName),
        );
        final streamed = await request.send();
        return http.Response.fromStream(streamed);
      },
      headers: headers,
    );
    return _decodeJsonMap(response);
  }

  Future<JsonMap> putJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final encodedBody = jsonEncode(body ?? const <String, dynamic>{});
    final response = await _sendRetryable(
      factory: (h) => _client.put(
        _uriResolver(path),
        headers: <String, String>{'Content-Type': 'application/json', ...h},
        body: encodedBody,
      ),
      headers: headers,
    );
    return _decodeJsonMap(response);
  }

  Future<JsonMap> patchJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final encodedBody = jsonEncode(body ?? const <String, dynamic>{});
    final response = await _sendRetryable(
      factory: (h) => _client.patch(
        _uriResolver(path),
        headers: <String, String>{'Content-Type': 'application/json', ...h},
        body: encodedBody,
      ),
      headers: headers,
    );
    return _decodeJsonMap(response);
  }

  Future<void> postEmpty(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final encodedBody = jsonEncode(body ?? const <String, dynamic>{});
    await _sendRetryable(
      factory: (h) => _client.post(
        _uriResolver(path),
        headers: <String, String>{'Content-Type': 'application/json', ...h},
        body: encodedBody,
      ),
      headers: headers,
    );
  }

  Future<void> patchEmpty(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final encodedBody = jsonEncode(body ?? const <String, dynamic>{});
    await _sendRetryable(
      factory: (h) => _client.patch(
        _uriResolver(path),
        headers: <String, String>{'Content-Type': 'application/json', ...h},
        body: encodedBody,
      ),
      headers: headers,
    );
  }

  Future<void> deleteEmpty(
    String path, {
    Map<String, String> headers = const <String, String>{},
  }) async {
    await _sendRetryable(
      factory: (h) => _client.delete(_uriResolver(path), headers: h),
      headers: headers,
    );
  }

  Future<http.Response> _sendRetryable({
    required Future<http.Response> Function(Map<String, String> headers) factory,
    required Map<String, String> headers,
  }) async {
    try {
      var response = await factory(headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      if (response.statusCode == 401 && onGetFreshToken != null) {
        final newToken = await onGetFreshToken!();
        if (newToken != null) {
          final fresh = Map<String, String>.from(headers)
            ..['Authorization'] = 'Bearer $newToken';
          response = await factory(fresh);
          if (response.statusCode >= 200 && response.statusCode < 300) {
            return response;
          }
        }
      }
      throw _exceptionFromResponse(response);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      debugPrint('[JsonHttpClient] network error: $e\n$st');
      throw const ApiException(
        statusCode: 0,
        code: 'network_error',
        message: 'Unable to connect to the server.',
      );
    }
  }

  JsonMap _decodeJsonMap(http.Response response) {
    if (response.body.trim().isEmpty) {
      return const <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      throw const ApiException(
        statusCode: 0,
        code: 'invalid_response',
        message: 'Unexpected response payload.',
      );
    }

    throw const ApiException(
      statusCode: 0,
      code: 'invalid_response',
      message: 'Unexpected response payload.',
    );
  }

  List<JsonMap> _decodeJsonList(http.Response response) {
    if (response.body.trim().isEmpty) {
      return const <JsonMap>[];
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    throw const ApiException(
      statusCode: 0,
      code: 'invalid_response',
      message: 'Unexpected response payload.',
    );
  }

  Uri _resolveUri(String path, {Map<String, String>? queryParameters}) {
    final baseUri = _uriResolver(path);
    if (queryParameters == null || queryParameters.isEmpty) {
      return baseUri;
    }

    return baseUri.replace(
      queryParameters: <String, String>{
        ...baseUri.queryParameters,
        ...queryParameters,
      },
    );
  }

  ApiException _exceptionFromResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      return ApiException(
        statusCode: response.statusCode,
        code: 'request_failed',
        message: 'Request failed with status ${response.statusCode}.',
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          return ApiException(
            statusCode: response.statusCode,
            code: '${error['code'] ?? 'request_failed'}',
            message: '${error['message'] ?? 'Request failed.'}',
          );
        }
      }
    } catch (_) {
      // Fall through to generic error below.
    }

    return ApiException(
      statusCode: response.statusCode,
      code: 'request_failed',
      message: 'Request failed with status ${response.statusCode}.',
    );
  }
}
