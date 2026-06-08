import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_catalog.dart';
import '../../../../app/state/demo_catalog_support.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../app/state/oop_code_tasks.dart';
import '../../../../app/state/oop_quiz_data.dart';
import '../../../../core/config/app_environment.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/json_http_client.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/datasources/backend_course_remote_data_source.dart';
import '../../data/models/backend_course_dto.dart';
import '../../data/models/backend_progress_dto.dart';
import '../../data/models/backend_lesson_dto.dart';
import '../../data/models/backend_module_dto.dart';
import '../../data/models/backend_notification_dto.dart';
import '../../data/models/backend_course_query.dart';
import '../../data/models/backend_practice_dto.dart';
import '../../data/models/backend_quiz_dto.dart';
import '../../data/models/backend_review_dto.dart';
import '../../data/models/backend_streak_dto.dart';
import '../../data/models/backend_student_statistics_dto.dart';

final backendCourseAccessTokenProvider = Provider<String?>((ref) {
  return ref.watch(
    authControllerProvider.select((state) => state.session?.accessToken),
  );
});

final backendCourseJsonHttpClientProvider = Provider<JsonHttpClient>((ref) {
  final client = ref.watch(authHttpClientProvider);
  final environment = ref.watch(appEnvironmentProvider);

  return JsonHttpClient(client: client, uriResolver: environment.resolve);
});

final backendCourseRemoteDataSourceProvider =
    Provider<BackendCourseRemoteDataSource>((ref) {
      final client = ref.watch(backendCourseJsonHttpClientProvider);
      return BackendCourseRemoteDataSource(client);
    });

final backendCourseLocaleCodeProvider = Provider<String>((ref) {
  final locale = ref.watch(
    demoAppControllerProvider.select((state) => state.locale),
  );
  return _localeCodeFor(locale);
});

class BackendCourseDictionaries {
  const BackendCourseDictionaries({
    required this.levels,
    required this.topics,
    required this.durationCategories,
    required this.statuses,
    this.tags = const <BackendDictionaryEntryDto>[],
    this.locales = const <BackendDictionaryEntryDto>[],
  });

  const BackendCourseDictionaries.empty()
    : levels = const <BackendDictionaryEntryDto>[],
      topics = const <BackendDictionaryEntryDto>[],
      durationCategories = const <BackendDictionaryEntryDto>[],
      statuses = const <BackendDictionaryEntryDto>[],
      tags = const <BackendDictionaryEntryDto>[],
      locales = const <BackendDictionaryEntryDto>[];

  final List<BackendDictionaryEntryDto> levels;
  final List<BackendDictionaryEntryDto> topics;
  final List<BackendDictionaryEntryDto> durationCategories;
  final List<BackendDictionaryEntryDto> statuses;
  final List<BackendDictionaryEntryDto> tags;
  final List<BackendDictionaryEntryDto> locales;

  bool get isEmpty =>
      levels.isEmpty &&
      topics.isEmpty &&
      durationCategories.isEmpty &&
      statuses.isEmpty &&
      tags.isEmpty &&
      locales.isEmpty;

  String? levelLabel(String? value) => _labelForValue(value, levels);

  String? topicLabel(String? value) => _labelForValue(value, topics);

  String? durationLabel(String? value) =>
      _labelForValue(value, durationCategories);

  String? tagLabel(String? value) => _labelForValue(value, tags);

  String? localeLabel(String? value) => _labelForValue(value, locales);
}

final backendCourseDictionariesProvider =
    FutureProvider<BackendCourseDictionaries>((ref) async {
      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return const BackendCourseDictionaries.empty();
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        Future<List<BackendDictionaryEntryDto>> optional(
          Future<List<BackendDictionaryEntryDto>> future,
        ) async {
          try {
            return await future;
          } catch (_) {
            return const <BackendDictionaryEntryDto>[];
          }
        }

        final responses = await Future.wait<List<BackendDictionaryEntryDto>>(
          <Future<List<BackendDictionaryEntryDto>>>[
            remote.fetchLevels(accessToken: accessToken),
            remote.fetchTopics(accessToken: accessToken),
            remote.fetchDurationCategories(accessToken: accessToken),
            remote.fetchStatuses(accessToken: accessToken),
            // Tags and locales are optional: a failure here must not wipe the
            // core level/topic/duration filters.
            optional(remote.fetchTags(accessToken: accessToken)),
            optional(remote.fetchLocales(accessToken: accessToken)),
          ],
        );

        return BackendCourseDictionaries(
          levels: responses[0],
          topics: responses[1],
          durationCategories: responses[2],
          statuses: responses[3],
          tags: responses[4],
          locales: responses[5],
        );
      } catch (_) {
        return const BackendCourseDictionaries.empty();
      }
    });

final backendPublishedCoursesProvider = FutureProvider<List<CommunityCourse>>((
  ref,
) async {
  return ref.watch(
    backendCourseCatalogProvider(const BackendCourseQuery()).future,
  );
});

final backendCourseCatalogProvider =
    FutureProvider.family<List<CommunityCourse>, BackendCourseQuery>((
      ref,
      query,
    ) async {
      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return const <CommunityCourse>[];
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        final courses = await remote.fetchCourses(
          accessToken: accessToken,
          query: query,
        );

        return courses
            .map(adaptBackendCourseToCommunityCourse)
            .toList(growable: false);
      } catch (_) {
        return const <CommunityCourse>[];
      }
    });

final teacherBackendCoursesProvider = FutureProvider<List<BackendCourseDto>>((
  ref,
) async {
  final accessToken = ref.watch(backendCourseAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) {
    return const <BackendCourseDto>[];
  }

  final remote = ref.watch(backendCourseRemoteDataSourceProvider);

  try {
    return await remote.fetchCourses(
      accessToken: accessToken,
      query: const BackendCourseQuery(statusCode: '', limit: 100),
    );
  } catch (_) {
    return const <BackendCourseDto>[];
  }
});

final backendCourseDetailProvider =
    FutureProvider.family<CommunityCourse?, String>((ref, courseId) async {
      final normalizedCourseId = courseId.trim();
      if (normalizedCourseId.isEmpty) {
        return null;
      }

      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return null;
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);
      final localeCode = ref.watch(backendCourseLocaleCodeProvider);

      try {
        final course = await remote.fetchCourseById(
          accessToken: accessToken,
          courseId: normalizedCourseId,
        );
        final modules =
            (await remote.fetchModules(
                  accessToken: accessToken,
                  localeCode: localeCode,
                ))
                .where((module) => module.courseId == course.id)
                .toList(growable: true)
              ..sort(
                (left, right) => left.createdAt.compareTo(right.createdAt),
              );

        final lessonResponses =
            await Future.wait<MapEntry<String, List<BackendLessonDto>>>(
              modules.map((module) async {
                final lessons = (await remote.fetchLessonsForModule(
                  accessToken: accessToken,
                  moduleId: module.id,
                )).toList(growable: true);
                lessons.sort(
                  (left, right) => left.createdAt.compareTo(right.createdAt),
                );
                return MapEntry<String, List<BackendLessonDto>>(
                  module.id,
                  lessons,
                );
              }),
            );

        final lessonsByModule = <String, List<BackendLessonDto>>{
          for (final entry in lessonResponses) entry.key: entry.value,
        };

        return adaptBackendCourseToDetailedCommunityCourse(
          course,
          modules: modules,
          lessonsByModule: lessonsByModule,
          localeCode: localeCode,
        );
      } catch (_) {
        return null;
      }
    });

final backendCourseLeaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((
      ref,
      courseId,
    ) async {
      final normalizedCourseId = courseId.trim();
      if (normalizedCourseId.isEmpty) {
        return const <LeaderboardEntry>[];
      }

      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return const <LeaderboardEntry>[];
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      final currentUserId = ref
          .watch(authControllerProvider)
          .session
          ?.user
          .id
          .trim();

      try {
        final response = await remote.getCoursePointByCourseId(
          accessToken: accessToken,
          courseId: normalizedCourseId,
        );

        final entries = response.map((json) {
          final xp = (json['xp'] as num?)?.toInt() ?? 0;
          final userId = json['user_id'] as String? ?? 'Unknown';
          final isCurrentUser =
              currentUserId != null && currentUserId.isNotEmpty && userId == currentUserId;
          final shortId = userId.length >= 4 ? userId.substring(0, 4) : userId;

          return LeaderboardEntry(
            id: userId,
            name: isCurrentUser ? 'You' : 'Learner $shortId',
            xp: xp,
            level: (xp / 100).floor() + 1,
            role: 'Learner',
            focus: 'Course',
            isCurrentUser: isCurrentUser,
          );
        }).toList(growable: true)
          ..sort((a, b) => b.xp.compareTo(a.xp));

        return entries;
      } catch (_) {
        return const <LeaderboardEntry>[];
      }
    });

/// Leaderboard for the fully integrated OOP course, used by the global
/// leaderboard screen. Falls back to an empty list when unauthenticated or
/// the backend is unavailable (the UI then shows local demo data).
/// Enrolls the signed-in user into [courseId] on the backend.
///
/// Call this alongside [DemoAppController.enrollCommunityCourse] so the local
/// state and the server stay in sync. Only real backend courses (UUID ids) are
/// sent to the server; local demo courses are silently skipped.
///
/// Returns null on success, or an error message string on failure.
Future<String?> backendEnrollCourse(
  WidgetRef ref,
  String courseId,
) async {
  if (!_looksLikeUuid(courseId)) return null;

  final accessToken = ref.read(backendCourseAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) return null;

  final userId = ref.read(authControllerProvider).session?.user.id ?? '';
  if (userId.trim().isEmpty) return null;

  final remote = ref.read(backendCourseRemoteDataSourceProvider);

  try {
    await remote.enrollCourse(
      accessToken: accessToken,
      courseId: courseId,
      userId: userId,
    );
    return null;
  } catch (_) {
    return null;
  }
}

final backendOopLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((
  ref,
) {
  return ref.watch(
    backendCourseLeaderboardProvider(_oopCourseBackendId).future,
  );
});

CommunityCourse adaptBackendCourseToCommunityCourse(BackendCourseDto course) {
  final topicKeys = _topicKeysForCourse(course);
  final topicKey = topicKeys.first;
  final author = _authorForCourse(course, topicKeys);
  final title = _titleForCourse(course);
  final subtitle = _subtitleForCourse(course);
  final description = _descriptionForCourse(course);
  final tags = _courseTags(course);
  final lessonPreviews = _lessonPreviewsForCourse(course, title);

  return buildCommunityCourse(
    id: course.id,
    title: title,
    subtitle: subtitle,
    description: description,
    level: _displayLevelLabel(course.level),
    rating: course.rating,
    enrollmentCount: course.studentsCount,
    estimatedHours: math.max(1, course.expectedHours),
    color: _accentColorForCourse(course.id),
    author: author,
    categoryKey: topicKey,
    topicKeys: topicKeys,
    searchKeywords: _searchKeywordsForCourse(course, author),
    isPopular: true,
    isRecommended: false,
    tags: tags,
    lessons: lessonPreviews,
    supportsCoursePlayer: false,
    learningOutcomes: course.learningOutcomes.isEmpty
        ? null
        : course.learningOutcomes,
    reviewSummary: CommunityCourseReviewSummary(
      averageRating: course.rating,
      reviewCount: course.ratingCount,
      ratingDistribution: _buildRatingDistribution(
        rating: course.rating,
        reviewCount: course.ratingCount,
      ),
    ),
    facts: CommunityCourseFacts(
      lessonCount: course.lessonsCount,
      videoMinutes: math.max(1, course.expectedHours) * 60,
      assessmentCount: math.max(1, course.learningOutcomes.length),
      interactiveCount: math.max(1, tags.length),
      languageLabel: 'EN / RU / KK',
      hasCertificate: course.hasCertificate,
      certificateLabel: course.hasCertificate
          ? 'Certificate included'
          : 'No certificate yet',
      startModeLabel: _displayStatusLabel(course),
    ),
  );
}

CommunityCourse adaptBackendCourseToDetailedCommunityCourse(
  BackendCourseDto course, {
  required List<BackendModuleDto> modules,
  required Map<String, List<BackendLessonDto>> lessonsByModule,
  required String localeCode,
}) {
  final topicKeys = _topicKeysForCourse(course);
  final topicKey = topicKeys.first;
  final author = _authorForCourse(course, topicKeys);
  final title = _titleForCourse(course);
  final subtitle = _subtitleForCourse(course);
  final description = _descriptionForCourse(course);
  final tags = _courseTags(course);
  final localizedModules = modules
      .map(
        (module) => CoursePlayerModule(
          id: module.id,
          title: sameText(
            module.title.trim().isEmpty ? 'Module' : module.title,
          ),
          summary: sameText(
            module.summary.trim().isEmpty
                ? 'Lessons for this module are available in the live curriculum.'
                : module.summary,
          ),
          lessons: (lessonsByModule[module.id] ?? const <BackendLessonDto>[])
              .map(
                (lesson) => CoursePlayerLesson(
                  id: lesson.id,
                  title: _localizedTextFromBackend(
                    lesson.title,
                    fallback: 'Lesson',
                  ),
                  annotation: _localizedTextFromBackend(
                    lesson.summary,
                    fallback: 'Lesson summary is not available yet.',
                  ),
                  explanation: _localizedTextFromBackend(
                    lesson.theoryContent,
                    fallback: _displayBackendText(
                      lesson.summary,
                      localeCode: localeCode,
                      fallback: 'Lesson theory is not available yet.',
                    ),
                  ),
                  objective: _localizedTextFromBackend(
                    lesson.outcome,
                    fallback: _displayBackendText(
                      lesson.summary,
                      localeCode: localeCode,
                      fallback: 'Explore the lesson content and key ideas.',
                    ),
                  ),
                  videoLabel:
                      '${math.max(1, lesson.durationMinutes)} min live lesson',
                  imageCaption: _displayBackendText(
                    lesson.summary,
                    localeCode: localeCode,
                    fallback:
                        'Read the lesson summary and continue through the module.',
                  ),
                  codeSnippet: lesson.codeSnippet.trim().isEmpty
                      ? '// Code snippet is not available for this lesson yet.'
                      : lesson.codeSnippet.trim(),
                  exampleOutput: lesson.exampleOutput.trim().isEmpty
                      ? 'No example output yet.'
                      : lesson.exampleOutput.trim(),
                  comments: const <CoursePlayerComment>[],
                  exercises: const <CoursePlayerExercise>[],
                  nextActionLabel: sameText(
                    'Review the key points and continue to the next lesson when you are ready.',
                  ),
                ),
              )
              .toList(growable: false),
        ),
      )
      .where((module) => module.lessons.isNotEmpty)
      .toList(growable: false);

  final lessonPreviews = _lessonPreviewsFromModules(localizedModules);
  final moduleSections = localizedModules
      .map(
        (module) => CommunityCourseModuleSection(
          title: module.title.en,
          description: module.summary.en,
          items: module.lessons
              .map(
                (lesson) => CommunityCourseModuleItem(
                  title: lesson.title.resolve(_localeFromCode(localeCode)),
                  durationLabel: _durationLabelForMinutes(
                    _minutesFromVideoLabel(lesson.videoLabel),
                  ),
                  viewerCount: math.max(0, course.studentsCount),
                  helpfulCount: math.max(
                    1,
                    _minutesFromVideoLabel(lesson.videoLabel) ~/ 15,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      )
      .toList(growable: false);
  final learningOutcomes = course.learningOutcomes.isNotEmpty
      ? course.learningOutcomes
      : _learningOutcomesFromModules(localizedModules, localeCode);

  return buildCommunityCourse(
    id: course.id,
    title: title,
    subtitle: subtitle,
    description: description,
    level: _displayLevelLabel(course.level),
    rating: course.rating,
    enrollmentCount: course.studentsCount,
    estimatedHours: math.max(1, course.expectedHours),
    color: _accentColorForCourse(course.id),
    author: author,
    categoryKey: topicKey,
    topicKeys: topicKeys,
    searchKeywords: _searchKeywordsForCourse(course, author),
    isPopular: true,
    isRecommended: false,
    tags: tags,
    lessons: lessonPreviews.isEmpty
        ? _lessonPreviewsForCourse(course, title)
        : lessonPreviews,
    supportsCoursePlayer: localizedModules.any(
      (module) => module.lessons.isNotEmpty,
    ),
    learningOutcomes: learningOutcomes,
    moduleSections: moduleSections,
    coursePlayerModules: localizedModules,
    reviews: const <CommunityCourseReview>[],
    updates: _updatesForCourse(course, localizedModules.length),
    reviewSummary: CommunityCourseReviewSummary(
      averageRating: course.rating,
      reviewCount: course.ratingCount,
      ratingDistribution: _buildRatingDistribution(
        rating: course.rating,
        reviewCount: course.ratingCount,
      ),
    ),
    facts: CommunityCourseFacts(
      lessonCount: localizedModules.fold<int>(
        0,
        (sum, module) => sum + module.lessons.length,
      ),
      videoMinutes: math.max(1, course.expectedHours) * 60,
      assessmentCount: math.max(1, learningOutcomes.length),
      interactiveCount: localizedModules.length,
      languageLabel: 'EN / RU / KK',
      hasCertificate: course.hasCertificate,
      certificateLabel: course.hasCertificate
          ? 'Certificate included'
          : 'No certificate yet',
      startModeLabel: _displayStatusLabel(course),
    ),
  );
}

String? normalizeBackendLevelCode(String? rawLevel) {
  final normalized = rawLevel?.trim();
  if (normalized == null || normalized.isEmpty || normalized == 'All') {
    return null;
  }

  switch (normalized.toLowerCase()) {
    case 'beginner':
      return 'beginner';
    case 'intermediate':
      return 'intermediate';
    case 'advanced':
      return 'advanced';
    default:
      return normalized;
  }
}

String? resolveBackendTopicCode(
  String? rawTopic,
  List<BackendDictionaryEntryDto> availableTopics,
) {
  final normalized = rawTopic?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  final directMatch = _entryForValue(normalized, availableTopics);
  if (directMatch != null) {
    return directMatch.code;
  }

  final lower = normalized.toLowerCase();
  for (final topic in availableTopics) {
    final haystacks = <String>[
      topic.name.toLowerCase(),
      topic.code.toLowerCase(),
    ];

    if (lower == courseTopicSqlDatabases &&
        haystacks.any((value) => value.contains('database'))) {
      return topic.code;
    }
    if (lower == courseTopicProgrammingLanguages &&
        haystacks.any((value) => value.contains('program'))) {
      return topic.code;
    }
    if (lower == courseTopicProgrammingLanguages &&
        haystacks.any(
          (value) =>
              value.contains('python') ||
              value.contains('golang') ||
              value.contains('network') ||
              value.contains('operating'),
        )) {
      return topic.code;
    }
    if (lower == courseTopicDataAnalytics &&
        haystacks.any(
          (value) =>
              value.contains('analytic') ||
              value.contains('algebra') ||
              value.contains('stat'),
        )) {
      return topic.code;
    }
    if (lower == courseTopicAi &&
        haystacks.any(
          (value) => value.contains('ai') || value.contains('ml'),
        )) {
      return topic.code;
    }
    if (lower == courseTopicSoftSkills &&
        haystacks.any((value) => value.contains('soft'))) {
      return topic.code;
    }
  }

  return normalized;
}

List<String> resolveMockTopicKeys(String? rawTopic) {
  final normalized = rawTopic?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return const <String>[];
  }

  if (normalized == courseTopicProgrammingLanguages ||
      normalized.contains('program') ||
      normalized.contains('python') ||
      normalized.contains('golang') ||
      normalized.contains('network') ||
      normalized.contains('operating') ||
      normalized.contains('linux') ||
      normalized.contains('devops')) {
    return const <String>[courseTopicProgrammingLanguages];
  }
  if (normalized == courseTopicDataAnalytics ||
      normalized.contains('analytic') ||
      normalized.contains('algebra') ||
      normalized.contains('statistics') ||
      normalized.contains('discrete')) {
    return const <String>[courseTopicDataAnalytics];
  }
  if (normalized == courseTopicAi ||
      normalized.contains('machine') ||
      normalized == 'ai') {
    return const <String>[courseTopicAi];
  }
  if (normalized == courseTopicSqlDatabases ||
      normalized.contains('database') ||
      normalized.contains('база')) {
    return const <String>[courseTopicSqlDatabases];
  }
  if (normalized == courseTopicSoftSkills || normalized.contains('soft')) {
    return const <String>[courseTopicSoftSkills];
  }

  return const <String>[];
}

String normalizeMockLevelLabel(String? rawLevel) {
  switch (normalizeBackendLevelCode(rawLevel)) {
    case 'beginner':
      return 'Beginner';
    case 'advanced':
      return 'Advanced';
    case 'intermediate':
      return 'Intermediate';
    default:
      return rawLevel?.trim().isEmpty ?? true ? 'All' : rawLevel!.trim();
  }
}

List<CommunityCourse> withComparisonCourse({
  required List<CommunityCourse> backendCourses,
  required CommunityCourse comparisonCourse,
}) {
  return <CommunityCourse>[
    comparisonCourse,
    ...backendCourses.where((course) => course.id != comparisonCourse.id),
  ];
}

String? _labelForValue(String? value, List<BackendDictionaryEntryDto> entries) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return _entryForValue(normalized, entries)?.name;
}

BackendDictionaryEntryDto? _entryForValue(
  String value,
  List<BackendDictionaryEntryDto> entries,
) {
  final normalized = value.trim().toLowerCase();

  for (final entry in entries) {
    if (entry.id.toLowerCase() == normalized ||
        entry.code.toLowerCase() == normalized ||
        entry.name.toLowerCase() == normalized) {
      return entry;
    }
  }
  return null;
}

String _authorDisplayName(String email) {
  final localPart = email.split('@').first.trim();
  if (localPart.isEmpty) {
    return 'Backend author';
  }

  final words = localPart
      .replaceAll(RegExp(r'[._-]+'), ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map((word) {
        final lower = word.toLowerCase();
        return '${lower[0].toUpperCase()}${lower.substring(1)}';
      })
      .toList(growable: false);

  return words.isEmpty ? 'Backend author' : words.join(' ');
}

String _authorRoleLabel(BackendCourseAuthorDto author) {
  if (author.roles.isEmpty) {
    return 'Course author';
  }

  final firstRole = author.roles.first;
  return firstRole.name.trim().isEmpty
      ? 'Course author'
      : firstRole.name.trim();
}

List<String> _courseTags(BackendCourseDto course) {
  final values = <String>[
    for (final tag in course.tags)
      if (tag.name.trim().isNotEmpty)
        tag.name.trim()
      else if (tag.code.trim().isNotEmpty)
        tag.code.trim(),
    if (course.topic?.name.trim().isNotEmpty == true) course.topic!.name.trim(),
    _displayLevelLabel(course.level),
  ];

  return values.isEmpty ? <String>[_displayLevelLabel(course.level)] : values;
}

List<String> _searchKeywordsForCourse(
  BackendCourseDto course,
  CommunityCourseAuthor author,
) {
  final values = <String>{
    course.title,
    course.subtitle,
    course.description,
    author.name,
    author.role,
    course.level.code,
    course.level.name,
    course.durationCategory.code,
    course.durationCategory.name,
    if (course.topic != null) course.topic!.code,
    if (course.topic != null) course.topic!.name,
    ...course.learningOutcomes,
    for (final tag in course.tags) tag.code,
    for (final tag in course.tags) tag.name,
  };

  return values
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

List<CommunityCourseLessonPreview> _lessonPreviewsForCourse(
  BackendCourseDto course,
  String title,
) {
  if (course.learningOutcomes.isNotEmpty) {
    return List<CommunityCourseLessonPreview>.generate(
      math.min(3, course.learningOutcomes.length),
      (index) => buildCourseLesson(
        '$title: step ${index + 1}',
        course.learningOutcomes[index],
        durationMinutes: _estimatedLessonMinutes(course),
      ),
      growable: false,
    );
  }

  return <CommunityCourseLessonPreview>[
    buildCourseLesson(
      '$title: overview',
      course.description.trim().isEmpty
          ? 'Preview lesson is not available yet.'
          : course.description.trim(),
      durationMinutes: _estimatedLessonMinutes(course),
    ),
  ];
}

int _estimatedLessonMinutes(BackendCourseDto course) {
  final lessons = math.max(1, course.lessonsCount);
  final totalMinutes = math.max(1, course.expectedHours) * 60;
  return math.max(8, (totalMinutes / lessons).round());
}

List<String> _topicKeysForCourse(BackendCourseDto course) {
  final mockTopicKeys = resolveMockTopicKeys(
    course.topic?.code ?? course.topic?.name,
  );
  return mockTopicKeys.isEmpty
      ? const <String>[courseTopicProgrammingLanguages]
      : mockTopicKeys;
}

CommunityCourseAuthor _authorForCourse(
  BackendCourseDto course,
  List<String> topicKeys,
) {
  return CommunityCourseAuthor(
    id: course.author.id.isEmpty
        ? 'backend-author-${course.id}'
        : course.author.id,
    name: _authorDisplayName(course.author.email),
    role: _authorRoleLabel(course.author),
    accentLabel: course.topic?.name.isNotEmpty == true
        ? course.topic!.name
        : _displayStatusLabel(course),
    followersCount: course.studentsCount,
    courseCount: 1,
    topicKeys: topicKeys,
    summary: course.author.email,
    rating: course.rating,
    studentCount: course.studentsCount,
  );
}

String _titleForCourse(BackendCourseDto course) {
  return course.title.trim().isEmpty ? 'Untitled course' : course.title.trim();
}

String _subtitleForCourse(BackendCourseDto course) {
  return course.subtitle.trim().isEmpty
      ? 'Backend course preview'
      : course.subtitle.trim();
}

String _descriptionForCourse(BackendCourseDto course) {
  return course.description.trim().isEmpty
      ? 'Course description is not available yet from the backend.'
      : course.description.trim();
}

String _displayLevelLabel(BackendDictionaryEntryDto level) {
  if (level.code.trim().isNotEmpty) {
    return _mockLevelLabelForCode(level.code);
  }
  if (level.name.trim().isNotEmpty) {
    return normalizeMockLevelLabel(level.name);
  }
  return 'Intermediate';
}

String _displayStatusLabel(BackendCourseDto course) {
  final code = course.status.code.trim();
  if (code.isEmpty) {
    return course.status.name.trim().isEmpty ? 'Published' : course.status.name;
  }

  return code
      .split(RegExp(r'[_\s-]+'))
      .where((segment) => segment.isNotEmpty)
      .map((segment) {
        final lower = segment.toLowerCase();
        return '${lower[0].toUpperCase()}${lower.substring(1)}';
      })
      .join(' ');
}

List<CommunityCourseLessonPreview> _lessonPreviewsFromModules(
  List<CoursePlayerModule> modules,
) {
  final lessons = <CoursePlayerLesson>[
    for (final module in modules) ...module.lessons,
  ];

  return lessons
      .take(3)
      .map(
        (lesson) => CommunityCourseLessonPreview(
          title: lesson.title,
          summary: lesson.annotation,
          durationMinutes: _minutesFromVideoLabel(lesson.videoLabel),
        ),
      )
      .toList(growable: false);
}

List<String> _learningOutcomesFromModules(
  List<CoursePlayerModule> modules,
  String localeCode,
) {
  return modules
      .expand((module) => module.lessons)
      .map(
        (lesson) =>
            lesson.objective.resolve(_localeFromCode(localeCode)).trim(),
      )
      .where((item) => item.isNotEmpty)
      .take(6)
      .toList(growable: false);
}

List<CommunityCourseUpdate> _updatesForCourse(
  BackendCourseDto course,
  int moduleCount,
) {
  final updates = <CommunityCourseUpdate>[
    CommunityCourseUpdate(
      id: '${course.id}_sync',
      title: 'Live curriculum sync',
      summary:
          'This course is connected to the curriculum service and shows $moduleCount live module${moduleCount == 1 ? '' : 's'}.',
      timeLabel: _relativeTimeLabel(course.updatedAt),
    ),
  ];

  if (course.publishedAt.millisecondsSinceEpoch > 0) {
    updates.add(
      CommunityCourseUpdate(
        id: '${course.id}_published',
        title: 'Published in curriculum',
        summary:
            'The course became available in the shared curriculum catalog.',
        timeLabel: _relativeTimeLabel(course.publishedAt),
      ),
    );
  }

  return updates;
}

LocalizedText _localizedTextFromBackend(
  BackendLocalizedTextDto value, {
  String fallback = '',
}) {
  final normalizedFallback = fallback.trim();
  final en = value.en.trim().isNotEmpty
      ? value.en.trim()
      : _firstNonEmpty(<String>[value.ru, value.kk, normalizedFallback]);
  final ru = value.ru.trim().isNotEmpty
      ? value.ru.trim()
      : _firstNonEmpty(<String>[value.en, value.kk, normalizedFallback]);
  final kk = value.kk.trim().isNotEmpty
      ? value.kk.trim()
      : _firstNonEmpty(<String>[value.en, value.ru, normalizedFallback]);

  return localizedText(ru, en, kk);
}

String _displayBackendText(
  BackendLocalizedTextDto value, {
  required String localeCode,
  String fallback = '',
}) {
  final text = _localizedTextFromBackend(value, fallback: fallback);
  return text.resolve(_localeFromCode(localeCode));
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    final normalized = value.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }
  }
  return '';
}

String _durationLabelForMinutes(int minutes) {
  final normalized = math.max(1, minutes);
  if (normalized < 60) {
    return '${normalized}m';
  }

  final hours = normalized ~/ 60;
  final restMinutes = normalized % 60;
  return restMinutes == 0 ? '${hours}h' : '${hours}h ${restMinutes}m';
}

int _minutesFromVideoLabel(String value) {
  final match = RegExp(r'(\d+)').firstMatch(value);
  return int.tryParse(match?.group(1) ?? '') ?? 15;
}

String _relativeTimeLabel(DateTime value) {
  if (value.millisecondsSinceEpoch <= 0) {
    return 'Recently';
  }

  final diff = DateTime.now().difference(value.toLocal());
  if (diff.inDays >= 1) {
    return '${diff.inDays}d ago';
  }
  if (diff.inHours >= 1) {
    return '${diff.inHours}h ago';
  }
  if (diff.inMinutes >= 1) {
    return '${diff.inMinutes}m ago';
  }
  return 'Just now';
}

String _localeCodeFor(AppLocale locale) {
  switch (locale) {
    case AppLocale.ru:
      return 'ru';
    case AppLocale.en:
      return 'en';
    case AppLocale.kk:
      return 'kk';
  }
}

AppLocale _localeFromCode(String localeCode) {
  switch (localeCode.trim().toLowerCase()) {
    case 'ru':
      return AppLocale.ru;
    case 'kk':
      return AppLocale.kk;
    case 'en':
    default:
      return AppLocale.en;
  }
}

Map<int, int> _buildRatingDistribution({
  required double rating,
  required int reviewCount,
}) {
  if (reviewCount <= 0) {
    return const <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
  }

  final roundedRating = rating.clamp(1, 5).round();
  final distribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
  distribution[roundedRating] = reviewCount;
  return distribution;
}

String _mockLevelLabelForCode(String rawCode) {
  switch (rawCode.trim().toLowerCase()) {
    case 'beginner':
      return 'Beginner';
    case 'advanced':
      return 'Advanced';
    case 'intermediate':
    default:
      return 'Intermediate';
  }
}

Color _accentColorForCourse(String courseId) {
  const palette = <Color>[
    AppColors.primary,
    AppColors.accent,
    AppColors.success,
    Color(0xFF4FC3F7),
    Color(0xFFA78BFA),
    Color(0xFFFF8A65),
  ];

  var hash = 0;
  for (final codeUnit in courseId.codeUnits) {
    hash = ((hash * 31) + codeUnit) & 0x7fffffff;
  }
  return palette[hash % palette.length];
}

final backendLessonByIdProvider =
    FutureProvider.family<BackendLessonDto?, String>((ref, lessonId) async {
      final normalizedLessonId = lessonId.trim();
      if (normalizedLessonId.isEmpty) {
        return null;
      }

      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return null;
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        return await remote.fetchLessonById(
          accessToken: accessToken,
          lessonId: normalizedLessonId,
        );
      } catch (_) {
        return null;
      }
    });

final backendPracticeByIdProvider =
    FutureProvider.family<BackendPracticeDto?, String>((ref, practiceId) async {
      final normalizedPracticeId = practiceId.trim();
      if (normalizedPracticeId.isEmpty ||
          !_looksLikeUuid(normalizedPracticeId)) {
        return null;
      }

      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return null;
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        return await remote.fetchPracticeById(
          accessToken: accessToken,
          practiceId: normalizedPracticeId,
        );
      } catch (_) {
        return null;
      }
    });

final backendPracticeByLessonIdProvider =
    FutureProvider.family<BackendPracticeDto?, String>((ref, lessonId) async {
      final normalizedLessonId = lessonId.trim();
      if (normalizedLessonId.isEmpty || !_looksLikeUuid(normalizedLessonId)) {
        return null;
      }

      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return null;
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        return await remote.fetchPracticeByLessonId(
          accessToken: accessToken,
          lessonId: normalizedLessonId,
        );
      } catch (_) {
        return null;
      }
    });

final backendQuizzesByLessonIdProvider =
    FutureProvider.family<List<BackendQuizDto>, String>((ref, lessonId) async {
      final normalizedLessonId = lessonId.trim();
      if (normalizedLessonId.isEmpty || !_looksLikeUuid(normalizedLessonId)) {
        return const <BackendQuizDto>[];
      }

      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return const <BackendQuizDto>[];
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        return await remote.fetchQuizzesByLessonId(
          accessToken: accessToken,
          lessonId: normalizedLessonId,
        );
      } catch (_) {
        return const <BackendQuizDto>[];
      }
    });

final backendReviewsByCourseIdProvider =
    FutureProvider.family<List<BackendReviewDto>, String>((
      ref,
      courseId,
    ) async {
      final normalizedCourseId = courseId.trim();
      if (normalizedCourseId.isEmpty) {
        return const <BackendReviewDto>[];
      }

      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return const <BackendReviewDto>[];
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        return await remote.fetchReviewsByCourseId(
          accessToken: accessToken,
          courseId: normalizedCourseId,
        );
      } catch (_) {
        return const <BackendReviewDto>[];
      }
    });

final backendReviewByIdProvider =
    FutureProvider.family<BackendReviewDto?, String>((ref, reviewId) async {
      final normalizedReviewId = reviewId.trim();
      if (normalizedReviewId.isEmpty) {
        return null;
      }

      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return null;
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        return await remote.fetchReviewById(
          accessToken: accessToken,
          reviewId: normalizedReviewId,
        );
      } catch (_) {
        return null;
      }
    });

/// Achievements for the signed-in user, mapped to the shared [Achievement]
/// model so the existing profile UI can render them directly. Returns an empty
/// list when unauthenticated or the backend is unavailable; the UI then falls
/// back to local demo achievements.
final backendAchievementsProvider = FutureProvider<List<Achievement>>((
  ref,
) async {
  final accessToken = ref.watch(backendCourseAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) {
    return const <Achievement>[];
  }

  final remote = ref.watch(backendCourseRemoteDataSourceProvider);

  try {
    final items = await remote.fetchAchievements(accessToken: accessToken);
    return items
        .map(
          (dto) => Achievement(
            id: dto.id,
            title: _localizedTextFromBackend(dto.title, fallback: 'Achievement'),
            description: _localizedTextFromBackend(
              dto.description,
              fallback: '',
            ),
            icon: _iconForAchievementKey(dto.iconKey),
            goal: dto.goal,
            progress: dto.progress,
            unlocked: dto.unlocked,
          ),
        )
        .toList(growable: false);
  } catch (_) {
    return const <Achievement>[];
  }
});

IconData _iconForAchievementKey(String iconKey) {
  switch (iconKey.trim().toLowerCase()) {
    case 'lesson':
    case 'lessons':
    case 'completed_lessons':
    case 'book':
    case 'school':
      return Icons.menu_book_rounded;
    case 'quiz':
    case 'quizzes':
    case 'passed_quizzes':
      return Icons.quiz_rounded;
    case 'streak':
    case 'max_streak':
    case 'fire':
    case 'flame':
      return Icons.local_fire_department_rounded;
    case 'xp':
    case 'xp_total':
    case 'points':
      return Icons.bolt_rounded;
    case 'course':
    case 'courses':
    case 'started_courses':
    case 'active_courses':
      return Icons.workspace_premium_rounded;
    case 'completed_courses':
    case 'graduate':
      return Icons.school_rounded;
    case 'module':
    case 'modules':
    case 'completed_modules':
      return Icons.account_tree_rounded;
    case 'star':
      return Icons.star_rounded;
    default:
      return Icons.emoji_events_rounded;
  }
}

/// Progress for a single course for the signed-in user.
/// Returns null when unauthenticated, not enrolled, or the backend is down.
final backendCourseProgressProvider =
    FutureProvider.family<BackendCourseProgressDto?, String>((
      ref,
      courseId,
    ) async {
      final normalizedCourseId = courseId.trim();
      if (normalizedCourseId.isEmpty) {
        return null;
      }

      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return null;
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        return await remote.fetchCourseProgress(
          accessToken: accessToken,
          courseId: normalizedCourseId,
        );
      } catch (_) {
        return null;
      }
    });

/// Progress across all of the signed-in user's courses.
final backendAllProgressProvider =
    FutureProvider<List<BackendCourseProgressDto>>((ref) async {
      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return const <BackendCourseProgressDto>[];
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        return await remote.fetchAllProgress(accessToken: accessToken);
      } catch (_) {
        return const <BackendCourseProgressDto>[];
      }
    });

/// Progress for the fully integrated OOP course.
final backendOopProgressProvider =
    FutureProvider<BackendCourseProgressDto?>((ref) {
      return ref.watch(
        backendCourseProgressProvider(_oopCourseBackendId).future,
      );
    });

final backendStreakProvider = FutureProvider<BackendStreakDto?>((ref) async {
  final accessToken = ref.watch(backendCourseAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) {
    return null;
  }

  final remote = ref.watch(backendCourseRemoteDataSourceProvider);

  try {
    return await remote.fetchStreak(accessToken: accessToken);
  } catch (_) {
    return null;
  }
});

final backendStudentStatisticsProvider =
    FutureProvider<BackendStudentStatisticsDto?>((ref) async {
      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return null;
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        return await remote.fetchStudentStatistics(accessToken: accessToken);
      } catch (_) {
        return null;
      }
    });

/// Inbox list (`GET /notifications`) for the signed-in user, newest first.
/// Returns an empty list when signed out or on failure — the bell/inbox UI
/// treats that the same as "nothing to show".
final backendNotificationsProvider =
    FutureProvider<BackendNotificationListDto?>((ref) async {
      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return null;
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        return await remote.fetchNotifications(accessToken: accessToken);
      } catch (_) {
        return null;
      }
    });

/// Unread badge count (`GET /notifications/unread-count`) — kept separate
/// from [backendNotificationsProvider] so the bell badge can refresh cheaply
/// without re-fetching the full inbox list.
final backendUnreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final accessToken = ref.watch(backendCourseAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) {
    return 0;
  }

  final remote = ref.watch(backendCourseRemoteDataSourceProvider);

  try {
    return await remote.fetchUnreadNotificationCount(accessToken: accessToken);
  } catch (_) {
    return 0;
  }
});

PracticeTask mergePracticeWithBackend({
  required PracticeTask mockPractice,
  required BackendPracticeDto backendPractice,
  required String localeCode,
}) {
  return PracticeTask(
    id: backendPractice.id.isNotEmpty ? backendPractice.id : mockPractice.id,
    trackId: mockPractice.trackId,
    moduleId: mockPractice.moduleId,
    title: _localizedTextFromBackend(
      backendPractice.title,
      fallback: mockPractice.title.en,
    ),
    summary: _localizedTextFromBackend(
      backendPractice.summary,
      fallback: mockPractice.summary.en,
    ),
    brief: _localizedTextFromBackend(
      backendPractice.brief,
      fallback: mockPractice.brief.en,
    ),
    starterCode: backendPractice.starterCode.trim().isEmpty
        ? mockPractice.starterCode
        : backendPractice.starterCode,
    successCriteria: backendPractice.successCriteria.isEmpty
        ? mockPractice.successCriteria
        : backendPractice.successCriteria
              .map(
                (item) => _localizedTextFromBackend(
                  item,
                  fallback: mockPractice.successCriteria.first.en,
                ),
              )
              .toList(growable: false),
    knowledgeChecks: backendPractice.knowledgeChecks.isEmpty
        ? mockPractice.knowledgeChecks
        : backendPractice.knowledgeChecks
              .map(
                (item) => _localizedTextFromBackend(
                  item,
                  fallback: mockPractice.knowledgeChecks.first.en,
                ),
              )
              .toList(growable: false),
    promptSuggestion: _localizedTextFromBackend(
      backendPractice.promptSuggestion,
      fallback: mockPractice.promptSuggestion.en,
    ),
    xpReward: backendPractice.xpReward > 0
        ? backendPractice.xpReward
        : mockPractice.xpReward,
    codeChallenge: mockPractice.codeChallenge,
    comments: mockPractice.comments,
  );
}

bool _looksLikeUuid(String value) {
  final pattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  return pattern.hasMatch(value);
}

// ─────────────────────────────────────────────────────────────────────────────
// OOP Track — backend integration
// ─────────────────────────────────────────────────────────────────────────────

const String _oopCourseBackendId = '00000000-0000-0000-0000-000000000200';

/// Full OOP learning track loaded from the curriculum-service.
/// Returns null when unauthenticated or the course has no modules.
final backendOopTrackProvider = FutureProvider<LearningTrack?>((ref) async {
  final accessToken = ref.watch(backendCourseAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) return null;

  final remote = ref.watch(backendCourseRemoteDataSourceProvider);

  try {
    final allModules = await remote.fetchModules(
      accessToken: accessToken,
      localeCode: 'en',
    );
    final modules =
        allModules
            .where((m) => m.courseId == _oopCourseBackendId)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (modules.isEmpty) return null;

    final learningModules = await Future.wait(
      modules.indexed.map((e) => _fetchOopModule(remote, e.$2, accessToken, moduleIndex: e.$1)),
    );
    return _buildOopLearningTrack(learningModules);
  } catch (_) {
    return null;
  }
});

/// Finds a LessonItem by UUID inside the loaded OOP track.
final backendOopLessonItemProvider =
    FutureProvider.family<LessonItem?, String>((ref, lessonId) async {
      if (!_looksLikeUuid(lessonId)) return null;
      final track = await ref.watch(backendOopTrackProvider.future);
      if (track == null) return null;
      for (final module in track.modules) {
        for (final lesson in module.lessons) {
          if (lesson.id == lessonId) return lesson;
        }
      }
      return null;
    });

Future<LearningModule> _fetchOopModule(
  BackendCourseRemoteDataSource remote,
  BackendModuleDto module,
  String accessToken, {
  int moduleIndex = 0,
}) async {
  final lessons =
      (await remote.fetchLessonsForModule(
            accessToken: accessToken,
            moduleId: module.id,
          ))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  final practice = lessons.isNotEmpty
      ? await _safeFetchPracticeDto(
          remote,
          accessToken: accessToken,
          lessonId: lessons.last.id,
        )
      : null;

  // Fetch quizzes for every lesson in parallel; failures silently return [].
  final quizzesPerLesson = await Future.wait(
    lessons.map(
      (lesson) => _safeFetchQuizzes(
        remote,
        accessToken: accessToken,
        lessonId: lesson.id,
      ),
    ),
  );

  final lessonItems = List.generate(
    lessons.length,
    (i) => _adaptBackendLessonDto(
      lessons[i],
      moduleId: module.id,
      moduleIndex: moduleIndex,
      lessonIndex: i,
      backendQuizzes: quizzesPerLesson[i],
    ),
  );

  return LearningModule(
    id: module.id,
    trackId: 'oop',
    title: LocalizedText(ru: module.title, en: module.title, kk: module.title),
    summary: LocalizedText(
      ru: module.summary,
      en: module.summary,
      kk: module.summary,
    ),
    lessons: lessonItems,
    practice:
        practice != null
            ? _adaptBackendPracticeDto(practice, moduleId: module.id)
            : null,
  );
}


/// Fetches quizzes for a lesson, returning an empty list on any error.
Future<List<BackendQuizDto>> _safeFetchQuizzes(
  BackendCourseRemoteDataSource remote, {
  required String accessToken,
  required String lessonId,
}) async {
  try {
    final quizzes = await remote.fetchQuizzesByLessonId(
      accessToken: accessToken,
      lessonId: lessonId,
    );
    final sorted = [...quizzes]
      ..sort((a, b) => a.position.compareTo(b.position));
    return sorted;
  } catch (_) {
    return const <BackendQuizDto>[];
  }
}

/// Converts a [BackendQuizDto] to the shared [LessonQuiz] domain model.
LessonQuiz _quizFromBackend(BackendQuizDto dto) {
  final sortedOptions = [...dto.options]
    ..sort((a, b) => a.position.compareTo(b.position));

  return LessonQuiz(
    id: dto.id,
    title: _localizedTextFromBackend(
      dto.question,
      fallback: 'Quiz question',
    ),
    prompt: _localizedTextFromBackend(
      dto.question,
      fallback: 'Quiz question',
    ),
    options: sortedOptions
        .map(
          (o) => QuizOption(
            id: o.id,
            label: _localizedTextFromBackend(o.text, fallback: 'Option'),
          ),
        )
        .toList(growable: false),
    correctOptionId: dto.correctOptionId,
    explanation: _localizedTextFromBackend(dto.explanation, fallback: ''),
  );
}

Future<BackendPracticeDto?> _safeFetchPracticeDto(
  BackendCourseRemoteDataSource remote, {
  required String accessToken,
  required String lessonId,
}) async {
  try {
    return await remote.fetchPracticeByLessonId(
      accessToken: accessToken,
      lessonId: lessonId,
    );
  } catch (_) {
    return null;
  }
}

LessonItem _adaptBackendLessonDto(
  BackendLessonDto dto, {
  required String moduleId,
  int moduleIndex = 0,
  int lessonIndex = 0,
  List<BackendQuizDto> backendQuizzes = const <BackendQuizDto>[],
}) {
  // Prefer quizzes from the backend; fall back to local OopQuizData when the
  // backend returns none (e.g. content not yet seeded for this lesson).
  final quizItems = backendQuizzes.isNotEmpty
      ? backendQuizzes
            .map(_quizFromBackend)
            .toList(growable: false)
      : OopQuizData.forModule(moduleIndex);

  final codeTask = getOopCodeTask(moduleIndex, lessonIndex);
  return LessonItem(
    id: dto.id,
    trackId: 'oop',
    moduleId: moduleId,
    title: _localizedTextFromBackend(dto.title),
    summary: _localizedTextFromBackend(dto.summary),
    durationMinutes: dto.durationMinutes > 0 ? dto.durationMinutes : 15,
    outcome: _localizedTextFromBackend(dto.outcome),
    codeSnippet: codeTask.starterCode,
    exampleOutput: codeTask.expectedOutput,
    keyPoints: dto.keyPoints
        .map((kp) => _localizedTextFromBackend(kp))
        .toList(growable: false),
    quizzes: quizItems,
    codeTrainers: const <CodeTrainer>[],
    completionRequirements:
        quizItems.map((q) => q.id).toList(growable: false),
    promptSuggestion: _localizedTextFromBackend(
      dto.theoryContent,
      fallback: 'Explain the key concepts in ${dto.title.en}',
    ),
    xpReward: dto.xpReward > 0 ? dto.xpReward : 50,
    theoryContent: _localizedTextFromBackend(dto.theoryContent),
  );
}


PracticeTask _adaptBackendPracticeDto(
  BackendPracticeDto dto, {
  required String moduleId,
}) {
  return PracticeTask(
    id: dto.id,
    trackId: 'oop',
    moduleId: moduleId,
    title: _localizedTextFromBackend(dto.title),
    summary: _localizedTextFromBackend(dto.summary),
    brief: _localizedTextFromBackend(dto.brief),
    starterCode: dto.starterCode,
    successCriteria: dto.successCriteria
        .map((sc) => _localizedTextFromBackend(sc))
        .toList(growable: false),
    knowledgeChecks: dto.knowledgeChecks
        .map((kc) => _localizedTextFromBackend(kc))
        .toList(growable: false),
    promptSuggestion: _localizedTextFromBackend(dto.promptSuggestion),
    xpReward: dto.xpReward > 0 ? dto.xpReward : 80,
  );
}

LearningTrack _buildOopLearningTrack(List<LearningModule> modules) {
  final totalLessons = modules.fold(0, (sum, m) => sum + m.lessons.length);
  return LearningTrack(
    id: 'oop',
    title: const LocalizedText(
      ru: 'ООП на Java',
      en: 'OOP in Java',
      kk: 'Java-да ООП',
    ),
    subtitle: const LocalizedText(
      ru: 'Классы, наследование, инкапсуляция и полиморфизм',
      en: 'Classes, inheritance, encapsulation, and polymorphism',
      kk: 'Класстар, мұрагерлік, инкапсуляция және полиморфизм',
    ),
    description: const LocalizedText(
      ru: 'Изучите основы синтаксиса Java, принципы ООП, SOLID и шаблоны проектирования.',
      en: 'Learn Java syntax basics, OOP principles, SOLID and design patterns.',
      kk: 'Java синтаксисін, ООП принциптерін, SOLID және жобалау паттерндерін үйреніңіз.',
    ),
    teaser: const LocalizedText(
      ru: 'Полезно для backend-сервисов и архитектуры приложений.',
      en: 'Useful for backend services, app architecture, and domain modeling.',
      kk: 'Backend қызметтері мен қолданба архитектурасы үшін пайдалы.',
    ),
    outcome: const LocalizedText(
      ru: 'Вы сможете проектировать классы с наследованием и GoF-паттернами.',
      en: 'You can design classes with inheritance and GoF design patterns.',
      kk: 'Мұрагерлік пен GoF паттерндерін қолданып класстар жасай аласыз.',
    ),
    heroMetric: LocalizedText(
      ru: '${modules.length} модулей · $totalLessons уроков · GoF паттерны',
      en: '${modules.length} modules · $totalLessons lessons · GoF patterns',
      kk: '${modules.length} модуль · $totalLessons сабақ · GoF паттерндері',
    ),
    icon: Icons.account_tree_rounded,
    color: const Color(0xFF6FD8FF),
    zone: TrackZone.computerScienceCore,
    availability: TrackAvailability.available,
    order: 12,
    nodeId: 'cs-oop',
    connections: const <String>['algorithms_data_structures', 'backend', 'mobile'],
    modules: modules,
  );
}
