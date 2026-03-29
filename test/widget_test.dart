import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_flutter/app/state/app_locale.dart';
import 'package:frontend_flutter/app/state/demo_app_controller.dart';
import 'package:frontend_flutter/core/network/json_http_client.dart';
import 'package:frontend_flutter/core/common_widgets/glow_card.dart';
import 'package:frontend_flutter/core/localization/app_localizations.dart';
import 'package:frontend_flutter/core/theme/app_theme.dart';
import 'package:frontend_flutter/features/ai/data/datasources/ai_chat_remote_data_source.dart';
import 'package:frontend_flutter/features/ai/data/models/ai_chat_reply_dto.dart';
import 'package:frontend_flutter/features/ai/presentation/pages/ai_mentor_page.dart';
import 'package:frontend_flutter/features/ai/presentation/providers/ai_chat_controller.dart';
import 'package:frontend_flutter/features/auth/presentation/providers/auth_controller.dart';
import 'package:frontend_flutter/features/auth/domain/entities/auth_role.dart';
import 'package:frontend_flutter/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_flutter/features/auth/domain/entities/auth_user.dart';
import 'package:frontend_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_flutter/features/home/presentation/pages/community_courses_page.dart';
import 'package:frontend_flutter/features/home/presentation/pages/home_page.dart';
import 'package:frontend_flutter/features/learning/presentation/pages/learn_page.dart';
import 'package:frontend_flutter/features/learning/presentation/pages/lesson_page.dart';
import 'package:frontend_flutter/features/learning/presentation/pages/track_assessment_page.dart';
import 'package:frontend_flutter/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend_flutter/main.dart';

void main() {
  Future<void> configureSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Future<ProviderContainer> createContainer({
    Map<String, Object> mockValues = const <String, Object>{},
    List<dynamic> overrides = const [],
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

  Future<void> pumpScene(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('email login from welcome opens dashboard', (tester) async {
    await configureSurface(tester);
    final container = await createContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );
    container
        .read(demoAppControllerProvider.notifier)
        .changeLocale(AppLocale.en);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await pumpScene(tester);

    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);

    await tester.tap(find.text('Log in'));
    await pumpScene(tester);

    await tester.enterText(find.byType(TextField).at(0), 'student@zerde.study');
    await tester.enterText(find.byType(TextField).at(1), '05072006');
    await tester.tap(find.text('Log in').last);
    await pumpScene(tester);

    expect(find.text('Recommended tracks'), findsOneWidget);
  });

  testWidgets('ctrl+k opens learn and reveals search', (tester) async {
    await configureSurface(tester);
    final container = await createContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(
            initialSession: fakeStudentSession(email: 'student@zerde.study'),
          ),
        ),
      ],
    );
    container
        .read(demoAppControllerProvider.notifier)
        .changeLocale(AppLocale.en);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await pumpScene(tester);

    expect(find.text('Recommended tracks'), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await pumpScene(tester);

    expect(find.text('Search courses'), findsOneWidget);
    expect(find.text('Programming languages'), findsOneWidget);
  });

  testWidgets('forgot password flow opens code page and authenticates', (
    tester,
  ) async {
    await configureSurface(tester);
    final container = await createContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );
    container
        .read(demoAppControllerProvider.notifier)
        .changeLocale(AppLocale.en);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await pumpScene(tester);

    await tester.tap(find.text('Forgot password?'));
    await pumpScene(tester);
    await tester.enterText(find.byType(TextField).first, 'student@zerde.study');
    await tester.tap(find.text('Send code'));
    await pumpScene(tester);

    expect(find.byType(TextField), findsNWidgets(8));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'student@zerde.study');
    for (var i = 0; i < 6; i++) {
      await tester.enterText(fields.at(i + 1), '${i + 1}');
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.enterText(fields.at(7), 'Newpass123');

    await tester.tap(find.text('Verify and continue'));
    await pumpScene(tester);

    expect(container.read(authControllerProvider).isAuthenticated, isTrue);
  });

  testWidgets('knowledge tree renders and opens track overview', (
    tester,
  ) async {
    await configureSurface(tester);
    final container = await createContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(
            initialSession: fakeStudentSession(email: 'student@zerde.study'),
          ),
        ),
      ],
    );
    container
        .read(demoAppControllerProvider.notifier)
        .changeLocale(AppLocale.en);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await pumpScene(tester);

    await tester.tap(find.text('Tree'));
    await pumpScene(tester);

    expect(find.text('Legend'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsNothing);
    expect(find.text('Operating Systems'), findsWidgets);
    expect(find.text('Frontend'), findsWidgets);

    await tester.tap(find.text('Discrete Math').first);
    await pumpScene(tester);

    expect(find.text('Track overview'), findsOneWidget);
    expect(find.text('Modules'), findsOneWidget);
  });

  testWidgets('learn discovery page shows search rails and frequent searches', (
    tester,
  ) async {
    await configureSurface(tester);
    final container = await createContainer();
    container
        .read(demoAppControllerProvider.notifier)
        .changeLocale(AppLocale.en);

    await tester.pumpWidget(buildTestApp(container, const LearnPage()));
    await pumpScene(tester);

    expect(find.text('Search courses'), findsOneWidget);
    expect(find.text('Programming languages'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Popular course authors'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Popular course authors'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Frequent searches'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Frequent searches'), findsOneWidget);
  });

  testWidgets('catalog applies initial topic filter and search', (
    tester,
  ) async {
    await configureSurface(tester);
    final container = await createContainer();
    container
        .read(demoAppControllerProvider.notifier)
        .changeLocale(AppLocale.en);

    await tester.pumpWidget(
      buildTestApp(
        container,
        const CommunityCoursesPage(initialTopicKey: 'sql_databases'),
      ),
    );
    await pumpScene(tester);

    expect(find.text('Search courses'), findsOneWidget);
    expect(find.text('SQL for Product Analysts'), findsOneWidget);
    expect(find.text('Feedback That Helps Teams Ship'), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'PostgreSQL');
    await pumpScene(tester);

    expect(find.text('PostgreSQL Performance First'), findsOneWidget);
  });

  testWidgets('home no longer shows community or achievements previews', (
    tester,
  ) async {
    await configureSurface(tester);
    final container = await createContainer();
    final controller = container.read(demoAppControllerProvider.notifier);
    controller.changeLocale(AppLocale.en);
    controller.loginWithProvider('google');

    await tester.pumpWidget(buildTestApp(container, const HomePage()));
    await pumpScene(tester);

    expect(find.text('Courses from the community'), findsNothing);
    expect(find.text('Achievements'), findsNothing);
    expect(find.text('Recommended tracks'), findsOneWidget);
  });

  testWidgets('lesson requires quiz and memory lab before completion', (
    tester,
  ) async {
    await configureSurface(tester);
    final container = await createContainer();
    container
        .read(demoAppControllerProvider.notifier)
        .changeLocale(AppLocale.en);

    await tester.pumpWidget(
      buildTestApp(
        container,
        const LessonPage(lessonId: 'fundamentals_lesson_2_2'),
      ),
    );
    await pumpScene(tester);

    final lesson = container
        .read(demoCatalogProvider)
        .lessonById('fundamentals_lesson_2_2');
    final quizTitle = lesson.quizzes.first.prompt.resolve(AppLocale.en);

    expect(find.text(quizTitle), findsOneWidget);

    await tester.tap(find.text('3'));
    await pumpScene(tester);
    await tester.tap(find.text('Check answer'));
    await pumpScene(tester);

    container
        .read(demoAppControllerProvider.notifier)
        .completeTrainer('fundamentals_lesson_2_2_trainer_1');
    await pumpScene(tester);

    await tester.scrollUntilVisible(
      find.text('Complete lesson'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Complete lesson'));
    await pumpScene(tester);

    expect(
      container.read(demoAppControllerProvider).completedLessonIds,
      contains('fundamentals_lesson_2_2'),
    );
  });

  testWidgets('track assessment submits and persists result', (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    container
        .read(demoAppControllerProvider.notifier)
        .changeLocale(AppLocale.en);

    await tester.pumpWidget(
      buildTestApp(container, const TrackAssessmentPage(trackId: 'frontend')),
    );
    await pumpScene(tester);

    final assessment = container
        .read(demoCatalogProvider)
        .assessmentForTrack('frontend');

    for (final question in assessment.questions) {
      final prompt = question.prompt.resolve(AppLocale.en);
      final correctOption = question.options
          .firstWhere((option) => option.id == question.correctOptionId)
          .label
          .resolve(AppLocale.en);
      final card = find.ancestor(
        of: find.text(prompt),
        matching: find.byType(GlowCard),
      );

      await tester.scrollUntilVisible(
        find.text(prompt),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(
        find
            .descendant(of: card.first, matching: find.text(correctOption))
            .first,
      );
      await pumpScene(tester);
    }

    await tester.scrollUntilVisible(
      find.text('Submit assessment'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Submit assessment'));
    await pumpScene(tester);

    final submittedResult = container
        .read(demoAppControllerProvider)
        .assessmentResultsByTrackId['frontend'];
    expect(submittedResult?.bestPercent, 100);
    expect(submittedResult?.lastPercent, 100);

    final preferences = await SharedPreferences.getInstance();
    final storedState = preferences.getString('zerdestudy_demo_state_v4');
    expect(storedState, isNotNull);
  });

  testWidgets('profile shows achievements preview favorites and history', (
    tester,
  ) async {
    await configureSurface(tester);
    final container = await createContainer();
    final controller = container.read(demoAppControllerProvider.notifier);
    final catalog = container.read(demoCatalogProvider);
    controller.changeLocale(AppLocale.en);
    controller.loginWithProvider('google');
    controller.saveCommunityCourse('course_secure_api_clinic');

    final frontend = catalog.trackById('frontend');
    for (final module in frontend.modules) {
      for (final lesson in module.lessons) {
        controller.completeQuiz(lesson.quizzes.first.id, isCorrect: true);
        controller.completeTrainer(lesson.codeTrainers.first.id);
        controller.completeLesson(lesson.id);
      }
      if (module.practice != null) {
        controller.completePractice(module.practice!.id);
      }
    }
    controller.submitTrackAssessment(
      trackId: 'frontend',
      selectedOptionIds: <String, String>{
        for (final question in catalog.assessmentForTrack('frontend').questions)
          question.id: question.correctOptionId,
      },
    );

    await tester.pumpWidget(buildTestApp(container, const ProfilePage()));
    await pumpScene(tester);

    expect(find.text('Achievements'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Favorites').first,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Secure API Clinic'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Completed').first,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Completed'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
    await pumpScene(tester);
    expect(find.text('Result history'), findsWidgets);
  });

  testWidgets('ai mentor still returns deterministic replies', (tester) async {
    await configureSurface(tester);
    final container = await createContainer(
      overrides: [
        aiChatRemoteDataSourceProvider.overrideWithValue(
          FakeAiChatRemoteDataSource(),
        ),
      ],
    );
    container
        .read(demoAppControllerProvider.notifier)
        .changeLocale(AppLocale.en);

    await tester.pumpWidget(buildTestApp(container, const AiMentorPage()));
    await pumpScene(tester);

    await tester.enterText(find.byType(TextField).last, 'Explain the tree');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await pumpScene(tester);
    final firstReply = container
        .read(demoAppControllerProvider)
        .aiMessages
        .last
        .text;

    await tester.enterText(
      find.byType(TextField).last,
      'Give me a hint for the next output quiz.',
    );
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await pumpScene(tester);
    final secondReply = container
        .read(demoAppControllerProvider)
        .aiMessages
        .last
        .text;

    expect(firstReply, isNot(secondReply));
  });
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthSession? initialSession}) : _session = initialSession;

  AuthSession? _session;

  @override
  Future<AuthSession?> restoreSession() async => _session;

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
  }) async {
    _session = fakeStudentSession(email: email);
    return _session!;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    _session = fakeStudentSession(email: email);
    return _session!;
  }

  @override
  Future<AuthSession> refreshSession() async {
    _session ??= fakeStudentSession(email: 'student@zerde.study');
    return _session!;
  }

  @override
  Future<void> logout() async {
    _session = null;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {}
}

AuthSession fakeStudentSession({required String email}) {
  return AuthSession(
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
    user: AuthUser(
      id: 'student-1',
      email: email,
      roles: <AuthRole>[
        AuthRole(
          id: 'role-student',
          code: 'student',
          name: 'Student',
          description: 'Student role',
          isDefault: true,
          isPrivileged: false,
          isSupport: false,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
  );
}

class FakeAiChatRemoteDataSource extends AiChatRemoteDataSource {
  FakeAiChatRemoteDataSource()
    : super(
        JsonHttpClient(
          client: http.Client(),
          uriResolver: (_) => Uri.parse('http://localhost'),
        ),
      );

  @override
  Future<AiChatReplyDto> sendMessage({
    required String conversation,
    required String appContext,
    String? userId,
  }) async {
    final latestMessage = conversation.trim().split('\n').last.toLowerCase();
    final text = latestMessage.contains('tree')
        ? 'The tree groups topics into connected branches so you can see prerequisites and the next step.'
        : 'Start with the last visible value, then trace the update line by line before choosing an answer.';

    return AiChatReplyDto(
      text: text,
      provider: 'fake',
      model: 'fake-model',
      latencyMs: 1,
    );
  }
}
