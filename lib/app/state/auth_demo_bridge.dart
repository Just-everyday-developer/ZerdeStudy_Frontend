import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/auth_user.dart';
import 'app_experience.dart';
import 'demo_app_controller.dart';
import 'demo_models.dart';

void syncDemoAuthFromUser(WidgetRef ref, AuthUser? user) {
  final controller = ref.read(demoAppControllerProvider.notifier);
  final currentExperience = ref
      .read(demoAppControllerProvider)
      .activeExperience;
  if (user == null) {
    controller.syncExternalAuth(
      activeExperience: currentExperience,
      isAuthenticated: false,
      isModerator: false,
      user: null,
    );
    return;
  }

  final activeExperience = _experienceForUser(
    user,
    fallback: currentExperience,
  );

  controller.syncExternalAuth(
    isAuthenticated: true,
    isModerator: activeExperience == AppExperience.moderator,
    activeExperience: activeExperience,
    user: DemoUser(
      name: user.displayName,
      email: user.email,
      role: _roleLabel(activeExperience),
      goal: _goalLabel(activeExperience),
    ),
  );
}

AppExperience _experienceForUser(
  AuthUser user, {
  required AppExperience fallback,
}) {
  if (user.roleCodes.contains('admin')) {
    return AppExperience.admin;
  }
  if (user.roleCodes.contains('manager')) {
    return AppExperience.moderator;
  }
  if (user.roleCodes.contains('teacher')) {
    return AppExperience.teacher;
  }
  return fallback;
}

String _roleLabel(AppExperience experience) {
  return switch (experience) {
    AppExperience.student => 'Student',
    AppExperience.teacher => 'Teacher',
    AppExperience.moderator => 'Moderator',
    AppExperience.admin => 'Administrator',
  };
}

String _goalLabel(AppExperience experience) {
  return switch (experience) {
    AppExperience.student => 'Build confidence across CS Core and IT Spheres',
    AppExperience.teacher =>
      'Design practical courses, guide cohorts, and improve learning outcomes',
    AppExperience.moderator =>
      'Keep course flows safe, clean, and well moderated',
    AppExperience.admin =>
      'Coordinate platform quality, settings, and operational health',
  };
}
