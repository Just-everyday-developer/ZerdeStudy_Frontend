import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routing/app_routes.dart';
import '../../app/state/app_theme_mode.dart';
import '../../app/state/demo_app_controller.dart';
import '../../features/app_guide/presentation/app_guide_controller.dart';
import '../../features/app_guide/presentation/app_guide_copy.dart';
import '../localization/app_localizations.dart';
import '../notifications/local_notification_service.dart';
import '../theme/app_theme_colors.dart';
import 'adaptive_panel.dart';
import 'app_notice.dart';
import 'locale_selector.dart';

Future<void> showAppSettingsPanel(BuildContext context) {
  final hostContext = context;
  return showAdaptivePanel<void>(
    context: context,
    builder: (context) {
      return _AppSettingsPanelContent(hostContext: hostContext);
    },
  );
}

class _AppSettingsPanelContent extends ConsumerStatefulWidget {
  const _AppSettingsPanelContent({required this.hostContext});

  final BuildContext hostContext;

  @override
  ConsumerState<_AppSettingsPanelContent> createState() =>
      _AppSettingsPanelContentState();
}

class _AppSettingsPanelContentState
    extends ConsumerState<_AppSettingsPanelContent> {
  bool _isSendingNotification = false;

  Future<void> _sendTestNotification() async {
    if (_isSendingNotification) {
      return;
    }

    final l10n = context.l10n;
    setState(() => _isSendingNotification = true);
    final notificationService = ref.read(localNotificationServiceProvider);
    final result = await notificationService.sendTestNotification(
      title: l10n.text('notifications_test_title'),
      body: l10n.text('notifications_test_body'),
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSendingNotification = false);
    switch (result) {
      case LocalNotificationSendStatus.sent:
        AppNotice.show(
          context,
          message: l10n.text('notifications_test_notice_sent'),
          type: AppNoticeType.success,
        );
        break;
      case LocalNotificationSendStatus.permissionDenied:
        AppNotice.show(
          context,
          message: l10n.text('notifications_test_notice_denied'),
          type: AppNoticeType.error,
        );
        break;
      case LocalNotificationSendStatus.unsupported:
        AppNotice.show(
          context,
          message: l10n.text('notifications_test_notice_unsupported'),
          type: AppNoticeType.error,
        );
        break;
      case LocalNotificationSendStatus.failed:
        AppNotice.show(
          context,
          message: l10n.text('notifications_test_notice_failed'),
          type: AppNoticeType.error,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final notificationService = ref.read(localNotificationServiceProvider);
    final colors = context.appColors;
    final l10n = context.l10n;
    final guideState = ref.watch(appGuideControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdaptivePanelHandle(),
          const SizedBox(height: 18),
          Text(
            l10n.text('settings'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 18),
          Text(
            l10n.text('locale'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          LocaleSelector(
            currentLocale: state.locale,
            onChanged: controller.changeLocale,
          ),
          const SizedBox(height: 18),
          Text(
            l10n.text('theme'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppThemeMode.values
                .map((mode) {
                  final selected = mode == state.themeMode;
                  return ChoiceChip(
                    label: Text(_themeLabel(l10n, mode)),
                    selected: selected,
                    onSelected: (_) => controller.changeThemeMode(mode),
                    selectedColor: colors.primary.withValues(alpha: 0.16),
                    backgroundColor: colors.surfaceSoft,
                    side: BorderSide(
                      color: selected ? colors.primary : colors.divider,
                    ),
                    labelStyle: TextStyle(
                      color: selected ? colors.primary : colors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                })
                .toList(growable: false),
          ),
          const SizedBox(height: 18),
          Text(
            AppGuideCopy.settingsSectionTitle(context),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colors.surfaceSoft,
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.explore_rounded, color: colors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppGuideCopy.settingsSectionTitle(context),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  AppGuideCopy.settingsSectionSubtitle(
                    context,
                    hasCompleted: guideState.hasCompleted,
                  ),
                  style: TextStyle(color: colors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!widget.hostContext.mounted) {
                        return;
                      }
                      ref
                          .read(appGuideControllerProvider.notifier)
                          .startManual(widget.hostContext);
                    });
                  },
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: Text(
                    AppGuideCopy.settingsActionLabel(
                      context,
                      hasCompleted: guideState.hasCompleted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.text('notifications_section_title'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colors.surfaceSoft,
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.text('notifications_card_title'),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: notificationService.isSupported
                            ? colors.primary.withValues(alpha: 0.16)
                            : colors.danger.withValues(alpha: 0.14),
                        border: Border.all(
                          color: notificationService.isSupported
                              ? colors.primary.withValues(alpha: 0.34)
                              : colors.danger.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Text(
                        l10n.text(
                          notificationService.isSupported
                              ? 'notifications_status_supported'
                              : 'notifications_status_unavailable',
                        ),
                        style: TextStyle(
                          color: notificationService.isSupported
                              ? colors.primary
                              : colors.danger,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.text(
                    notificationService.isSupported
                        ? 'notifications_card_subtitle'
                        : 'notifications_card_subtitle_unavailable',
                  ),
                  style: TextStyle(color: colors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed:
                      notificationService.isSupported && !_isSendingNotification
                      ? _sendTestNotification
                      : null,
                  icon: _isSendingNotification
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors.background,
                            ),
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(l10n.text('notifications_send_test')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.text('help'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              GoRouter.of(context).push(AppRoutes.faq);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: colors.surfaceSoft,
                border: Border.all(color: colors.divider),
              ),
              child: Row(
                children: [
                  Icon(Icons.quiz_rounded, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.text('faq_title'),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.text('faq_subtitle'),
                          style: TextStyle(
                            color: colors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colors.surfaceSoft,
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.keyboard_command_key_rounded,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.text('hotkeys'),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ShortcutRow(
                  combo: 'Alt + 1..5',
                  description: l10n.text('hotkey_tabs_direct'),
                ),
                _ShortcutRow(
                  combo: 'Left / Right',
                  description: l10n.text('hotkey_tabs_arrows'),
                ),
                _ShortcutRow(
                  combo: 'Ctrl + Tab',
                  description: l10n.text('hotkey_next_screen'),
                ),
                _ShortcutRow(
                  combo: 'Ctrl + Shift + Tab',
                  description: l10n.text('hotkey_prev_screen'),
                ),
                _ShortcutRow(
                  combo: 'Alt + Left / Alt + Z',
                  description: l10n.text('hotkey_back'),
                ),
                _ShortcutRow(
                  combo: 'Ctrl + K',
                  description: l10n.text('hotkey_focus_search'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(AppLocalizations l10n, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return l10n.text('theme_dark');
      case AppThemeMode.light:
        return l10n.text('theme_light');
    }
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.combo, required this.description});

  final String combo;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colors.backgroundElevated,
              border: Border.all(color: colors.divider),
            ),
            child: Text(
              combo,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(color: colors.textSecondary, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
