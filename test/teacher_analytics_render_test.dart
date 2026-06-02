import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_flutter/app/state/demo_app_controller.dart';
import 'package:frontend_flutter/core/theme/app_theme.dart';
import 'package:frontend_flutter/features/teacher/presentation/pages/teacher_analytics_page.dart';
import 'package:frontend_flutter/features/teacher/presentation/pages/teacher_shell_page.dart';

void main() {
  testWidgets('teacher analytics section renders in the teacher shell', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const TeacherShellPage(section: TeacherSection.analytics),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TeacherAnalyticsPage), findsOneWidget);
  });
}
