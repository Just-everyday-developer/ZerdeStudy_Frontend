import '../../../../core/network/json_http_client.dart';
import '../models/backend_achievement_dto.dart';
import '../models/backend_code_attempt_dto.dart';
import '../models/backend_course_dto.dart';
import '../models/backend_progress_dto.dart';
import '../models/backend_lesson_dto.dart';
import '../models/backend_module_dto.dart';
import '../models/backend_notification_dto.dart';
import '../models/backend_course_query.dart';
import '../models/backend_practice_dto.dart';
import '../models/backend_quiz_dto.dart';
import '../models/backend_review_dto.dart';
import '../models/backend_streak_dto.dart';
import '../models/backend_student_statistics_dto.dart';

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

  Future<BackendLessonDto> uploadLessonVideo({
    required String accessToken,
    required String lessonId,
    required List<int> videoBytes,
    required String fileName,
    String? videoObjectKey,
  }) async {
    final fields = <String, String>{
      if (videoObjectKey != null && videoObjectKey.trim().isNotEmpty)
        'video_object_key': videoObjectKey.trim(),
    };
    final json = await _client.postMultipart(
      '/api/v1/lesson/${lessonId.trim()}/video',
      headers: _authHeaders(accessToken),
      fields: fields,
      fileField: 'video',
      fileBytes: videoBytes,
      fileName: fileName.trim().isEmpty ? 'lesson-video.mp4' : fileName.trim(),
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

  /// Lists all practice tasks attached to a lesson via curriculum-service's
  /// `GET /lesson/:id/practice` (replaced the old `GET /practice?lesson_id=`
  /// single-object lookup, which now 404s).
  Future<List<BackendPracticeDto>> fetchPracticesForLesson({
    required String accessToken,
    required String lessonId,
  }) async {
    final items = await _client.getJsonList(
      '/api/v1/lesson/${lessonId.trim()}/practice',
      headers: _authHeaders(accessToken),
    );

    return items.map(BackendPracticeDto.fromJson).toList(growable: false);
  }

  Future<BackendPracticeDto?> fetchPracticeByLessonId({
    required String accessToken,
    required String lessonId,
  }) async {
    final items = await fetchPracticesForLesson(
      accessToken: accessToken,
      lessonId: lessonId,
    );
    if (items.isEmpty) {
      return null;
    }

    final sorted = items.toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return sorted.first;
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

  /// Runs or submits code for a practice task via curriculum-service's
  /// authoritative code-attempt flow (`POST /api/v1/practice/:id/run`).
  /// [runType] is either `"run"` (draft, no XP) or `"submit"` (graded against
  /// the task's expected output, awards XP on first pass).
  Future<BackendCodeAttemptResultDto> runPractice({
    required String accessToken,
    required String practiceId,
    required String courseId,
    required String lessonId,
    required String runType,
    required String language,
    required String code,
  }) async {
    final json = await _client.postJson(
      '/api/v1/practice/${practiceId.trim()}/run',
      headers: _authHeaders(accessToken),
      body: <String, dynamic>{
        'course_id': courseId.trim(),
        'lesson_id': lessonId.trim(),
        'run_type': runType,
        'language': language,
        'code': code,
      },
    );

    return BackendCodeAttemptResultDto.fromJson(json);
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

  /// Issues (or fetches existing) PDF certificate for [courseId].
  /// Returns a map with: certificate_number, issued_at, completed_at, download_url.
  Future<JsonMap> issueCertificate({
    required String accessToken,
    required String courseId,
  }) {
    return _client.getJson(
      '/api/v1/course/${courseId.trim()}/certificate',
      headers: _authHeaders(accessToken),
    );
  }

  Future<BackendStreakDto> fetchStreak({required String accessToken}) async {
    final json = await _client.getJson(
      '/api/v1/streak',
      headers: _authHeaders(accessToken),
    );

    return BackendStreakDto.fromJson(json);
  }

  /// Fetches the aggregated learning statistics for the signed-in student
  /// (`GET /api/v1/student/statistics`) — a single call that combines XP,
  /// streaks, quiz/practice performance, 30-day activity, topic and
  /// per-course progress, replacing several piecemeal local computations.
  Future<BackendStudentStatisticsDto> fetchStudentStatistics({
    required String accessToken,
  }) async {
    final json = await _client.getJson(
      '/api/v1/student/statistics',
      headers: _authHeaders(accessToken),
    );

    return BackendStudentStatisticsDto.fromJson(json);
  }

  /// Lists in-app notifications for the signed-in user
  /// (`GET /api/v1/notifications?limit=&offset=`).
  Future<BackendNotificationListDto> fetchNotifications({
    required String accessToken,
    int limit = 20,
    int offset = 0,
  }) async {
    final json = await _client.getJson(
      '/api/v1/notifications',
      headers: _authHeaders(accessToken),
      queryParameters: <String, String>{
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    return BackendNotificationListDto.fromJson(json);
  }

  /// Fetches just the unread notification count
  /// (`GET /api/v1/notifications/unread-count`).
  Future<int> fetchUnreadNotificationCount({required String accessToken}) async {
    final json = await _client.getJson(
      '/api/v1/notifications/unread-count',
      headers: _authHeaders(accessToken),
    );

    return (json['unreadCount'] as num?)?.round() ?? 0;
  }

  /// Marks a single notification as read (`PATCH /api/v1/notifications/:id/read`).
  Future<void> markNotificationRead({
    required String accessToken,
    required String notificationId,
  }) {
    return _client.patchJson(
      '/api/v1/notifications/${notificationId.trim()}/read',
      headers: _authHeaders(accessToken),
    );
  }

  /// Marks every notification as read (`PATCH /api/v1/notifications/read-all`).
  Future<void> markAllNotificationsRead({required String accessToken}) {
    return _client.patchJson(
      '/api/v1/notifications/read-all',
      headers: _authHeaders(accessToken),
    );
  }

  /// Deletes a notification (`DELETE /api/v1/notifications/:id`).
  Future<void> deleteNotification({
    required String accessToken,
    required String notificationId,
  }) {
    return _client.deleteEmpty(
      '/api/v1/notifications/${notificationId.trim()}',
      headers: _authHeaders(accessToken),
    );
  }

  /// Marks a lesson complete for the signed-in user and returns the updated
  /// course progress. POST /api/v1/lesson/:id/complete (write-role exempt).
  Future<BackendCourseProgressDto> completeLesson({
    required String accessToken,
    required String lessonId,
  }) async {
    final json = await _client.postJson(
      '/api/v1/lesson/${lessonId.trim()}/complete',
      headers: _authHeaders(accessToken),
    );

    return BackendCourseProgressDto.fromJson(json);
  }

  /// Progress for a single course for the signed-in user.
  Future<BackendCourseProgressDto> fetchCourseProgress({
    required String accessToken,
    required String courseId,
  }) async {
    final json = await _client.getJson(
      '/api/v1/course/${courseId.trim()}/progress',
      headers: _authHeaders(accessToken),
    );

    return BackendCourseProgressDto.fromJson(json);
  }

  Future<BackendCourseProgressDto> fetchCourseProgressForUser({
    required String accessToken,
    required String courseId,
    required String userId,
  }) async {
    final json = await _client.getJson(
      '/api/v1/course/${courseId.trim()}/progress/${userId.trim()}',
      headers: _authHeaders(accessToken),
    );

    return BackendCourseProgressDto.fromJson(json);
  }

  /// Progress across all of the signed-in user's courses.
  Future<List<BackendCourseProgressDto>> fetchAllProgress({
    required String accessToken,
  }) async {
    final json = await _client.getJsonList(
      '/api/v1/progress',
      headers: _authHeaders(accessToken),
    );

    return json.map(BackendCourseProgressDto.fromJson).toList(growable: false);
  }

  Future<List<BackendCourseProgressDto>> fetchAllProgressForUser({
    required String accessToken,
    required String userId,
  }) async {
    final json = await _client.getJsonList(
      '/api/v1/progress/${userId.trim()}',
      headers: _authHeaders(accessToken),
    );

    return json.map(BackendCourseProgressDto.fromJson).toList(growable: false);
  }

  Future<List<BackendAchievementDto>> fetchAchievements({
    required String accessToken,
  }) async {
    final json = await _client.getJsonList(
      '/api/v1/achievements',
      headers: _authHeaders(accessToken),
    );

    return json.map(BackendAchievementDto.fromJson).toList(growable: false);
  }

  Future<List<BackendAchievementDto>> fetchAchievementsForUser({
    required String accessToken,
    required String userId,
  }) async {
    final json = await _client.getJsonList(
      '/api/v1/achievements/${userId.trim()}',
      headers: _authHeaders(accessToken),
    );

    return json.map(BackendAchievementDto.fromJson).toList(growable: false);
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

  Future<List<BackendDictionaryEntryDto>> fetchTags({
    required String accessToken,
  }) {
    return _fetchDictionary('/api/v1/dictionary/tag', accessToken: accessToken);
  }

  Future<List<BackendDictionaryEntryDto>> fetchLocales({
    required String accessToken,
  }) {
    return _fetchDictionary(
      '/api/v1/dictionary/locale',
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

  /// Enrolls [userId] into [courseId]. Idempotent — a second call for the
  /// same pair is handled gracefully (backend returns the existing record).
  Future<void> enrollCourse({
    required String accessToken,
    required String courseId,
    required String userId,
  }) {
    return _client.postJson(
      '/api/v1/course/enrollment',
      headers: _authHeaders(accessToken),
      body: <String, dynamic>{'course_id': courseId, 'user_id': userId},
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
