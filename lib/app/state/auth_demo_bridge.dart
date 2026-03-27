import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/auth_user.dart';
import 'demo_app_controller.dart';
import 'demo_models.dart';

void syncDemoAuthFromUser(WidgetRef ref, AuthUser? user) {
  final controller = ref.read(demoAppControllerProvider.notifier);
  if (user == null) {
    controller.syncExternalAuth(
      isAuthenticated: false,
      isModerator: false,
      user: null,
    );
    return;
  }

  controller.syncExternalAuth(
    isAuthenticated: true,
    isModerator: user.isModerator,
    user: DemoUser(
      name: user.displayName,
      email: user.email,
      role: _roleLabel(user),
      goal: user.isModerator
          ? 'Keep course flows safe, clean, and well moderated'
          : 'Build confidence across CS Core and IT Spheres',
    ),
  );
}

String _roleLabel(AuthUser user) {
  if (user.roleCodes.contains('admin')) {
    return 'Administrator';
  }
  if (user.roleCodes.contains('manager')) {
    return 'Manager';
  }
  if (user.roleCodes.contains('teacher')) {
    return 'Teacher';
  }
  return 'Student';
}
