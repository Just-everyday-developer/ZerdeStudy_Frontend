import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_flutter/app/state/app_locale.dart';
import 'package:frontend_flutter/app/state/demo_app_controller.dart';
import 'package:frontend_flutter/core/common_widgets/glow_card.dart';
import 'package:frontend_flutter/core/localization/app_localizations.dart';
import 'package:frontend_flutter/core/theme/app_theme.dart';
import 'package:frontend_flutter/features/ai/presentation/pages/ai_mentor_page.dart';
import 'package:frontend_flutter/features/auth/presentation/pages/welcome_page.dart';
import 'package:frontend_flutter/features/home/presentation/pages/community_course_detail_page.dart';
import 'package:frontend_flutter/features/home/presentation/pages/community_courses_page.dart';
import 'package:frontend_flutter/features/home/presentation/pages/home_page.dart';
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
  }) async {
    SharedPreferences.setMockInitialValues(mockValues);
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
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

  testWidgets('social login from welcome opens dashboard', (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    container.read(demoAppControllerProvider.notifier).changeLocale(AppLocale.en);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
    await pumpScene(tester);

    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Войти через'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple ID'), findsOneWidget);

    await tester.tap(find.text('Google'));
    await pumpScene(tester);

    expect(find.text('Daily mission'), findsOneWidget);
  });

  testWidgets('locale switch updates welcome CTA text', (tester) async {
    await configureSurface(tester);
    final container = await createContainer();

    await tester.pumpWidget(buildTestApp(container, const WelcomePage()));
    await pumpScene(tester);

    expect(find.text('Войти'), findsOneWidget);
    await tester.tap(find.text('EN'));
    await pumpScene(tester);

    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('tree renders the new unified tree and opens track overview',
      (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    final controller = container.read(demoAppControllerProvider.notifier);
    controller.changeLocale(AppLocale.en);
    controller.loginWithProvider('google');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
    await pumpScene(tester);

    await tester.tap(find.byIcon(Icons.account_tree_outlined));
    await pumpScene(tester);

    expect(find.textContaining('One connected knowledge tree grows'), findsOneWidget);
    expect(find.text('Computer Science'), findsWidgets);
    expect(find.text('Operating Systems'), findsWidgets);
    expect(find.text('Frontend'), findsWidgets);
    expect(find.text('Visible branches'), findsOneWidget);

    await tester.tap(find.text('Discrete Math').first);
    await pumpScene(tester);

    expect(find.text('Track overview'), findsOneWidget);
    expect(find.text('Modules'), findsOneWidget);
    expect(find.text('Track assessment'), findsOneWidget);
  });

  testWidgets('lesson requires quiz and memory lab before completion', (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    container.read(demoAppControllerProvider.notifier).changeLocale(AppLocale.en);

    await tester.pumpWidget(
      buildTestApp(
        container,
        const LessonPage(lessonId: 'fundamentals_lesson_2_2'),
      ),
    );
    await pumpScene(tester);

    expect(find.text('Output Quiz'), findsOneWidget);
    expect(find.text('Code Memory Lab'), findsOneWidget);

    await tester.tap(find.text('3'));
    await pumpScene(tester);
    await tester.tap(find.text('Check answer'));
    await pumpScene(tester);

    container.read(demoAppControllerProvider.notifier).completeTrainer(
          'fundamentals_lesson_2_2_trainer_1',
        );
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

  testWidgets('ai mentor returns different deterministic replies for different intents',
      (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    container.read(demoAppControllerProvider.notifier).changeLocale(AppLocale.en);

    await tester.pumpWidget(buildTestApp(container, const AiMentorPage()));
    await pumpScene(tester);

    expect(find.text('Prepared questions'), findsOneWidget);
    expect(find.text('Where should I start in this tree?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Explain the tree');
    await tester.tap(find.text('Send'));
    await pumpScene(tester);
    final firstReply = container.read(demoAppControllerProvider).aiMessages.last.text;

    await tester.enterText(
      find.byType(TextField).last,
      'Give me a hint for the next output quiz.',
    );
    await tester.tap(find.text('Send'));
    await pumpScene(tester);
    final secondReply = container.read(demoAppControllerProvider).aiMessages.last.text;

    expect(firstReply, isNot(secondReply));
  });

  testWidgets('home community block opens catalog and detail page', (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    final controller = container.read(demoAppControllerProvider.notifier);
    controller.changeLocale(AppLocale.en);
    controller.loginWithProvider('google');

    await tester.pumpWidget(buildTestApp(container, const HomePage()));
    await pumpScene(tester);

    await tester.scrollUntilVisible(
      find.text('Courses from the community'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Courses from the community'), findsOneWidget);

    await tester.pumpWidget(buildTestApp(container, const CommunityCoursesPage()));
    await pumpScene(tester);

    expect(find.text('Community courses'), findsOneWidget);

    await tester.pumpWidget(
      buildTestApp(
        container,
        const CommunityCourseDetailPage(
          courseId: 'course_portfolio_engineering',
        ),
      ),
    );
    await pumpScene(tester);

    expect(find.text('Save course'), findsOneWidget);
  });

  testWidgets('track assessment submits and persists result', (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    container.read(demoAppControllerProvider.notifier).changeLocale(AppLocale.en);

    await tester.pumpWidget(
      buildTestApp(
        container,
        const TrackAssessmentPage(trackId: 'frontend'),
      ),
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
        find.descendant(of: card.first, matching: find.text(correctOption)).first,
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
    expect(submittedResult?.attemptCount, greaterThanOrEqualTo(1));

    final preferences = await SharedPreferences.getInstance();
    final storedState = preferences.getString('zerdestudy_demo_state_v4');
    expect(storedState, isNotNull);

    final restarted = await createContainer(
      mockValues: <String, Object>{
        'zerdestudy_demo_state_v4': storedState!,
      },
    );
    expect(
      restarted
          .read(demoAppControllerProvider)
          .assessmentResultsByTrackId['frontend']
          ?.bestPercent,
      100,
    );
  });

  testWidgets('profile reset restores seeded progress', (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    final controller = container.read(demoAppControllerProvider.notifier);
    controller.changeLocale(AppLocale.en);
    controller.loginWithProvider('google');
    controller.completeQuiz('fundamentals_lesson_2_2_quiz_1', isCorrect: true);
    controller.completeTrainer('fundamentals_lesson_2_2_trainer_1');
    controller.completeLesson('fundamentals_lesson_2_2');

    expect(
      container.read(demoAppControllerProvider).completedLessonIds,
      contains('fundamentals_lesson_2_2'),
    );

    await tester.pumpWidget(buildTestApp(container, const ProfilePage()));
    await pumpScene(tester);

    await tester.scrollUntilVisible(find.byIcon(Icons.restart_alt_rounded), 300);
    await tester.tap(find.byIcon(Icons.restart_alt_rounded));
    await pumpScene(tester);

    final state = container.read(demoAppControllerProvider);
    expect(state.completedLessonIds, isNot(contains('fundamentals_lesson_2_2')));
    expect(state.isAuthenticated, isTrue);
  });

  testWidgets('profile achievements menu opens unlocked and locked sections',
      (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    final controller = container.read(demoAppControllerProvider.notifier);
    controller.changeLocale(AppLocale.en);
    controller.loginWithProvider('google');

    await tester.pumpWidget(buildTestApp(container, const ProfilePage()));
    await pumpScene(tester);

    await tester.tap(find.text('Open'));
    await pumpScene(tester);

    expect(find.text('Unlocked'), findsOneWidget);
    expect(find.text('Locked'), findsOneWidget);
  });

  testWidgets('profile shows favorites completed items and history', (tester) async {
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

    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Secure API Clinic'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Completed'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Frontend'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Result history'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Result history'), findsOneWidget);
    expect(find.text('Track assessment completed'), findsOneWidget);
  });
}
