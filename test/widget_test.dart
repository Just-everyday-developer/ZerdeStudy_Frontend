import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_flutter/app/state/app_locale.dart';
import 'package:frontend_flutter/app/state/demo_app_controller.dart';
import 'package:frontend_flutter/core/localization/app_localizations.dart';
import 'package:frontend_flutter/core/theme/app_theme.dart';
import 'package:frontend_flutter/features/ai/presentation/pages/ai_mentor_page.dart';
import 'package:frontend_flutter/features/auth/presentation/pages/welcome_page.dart';
import 'package:frontend_flutter/features/learning/presentation/pages/lesson_page.dart';
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
    await tester.tap(find.text('GitHub'));
    await pumpScene(tester);

    expect(find.text('Dashboard'), findsOneWidget);
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

  testWidgets('tree renders the new organic layout and opens track overview',
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

    await tester.tap(find.text('Tree'));
    await pumpScene(tester);

    expect(find.textContaining('grows like a real tree'), findsOneWidget);
    expect(find.text('Mathematical Analysis'), findsOneWidget);
    expect(find.text('Discrete Math'), findsOneWidget);
    expect(find.text('Linear Algebra'), findsOneWidget);

    await tester.tap(find.text('Discrete Math').first);
    await pumpScene(tester);

    expect(find.text('Track overview'), findsOneWidget);
    expect(find.text('Modules'), findsOneWidget);
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

    expect(find.text('Common questions'), findsOneWidget);
    expect(
      find.text('Why does the tree begin with Computer Science Core?'),
      findsOneWidget,
    );

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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
    await pumpScene(tester);

    await tester.scrollUntilVisible(find.text('Open catalog'), 300);
    await tester.tap(find.text('Open catalog'));
    await pumpScene(tester);

    expect(find.text('Community courses'), findsOneWidget);
    await tester.tap(find.text('Portfolio Engineering for Students'));
    await pumpScene(tester);

    expect(find.text('Save course'), findsOneWidget);
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

    await tester.tap(find.text('Open menu'));
    await pumpScene(tester);

    expect(find.text('Unlocked'), findsOneWidget);
    expect(find.text('Locked'), findsOneWidget);
  });
}
