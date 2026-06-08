import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routing/app_routes.dart';
import '../../features/courses_backend/presentation/providers/backend_course_providers.dart';
import '../localization/app_localizations.dart';
import '../theme/app_theme_colors.dart';

/// Bell icon with an unread-count badge, opening the notifications inbox.
/// Hidden once the unread count settles at zero so signed-out / backend-less
/// sessions don't show a dead button.
class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final unreadCount = ref
        .watch(backendUnreadNotificationCountProvider)
        .maybeWhen(data: (value) => value, orElse: () => 0);

    return IconButton(
      onPressed: () => context.push(AppRoutes.notifications),
      tooltip: context.l10n.text('notifications'),
      icon: Badge(
        label: Text('$unreadCount'),
        isLabelVisible: unreadCount > 0,
        backgroundColor: colors.danger,
        child: Icon(
          unreadCount > 0
              ? Icons.notifications_active_rounded
              : Icons.notifications_outlined,
          color: iconColor ?? colors.textPrimary,
        ),
      ),
    );
  }
}
