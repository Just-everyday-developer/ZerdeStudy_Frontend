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
    expect(find.text('Continue with'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple ID'), findsOneWidget);

    await tester.tap(find.text('Google'));
    await pumpScene(tester);

    expect(find.text('Daily mission'), findsOneWidget);
  });

  testWidgets('knowledge tree summary renders and opens track overview',
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

    expect(find.textContaining('single knowledge tree'), findsOneWidget);
    expect(find.text('Visible branches'), findsOneWidget);
    expect(find.text('Operating Systems'), findsWidgets);
    expect(find.text('Frontend'), findsWidgets);

    await tester.tap(find.text('Discrete Math').first);
    await pumpScene(tester);

    expect(find.text('Track overview'), findsOneWidget);
    expect(find.text('Modules'), findsOneWidget);
  });

  testWidgets('learn discovery page shows search rails and frequent searches',
      (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    container.read(demoAppControllerProvider.notifier).changeLocale(AppLocale.en);

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

  testWidgets('catalog applies initial topic filter and search', (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    container.read(demoAppControllerProvider.notifier).changeLocale(AppLocale.en);

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

  testWidgets('home no longer shows community or achievements previews',
      (tester) async {
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

  testWidgets('lesson requires quiz and memory lab before completion',
      (tester) async {
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
    await tester.scrollUntilVisible(
      find.text('Code Memory Lab'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
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

    final preferences = await SharedPreferences.getInstance();
    final storedState = preferences.getString('zerdestudy_demo_state_v4');
    expect(storedState, isNotNull);
  });

  testWidgets('profile shows achievements preview favorites and history',
      (tester) async {
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
      find.text('Favorites'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Secure API Clinic'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Completed'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Completed'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Result history'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Result history'), findsOneWidget);
  });

  testWidgets('ai mentor still returns deterministic replies', (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    container.read(demoAppControllerProvider.notifier).changeLocale(AppLocale.en);

    await tester.pumpWidget(buildTestApp(container, const AiMentorPage()));
    await pumpScene(tester);

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
    final secondReply =
        container.read(demoAppControllerProvider).aiMessages.last.text;

    expect(firstReply, isNot(secondReply));
  });
}
