import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../courses_backend/data/models/backend_notification_dto.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';

typedef _Translator = String Function({required String ru, required String en, required String kk});

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final locale = state.locale;
    final colors = context.appColors;
    final compact = context.isCompactLayout;

    String t({required String ru, required String en, required String kk}) {
      if (locale == AppLocale.kk) return kk;
      if (locale == AppLocale.ru) return ru;
      return en;
    }

    final list = ref.watch(backendNotificationsProvider);
    final hasUnread = list.maybeWhen(
      data: (data) => (data?.unreadCount ?? 0) > 0,
      orElse: () => false,
    );

    Future<void> markAllRead() async {
      final remote = ref.read(backendCourseRemoteDataSourceProvider);
      final accessToken = ref.read(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) return;
      try {
        await remote.markAllNotificationsRead(accessToken: accessToken);
      } catch (_) {
        // Ignore — list refresh below will simply show the prior state.
      }
      ref.invalidate(backendNotificationsProvider);
      ref.invalidate(backendUnreadNotificationCountProvider);
    }

    return AppPageScaffold(
      title: t(ru: 'Уведомления', en: 'Notifications', kk: 'Хабарландырулар'),
      actions: [
        if (hasUnread)
          TextButton(
            onPressed: markAllRead,
            child: Text(
              t(ru: 'Прочитать всё', en: 'Mark all read', kk: 'Барлығын оқу'),
            ),
          ),
      ],
      child: list.when(
        data: (data) {
          final items = data?.items ?? const <BackendNotificationDto>[];
          if (items.isEmpty) {
            return _EmptyNotifications(t: t, colors: colors);
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(0, compact ? 6 : 8, 0, 40),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _NotificationTile(
              notification: items[index],
              t: t,
              colors: colors,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _EmptyNotifications(t: t, colors: colors),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({
    required this.notification,
    required this.t,
    required this.colors,
  });

  final BackendNotificationDto notification;
  final _Translator t;
  final AppThemeColors colors;

  IconData get _icon => switch (notification.type) {
    'achievement' => Icons.emoji_events_rounded,
    'streak' => Icons.local_fire_department_rounded,
    'course' => Icons.menu_book_rounded,
    'review' => Icons.rate_review_rounded,
    'system' => Icons.campaign_rounded,
    _ => Icons.notifications_rounded,
  };

  String _relativeTime() {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 1) {
      return t(ru: 'только что', en: 'just now', kk: 'жаңа ғана');
    }
    if (diff.inHours < 1) {
      return t(
        ru: '${diff.inMinutes} мин назад',
        en: '${diff.inMinutes}m ago',
        kk: '${diff.inMinutes} мин бұрын',
      );
    }
    if (diff.inDays < 1) {
      return t(
        ru: '${diff.inHours} ч назад',
        en: '${diff.inHours}h ago',
        kk: '${diff.inHours} сағ бұрын',
      );
    }
    return t(
      ru: '${diff.inDays} дн назад',
      en: '${diff.inDays}d ago',
      kk: '${diff.inDays} күн бұрын',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> markRead() async {
      if (notification.isRead) return;
      final remote = ref.read(backendCourseRemoteDataSourceProvider);
      final accessToken = ref.read(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) return;
      try {
        await remote.markNotificationRead(
          accessToken: accessToken,
          notificationId: notification.id,
        );
      } catch (_) {}
      ref.invalidate(backendNotificationsProvider);
      ref.invalidate(backendUnreadNotificationCountProvider);
    }

    Future<void> delete() async {
      final remote = ref.read(backendCourseRemoteDataSourceProvider);
      final accessToken = ref.read(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) return;
      try {
        await remote.deleteNotification(
          accessToken: accessToken,
          notificationId: notification.id,
        );
      } catch (_) {}
      ref.invalidate(backendNotificationsProvider);
      ref.invalidate(backendUnreadNotificationCountProvider);
    }

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: colors.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Icon(Icons.delete_outline_rounded, color: colors.danger),
      ),
      onDismissed: (_) => delete(),
      child: GlowCard(
        accent: notification.isRead ? colors.divider : colors.primary,
        onTap: notification.isRead ? null : markRead,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (notification.isRead ? colors.surfaceSoft : colors.primary)
                    .withValues(alpha: 0.18),
              ),
              child: Icon(
                _icon,
                color: notification.isRead ? colors.textSecondary : colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                          ),
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (notification.body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textSecondary, height: 1.35),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _relativeTime(),
                    style: TextStyle(
                      color: colors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({required this.t, required this.colors});

  final _Translator t;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: colors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 18),
            Text(
              t(ru: 'Пока нет уведомлений', en: 'No notifications yet', kk: 'Әзірге хабарландырулар жоқ'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                ru: 'Здесь будут появляться важные обновления о курсах, достижениях и серии дней.',
                en: 'Important updates about courses, achievements, and your streak will appear here.',
                kk: 'Курстар, жетістіктер және серия туралы маңызды жаңартулар осында пайда болады.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
