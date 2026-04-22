import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/routing/app_routes.dart';
import '../../../app/routing/router_keys.dart';
import '../../../app/state/app_experience.dart';
import '../../../app/state/demo_app_controller.dart';
import '../../auth/presentation/providers/auth_controller.dart';

final appGuideControllerProvider =
    NotifierProvider<AppGuideController, AppGuideState>(AppGuideController.new);

class AppGuideController extends Notifier<AppGuideState> {
  static const String _completedStorageKey = 'zerdestudy_app_guide_completed';
  static const Duration _routeSettleDuration = Duration(milliseconds: 320);

  late final SharedPreferences _preferences;
  GoRouter? _router;

  @override
  AppGuideState build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    return AppGuideState(
      hasCompleted: _preferences.getBool(_completedStorageKey) ?? false,
    );
  }

  Future<void> startFromLogin(BuildContext context) async {
    ref
        .read(demoAppControllerProvider.notifier)
        .setActiveExperience(AppExperience.student);
    await ref
        .read(authControllerProvider.notifier)
        .signInWithMockProvider(provider: 'guide', roleCode: 'student');
    if (!context.mounted) {
      return;
    }
    await _start(GoRouter.of(context));
  }

  Future<void> startManual(BuildContext context) async {
    await _start(GoRouter.of(context));
  }

  Future<void> next() async {
    final currentStep = state.currentStep;
    if (!state.isActive || currentStep == null) {
      return;
    }

    if (currentStep.id == AppGuideStepId.completion) {
      await finish();
      return;
    }

    final nextIndex = state.currentStepIndex + 1;
    if (nextIndex >= appGuideSteps.length) {
      await finish();
      return;
    }

    final nextStep = appGuideSteps[nextIndex];
    if (nextStep.route != currentStep.route) {
      final routerContext = appRootNavigatorKey.currentContext;
      final activeRouter = routerContext != null
          ? GoRouter.of(routerContext)
          : _router;
      activeRouter?.go(nextStep.route);
      await Future<void>.delayed(_routeSettleDuration);
    }

    state = state.copyWith(currentStepIndex: nextIndex);
  }

  Future<void> dismiss() async {
    state = state.copyWith(isActive: false);
  }

  Future<void> finish() async {
    await _preferences.setBool(_completedStorageKey, true);
    state = state.copyWith(isActive: false, hasCompleted: true);
  }

  Future<void> _start(GoRouter router) async {
    final firstStep = appGuideSteps.first;
    final nextSessionId = state.sessionId + 1;

    _router = router;
    router.go(firstStep.route);
    await Future<void>.delayed(_routeSettleDuration);

    state = state.copyWith(
      isActive: true,
      currentStepIndex: 0,
      sessionId: nextSessionId,
    );
  }
}

class AppGuideState {
  const AppGuideState({
    this.isActive = false,
    this.hasCompleted = false,
    this.currentStepIndex = 0,
    this.sessionId = 0,
  });

  final bool isActive;
  final bool hasCompleted;
  final int currentStepIndex;
  final int sessionId;

  AppGuideStep? get currentStep {
    if (!isActive ||
        currentStepIndex < 0 ||
        currentStepIndex >= appGuideSteps.length) {
      return null;
    }
    return appGuideSteps[currentStepIndex];
  }

  String get overlayPageKey {
    final stepId = currentStep?.id.name ?? 'idle';
    return '$sessionId-$currentStepIndex-$stepId';
  }

  AppGuideState copyWith({
    bool? isActive,
    bool? hasCompleted,
    int? currentStepIndex,
    int? sessionId,
  }) {
    return AppGuideState(
      isActive: isActive ?? this.isActive,
      hasCompleted: hasCompleted ?? this.hasCompleted,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

enum AppGuideStepId {
  shellNavigation,
  homeProgress,
  treeOverview,
  learnDiscovery,
  communityGroups,
  aiMentor,
  profileOverview,
  settingsAccess,
  completion,
}

enum AppGuidePanelSide { auto, above, below, center }

class AppGuideStep {
  const AppGuideStep({
    required this.id,
    required this.route,
    this.targetId,
    this.panelSide = AppGuidePanelSide.auto,
    this.spotlightPadding = const EdgeInsets.all(12),
    this.spotlightRadius = 28,
  });

  final AppGuideStepId id;
  final String route;
  final String? targetId;
  final AppGuidePanelSide panelSide;
  final EdgeInsets spotlightPadding;
  final double spotlightRadius;
}

abstract final class AppGuideTargetIds {
  static const String shellNavigation = 'shell-navigation';
  static const String homeContinue = 'home-continue';
  static const String treeCanvas = 'tree-canvas';
  static const String learnSearch = 'learn-search';
  static const String communityCreate = 'community-create';
  static const String aiComposer = 'ai-composer';
  static const String profileHeader = 'profile-header';
  static const String profileSettings = 'profile-settings';
}

const List<AppGuideStep> appGuideSteps = <AppGuideStep>[
  AppGuideStep(
    id: AppGuideStepId.shellNavigation,
    route: AppRoutes.home,
    targetId: AppGuideTargetIds.shellNavigation,
  ),
  AppGuideStep(
    id: AppGuideStepId.homeProgress,
    route: AppRoutes.home,
    targetId: AppGuideTargetIds.homeContinue,
    panelSide: AppGuidePanelSide.below,
  ),
  AppGuideStep(
    id: AppGuideStepId.treeOverview,
    route: AppRoutes.tree,
    targetId: AppGuideTargetIds.treeCanvas,
    panelSide: AppGuidePanelSide.center,
  ),
  AppGuideStep(
    id: AppGuideStepId.learnDiscovery,
    route: AppRoutes.learn,
    targetId: AppGuideTargetIds.learnSearch,
    panelSide: AppGuidePanelSide.below,
  ),
  AppGuideStep(
    id: AppGuideStepId.communityGroups,
    route: AppRoutes.community,
    targetId: AppGuideTargetIds.communityCreate,
    panelSide: AppGuidePanelSide.below,
  ),
  AppGuideStep(
    id: AppGuideStepId.aiMentor,
    route: AppRoutes.ai,
    targetId: AppGuideTargetIds.aiComposer,
    panelSide: AppGuidePanelSide.above,
  ),
  AppGuideStep(
    id: AppGuideStepId.profileOverview,
    route: AppRoutes.profile,
    targetId: AppGuideTargetIds.profileHeader,
    panelSide: AppGuidePanelSide.below,
  ),
  AppGuideStep(
    id: AppGuideStepId.settingsAccess,
    route: AppRoutes.profile,
    targetId: AppGuideTargetIds.profileSettings,
    panelSide: AppGuidePanelSide.above,
  ),
  AppGuideStep(
    id: AppGuideStepId.completion,
    route: AppRoutes.profile,
    panelSide: AppGuidePanelSide.center,
  ),
];
