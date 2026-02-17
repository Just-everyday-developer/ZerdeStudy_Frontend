import "package:flutter/material.dart";
import "package:frontend_flutter/features/auth/presentation/pages/welcome_page.dart";

import "app/routing/router.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'ZerdeStudy',
    );
  }

}