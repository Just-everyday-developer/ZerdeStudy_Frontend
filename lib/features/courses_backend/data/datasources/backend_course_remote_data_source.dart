import '../../../../core/network/json_http_client.dart';
import '../models/backend_course_dto.dart';
import '../models/backend_lesson_dto.dart';
import '../models/backend_module_dto.dart';
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

  Future<BackendCourseDto> fetchCourseById({
    required String accessToken,
    required String courseId,
  }) async {
    final json = await _client.getJson(
      '/api/v1/course/${courseId.trim()}',
      headers: _authHeaders(accessToken),
    );

    return BackendCourseDto.fromJson(json);
  }

  Future<List<BackendModuleDto>> fetchModules({
    required String accessToken,
    required String localeCode,
    int limit = 200,
  }) async {
    final json = await _client.getJsonList(
      '/api/v1/module',
      headers: _authHeaders(accessToken),
      queryParameters: <String, String>{
        'locale': localeCode.trim().isEmpty ? 'en' : localeCode.trim(),
        if (limit > 0) 'limit': '$limit',
      },
    );

    return json.map(BackendModuleDto.fromJson).toList(growable: false);
  }

  Future<List<BackendLessonDto>> fetchLessonsForModule({
    required String accessToken,
    required String moduleId,
  }) async {
    final json = await _client.getJsonList(
      '/api/v1/module/lesson/${moduleId.trim()}',
      headers: _authHeaders(accessToken),
    );

    return json.map(BackendLessonDto.fromJson).toList(growable: false);
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

  Future<JsonMap> createSubscription({
    required String accessToken,
    required Map<String, dynamic> body,
  }) {
    return _client.postJson(
      '/api/v1/course/enrollment',
      headers: _authHeaders(accessToken),
      body: body,
    );
  }

  Future<JsonMap> createCoursePoint({
    required String accessToken,
    required Map<String, dynamic> body,
  }) {
    return _client.postJson(
      '/api/v1/point',
      headers: _authHeaders(accessToken),
      body: body,
    );
  }

  Future<JsonMap> updateCoursePoint({
    required String accessToken,
    required String pointId,
    required Map<String, dynamic> body,
  }) {
    return _client.putJson(
      '/api/v1/point/${pointId.trim()}',
      headers: _authHeaders(accessToken),
      body: body,
    );
  }

  Future<void> deleteCoursePoint({
    required String accessToken,
    required String pointId,
  }) {
    return _client.deleteEmpty(
      '/api/v1/point/${pointId.trim()}',
      headers: _authHeaders(accessToken),
    );
  }

  Future<List<JsonMap>> getCoursePointByCourseId({
    required String accessToken,
    required String courseId,
  }) {
    return _client.getJsonList(
      '/api/v1/leaderboard/${courseId.trim()}',
      headers: _authHeaders(accessToken),
    );
  }

  Future<JsonMap> createOrder({
    required String accessToken,
    required Map<String, dynamic> body,
  }) {
    return _client.postJson(
      '/api/v1/order',
      headers: _authHeaders(accessToken),
      body: body,
    );
  }

  Map<String, String> _authHeaders(String accessToken) {
    return <String, String>{'Authorization': 'Bearer ${accessToken.trim()}'};
  }
}
