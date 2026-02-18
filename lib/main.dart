import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "app/routing/router.dart";
import "core/providers/background_controller.dart";

final backgroundController = BackgroundController();

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    backgroundController.initialize(this); // Запускаем один раз на всё приложение
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'ZerdeStudy',
    );
  }
}