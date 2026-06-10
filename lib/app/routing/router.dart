import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/oauth_web_bootstrap.dart';
import '../state/app_experience.dart';
import '../state/demo_app_controller.dart';
import '../../core/common_widgets/app_shell_scaffold.dart';
import '../../core/utils/cyber_transition.dart';
import '../../features/ai/presentation/pages/ai_mentor_page.dart';
import '../../features/analytics/presentation/pages/leaderboard_page.dart';
import '../../features/analytics/presentation/pages/stats_page.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/pages/forgot_password_code_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/oauth_callback_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
// Community Groups removed (no backend, fully hardcoded mock).
// FAQ and Moderator removed (no backend, hardcoded mock).
import '../../features/home/presentation/pages/community_course_detail_page.dart';
import '../../features/home/presentation/pages/backend_course_player_page.dart';
import '../../features/home/presentation/pages/community_course_player_page.dart';
import '../../features/home/presentation/pages/community_courses_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/diagnostic_test_page.dart';
import '../../features/knowledge_tree/presentation/pages/knowledge_tree.dart';
import '../../features/learning/presentation/pages/learn_page.dart';
import '../../features/learning/presentation/pages/track_assessment_page.dart';
import '../../features/learning/presentation/pages/lesson_page.dart';
import '../../features/learning/presentation/pages/practice_page.dart';
import '../../features/learning/presentation/pages/track_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/admin/presentation/pages/admin_shell_page.dart';
import '../../features/payment/presentation/pages/payment_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/teacher/presentation/pages/teacher_shell_page.dart';
import 'app_routes.dart';
import 'router_keys.dart';

final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'home',
);
final GlobalKey<NavigatorState> _treeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'tree',
);
final GlobalKey<NavigatorState> _learnNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'learn',
);
final GlobalKey<NavigatorState> _aiNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'ai',
);
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

typedef _AuthRouterSnapshot = ({bool isReady, bool isAuthenticated});

final _routerRefreshProvider = Provider<_RouterRefreshListenable>((ref) {
  final listenable = _RouterRefreshListenable();

  ref.listen<_AuthRouterSnapshot>(
    authControllerProvider.select(
      (state) =>
          (isReady: state.isReady, isAuthenticated: state.isAuthenticated),
    ),
    (_, __) => listenable.notify(),
  );
  ref.listen<AppExperience>(
    demoAppControllerProvider.select((state) => state.activeExperience),
    (_, __) => listenable.notify(),
  );
  ref.onDispose(listenable.dispose);

  return listenable;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(_routerRefreshProvider);

  return GoRouter(
    navigatorKey: appRootNavigatorKey,
    initialLocation: OAuthWebBootstrap.initialLocation,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      if (kIsWeb) {
        final oauthRoute = OAuthWebBootstrap.redirectForGoRouter(
          state.matchedLocation,
        );
        if (oauthRoute != null) {
          return oauthRoute;
        }
      }

      final authSnapshot = ref.read(
        authControllerProvider.select(
          (controllerState) => (
            isReady: controllerState.isReady,
            isAuthenticated: controllerState.isAuthenticated,
          ),
        ),
      );
      final activeExperience = ref
          .read(demoAppControllerProvider)
          .activeExperience;
      final isReady = authSnapshot.isReady;
      final isAuthenticated = authSnapshot.isAuthenticated;
      final path = state.matchedLocation;
      final isAuthRoute = <String>{
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.forgotPassword,
        AppRoutes.forgotPasswordCode,
        AppRoutes.resetPassword,
        AppRoutes.googleCallback,
        AppRoutes.githubCallback,
      }.contains(path);
      final isTeacherRoute = path.startsWith(AppRoutes.teacher);
      final isAdminRoute = path.startsWith(AppRoutes.admin);
      final primaryAuthenticatedRoute = switch (activeExperience) {
        AppExperience.student => AppRoutes.home,
        AppExperience.teacher => AppRoutes.teacher,
        AppExperience.admin => AppRoutes.admin,
      };

      if (!isReady) {
        return isAuthRoute ? null : AppRoutes.welcome;
      }
      // Never redirect away from an OAuth callback route — OAuthCallbackPage
      // handles navigation itself after exchanging the code for tokens.
      // Without this guard a stored session restored by _restoreSession would
      // fire isAuthenticated=true and kick the user to home before the code
      // exchange POST can complete.
      if (path == AppRoutes.googleCallback || path == AppRoutes.githubCallback) {
        return null;
      }
      if (!isAuthenticated) {
        return isAuthRoute ? null : AppRoutes.welcome;
      }
      if (isAuthenticated && isAuthRoute) {
        return primaryAuthenticatedRoute;
      }
      // Role-specific workspaces should only lock the route after sign in.
      if (isAuthenticated && activeExperience == AppExperience.teacher) {
        return isTeacherRoute ? null : AppRoutes.teacher;
      }
      if (isAuthenticated && activeExperience == AppExperience.admin) {
        return isAdminRoute ? null : AppRoutes.admin;
      }
      if (isTeacherRoute || isAdminRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (context, state) =>
            cyberTransition(state: state, child: const WelcomePage()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            cyberTransition(state: state, child: const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) =>
            cyberTransition(state: state, child: const SignUpPage()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) =>
            cyberTransition(state: state, child: const ForgotPasswordPage()),
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordCode,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: ForgotPasswordCodePage(
            email: state.uri.queryParameters['email'],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: ResetPasswordPage(
            email: state.uri.queryParameters['email'],
            code: state.uri.queryParameters['code'],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.googleCallback,
        pageBuilder: (context, state) {
          final code = state.uri.queryParameters['code'] ?? '';
          return cyberTransition(
            state: state,
            child: OAuthCallbackPage(provider: 'google', code: code),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.githubCallback,
        pageBuilder: (context, state) {
          final code = state.uri.queryParameters['code'] ?? '';
          return cyberTransition(
            state: state,
            child: OAuthCallbackPage(provider: 'github', code: code),
          );
        },
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
              // Community Groups removed — no backend, fully hardcoded mock.
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
      // Community group detail removed together with community groups.
      GoRoute(
        path: AppRoutes.profilePreview,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const ProfilePage(enableShellAvatarHero: true),
        ),
      ),
      GoRoute(
        path: AppRoutes.diagnostics,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const DiagnosticTestPage(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.track}/:trackId',
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: TrackPage(
            trackId: state.pathParameters['trackId'] ?? 'fundamentals',
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.lesson}/:lessonId',
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: LessonPage(lessonId: state.pathParameters['lessonId'] ?? ''),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.practice}/:practiceId',
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: PracticePage(
            practiceId: state.pathParameters['practiceId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.assessment}/:trackId',
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: TrackAssessmentPage(
            trackId: state.pathParameters['trackId'] ?? 'fundamentals',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.stats,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) =>
            cyberTransition(state: state, child: const StatsPage()),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) =>
            cyberTransition(state: state, child: const LeaderboardPage()),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) =>
            cyberTransition(state: state, child: const NotificationsPage()),
      ),
      GoRoute(
        path: AppRoutes.courses,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: CommunityCoursesPage(
            initialTopicKey: state.uri.queryParameters['topic'],
            initialSearchQuery: state.uri.queryParameters['search'],
            initialLevel: state.uri.queryParameters['level'],
            initialMinRating: double.tryParse(
              state.uri.queryParameters['minRating'] ?? '',
            ),
            initialDurationCode: state.uri.queryParameters['duration'],
            initialCertificateOnly:
                state.uri.queryParameters['certificate'] == '1',
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.courses}/:courseId',
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: CommunityCourseDetailPage(
            courseId: state.pathParameters['courseId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.coursePlayer}/:courseId',
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: CommunityCoursePlayerPage(
            courseId: state.pathParameters['courseId'] ?? '',
            skipIntro: state.uri.queryParameters['skipIntro'] == '1',
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.backendCoursePlayer}/:courseId',
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: BackendCoursePlayerPage(
            courseId: state.pathParameters['courseId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.payment}/:courseId',
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          final amount = int.tryParse(
                state.uri.queryParameters['amount'] ?? '',
              ) ?? 0;
          final currency = state.uri.queryParameters['currency'] ?? 'KZT';
          return cyberTransition(
            state: state,
            child: PaymentPage(
              courseId: courseId,
              amount: amount,
              currency: currency,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.teacher,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.dashboard),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherGenerator,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.dashboard),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherBuilder,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.dashboard),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherAssessments,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.dashboard),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherPublishing,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.dashboard),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherQna,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.qna),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherAnalytics,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.analytics),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherProfile,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.profile),
        ),
      ),
      GoRoute(
        path: AppRoutes.admin,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const AdminShellPage(section: AdminSection.users),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminRoles,
        parentNavigatorKey: appRootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const AdminShellPage(section: AdminSection.roles),
        ),
      ),
    ],
  );
});

class _RouterRefreshListenable extends ChangeNotifier {
  void notify() => notifyListeners();
}
