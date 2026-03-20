import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/app_theme_mode.dart';
import '../../app/state/demo_app_controller.dart';
import '../localization/app_localizations.dart';
import '../theme/app_theme_colors.dart';
import 'adaptive_panel.dart';
import 'locale_selector.dart';

Future<void> showAppSettingsPanel(BuildContext context) {
  return showAdaptivePanel<void>(
    context: context,
    builder: (context) {
      return const _AppSettingsPanelContent();
    },
  );
}

class _AppSettingsPanelContent extends ConsumerWidget {
  const _AppSettingsPanelContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final colors = context.appColors;
    final l10n = context.l10n;

    return Padding(
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
            children: AppThemeMode.values.map((mode) {
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
            }).toList(growable: false),
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
