import '../../../../core/network/json_http_client.dart';
import '../models/backend_course_dto.dart';
import '../models/backend_course_query.dart';

class BackendCourseRemoteDataSource {
  BackendCourseRemoteDataSource(this._client);

  final JsonHttpClient _client;

  Future<List<BackendCourseDto>> fetchCourses({
    required String accessToken,
    BackendCourseQuery query = const BackendCourseQuery(),
  }) async {
    final json = await _client.getJsonList(
      '/api/v1/course',
      headers: _authHeaders(accessToken),
      queryParameters: query.queryParameters,
    );

    return json.map(BackendCourseDto.fromJson).toList(growable: false);
  }

  Future<List<BackendDictionaryEntryDto>> fetchLevels({
    required String accessToken,
  }) {
    return _fetchDictionary(
      '/api/v1/dictionary/level',
      accessToken: accessToken,
    );
  }

  Future<List<BackendDictionaryEntryDto>> fetchTopics({
    required String accessToken,
  }) {
    return _fetchDictionary(
      '/api/v1/dictionary/topic',
      accessToken: accessToken,
    );
  }

  Future<List<BackendDictionaryEntryDto>> fetchDurationCategories({
    required String accessToken,
  }) {
    return _fetchDictionary(
      '/api/v1/dictionary/duration_category',
      accessToken: accessToken,
    );
  }

  Future<List<BackendDictionaryEntryDto>> fetchStatuses({
    required String accessToken,
  }) {
    return _fetchDictionary(
      '/api/v1/dictionary/status',
      accessToken: accessToken,
    );
  }

  Future<List<BackendDictionaryEntryDto>> _fetchDictionary(
    String path, {
    required String accessToken,
  }) async {
    final json = await _client.getJsonList(
      path,
      headers: _authHeaders(accessToken),
    );

    return json.map(BackendDictionaryEntryDto.fromJson).toList(growable: false);
  }

  Map<String, String> _authHeaders(String accessToken) {
    return <String, String>{'Authorization': 'Bearer ${accessToken.trim()}'};
  }
}
