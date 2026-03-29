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
      description: LocalizedText(
        ru: 'Текущий учебный интерфейс, прогресс и каталог курсов.',
        en: 'Current learning app, progress flow, and course catalog.',
        kk: 'Ағымдағы оқу интерфейсі, прогресс және курс каталогы.',
      ),
    ),
    _ExperienceOption(
      experience: AppExperience.teacher,
      icon: Icons.auto_stories_rounded,
      title: LocalizedText(ru: 'Преподаватель', en: 'Teacher', kk: 'Оқытушы'),
      description: LocalizedText(
        ru: 'Панель преподавателя: генерация курсов, конструктор и аналитика.',
        en: 'Teacher workspace with generation, builder, and analytics.',
        kk: 'Курс генерациясы, конструктор және аналитикасы бар оқытушы панелі.',
      ),
    ),
    _ExperienceOption(
      experience: AppExperience.moderator,
      icon: Icons.verified_user_rounded,
      title: LocalizedText(ru: 'Модератор', en: 'Moderator', kk: 'Модератор'),
      description: LocalizedText(
        ru: 'Доступ к существующей панели модерации и ревью.',
        en: 'Open the existing moderation and review workspace.',
        kk: 'Қолданыстағы модерация және ревью панеліне өту.',
      ),
    ),
    _ExperienceOption(
      experience: AppExperience.admin,
      icon: Icons.admin_panel_settings_rounded,
      title: LocalizedText(ru: 'Админ', en: 'Admin', kk: 'Админ'),
      description: LocalizedText(
        ru: 'Панель администратора еще не готова, роль пока недоступна.',
        en: 'The admin panel is not ready yet and remains unavailable.',
        kk: 'Әкімші панелі әлі дайын емес, бұл рөл әзірге қолжетімсіз.',
      ),
      isAvailable: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = switch (constraints.maxWidth) {
          >= 1320 => 4,
          >= 760 => 2,
          _ => 1,
        };

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _options.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: crossAxisCount == 1 ? 176 : 208,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                const Spacer(),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              option.title.resolve(locale),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              option.description.resolve(locale),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
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
    required this.description,
    this.isAvailable = true,
  });

  final AppExperience experience;
  final IconData icon;
  final LocalizedText title;
  final LocalizedText description;
  final bool isAvailable;
}

String _comingSoon(AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => 'Скоро',
    AppLocale.en => 'Soon',
    AppLocale.kk => 'Жақында',
  };
}
