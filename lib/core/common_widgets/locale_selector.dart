import 'package:flutter/material.dart';

import '../../app/state/app_locale.dart';
import '../constants/app_colors.dart';

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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppLocale.values.map((locale) {
        final selected = locale == currentLocale;
        return ChoiceChip(
          label: Text(locale.label),
          selected: selected,
          onSelected: (_) => onChanged(locale),
          selectedColor: AppColors.primary.withValues(alpha: 0.16),
          backgroundColor: AppColors.surfaceSoft,
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
          labelStyle: TextStyle(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        );
      }).toList(growable: false),
    );
  }
}
