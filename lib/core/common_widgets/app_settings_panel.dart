import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/state/app_theme_mode.dart';
import '../../app/state/demo_app_controller.dart';
import '../../features/ai/presentation/providers/ai_user_api_key_controller.dart';
import '../../features/app_guide/presentation/app_guide_controller.dart';
import '../../features/app_guide/presentation/app_guide_copy.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../localization/app_localizations.dart';
import '../theme/app_theme_colors.dart';
import 'adaptive_panel.dart';
import 'app_notice.dart';
import 'glow_card.dart';
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
  String? _maskApiKey(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.length <= 8) {
      return '${trimmed.substring(0, 2)}***${trimmed.substring(trimmed.length - 2)}';
    }
    return '${trimmed.substring(0, 4)}***${trimmed.substring(trimmed.length - 4)}';
  }

  Future<void> _showApiKeyDialog() async {
    final currentKey = ref.read(aiUserApiKeyProvider) ?? '';
    final controller = TextEditingController(text: currentKey);
    var obscureText = true;

    final l10n = context.l10n;

    final submittedKey = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Text(l10n.text('ai_api_key_title')),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.text('ai_api_key_description'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      obscureText: obscureText,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: l10n.text('ai_api_key_label'),
                        hintText: l10n.text('ai_api_key_hint'),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.text('cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(controller.text);
                  },
                  child: Text(l10n.text('ai_api_key_save')),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (submittedKey == null) {
      return;
    }

    await ref.read(aiUserApiKeyProvider.notifier).saveKey(submittedKey);
    if (!mounted) {
      return;
    }

    final hasKey = (submittedKey.trim().isNotEmpty);
    AppNotice.show(
      context,
      message: hasKey
          ? context.l10n.text('ai_api_key_saved')
          : context.l10n.text('ai_api_key_removed'),
      type: AppNoticeType.success,
    );
  }

  Future<void> _clearApiKey() async {
    await ref.read(aiUserApiKeyProvider.notifier).clearKey();
    if (!mounted) {
      return;
    }

    AppNotice.show(
      context,
      message: context.l10n.text('ai_api_key_removed'),
      type: AppNoticeType.success,
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final changed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ChangePasswordDialogInSettings(
        onSubmit: (current, next) => ref
            .read(authControllerProvider.notifier)
            .changePassword(currentPassword: current, newPassword: next),
      ),
    );

    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();

    if (changed == true && mounted) {
      AppNotice.show(context,
          message: 'Пароль обновлён', type: AppNoticeType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.text('settings'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.text('locale'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 10),
          LocaleSelector(
            currentLocale: state.locale,
            onChanged: controller.changeLocale,
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.text('theme'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
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
          (() {
            final userApiKey = ref.watch(aiUserApiKeyProvider);
            final hasCustomKey = (userApiKey ?? '').trim().isNotEmpty;
            final maskedKey = _maskApiKey(userApiKey);
            return GlowCard(
              accent: hasCustomKey ? colors.primary : colors.divider,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.vpn_key_rounded, color: colors.primary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        l10n.text('personal_ai_key_title'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hasCustomKey
                        ? '${l10n.text('personal_ai_key_custom_desc')} $maskedKey'
                        : l10n.text('personal_ai_key_default_desc'),
                    style: TextStyle(color: colors.textSecondary, height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _showApiKeyDialog,
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: Text(l10n.text('ai_api_key_save')),
                      ),
                      if (hasCustomKey)
                        OutlinedButton.icon(
                          onPressed: _clearApiKey,
                          icon: const Icon(Icons.delete_rounded, size: 16),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.danger,
                            side: BorderSide(color: colors.danger.withValues(alpha: 0.5)),
                          ),
                          label: Text(l10n.text('clear_filters')),
                        ),
                    ],
                  ),
                ],
              ),
            );
          })(),
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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showChangePasswordDialog,
              icon: const Icon(Icons.lock_reset_rounded),
              label: Text(l10n.text('change_password_title')),
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

class _ChangePasswordDialogInSettings extends StatefulWidget {
  const _ChangePasswordDialogInSettings({required this.onSubmit});

  final Future<String?> Function(String current, String next) onSubmit;

  @override
  State<_ChangePasswordDialogInSettings> createState() =>
      _ChangePasswordDialogInSettingsState();
}

class _ChangePasswordDialogInSettingsState
    extends State<_ChangePasswordDialogInSettings> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _submitting = false;
  String _error = '';

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _error = l10n.text('passwords_mismatch'));
      return;
    }
    if (_newCtrl.text.length < 8) {
      setState(() => _error = l10n.text('password_min_length'));
      return;
    }
    setState(() {
      _submitting = true;
      _error = '';
    });
    final err = await widget.onSubmit(_currentCtrl.text, _newCtrl.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _error = err;
        _submitting = false;
      });
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock_reset_rounded, color: colors.primary, size: 22),
          const SizedBox(width: 10),
          Text(l10n.text('change_password_title')),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentCtrl,
              obscureText: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.text('current_password'),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _newCtrl,
              obscureText: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.text('new_password'),
                prefixIcon: const Icon(Icons.lock_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: l10n.text('confirm_password'),
                prefixIcon: const Icon(Icons.lock_rounded),
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: colors.danger, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _error,
                      style: TextStyle(color: colors.danger, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.text('cancel')),
        ),
        FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: Text(l10n.text('save')),
        ),
      ],
    );
  }
}

