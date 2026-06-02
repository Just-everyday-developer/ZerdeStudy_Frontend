// Teacher Studio · Analytics — Phase 2.
//
// Mirrors the HTML prototype:
//   - 4 KPI tiles (enrolled / completion / quiz mean / Q&A volume)
//   - Learner funnel with drop-off highlighting
//   - Two-column split: per-cohort quiz heatmap (left) + cohort grid (right)
//   - AI root-cause cards
//
// All blocks adapt to mobile: KPIs go 1-col, funnel rows shrink, heatmap
// becomes horizontally scrollable, cohort grid stays a column.

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
      demoAppControllerProvider.select((state) => state.locale),
    );
    final colors = context.appColors;

    return TsPageScrollView(
      children: [
        TsPageHeader(
          eyebrow: _heroEyebrow.resolve(locale),
          title: _heroTitle.resolve(locale),
          subtitle: _heroSubtitle.resolve(locale),
          actions: [
            TsButton(
              label: _actionCohort.resolve(locale),
              icon: Icons.tune_rounded,
              onPressed: () {},
            ),
            TsButton(
              label: _actionPeriod.resolve(locale),
              icon: Icons.calendar_today_rounded,
              onPressed: () {},
            ),
            TsButton.primary(
              label: _actionRescan.resolve(locale),
              icon: Icons.auto_awesome_rounded,
              onPressed: () {},
            ),
          ],
        ),

        // ── KPI strip ────────────────────────────────────────────────────
        TsResponsiveGrid(
          desktopCols: 4,
          children: [
            TsKpiCard(
              label: _kpiEnrolledLabel.resolve(locale),
              value: '1 284',
              accent: colors.primary,
              delta: 11,
            ),
            TsKpiCard(
              label: _kpiCompletionLabel.resolve(locale),
              value: '78%',
              accent: colors.accent,
              delta: -2,
            ),
            TsKpiCard(
              label: _kpiQuizLabel.resolve(locale),
              value: '68%',
              accent: const Color(0xFFFBBF24),
              delta: -4,
            ),
            TsKpiCard(
              label: _kpiQnaLabel.resolve(locale),
              value: '142',
              accent: const Color(0xFFB4A8FF),
              delta: 22,
              subtitle: _kpiQnaSub.resolve(locale),
            ),
          ],
        ),

        // ── Funnel ──────────────────────────────────────────────────────
        TsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TsCardHeader(
                eyebrow: _funnelEyebrow.resolve(locale),
                eyebrowDot: colors.accent,
                title: _funnelTitle.resolve(locale),
                subtitle: _funnelSubtitle.resolve(locale),
                actions: [
                  TsButton(
                    label: _funnelByCohort.resolve(locale),
                    onPressed: () {},
                  ),
                  TsButton.primary(
                    label: _funnelWhy.resolve(locale),
                    icon: Icons.auto_awesome_rounded,
                    onPressed: () {},
                  ),
                ],
              ),
              _FunnelChart(steps: _funnelSteps(locale, colors)),
            ],
          ),
        ),

        // ── Heatmap + Cohorts ───────────────────────────────────────────
        TsResponsiveSplit(
          leftFlex: 14,
          rightFlex: 10,
          left: TsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TsCardHeader(
                  eyebrow: _heatmapEyebrow.resolve(locale),
                  title: _heatmapTitle.resolve(locale),
                  subtitle: _heatmapSubtitle.resolve(locale),
                ),
                _QuizHeatmap(
                  cohorts: const ['C-24/A', 'C-24/B', 'C-25/A', 'C-25/B'],
                  rows: [
                    _HeatRow(_q1.resolve(locale), const [.91, .88, .90, .86]),
                    _HeatRow(_q2.resolve(locale), const [.62, .58, .66, .54]),
                    _HeatRow(_q3.resolve(locale), const [.74, .69, .71, .65]),
                    _HeatRow(_q4.resolve(locale), const [.38, .34, .41, .36]),
                    _HeatRow(_q5.resolve(locale), const [.55, .48, .52, .46]),
                    _HeatRow(_q6.resolve(locale), const [.82, .79, .81, .78]),
                    _HeatRow(_q7.resolve(locale), const [.66, .61, .64, .60]),
                    _HeatRow(_q8.resolve(locale), const [.71, .67, .73, .68]),
                  ],
                ),
              ],
            ),
          ),
          right: TsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TsCardHeader(
                  eyebrow: _cohortsEyebrow.resolve(locale),
                  title: _cohortsTitle.resolve(locale),
                  subtitle: _cohortsSubtitle.resolve(locale),
                ),
                _CohortGrid(items: _cohortItems(locale)),
              ],
            ),
          ),
        ),

        // ── AI root-cause cards ─────────────────────────────────────────
        TsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TsCardHeader(
                eyebrow: _causeEyebrow.resolve(locale),
                eyebrowDot: colors.success,
                title: _causeTitle.resolve(locale),
                subtitle: _causeSubtitle.resolve(locale),
                actions: [
                  TsButton(
                    label: _causeMore.resolve(locale),
                    icon: Icons.auto_awesome_rounded,
                    onPressed: () {},
                  ),
                ],
              ),
              TsResponsiveGrid(
                desktopCols: 3,
                children: [
                  _CauseCard(
                    color: colors.danger,
                    tag: _cause1Tag.resolve(locale),
                    title: _cause1Title.resolve(locale),
                    body: _cause1Body.resolve(locale),
                    weight: 0.82,
                    action: _causeAction.resolve(locale),
                  ),
                  _CauseCard(
                    color: const Color(0xFFFBBF24),
                    tag: _cause2Tag.resolve(locale),
                    title: _cause2Title.resolve(locale),
                    body: _cause2Body.resolve(locale),
                    weight: 0.61,
                    action: _causeAction.resolve(locale),
                  ),
                  _CauseCard(
                    color: colors.accent,
                    tag: _cause3Tag.resolve(locale),
                    title: _cause3Title.resolve(locale),
                    body: _cause3Body.resolve(locale),
                    weight: 0.54,
                    action: _causeAction.resolve(locale),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_FunnelStep> _funnelSteps(AppLocale l, AppThemeColors c) => [
        _FunnelStep(_step1.resolve(l), 1284, c.primary),
        _FunnelStep(_step2.resolve(l), 1241, c.primary),
        _FunnelStep(_step3.resolve(l), 1180, c.primary),
        _FunnelStep(_step4.resolve(l), 1144, c.primary),
        _FunnelStep(_step5.resolve(l), 1052, c.primary),
        _FunnelStep(_step6.resolve(l), 1018, c.accent),
        _FunnelStep(_step7.resolve(l), 612, c.danger),
        _FunnelStep(_step8.resolve(l), 542, c.primary),
        _FunnelStep(_step9.resolve(l), 471, c.primary),
        _FunnelStep(_step10.resolve(l), 459, c.success),
      ];

  List<_CohortItem> _cohortItems(AppLocale l) => [
        _CohortItem('C-24/A', 312, 82, 58, active: false),
        _CohortItem('C-24/B', 287, 76, 51, active: false),
        _CohortItem('C-25/A', 341, 71, 49, active: true),
        _CohortItem('C-25/B', 344, 64, 44, active: true),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Funnel chart
// ─────────────────────────────────────────────────────────────────────────────

class _FunnelStep {
  _FunnelStep(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}

class _FunnelChart extends StatelessWidget {
  const _FunnelChart({required this.steps});
  final List<_FunnelStep> steps;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final maxValue = steps.first.value;
    final compact = MediaQuery.sizeOf(context).width < 600;
    final labelWidth = compact ? 110.0 : 180.0;

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          () {
            final s = steps[i];
            final pct = s.value / maxValue;
            final prev = i > 0 ? steps[i - 1].value : s.value;
            final drop = i > 0 ? ((prev - s.value) / prev * 100).round() : 0;
            final big = drop >= 30;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: labelWidth,
                    child: Text(
                      s.label,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Stack(
                        children: [
                          Container(
                            height: 22,
                            decoration: BoxDecoration(
                              color: colors.surfaceSoft,
                              border: Border.all(color: colors.divider),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.centerLeft,
                            widthFactor: pct,
                            child: Container(
                              height: 22,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    s.color,
                                    s.color.withValues(alpha: 0.6),
                                  ],
                                ),
                                border: Border(
                                  right: big
                                      ? BorderSide(
                                          color: colors.danger, width: 2)
                                      : BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 64,
                    child: Text(
                      _formatNumber(s.value),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 50,
                    child: Text(
                      i == 0 ? '100%' : '−$drop%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: i == 0
                            ? colors.textSecondary
                            : drop >= 30
                                ? colors.danger
                                : drop >= 10
                                    ? colors.accent
                                    : colors.textSecondary,
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }(),
        ],
      ],
    );
  }

  String _formatNumber(int n) =>
      n.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m.group(1)} ',
          );
}

// ─────────────────────────────────────────────────────────────────────────────
// Quiz accuracy heatmap
// ─────────────────────────────────────────────────────────────────────────────

class _HeatRow {
  _HeatRow(this.label, this.values);
  final String label;
  final List<double> values;
}

class _QuizHeatmap extends StatelessWidget {
  const _QuizHeatmap({required this.cohorts, required this.rows});
  final List<String> cohorts;
  final List<_HeatRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 360),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row
            Row(
              children: [
                const SizedBox(width: 180),
                for (final c in cohorts)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: 56,
                      child: Text(
                        c,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 10.5,
                          fontFamily: 'monospace',
                          letterSpacing: 0.04,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: Text(
                        row.label,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    for (final v in row.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _HeatCell(value: v),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            // Legend
            Row(
              children: [
                Text(
                  '0%',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 10.5,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          colors.danger,
                          colors.accent,
                          const Color(0xFFFBBF24),
                          colors.primary,
                          colors.success,
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '100%',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 10.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.value});
  final double value;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bg = tsQualityColor(value, colors);
    return Container(
      width: 56,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${(value * 100).round()}',
        style: TextStyle(
          color: value < 0.5 ? Colors.white : const Color(0xFF062623),
          fontSize: 11.5,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cohort grid
// ─────────────────────────────────────────────────────────────────────────────

class _CohortItem {
  _CohortItem(this.id, this.learners, this.completion, this.nps,
      {required this.active});
  final String id;
  final int learners;
  final int completion;
  final int nps;
  final bool active;
}

class _CohortGrid extends StatelessWidget {
  const _CohortGrid({required this.items});
  final List<_CohortItem> items;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: items[i].active
                  ? colors.primary.withValues(alpha: 0.07)
                  : colors.surfaceSoft.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: items[i].active
                    ? colors.primary.withValues(alpha: 0.3)
                    : colors.divider.withValues(alpha: 0.55),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].id,
                        style: TextStyle(
                          color: items[i].active
                              ? colors.primary
                              : colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].active ? 'ACTIVE' : 'CLOSED',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 9.5,
                          fontFamily: 'monospace',
                          letterSpacing: 0.14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _CohortMetric(
                        label: 'LEARNERS',
                        value: items[i].learners.toString(),
                      ),
                      _CohortMetric(
                        label: 'COMPLETION',
                        value: '${items[i].completion}%',
                        color: items[i].completion >= 75
                            ? colors.success
                            : items[i].completion >= 65
                                ? colors.accent
                                : colors.danger,
                      ),
                      _CohortMetric(
                        label: 'NPS',
                        value: '+${items[i].nps}',
                        color: items[i].nps >= 50
                            ? colors.success
                            : colors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (i != items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _CohortMetric extends StatelessWidget {
  const _CohortMetric({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TsEyebrow(label),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color ?? colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: 'monospace',
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cause card
// ─────────────────────────────────────────────────────────────────────────────

class _CauseCard extends StatelessWidget {
  const _CauseCard({
    required this.color,
    required this.tag,
    required this.title,
    required this.body,
    required this.weight,
    required this.action,
  });
  final Color color;
  final String tag, title, body, action;
  final double weight;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider.withValues(alpha: 0.55)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TsTag(label: tag, color: color),
                    const Spacer(),
                    Text(
                      'conf · ${(weight * 100).round()}',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 10.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TsButton(
                    label: action,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Strings
// ─────────────────────────────────────────────────────────────────────────────

final _heroEyebrow = teacherText(
  ru: 'SQL/01 · ПОСЛЕДНИЕ 30 ДНЕЙ',
  en: 'SQL/01 · LAST 30 DAYS',
  kk: 'SQL/01 · СОҢҒЫ 30 КҮН',
);
final _heroTitle = teacherText(
  ru: 'Аналитика',
  en: 'Analytics',
  kk: 'Аналитика',
);
final _heroSubtitle = teacherText(
  ru:
      'Funnel, точность quiz, сравнение групп и AI-причины для курса SQL for Analysts.',
  en:
      'Funnel, quiz accuracy, cohort comparison and AI-surfaced root causes for SQL for Analysts.',
  kk:
      'SQL for Analysts курсы үшін funnel, quiz дәлдігі, топ салыстыру және AI себептері.',
);
final _actionCohort = teacherText(
  ru: 'Группа: все',
  en: 'Cohort: All',
  kk: 'Топ: бәрі',
);
final _actionPeriod =
    teacherText(ru: '30 дней', en: '30 days', kk: '30 күн');
final _actionRescan = teacherText(
  ru: 'Перезапустить AI-сканирование',
  en: 'Re-run AI scan',
  kk: 'AI сканерді қайта іске қосу',
);

final _kpiEnrolledLabel = teacherText(
  ru: 'Записались · 30д',
  en: 'Enrolled · 30d',
  kk: 'Жазылғандар · 30к',
);
final _kpiCompletionLabel = teacherText(
  ru: 'Завершение',
  en: 'Completion',
  kk: 'Аяқтау',
);
final _kpiQuizLabel = teacherText(
  ru: 'Среднее quiz',
  en: 'Quiz mean',
  kk: 'Quiz орташасы',
);
final _kpiQnaLabel = teacherText(
  ru: 'Объём Q&A',
  en: 'Q&A volume',
  kk: 'Q&A көлемі',
);
final _kpiQnaSub = teacherText(
  ru: '↑ в модуле joins',
  en: '↑ in joins module',
  kk: '↑ joins модулінде',
);

final _funnelEyebrow = teacherText(
  ru: 'ВОРОНКА УЧЕНИКОВ',
  en: 'LEARNER FUNNEL',
  kk: 'ОҚУШЫ ВОРОНКАСЫ',
);
final _funnelTitle = teacherText(
  ru: 'Где ученики уходят',
  en: 'Where learners drop out',
  kk: 'Оқушылар қайдан кетеді',
);
final _funnelSubtitle = teacherText(
  ru:
      '612 из 1018 доходят до конца M3 · Joins. 40% потеря — главный сигнал месяца.',
  en:
      '612 of 1018 reach the end of M3 · Joins. The 40% loss is the dominant signal this month.',
  kk:
      '1018-дің 612-сі M3 · Joins аяғына жетеді. 40% жоғалту — айдың басты сигналы.',
);
final _funnelByCohort = teacherText(
  ru: 'По группам',
  en: 'By cohort',
  kk: 'Топтар бойынша',
);
final _funnelWhy =
    teacherText(ru: 'Почему? · AI', en: 'Why? · AI', kk: 'Неге? · AI');
final _step1 =
    teacherText(ru: 'Записались', en: 'Enrolled', kk: 'Жазылған');
final _step2 = teacherText(ru: 'Начали M1', en: 'Started M1', kk: 'M1 бастаған');
final _step3 = teacherText(
  ru: 'Закончили M1',
  en: 'Finished M1',
  kk: 'M1 аяқтаған',
);
final _step4 = teacherText(ru: 'Начали M2', en: 'Started M2', kk: 'M2 бастаған');
final _step5 = teacherText(
  ru: 'Закончили M2',
  en: 'Finished M2',
  kk: 'M2 аяқтаған',
);
final _step6 = teacherText(
  ru: 'Начали M3 · Joins',
  en: 'Started M3 · Joins',
  kk: 'M3 · Joins бастаған',
);
final _step7 = teacherText(
  ru: 'Закончили M3',
  en: 'Finished M3',
  kk: 'M3 аяқтаған',
);
final _step8 = teacherText(
  ru: 'Закончили M4',
  en: 'Finished M4',
  kk: 'M4 аяқтаған',
);
final _step9 = teacherText(
  ru: 'Сдали capstone',
  en: 'Capstone submitted',
  kk: 'Capstone тапсырған',
);
final _step10 = teacherText(
  ru: 'Сертификат',
  en: 'Certified',
  kk: 'Сертификат',
);

final _heatmapEyebrow = teacherText(
  ru: 'ТОЧНОСТЬ QUIZ · ПО ГРУППАМ',
  en: 'QUIZ ACCURACY · BY COHORT',
  kk: 'QUIZ ДӘЛДІГІ · ТОПТАР БОЙЫНША',
);
final _heatmapTitle = teacherText(
  ru: 'Joins quiz · по вопросам',
  en: 'Joins quiz · item-level heatmap',
  kk: 'Joins quiz · сұрақтар бойынша',
);
final _heatmapSubtitle = teacherText(
  ru:
      'Каждая ячейка — средняя точность по вопросу. Q4 (Self join) слабейший везде.',
  en:
      'Each cell = mean accuracy on that item. Q4 (Self join cases) is the weakest item across every cohort.',
  kk:
      'Әр ұяшық — сұрақтың орташа дәлдігі. Q4 (Self join) барлық топта әлсіз.',
);
final _q1 = teacherText(
  ru: 'Q1 · INNER JOIN базис',
  en: 'Q1 · INNER JOIN basics',
  kk: 'Q1 · INNER JOIN негіздері',
);
final _q2 = teacherText(
  ru: 'Q2 · семантика NULL',
  en: 'Q2 · NULL semantics',
  kk: 'Q2 · NULL семантикасы',
);
final _q3 = teacherText(
  ru: 'Q3 · LEFT vs RIGHT',
  en: 'Q3 · LEFT vs RIGHT',
  kk: 'Q3 · LEFT vs RIGHT',
);
final _q4 = teacherText(
  ru: 'Q4 · self join',
  en: 'Q4 · Self join cases',
  kk: 'Q4 · self join',
);
final _q5 = teacherText(
  ru: 'Q5 · CROSS JOIN ловушка',
  en: 'Q5 · CROSS JOIN footgun',
  kk: 'Q5 · CROSS JOIN тұзақ',
);
final _q6 = teacherText(
  ru: 'Q6 · смешанные AND/OR',
  en: 'Q6 · Mixed AND/OR',
  kk: 'Q6 · аралас AND/OR',
);
final _q7 = teacherText(
  ru: 'Q7 · equi-join',
  en: 'Q7 · Equi-join',
  kk: 'Q7 · equi-join',
);
final _q8 = teacherText(
  ru: 'Q8 · set operations',
  en: 'Q8 · Set operations',
  kk: 'Q8 · set operations',
);

final _cohortsEyebrow =
    teacherText(ru: 'ГРУППЫ', en: 'COHORTS', kk: 'ТОПТАР');
final _cohortsTitle = teacherText(
  ru: 'Сравнение',
  en: 'Side-by-side',
  kk: 'Қатар салыстыру',
);
final _cohortsSubtitle = teacherText(
  ru: 'Сравниваем 4 последние группы по ключевым метрикам.',
  en: 'Compare the 4 most recent cohorts on the metrics that matter.',
  kk: 'Соңғы 4 топты негізгі метрикалар бойынша салыстырамыз.',
);

final _causeEyebrow = teacherText(
  ru: 'AI · ПРИЧИНЫ',
  en: 'AI ROOT-CAUSE',
  kk: 'AI · СЕБЕПТЕР',
);
final _causeTitle = teacherText(
  ru: 'Почему это происходит?',
  en: 'Why is this happening?',
  kk: 'Неге бұл болып жатыр?',
);
final _causeSubtitle = teacherText(
  ru: 'Три причинных гипотезы из данных недели.',
  en: "Three causal hypotheses the system extracted from this week's data.",
  kk: 'Осы апта деректерінен үш себептік болжам.',
);
final _causeMore = teacherText(
  ru: 'Ещё гипотезы',
  en: 'Generate more',
  kk: 'Тағы болжам',
);
final _causeAction = teacherText(
  ru: 'Разобрать',
  en: 'Investigate',
  kk: 'Зерттеу',
);
final _cause1Tag =
    teacherText(ru: 'ПРЕРЕКВИЗИТ', en: 'PREREQUISITE GAP', kk: 'ПРЕРЕКВИЗИТ');
final _cause1Title = teacherText(
  ru: 'Учеников бросают на OUTER joins без знания NULL',
  en: 'Learners hit OUTER joins without NULL fluency',
  kk: 'Оқушылар NULL білмей-ақ OUTER joins-қа жетеді',
);
final _cause1Body = teacherText(
  ru:
      '84% тех, кто провалил Q4, также промахивались по NULL в Q2. Bridge-урок решает оба.',
  en:
      '84% of learners who fail Q4 also miss NULL-related items in Q2. The bridge lesson addresses both.',
  kk:
      'Q4 құлаған 84% оқушы Q2-де NULL сұрақтарын да қателесті. Bridge-сабақ екеуін де шешеді.',
);
final _cause2Tag = teacherText(
  ru: 'НЕОДНОЗНАЧНОСТЬ',
  en: 'AMBIGUOUS WORDING',
  kk: 'ЕКІҰШТЫ ТҰЖЫРЫМ',
);
final _cause2Title = teacherText(
  ru: 'У Q4 distractor B выглядит верным',
  en: 'Q4 distractor B is plausibly correct',
  kk: 'Q4 distractor B дұрыс сияқты көрінеді',
);
final _cause2Body = teacherText(
  ru:
      'C-24/A непропорционально выбирали distractor B — проблема в формулировке, не в концепции.',
  en:
      'Cohort-A students disproportionately picked distractor B, suggesting wording is the issue.',
  kk:
      'C-24/A студенттері B-ні жиі таңдады — мәселе тұжырымда, концепцияда емес.',
);
final _cause3Tag = teacherText(ru: 'ТЕМП', en: 'PACING', kk: 'ҚАРҚЫН');
final _cause3Title = teacherText(
  ru: 'Lab #14 на 38% длиннее медианы',
  en: 'Lab #14 is 38% longer than median',
  kk: 'Lab #14 медианадан 38% ұзақ',
);
final _cause3Body = teacherText(
  ru:
      'Медиана для Lab 14 = 92 мин против 55 мин по курсу. Сократите до 8 puzzles или разделите.',
  en:
      'Median completion for Lab 14 is 92 min vs the course median of 55 min. Trim to 8 puzzles or split.',
  kk:
      'Lab 14 медианасы — 92 мин, ал курс медианасы — 55 мин. 8 puzzles-қа дейін қысқартыңыз.',
);
