import '../../../../core/network/json_http_client.dart';
import '../models/backend_course_dto.dart';
import '../models/backend_lesson_dto.dart';
import '../models/backend_module_dto.dart';
import '../models/backend_course_query.dart';
import '../models/backend_practice_dto.dart';
import '../models/backend_quiz_dto.dart';
import '../models/backend_review_dto.dart';
import '../models/backend_streak_dto.dart';

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

  Future<BackendCourseDto> createCourse({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final json = await _client.postJson(
      '/api/v1/course',
      headers: _authHeaders(accessToken),
      body: body,
    );

    return BackendCourseDto.fromJson(json);
  }

  Future<BackendCourseDto> updateCourse({
    required String accessToken,
    required String courseId,
    required Map<String, dynamic> body,
  }) async {
    final json = await _client.putJson(
      '/api/v1/course/${courseId.trim()}',
      headers: _authHeaders(accessToken),
      body: body,
    );

    return BackendCourseDto.fromJson(json);
  }

  Future<void> deleteCourse({
    required String accessToken,
    required String courseId,
  }) {
    return _client.deleteEmpty(
      '/api/v1/course/${courseId.trim()}',
      headers: _authHeaders(accessToken),
    );
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

  Future<BackendModuleDto> createModule({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final json = await _client.postJson(
      '/api/v1/module',
      headers: _authHeaders(accessToken),
      body: body,
    );

    return BackendModuleDto.fromJson(json);
  }

  Future<BackendModuleDto> updateModule({
    required String accessToken,
    required String moduleId,
    required Map<String, dynamic> body,
  }) async {
    final json = await _client.putJson(
      '/api/v1/module/${moduleId.trim()}',
      headers: _authHeaders(accessToken),
      body: body,
    );

    return BackendModuleDto.fromJson(json);
  }

  Future<void> deleteModule({
    required String accessToken,
    required String moduleId,
  }) {
    return _client.deleteEmpty(
      '/api/v1/module/${moduleId.trim()}',
      headers: _authHeaders(accessToken),
    );
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

  Future<BackendLessonDto> fetchLessonById({
    required String accessToken,
    required String lessonId,
  }) async {
    final json = await _client.getJson(
      '/api/v1/lesson/${lessonId.trim()}',
      headers: _authHeaders(accessToken),
    );

    return BackendLessonDto.fromJson(json);
  }

  Future<BackendLessonDto> createLesson({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final json = await _client.postJson(
      '/api/v1/lesson',
      headers: _authHeaders(accessToken),
      body: body,
    );

    return BackendLessonDto.fromJson(json);
  }

  Future<BackendLessonDto> updateLesson({
    required String accessToken,
    required String lessonId,
    required Map<String, dynamic> body,
  }) async {
    final json = await _client.putJson(
      '/api/v1/lesson/${lessonId.trim()}',
      headers: _authHeaders(accessToken),
      body: body,
    );

    return BackendLessonDto.fromJson(json);
  }

  Future<BackendPracticeDto> fetchPracticeById({
    required String accessToken,
    required String practiceId,
  }) async {
    final json = await _client.getJson(
      '/api/v1/practice/${practiceId.trim()}',
      headers: _authHeaders(accessToken),
    );

    return BackendPracticeDto.fromJson(json);
  }

  Future<BackendPracticeDto> fetchPracticeByLessonId({
    required String accessToken,
    required String lessonId,
  }) async {
    final json = await _client.getJson(
      '/api/v1/practice',
      headers: _authHeaders(accessToken),
      queryParameters: <String, String>{'lesson_id': lessonId.trim()},
    );

    return BackendPracticeDto.fromJson(json);
  }

  Future<BackendPracticeDto> createPractice({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final json = await _client.postJson(
      '/api/v1/practice',
      headers: _authHeaders(accessToken),
      body: body,
    );

    return BackendPracticeDto.fromJson(json);
  }

  Future<BackendPracticeDto> updatePractice({
    required String accessToken,
    required String practiceId,
    required Map<String, dynamic> body,
  }) async {
    final json = await _client.putJson(
      '/api/v1/practice/${practiceId.trim()}',
      headers: _authHeaders(accessToken),
      body: body,
    );

    return BackendPracticeDto.fromJson(json);
  }

  Future<void> deletePractice({
    required String accessToken,
    required String practiceId,
  }) {
    return _client.deleteEmpty(
      '/api/v1/practice/${practiceId.trim()}',
      headers: _authHeaders(accessToken),
    );
  }

  Future<List<BackendQuizDto>> fetchQuizzesByLessonId({
    required String accessToken,
    required String lessonId,
  }) async {
    final json = await _client.getJsonList(
      '/api/v1/lesson/${lessonId.trim()}/quiz',
      headers: _authHeaders(accessToken),
    );

    return json.map(BackendQuizDto.fromJson).toList(growable: false);
  }

  Future<BackendQuizDto> createQuiz({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final json = await _client.postJson(
      '/api/v1/quiz',
      headers: _authHeaders(accessToken),
      body: body,
    );

    return BackendQuizDto.fromJson(json);
  }

  Future<BackendQuizDto> updateQuiz({
    required String accessToken,
    required String quizId,
    required Map<String, dynamic> body,
  }) async {
    final json = await _client.putJson(
      '/api/v1/quiz/${quizId.trim()}',
      headers: _authHeaders(accessToken),
      body: body,
    );

    return BackendQuizDto.fromJson(json);
  }

  Future<void> deleteQuiz({
    required String accessToken,
    required String quizId,
  }) {
    return _client.deleteEmpty(
      '/api/v1/quiz/${quizId.trim()}',
      headers: _authHeaders(accessToken),
    );
  }

  Future<BackendQuizAnswerResultDto> submitQuizAnswer({
    required String accessToken,
    required String quizId,
    required int selectedAnswerIndex,
  }) async {
    final json = await _client.postJson(
      '/api/v1/quiz/${quizId.trim()}/answer',
      headers: _authHeaders(accessToken),
      body: <String, dynamic>{'selected_answer_index': selectedAnswerIndex},
    );

    return BackendQuizAnswerResultDto.fromJson(json);
  }

  Future<BackendStreakDto> fetchStreak({required String accessToken}) async {
    final json = await _client.getJson(
      '/api/v1/streak',
      headers: _authHeaders(accessToken),
    );

    return BackendStreakDto.fromJson(json);
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

  Future<BackendReviewDto> fetchReviewById({
    required String accessToken,
    required String reviewId,
  }) async {
    final json = await _client.getJson(
      '/api/v1/review/${reviewId.trim()}',
      headers: _authHeaders(accessToken),
    );
    return BackendReviewDto.fromJson(json);
  }

  Future<List<BackendReviewDto>> fetchReviewsByCourseId({
    required String accessToken,
    required String courseId,
  }) async {
    final json = await _client.getJsonList(
      '/api/v1/course/review/${courseId.trim()}',
      headers: _authHeaders(accessToken),
    );
    return json.map(BackendReviewDto.fromJson).toList(growable: false);
  }

  Future<BackendReviewDto> createReview({
    required String accessToken,
    required BackendCreateReviewRequest request,
  }) async {
    final json = await _client.postJson(
      '/api/v1/review',
      headers: _authHeaders(accessToken),
      body: request.toJson(),
    );
    return BackendReviewDto.fromJson(json);
  }

  Future<BackendReviewDto> updateReview({
    required String accessToken,
    required String reviewId,
    required BackendUpdateReviewRequest request,
  }) async {
    final json = await _client.putJson(
      '/api/v1/review/${reviewId.trim()}',
      headers: _authHeaders(accessToken),
      body: request.toJson(),
    );
    return BackendReviewDto.fromJson(json);
  }

  Future<void> deleteReview({
    required String accessToken,
    required String reviewId,
  }) async {
    await _client.deleteEmpty(
      '/api/v1/review/${reviewId.trim()}',
      headers: _authHeaders(accessToken),
    );
  }

  Map<String, String> _authHeaders(String accessToken) {
    return <String, String>{'Authorization': 'Bearer ${accessToken.trim()}'};
  }
}
