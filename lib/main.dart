import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/routing/router.dart';
import 'app/state/app_locale.dart';
import 'app/state/demo_app_controller.dart';
import 'core/localization/app_localizations.dart';
import 'core/providers/background_controller.dart';
import 'core/theme/app_theme.dart';

final backgroundController = BackgroundController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    backgroundController.initialize(this);
  }

  @override
  void dispose() {
    backgroundController.shutdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(
      demoAppControllerProvider.select((state) => state.locale),
    );
    final themeMode = ref.watch(
      demoAppControllerProvider.select((state) => state.themeMode),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'ZerdeStudy',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.materialMode,
      locale: locale.locale,
      supportedLocales: AppLocale.values
          .map((appLocale) => appLocale.locale)
          .toList(growable: false),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
