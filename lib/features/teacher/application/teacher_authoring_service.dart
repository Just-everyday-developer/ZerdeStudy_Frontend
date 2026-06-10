import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_controller.dart';
import '../../courses_backend/data/datasources/backend_course_remote_data_source.dart';
import '../../courses_backend/data/models/backend_course_dto.dart';
import '../../courses_backend/data/models/backend_lesson_dto.dart';
import '../../courses_backend/data/models/backend_module_dto.dart';
import '../../courses_backend/presentation/providers/backend_course_providers.dart';
import '../../payment/data/datasources/payment_remote_data_source.dart';
import '../../payment/data/models/order_models.dart';
import '../../payment/presentation/providers/payment_providers.dart';

/// A localized text triple sent to the backend as {en, ru, kk}.
class LocalizedInput {
  const LocalizedInput({this.en = '', this.ru = '', this.kk = ''});

  final String en;
  final String ru;
  final String kk;

  /// Fills empty languages with the first non-empty value so no field is blank.
  Map<String, dynamic> toJson() {
    final fallback = [
      en,
      ru,
      kk,
    ].firstWhere((v) => v.trim().isNotEmpty, orElse: () => '');
    return <String, dynamic>{
      'en': en.trim().isEmpty ? fallback : en.trim(),
      'ru': ru.trim().isEmpty ? fallback : ru.trim(),
      'kk': kk.trim().isEmpty ? fallback : kk.trim(),
    };
  }

  bool get isEmpty =>
      en.trim().isEmpty && ru.trim().isEmpty && kk.trim().isEmpty;
}

/// Wraps the backend CRUD endpoints for teacher course authoring.
/// All methods throw on failure (callers surface the error).
class TeacherAuthoringService {
  TeacherAuthoringService({
    required BackendCourseRemoteDataSource remote,
    required PaymentRemoteDataSource paymentRemote,
    required String accessToken,
    required String authorId,
  }) : _remote = remote,
       _paymentRemote = paymentRemote,
       _accessToken = accessToken,
       _authorId = authorId;

  final BackendCourseRemoteDataSource _remote;
  final PaymentRemoteDataSource _paymentRemote;
  final String _accessToken;
  final String _authorId;

  String get authorId => _authorId;

  Future<BackendCourseDto> createCourse({
    required String title,
    required String subtitle,
    required String description,
    required int expectedHours,
    required bool hasCertificate,
    required List<String> learningOutcomes,
    required String levelId,
    required String statusId,
    required String durationCategoryId,
    required String topicId,
    List<String> tagIds = const <String>[],
  }) {
    return _remote.createCourse(
      accessToken: _accessToken,
      body: <String, dynamic>{
        'title': title,
        'sub_title': subtitle,
        'description': description,
        'expected_hours': expectedHours,
        'students_count': 0,
        'lessons_count': 0,
        'has_certificate': hasCertificate,
        'cover_image_url': '',
        'learning_outcomes': learningOutcomes,
        'level_id': levelId,
        'status_id': statusId,
        'duration_category_id': durationCategoryId,
        'author_id': _authorId,
        'tag_ids': tagIds,
        'topic_id': topicId,
      },
    );
  }

  Future<BackendCourseDto> updateCourse({
    required String courseId,
    required String title,
    required String subtitle,
    required String description,
    required int expectedHours,
    required bool hasCertificate,
    required List<String> learningOutcomes,
    required String levelId,
    required String statusId,
    required String durationCategoryId,
    required String topicId,
    List<String> tagIds = const <String>[],
  }) {
    return _remote.updateCourse(
      accessToken: _accessToken,
      courseId: courseId,
      body: <String, dynamic>{
        'title': title,
        'sub_title': subtitle,
        'description': description,
        'expected_hours': expectedHours,
        'students_count': 0,
        'lessons_count': 0,
        'has_certificate': hasCertificate,
        'cover_image_url': '',
        'learning_outcomes': learningOutcomes,
        'level_id': levelId,
        'status_id': statusId,
        'duration_category_id': durationCategoryId,
        'author_id': _authorId,
        'tag_ids': tagIds,
        'topic_id': topicId,
      },
    );
  }

  Future<void> deleteCourse(String courseId) =>
      _remote.deleteCourse(accessToken: _accessToken, courseId: courseId);

  Future<BackendModuleDto> createModule({
    required String courseId,
    required String title,
    required String summary,
    String locale = 'ru',
  }) {
    return _remote.createModule(
      accessToken: _accessToken,
      body: <String, dynamic>{
        'course_id': courseId,
        'title': title,
        'summary': summary,
        'locale': locale,
      },
    );
  }

  Future<void> deleteModule(String moduleId) =>
      _remote.deleteModule(accessToken: _accessToken, moduleId: moduleId);

  Future<BackendLessonDto> createLesson({
    required String moduleId,
    required int position,
    required int durationMinutes,
    required int xpReward,
    required LocalizedInput title,
    required LocalizedInput summary,
    required LocalizedInput outcome,
    required LocalizedInput theoryContent,
    List<LocalizedInput> keyPoints = const <LocalizedInput>[],
    String codeSnippet = '',
    String exampleOutput = '',
  }) {
    return _remote.createLesson(
      accessToken: _accessToken,
      body: <String, dynamic>{
        'module_id': moduleId,
        'position': position,
        'duration_minutes': durationMinutes,
        'xp_reward': xpReward,
        'code_snippet': codeSnippet,
        'example_output': exampleOutput,
        'video_object_key': '',
        'title': title.toJson(),
        'summary': summary.toJson(),
        'outcome': outcome.toJson(),
        'theory_content': theoryContent.toJson(),
        'key_points': keyPoints
            .where((k) => !k.isEmpty)
            .map((k) => k.toJson())
            .toList(),
      },
    );
  }

  Future<BackendLessonDto> uploadLessonVideo({
    required String lessonId,
    required List<int> videoBytes,
    required String fileName,
  }) {
    return _remote.uploadLessonVideo(
      accessToken: _accessToken,
      lessonId: lessonId,
      videoBytes: videoBytes,
      fileName: fileName,
    );
  }

  Future<CoursePriceResponse> saveCoursePrice({
    required String courseId,
    String? priceId,
    required int amount,
    required String currency,
  }) async {
    final normalizedCurrency = currency.trim().isEmpty
        ? 'KZT'
        : currency.trim().toUpperCase();
    final normalizedPriceId = priceId?.trim() ?? '';

    if (normalizedPriceId.isNotEmpty) {
      return _paymentRemote.updateCoursePrice(
        accessToken: _accessToken,
        priceId: normalizedPriceId,
        amount: amount,
        currency: normalizedCurrency,
      );
    }

    try {
      final existing = await _paymentRemote.fetchCoursePrice(
        accessToken: _accessToken,
        courseId: courseId,
      );
      if (existing.id.trim().isNotEmpty) {
        return _paymentRemote.updateCoursePrice(
          accessToken: _accessToken,
          priceId: existing.id,
          amount: amount,
          currency: normalizedCurrency,
        );
      }
    } catch (_) {
      // No existing price for this course yet.
    }

    return _paymentRemote.createCoursePrice(
      accessToken: _accessToken,
      body: <String, dynamic>{
        'course_id': courseId,
        'amount': amount,
        'currency': normalizedCurrency,
      },
    );
  }

  Future<void> deleteLessonPractice(String practiceId) =>
      _remote.deletePractice(accessToken: _accessToken, practiceId: practiceId);

  Future<void> createQuiz({
    required String lessonId,
    required int position,
    required LocalizedInput question,
    required List<LocalizedInput> options,
    required int correctAnswerIndex,
    required LocalizedInput explanation,
  }) {
    return _remote.createQuiz(
      accessToken: _accessToken,
      body: <String, dynamic>{
        'lesson_id': lessonId,
        'position': position,
        'question': question.toJson(),
        'options': options.map((o) => o.toJson()).toList(),
        'correct_answer_index': correctAnswerIndex,
        'explanation': explanation.toJson(),
      },
    );
  }

  Future<void> createPractice({
    required String lessonId,
    required int position,
    required String title,
    required String description,
    required String language,
    required String starterCode,
    required String expectedOutput,
    required int xpReward,
    String checkType = 'manual',
  }) {
    return _remote.createPractice(
      accessToken: _accessToken,
      body: <String, dynamic>{
        'lesson_id': lessonId,
        'position': position,
        'title': title,
        'description': description,
        'language': language,
        'starter_code': starterCode,
        'expected_output': expectedOutput,
        'xp_reward': xpReward,
        'check_type': checkType,
      },
    );
  }
}

/// Provides the authoring service. Returns null when unauthenticated.
final teacherAuthoringServiceProvider = Provider<TeacherAuthoringService?>((
  ref,
) {
  final accessToken = ref.watch(backendCourseAccessTokenProvider);
  final authorId = ref.watch(authControllerProvider).session?.user.id ?? '';
  if (accessToken == null || accessToken.trim().isEmpty || authorId.isEmpty) {
    return null;
  }
  final remote = ref.watch(backendCourseRemoteDataSourceProvider);
  final paymentRemote = ref.watch(paymentRemoteDataSourceProvider);
  return TeacherAuthoringService(
    remote: remote,
    paymentRemote: paymentRemote,
    accessToken: accessToken,
    authorId: authorId,
  );
});

final teacherCoursePriceProvider =
    FutureProvider.family<CoursePriceResponse?, String>((ref, courseId) async {
      final normalizedCourseId = courseId.trim();
      if (normalizedCourseId.isEmpty) {
        return null;
      }

      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return null;
      }

      final remote = ref.watch(paymentRemoteDataSourceProvider);
      try {
        return await remote.fetchCoursePrice(
          accessToken: accessToken,
          courseId: normalizedCourseId,
        );
      } catch (_) {
        return null;
      }
    });

/// Modules of a course (filtered by courseId), sorted by creation time.
final teacherModulesProvider =
    FutureProvider.family<List<BackendModuleDto>, String>((
      ref,
      courseId,
    ) async {
      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return const <BackendModuleDto>[];
      }
      final remote = ref.watch(backendCourseRemoteDataSourceProvider);
      final all = await remote.fetchModules(
        accessToken: accessToken,
        localeCode: 'ru',
      );
      final filtered = all.where((m) => m.courseId == courseId).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return filtered;
    });

/// Lessons of a module, sorted by creation time.
final teacherLessonsProvider =
    FutureProvider.family<List<BackendLessonDto>, String>((
      ref,
      moduleId,
    ) async {
      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return const <BackendLessonDto>[];
      }
      final remote = ref.watch(backendCourseRemoteDataSourceProvider);
      final lessons = (await remote.fetchLessonsForModule(
        accessToken: accessToken,
        moduleId: moduleId,
      )).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return lessons;
    });
