import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/community/presentation/pages/community_group_page.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/faq/presentation/pages/faq_page.dart';
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
import '../../features/moderator/presentation/pages/moderator_shell_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/teacher/presentation/pages/teacher_shell_page.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'home',
);
final GlobalKey<NavigatorState> _treeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'tree',
);
final GlobalKey<NavigatorState> _learnNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'learn',
);
final GlobalKey<NavigatorState> _communityNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'community');
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
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.welcome,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
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
      }.contains(path);
      final isTeacherRoute = path.startsWith(AppRoutes.teacher);
      final isModeratorRoute = path.startsWith(AppRoutes.moderator);
      final primaryAuthenticatedRoute = switch (activeExperience) {
        AppExperience.student => AppRoutes.home,
        AppExperience.teacher => AppRoutes.teacher,
        AppExperience.moderator => AppRoutes.moderator,
        AppExperience.admin => AppRoutes.home,
      };

      if (!isReady) {
        return isAuthRoute ? null : AppRoutes.welcome;
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
      if (isAuthenticated && activeExperience == AppExperience.moderator) {
        return isModeratorRoute ? null : AppRoutes.moderator;
      }
      if (isTeacherRoute || isModeratorRoute) {
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScaffold(
            navigationShell: navigationShell,
            navigatorKeys: <GlobalKey<NavigatorState>>[
              _homeNavigatorKey,
              _treeNavigatorKey,
              _learnNavigatorKey,
              _communityNavigatorKey,
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
            navigatorKey: _communityNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.community,
                builder: (context, state) => const CommunityPage(),
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
        path: '${AppRoutes.community}/groups/:groupId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: CommunityGroupPage(
            groupId: state.pathParameters['groupId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.profilePreview,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const ProfilePage(enableShellAvatarHero: true),
        ),
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
          child: LessonPage(lessonId: state.pathParameters['lessonId'] ?? ''),
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
        pageBuilder: (context, state) =>
            cyberTransition(state: state, child: const StatsPage()),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            cyberTransition(state: state, child: const LeaderboardPage()),
      ),
      GoRoute(
        path: AppRoutes.faq,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            cyberTransition(state: state, child: const FaqPage()),
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
      GoRoute(
        path: AppRoutes.teacher,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.dashboard),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherGenerator,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.generator),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherBuilder,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.builder),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherAssessments,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.assessments),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherPublishing,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.publishing),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherQna,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.qna),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherAnalytics,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.analytics),
        ),
      ),
      GoRoute(
        path: AppRoutes.teacherProfile,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const TeacherShellPage(section: TeacherSection.profile),
        ),
      ),
      GoRoute(
        path: AppRoutes.moderator,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const ModeratorShellPage(initialTab: 0),
        ),
      ),
      GoRoute(
        path: AppRoutes.moderatorCourses,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const ModeratorShellPage(initialTab: 1),
        ),
      ),
      GoRoute(
        path: AppRoutes.moderatorReports,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const ModeratorShellPage(initialTab: 2),
        ),
      ),
      GoRoute(
        path: AppRoutes.moderatorComments,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const ModeratorShellPage(initialTab: 3),
        ),
      ),
      GoRoute(
        path: AppRoutes.moderatorCommunity,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const ModeratorShellPage(initialTab: 4),
        ),
      ),
      GoRoute(
        path: AppRoutes.moderatorFaq,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => cyberTransition(
          state: state,
          child: const ModeratorShellPage(initialTab: 5),
        ),
      ),
    ],
  );
});

class _RouterRefreshListenable extends ChangeNotifier {
  void notify() => notifyListeners();
}
