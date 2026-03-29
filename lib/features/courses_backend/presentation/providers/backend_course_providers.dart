import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_catalog.dart';
import '../../../../app/state/demo_catalog_support.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/config/app_environment.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/json_http_client.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/datasources/backend_course_remote_data_source.dart';
import '../../data/models/backend_course_dto.dart';
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

CommunityCourse adaptBackendCourseToCommunityCourse(BackendCourseDto course) {
  final mockTopicKeys = resolveMockTopicKeys(
    course.topic?.code ?? course.topic?.name,
  );
  final topicKey = mockTopicKeys.isEmpty
      ? courseTopicProgrammingLanguages
      : mockTopicKeys.first;
  final author = CommunityCourseAuthor(
    id: course.author.id.isEmpty
        ? 'backend-author-${course.id}'
        : course.author.id,
    name: _authorDisplayName(course.author.email),
    role: _authorRoleLabel(course.author),
    accentLabel: course.topic?.name.isNotEmpty == true
        ? course.topic!.name
        : course.status.name,
    followersCount: course.studentsCount,
    courseCount: 1,
    topicKeys: mockTopicKeys.isEmpty ? <String>[topicKey] : mockTopicKeys,
    summary: course.author.email,
    rating: course.rating,
    studentCount: course.studentsCount,
  );

  final title = course.title.trim().isEmpty ? 'Untitled course' : course.title;
  final subtitle = course.subtitle.trim().isEmpty
      ? 'Backend course preview'
      : course.subtitle.trim();
  final description = course.description.trim().isEmpty
      ? 'Course description is not available yet from the backend.'
      : course.description.trim();
  final tags = _courseTags(course);
  final lessonPreviews = _lessonPreviewsForCourse(course, title);

  return buildCommunityCourse(
    id: course.id,
    title: title,
    subtitle: subtitle,
    description: description,
    level: course.level.name.trim().isEmpty
        ? _mockLevelLabelForCode(course.level.code)
        : course.level.name.trim(),
    rating: course.rating,
    enrollmentCount: course.studentsCount,
    estimatedHours: math.max(1, course.expectedHours),
    color: _accentColorForCourse(course.id),
    author: author,
    categoryKey: topicKey,
    topicKeys: mockTopicKeys.isEmpty ? <String>[topicKey] : mockTopicKeys,
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
      languageLabel: 'Unknown',
      hasCertificate: course.hasCertificate,
      certificateLabel: course.hasCertificate
          ? 'Certificate included'
          : 'No certificate yet',
      startModeLabel: course.status.name,
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
    if (lower == courseTopicDataAnalytics &&
        haystacks.any((value) => value.contains('analytic'))) {
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
      normalized.contains('program')) {
    return const <String>[courseTopicProgrammingLanguages];
  }
  if (normalized == courseTopicDataAnalytics ||
      normalized.contains('analytic')) {
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
    if (course.level.name.trim().isNotEmpty) course.level.name.trim(),
  ];

  return values.isEmpty ? <String>[course.level.name] : values;
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
