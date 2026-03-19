import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/common_widgets/app_shell_scaffold.dart';
import '../../core/utils/cyber_transition.dart';
import '../../features/ai/presentation/pages/ai_mentor_page.dart';
import '../../features/analytics/presentation/pages/leaderboard_page.dart';
import '../../features/analytics/presentation/pages/stats_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/home/presentation/pages/community_course_detail_page.dart';
import '../../features/home/presentation/pages/community_course_player_page.dart';
import '../../features/home/presentation/pages/community_courses_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/knowledge_tree/presentation/pages/knowledge_tree.dart';
import '../../features/learning/presentation/pages/learn_page.dart';
import '../../features/learning/presentation/pages/track_assessment_page.dart';
import '../../features/learning/presentation/pages/lesson_page.dart';
import '../../features/learning/presentation/pages/practice_page.dart';
import '../../features/learning/presentation/pages/track_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../state/demo_app_controller.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _treeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'tree');
final GlobalKey<NavigatorState> _learnNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'learn');
final GlobalKey<NavigatorState> _aiNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'ai');
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(
    demoAppControllerProvider.select((state) => state.isAuthenticated),
  );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.welcome,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final isAuthRoute = <String>{
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.signup,
      }.contains(path);

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.welcome;
      }
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const WelcomePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const SignUpPage(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScaffold(
            navigationShell: navigationShell,
            navigatorKeys: <GlobalKey<NavigatorState>>[
              _homeNavigatorKey,
              _treeNavigatorKey,
              _learnNavigatorKey,
              _aiNavigatorKey,
              _profileNavigatorKey,
            ],
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _treeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.tree,
                builder: (context, state) => const KnowledgeTreePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _learnNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.learn,
                builder: (context, state) => const LearnPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _aiNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.ai,
                builder: (context, state) => const AiMentorPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.track}/:trackId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: TrackPage(
            trackId: state.pathParameters['trackId'] ?? 'fundamentals',
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.lesson}/:lessonId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: LessonPage(
            lessonId: state.pathParameters['lessonId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.practice}/:practiceId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: PracticePage(
            practiceId: state.pathParameters['practiceId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.assessment}/:trackId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: TrackAssessmentPage(
            trackId: state.pathParameters['trackId'] ?? 'fundamentals',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.stats,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const StatsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const LeaderboardPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.courses,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: CommunityCoursesPage(
            initialTopicKey: state.uri.queryParameters['topic'],
            initialSearchQuery: state.uri.queryParameters['search'],
            initialLevel: state.uri.queryParameters['level'],
            initialAuthorId: state.uri.queryParameters['author'],
            initialMinRating:
                double.tryParse(state.uri.queryParameters['minRating'] ?? ''),
            initialDurationCode: state.uri.queryParameters['duration'],
            initialCertificateOnly:
                state.uri.queryParameters['certificate'] == '1',
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.courses}/:courseId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: CommunityCourseDetailPage(
            courseId: state.pathParameters['courseId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.coursePlayer}/:courseId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: CommunityCoursePlayerPage(
            courseId: state.pathParameters['courseId'] ?? '',
            skipIntro: state.uri.queryParameters['skipIntro'] == '1',
          ),
        ),
      ),
    ],
  );
});
