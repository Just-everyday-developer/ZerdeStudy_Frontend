import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_catalog.dart';
import '../../../../app/state/demo_catalog_support.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/config/app_environment.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/json_http_client.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/datasources/backend_course_remote_data_source.dart';
import '../../data/models/backend_course_dto.dart';
import '../../data/models/backend_lesson_dto.dart';
import '../../data/models/backend_module_dto.dart';
import '../../data/models/backend_course_query.dart';

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
  });

  const BackendCourseDictionaries.empty()
    : levels = const <BackendDictionaryEntryDto>[],
      topics = const <BackendDictionaryEntryDto>[],
      durationCategories = const <BackendDictionaryEntryDto>[],
      statuses = const <BackendDictionaryEntryDto>[];

  final List<BackendDictionaryEntryDto> levels;
  final List<BackendDictionaryEntryDto> topics;
  final List<BackendDictionaryEntryDto> durationCategories;
  final List<BackendDictionaryEntryDto> statuses;

  bool get isEmpty =>
      levels.isEmpty &&
      topics.isEmpty &&
      durationCategories.isEmpty &&
      statuses.isEmpty;

  String? levelLabel(String? value) => _labelForValue(value, levels);

  String? topicLabel(String? value) => _labelForValue(value, topics);

  String? durationLabel(String? value) =>
      _labelForValue(value, durationCategories);
}

final backendCourseDictionariesProvider =
    FutureProvider<BackendCourseDictionaries>((ref) async {
      final accessToken = ref.watch(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return const BackendCourseDictionaries.empty();
      }

      final remote = ref.watch(backendCourseRemoteDataSourceProvider);

      try {
        final responses = await Future.wait<List<BackendDictionaryEntryDto>>(
          <Future<List<BackendDictionaryEntryDto>>>[
            remote.fetchLevels(accessToken: accessToken),
            remote.fetchTopics(accessToken: accessToken),
            remote.fetchDurationCategories(accessToken: accessToken),
            remote.fetchStatuses(accessToken: accessToken),
          ],
        );

        return BackendCourseDictionaries(
          levels: responses[0],
          topics: responses[1],
          durationCategories: responses[2],
          statuses: responses[3],
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
        final modules = (await remote.fetchModules(
          accessToken: accessToken,
          localeCode: localeCode,
        ))
            .where((module) => module.courseId == course.id)
            .toList(growable: true)
          ..sort((left, right) => left.createdAt.compareTo(right.createdAt));

        final lessonResponses = await Future.wait<MapEntry<String, List<BackendLessonDto>>>(
          modules.map((module) async {
            final lessons = (await remote.fetchLessonsForModule(
              accessToken: accessToken,
              moduleId: module.id,
            )).toList(growable: true);
            lessons.sort(
              (left, right) => left.createdAt.compareTo(right.createdAt),
            );
            return MapEntry<String, List<BackendLessonDto>>(module.id, lessons);
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
          title: sameText(module.title.trim().isEmpty ? 'Module' : module.title),
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
                    fallback: 'Read the lesson summary and continue through the module.',
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
    supportsCoursePlayer: localizedModules.any((module) => module.lessons.isNotEmpty),
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
        (lesson) => lesson.objective.resolve(_localeFromCode(localeCode)).trim(),
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
        summary: 'The course became available in the shared curriculum catalog.',
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
