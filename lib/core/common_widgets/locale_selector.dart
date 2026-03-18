import 'package:flutter/material.dart';

import '../../app/state/app_locale.dart';
import '../theme/app_theme_colors.dart';

class LocaleSelector extends StatelessWidget {
  const LocaleSelector({
    super.key,
    required this.currentLocale,
    required this.onChanged,
  });

  final AppLocale currentLocale;
  final ValueChanged<AppLocale> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppLocale.values.map((locale) {
        final selected = locale == currentLocale;
        return ChoiceChip(
          label: Text(locale.label),
          selected: selected,
          onSelected: (_) => onChanged(locale),
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
    );
  }
}
