import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_flutter/app/state/app_locale.dart';
import 'package:frontend_flutter/app/state/demo_app_controller.dart';
import 'package:frontend_flutter/core/localization/app_localizations.dart';
import 'package:frontend_flutter/core/network/json_http_client.dart';
import 'package:frontend_flutter/core/theme/app_theme.dart';
import 'package:frontend_flutter/features/auth/presentation/providers/auth_controller.dart';
import 'package:frontend_flutter/features/courses_backend/data/datasources/backend_course_remote_data_source.dart';
import 'package:frontend_flutter/features/courses_backend/data/models/backend_course_dto.dart';
import 'package:frontend_flutter/features/courses_backend/data/models/backend_course_query.dart';
import 'package:frontend_flutter/features/courses_backend/presentation/providers/backend_course_providers.dart';
import 'package:frontend_flutter/features/home/presentation/pages/community_courses_page.dart';
import 'package:frontend_flutter/features/learning/presentation/pages/learn_page.dart';

void main() {
  Future<void> configureSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Future<ProviderContainer> createContainer({
    Map<String, Object> mockValues = const <String, Object>{},
    List<dynamic> overrides = const <dynamic>[],
  }) async {
    SharedPreferences.setMockInitialValues(mockValues);
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        authSharedPreferencesProvider.overrideWithValue(preferences),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget buildTestApp(ProviderContainer container, Widget child) {
    return UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) {
          final locale = ref.watch(
            demoAppControllerProvider.select((state) => state.locale),
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            locale: locale.locale,
            supportedLocales: AppLocale.values
                .map((appLocale) => appLocale.locale)
                .toList(growable: false),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: child,
          );
        },
      ),
    );
  }

  test(
    'backend course query builds snake_case params with default published',
    () {
      const query = BackendCourseQuery(
        minRating: 4.0,
        levelCode: 'intermediate',
        durationCode: 'quick',
        topicCode: 'Database systems',
      );

      expect(query.queryParameters, <String, String>{
        'min_rating': '4.0',
        'level': 'intermediate',
        'status': 'published',
        'duration_category': 'quick',
        'topic': 'Database systems',
      });
    },
  );

  test('backend course adapter creates preview-only community course', () {
    final course = adaptBackendCourseToCommunityCourse(
      BackendCourseDto.fromJson(sampleBackendCourses.first),
    );

    expect(course.id, 'backend_go_1');
    expect(course.supportsCoursePlayer, isFalse);
    expect(course.facts.hasCertificate, isTrue);
    expect(course.reviewSummary.reviewCount, 18);
    expect(course.learningOutcomes, contains('Build REST APIs with Gin'));
  });

  testWidgets(
    'learn shows backend popular rail first and keeps SQL comparison',
    (tester) async {
      await configureSurface(tester);
      final container = await createContainer(
        overrides: [
          backendCourseAccessTokenProvider.overrideWith((ref) => 'test-token'),
          backendCourseRemoteDataSourceProvider.overrideWithValue(
            FakeBackendCourseRemoteDataSource(),
          ),
        ],
      );
      container
          .read(demoAppControllerProvider.notifier)
          .changeLocale(AppLocale.en);

      await tester.pumpWidget(buildTestApp(container, const LearnPage()));
      await tester.pumpAndSettle();

      expect(find.text('Popular courses'), findsOneWidget);
      expect(find.text('Go Backend Development'), findsOneWidget);
      expect(find.text('SQL for Product Analysts'), findsWidgets);

      final popularTop = tester.getTopLeft(find.text('Popular courses')).dy;
      final programmingTop = tester
          .getTopLeft(find.text('Programming languages'))
          .dy;
      expect(popularTop, lessThan(programmingTop));
    },
  );

  testWidgets(
    'catalog shows backend block above mock grid and search filters it',
    (tester) async {
      await configureSurface(tester);
      final container = await createContainer(
        overrides: [
          backendCourseAccessTokenProvider.overrideWith((ref) => 'test-token'),
          backendCourseRemoteDataSourceProvider.overrideWithValue(
            FakeBackendCourseRemoteDataSource(),
          ),
        ],
      );
      container
          .read(demoAppControllerProvider.notifier)
          .changeLocale(AppLocale.en);

      await tester.pumpWidget(
        buildTestApp(container, const CommunityCoursesPage()),
      );
      await tester.pumpAndSettle();

      final backendTop = tester
          .getTopLeft(find.text('Go Backend Development'))
          .dy;
      final mockTop = tester
          .getTopLeft(find.text('Portfolio Engineering for Students'))
          .dy;
      expect(backendTop, lessThan(mockTop));

      await tester.enterText(find.byType(TextField).first, 'Python');
      await tester.pumpAndSettle();

      expect(find.text('Python Builders'), findsOneWidget);
      expect(find.text('Go Backend Development'), findsNothing);
    },
  );
}

class FakeBackendCourseRemoteDataSource extends BackendCourseRemoteDataSource {
  FakeBackendCourseRemoteDataSource()
    : super(
        JsonHttpClient(
          client: http.Client(),
          uriResolver: (_) => Uri.parse('http://localhost'),
        ),
      );

  @override
  Future<List<BackendCourseDto>> fetchCourses({
    required String accessToken,
    BackendCourseQuery query = const BackendCourseQuery(),
  }) async {
    return sampleBackendCourses
        .map(BackendCourseDto.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<BackendDictionaryEntryDto>> fetchDurationCategories({
    required String accessToken,
  }) async {
    return sampleDurationCategories
        .map(BackendDictionaryEntryDto.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<BackendDictionaryEntryDto>> fetchLevels({
    required String accessToken,
  }) async {
    return sampleLevels
        .map(BackendDictionaryEntryDto.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<BackendDictionaryEntryDto>> fetchStatuses({
    required String accessToken,
  }) async {
    return sampleStatuses
        .map(BackendDictionaryEntryDto.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<BackendDictionaryEntryDto>> fetchTopics({
    required String accessToken,
  }) async {
    return sampleTopics
        .map(BackendDictionaryEntryDto.fromJson)
        .toList(growable: false);
  }
}

const sampleBackendCourses = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'backend_go_1',
    'title': 'Go Backend Development',
    'sub_title': 'Build modern backend services with Go',
    'description':
        'A practical course on building REST APIs and backend services using Go.',
    'expected_hours': 40,
    'rating': 4.5,
    'rating_count': 18,
    'students_count': 120,
    'lessons_count': 12,
    'has_certificate': true,
    'cover_image_url': 'https://example.com/go.png',
    'status': <String, dynamic>{
      'id': 'status_published',
      'name': 'Опубликовано',
      'code': 'published',
    },
    'level': <String, dynamic>{
      'id': 'level_intermediate',
      'name': 'средний',
      'code': 'intermediate',
    },
    'duration_category': <String, dynamic>{
      'id': 'duration_quick',
      'name': 'быстрый',
      'code': 'quick',
    },
    'author': <String, dynamic>{
      'id': 'author_go',
      'email': 'aliya@akm123.com',
      'roles': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'teacher_role',
          'code': 'teacher',
          'name': 'Teacher',
        },
      ],
      'is_active': true,
    },
    'tags': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'tag_backend',
        'name': 'бэкенд',
        'code': 'backend',
      },
    ],
    'topic': <String, dynamic>{
      'id': 'topic_database',
      'name': 'База Данных',
      'code': 'Database systems',
    },
    'learning_outcome': <String>[
      'Understand Go syntax and structure',
      'Build REST APIs with Gin',
      'Work with PostgreSQL and GORM',
    ],
  },
  <String, dynamic>{
    'id': 'backend_python_2',
    'title': 'Python Builders',
    'sub_title': 'Ship backend scripts and APIs faster',
    'description':
        'A backend-flavored Python course for quick tooling and service work.',
    'expected_hours': 24,
    'rating': 4.7,
    'rating_count': 11,
    'students_count': 80,
    'lessons_count': 9,
    'has_certificate': false,
    'cover_image_url': '',
    'status': <String, dynamic>{
      'id': 'status_published',
      'name': 'Опубликовано',
      'code': 'published',
    },
    'level': <String, dynamic>{
      'id': 'level_beginner',
      'name': 'начинающий',
      'code': 'beginner',
    },
    'duration_category': <String, dynamic>{
      'id': 'duration_quick',
      'name': 'быстрый',
      'code': 'quick',
    },
    'author': <String, dynamic>{
      'id': 'author_python',
      'email': 'python@akm123.com',
      'roles': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'teacher_role',
          'code': 'teacher',
          'name': 'Teacher',
        },
      ],
      'is_active': true,
    },
    'tags': <Map<String, dynamic>>[
      <String, dynamic>{'id': 'tag_python', 'name': 'python', 'code': 'python'},
    ],
    'topic': <String, dynamic>{
      'id': 'topic_programming',
      'name': 'Ознакомление с программированием',
      'code': 'Introduction to Programming',
    },
    'learning_outcome': <String>[
      'Write small backend utilities',
      'Automate repetitive workflows',
    ],
  },
];

const sampleLevels = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'level_beginner',
    'name': 'начинающий',
    'code': 'beginner',
  },
  <String, dynamic>{
    'id': 'level_intermediate',
    'name': 'средний',
    'code': 'intermediate',
  },
];

const sampleTopics = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'topic_database',
    'name': 'База Данных',
    'code': 'Database systems',
  },
  <String, dynamic>{
    'id': 'topic_programming',
    'name': 'Ознакомление с программированием',
    'code': 'Introduction to Programming',
  },
];

const sampleDurationCategories = <Map<String, dynamic>>[
  <String, dynamic>{'id': 'duration_quick', 'name': 'быстрый', 'code': 'quick'},
  <String, dynamic>{'id': 'duration_deep', 'name': 'глубокий', 'code': 'deep'},
];

const sampleStatuses = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'status_published',
    'name': 'Опубликовано',
    'code': 'published',
  },
];
