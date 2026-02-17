import 'package:frontend_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_flutter/features/auth/presentation/pages/welcome_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/sign_up.dart';

List<RouteBase> routes = [
  GoRoute(
    path: '/welcome',
    builder: (context, state) => WelcomePage(),
  ),
  GoRoute(
    path: '/login',
    builder: (context, state) => LoginPage(),
  ),
  GoRoute(
    path: '/signup',
    builder: (context, state) => SignUpPage(),
  )
];