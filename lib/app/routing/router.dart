import 'package:flutter/material.dart';
import 'package:frontend_flutter/app/routing/routes.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: "/welcome",
  routes: routes,
  errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
    body: Center(
      child: Text("Something went wrong"),
    ),
  )
);