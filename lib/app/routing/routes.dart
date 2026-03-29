import 'package:go_router/go_router.dart';
import 'package:frontend_flutter/features/home/presentation/pages/home_page.dart';
import 'package:frontend_flutter/features/knowledge_tree/presentation/pages/knowledge_tree.dart';
import 'package:frontend_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_flutter/features/auth/presentation/pages/welcome_page.dart';
import 'package:frontend_flutter/features/auth/presentation/pages/sign_up_page.dart';
import '../../core/utils/cyber_transition.dart';

List<RouteBase> routes = [
  GoRoute(
    path: '/welcome',
    pageBuilder: (context, state) =>
        cyberTransition(state: state, child: const WelcomePage()),
  ),
  GoRoute(
    path: '/login',
    pageBuilder: (context, state) =>
        cyberTransition(state: state, child: const LoginPage()),
  ),
  GoRoute(
    path: '/signup',
    pageBuilder: (context, state) =>
        cyberTransition(state: state, child: const SignUpPage()),
  ),
  GoRoute(
    path: '/home',
    pageBuilder: (context, state) =>
        cyberTransition(state: state, child: const HomePage()),
  ),
  GoRoute(
    path: '/tree',
    pageBuilder: (context, state) =>
        cyberTransition(state: state, child: const KnowledgeTreePage()),
  ),
];
