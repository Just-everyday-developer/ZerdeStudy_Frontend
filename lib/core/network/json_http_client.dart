import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

typedef JsonMap = Map<String, dynamic>;

class JsonHttpClient {
  JsonHttpClient({
    required http.Client client,
    required Uri Function(String path) uriResolver,
  }) : _client = client,
       _uriResolver = uriResolver;

  final http.Client _client;
  final Uri Function(String path) _uriResolver;

  Future<JsonMap> getJson(
    String path, {
    Map<String, String> headers = const <String, String>{},
    Map<String, String>? queryParameters,
  }) async {
    final response = await _send(
      () => _client.get(
        _resolveUri(path, queryParameters: queryParameters),
        headers: headers,
      ),
    );
    return _decodeJsonMap(response);
  }

  Future<List<JsonMap>> getJsonList(
    String path, {
    Map<String, String> headers = const <String, String>{},
    Map<String, String>? queryParameters,
  }) async {
    final response = await _send(
      () => _client.get(
        _resolveUri(path, queryParameters: queryParameters),
        headers: headers,
      ),
    );
    return _decodeJsonList(response);
  }

  Future<JsonMap> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final response = await _send(
      () => _client.post(
        _uriResolver(path),
        headers: <String, String>{
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
    );
    return _decodeJsonMap(response);
  }

  Future<JsonMap> putJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final response = await _send(
      () => _client.put(
        _uriResolver(path),
        headers: <String, String>{
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
    );
    return _decodeJsonMap(response);
  }

  Future<void> postEmpty(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const <String, String>{},
  }) async {
    await _send(
      () => _client.post(
        _uriResolver(path),
        headers: <String, String>{
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
    );
  }

  Future<void> deleteEmpty(
    String path, {
    Map<String, String> headers = const <String, String>{},
  }) async {
    await _send(() => _client.delete(_uriResolver(path), headers: headers));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      throw _exceptionFromResponse(response);
    } on ApiException {
      rethrow;
    } catch (_) {
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

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
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
