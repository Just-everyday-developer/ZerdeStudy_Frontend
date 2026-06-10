import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../teacher_text.dart';
import '../widgets/teacher_studio_widgets.dart';

class TeacherAnalyticsPage extends ConsumerWidget {
  const TeacherAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      demoAppControllerProvider.select((s) => s.locale),
    );
    final colors = context.appColors;

    return TsPageScrollView(
      children: [
        TsPageHeader(
          eyebrow: _eyebrow.resolve(locale),
          title: _title.resolve(locale),
          subtitle: _subtitle.resolve(locale),
        ),
        _EmptyState(colors: colors, locale: locale),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.locale});
  final AppThemeColors colors;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 52, color: colors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            _emptyTitle.resolve(locale),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _emptyBody.resolve(locale),
            style: TextStyle(color: colors.textSecondary, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

final _eyebrow = teacherText(ru: 'АНАЛИТИКА', en: 'ANALYTICS', kk: 'АНАЛИТИКА');
final _title = teacherText(ru: 'Статистика курсов', en: 'Course Analytics', kk: 'Курс статистикасы');
final _subtitle = teacherText(
  ru: 'Данные о прохождении, результатах тестов и активности учеников.',
  en: 'Completion rates, quiz results and learner activity.',
  kk: 'Аяқтау деңгейі, тест нәтижелері және оқушы белсенділігі.',
);
final _emptyTitle = teacherText(
  ru: 'Аналитика пока недоступна',
  en: 'Analytics not available yet',
  kk: 'Аналитика әлі қолжетімді емес',
);
final _emptyBody = teacherText(
  ru: 'Статистика появится после того, как студенты начнут проходить ваши курсы.',
  en: 'Stats will appear once students start progressing through your courses.',
  kk: 'Студенттер курстарыңызды өте бастаған соң статистика пайда болады.',
);
