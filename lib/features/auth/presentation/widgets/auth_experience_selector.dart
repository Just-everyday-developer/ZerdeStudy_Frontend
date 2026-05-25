import 'package:flutter/material.dart';

import '../../../../app/state/app_experience.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/theme/app_theme_colors.dart';

class AuthExperienceSelector extends StatelessWidget {
  const AuthExperienceSelector({
    super.key,
    required this.locale,
    required this.selectedExperience,
    required this.onChanged,
  });

  final AppLocale locale;
  final AppExperience selectedExperience;
  final ValueChanged<AppExperience> onChanged;

  static const List<_ExperienceOption> _options = <_ExperienceOption>[
    _ExperienceOption(
      experience: AppExperience.student,
      icon: Icons.school_rounded,
      title: LocalizedText(ru: 'Студент', en: 'Student', kk: 'Студент'),
    ),
    _ExperienceOption(
      experience: AppExperience.teacher,
      icon: Icons.auto_stories_rounded,
      title: LocalizedText(ru: 'Преподаватель', en: 'Teacher', kk: 'Оқытушы'),
    ),
    _ExperienceOption(
      experience: AppExperience.admin,
      icon: Icons.admin_panel_settings_rounded,
      title: LocalizedText(ru: 'Админ', en: 'Admin', kk: 'Админ'),
      isAvailable: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = switch (constraints.maxWidth) {
          >= 1320 => 3,
          >= 760 => 2,
          _ => 1,
        };

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _options.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: crossAxisCount == 1 ? 84 : 100,
          ),
          itemBuilder: (context, index) {
            final option = _options[index];
            return _ExperienceCard(
              option: option,
              locale: locale,
              selected: option.experience == selectedExperience,
              onTap: () => onChanged(option.experience),
            );
          },
        );
      },
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.option,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final _ExperienceOption option;
  final AppLocale locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = option.isAvailable ? colors.primary : colors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: selected
              ? accent.withValues(alpha: 0.13)
              : colors.surfaceSoft.withValues(alpha: 0.92),
          border: Border.all(color: selected ? accent : colors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(option.icon, color: accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.title.resolve(locale),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected ? accent : colors.textPrimary,
                ),
              ),
            ),
            if (!option.isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colors.divider),
                ),
                child: Text(
                  _comingSoon(locale),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: accent, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ExperienceOption {
  const _ExperienceOption({
    required this.experience,
    required this.icon,
    required this.title,
    this.isAvailable = true,
  });

  final AppExperience experience;
  final IconData icon;
  final LocalizedText title;
  final bool isAvailable;
}

String _comingSoon(AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => 'Скоро',
    AppLocale.en => 'Soon',
    AppLocale.kk => 'Жақында',
  };
}
