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

  testWidgets('demo entry from welcome opens dashboard', (tester) async {
    await configureSurface(tester);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Войти в демо'), findsOneWidget);

    await tester.ensureVisible(find.text('Войти в демо'));
    await tester.tap(find.text('Войти в демо'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(find.text('Дашборд'), findsOneWidget);
  });

  testWidgets('locale switch updates welcome CTA', (tester) async {
    await configureSurface(tester);
    final container = await createContainer();

    await tester.pumpWidget(
      buildTestApp(container, const WelcomePage()),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Войти в демо'), findsOneWidget);

    await tester.ensureVisible(find.text('EN'));
    await tester.tap(find.text('EN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Enter demo'), findsOneWidget);
  });

  testWidgets('completing a lesson updates demo state', (tester) async {
    await configureSurface(tester);
    final container = await createContainer();

    await tester.pumpWidget(
      buildTestApp(
        container,
        const LessonPage(lessonId: 'fundamentals_flow'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      container.read(demoAppControllerProvider).completedLessonIds,
      isNot(contains('fundamentals_flow')),
    );

    await tester.ensureVisible(find.text('Завершить урок'));
    await tester.tap(find.text('Завершить урок'));
    await tester.pump();

    expect(
      container.read(demoAppControllerProvider).completedLessonIds,
      contains('fundamentals_flow'),
    );
    expect(find.text('+55 XP'), findsOneWidget);
  });

  testWidgets('ai mentor sends message and appends deterministic reply',
      (tester) async {
    await configureSurface(tester);
    final container = await createContainer();

    await tester.pumpWidget(
      buildTestApp(container, const AiMentorPage()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(
      find.byType(TextField).last,
      'How do I debug this?',
    );
    await tester.tap(find.text('Отправить'));
    await tester.pump();

    final messages = container.read(demoAppControllerProvider).aiMessages;
    expect(messages.length, 3);
    expect(messages.last.author.name, 'mentor');
  });

  testWidgets('profile reset restores seeded progress', (tester) async {
    await configureSurface(tester);
    final container = await createContainer();
    final controller = container.read(demoAppControllerProvider.notifier);
    controller.loginWithEmail(email: 'demo@zerdestudy.app');
    controller.completeLesson('fundamentals_flow');

    expect(
      container.read(demoAppControllerProvider).completedLessonIds,
      contains('fundamentals_flow'),
    );

    await tester.pumpWidget(
      buildTestApp(container, const ProfilePage()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.text('Сбросить демо'));
    await tester.tap(find.text('Сбросить демо'));
    await tester.pump();

    final state = container.read(demoAppControllerProvider);
    expect(state.completedLessonIds, isNot(contains('fundamentals_flow')));
    expect(state.isAuthenticated, isTrue);
  });
}
