// Teacher Studio · Dashboard (Overview) — Phase 2.
//
// Mirrors the HTML prototype:
//   - Hero header (greeting + actions)
//   - 4 KPI cards with deltas + sparklines
//   - Two-column split (collapses): "Today" operating list | "AI insights"
//   - Course portfolio (table on desktop, card list on mobile)
//
// All copy goes through `teacherText(ru/en/kk)` to stay locale-aware.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../teacher_text.dart';
import '../widgets/teacher_studio_widgets.dart';

class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      demoAppControllerProvider.select((state) => state.locale),
    );
    final demoState = ref.watch(demoAppControllerProvider);
    final colors = context.appColors;
    final compact = MediaQuery.sizeOf(context).width < 700;
    final firstName = (demoState.user?.name ?? 'Aigerim').split(' ').first;

    return TsPageScrollView(
      children: [
        TsPageHeader(
          eyebrow: _heroEyebrow.resolve(locale),
          title: _heroTitleTemplate.resolve(locale).replaceAll(
                '{name}',
                firstName,
              ),
          subtitle: _heroSubtitle.resolve(locale),
          actions: [
            TsButton(
              label: _actionPreview.resolve(locale),
              icon: Icons.remove_red_eye_outlined,
              onPressed: () {},
            ),
            TsButton.primary(
              label: _actionNew.resolve(locale),
              icon: Icons.add_rounded,
              onPressed: () => context.go(AppRoutes.teacherBuilder),
            ),
          ],
        ),

        // ── KPI strip ────────────────────────────────────────────────────
        TsResponsiveGrid(
          desktopCols: 4,
          children: [
            TsKpiCard(
              label: _kpiCoursesLabel.resolve(locale),
              value: '12',
              accent: colors.primary,
              delta: 8,
              subtitle: _kpiCoursesSub.resolve(locale),
              spark: const [3, 5, 6, 8, 9, 10, 12],
            ),
            TsKpiCard(
              label: _kpiLearnersLabel.resolve(locale),
              value: '2 488',
              accent: colors.success,
              delta: 9,
              subtitle: _kpiLearnersSub.resolve(locale),
              spark: const [1800, 1900, 1980, 2100, 2240, 2380, 2488],
            ),
            TsKpiCard(
              label: _kpiCompletionLabel.resolve(locale),
              value: '78%',
              accent: colors.accent,
              delta: -2,
              subtitle: _kpiCompletionSub.resolve(locale),
              spark: const [80, 79, 78, 80, 79, 78, 78],
            ),
            TsKpiCard(
              label: _kpiQnaLabel.resolve(locale),
              value: '12',
              accent: const Color(0xFFB4A8FF),
              delta: 22,
              subtitle: _kpiQnaSub.resolve(locale),
              spark: const [6, 8, 7, 9, 10, 11, 12],
            ),
          ],
        ),

        // ── Today × AI insights ─────────────────────────────────────────
        TsResponsiveSplit(
          leftFlex: 11,
          rightFlex: 10,
          left: TsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TsCardHeader(
                  eyebrow: _todayEyebrow.resolve(locale),
                  eyebrowDot: colors.success,
                  title: _todayTitle.resolve(locale),
                  subtitle: _todaySubtitle.resolve(locale),
                ),
                _todayList(context, locale, colors),
              ],
            ),
          ),
          right: TsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TsCardHeader(
                  eyebrow: _insightsEyebrow.resolve(locale),
                  eyebrowDot: colors.accent,
                  title: _insightsTitle.resolve(locale),
                  subtitle: _insightsSubtitle.resolve(locale),
                ),
                _insightsList(context, locale, colors),
              ],
            ),
          ),
        ),

        // ── Course portfolio ─────────────────────────────────────────────
        TsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TsCardHeader(
                eyebrow: _portfolioEyebrow.resolve(locale),
                title: _portfolioTitle.resolve(locale),
                subtitle: _portfolioSubtitle.resolve(locale),
              ),
              compact
                  ? _PortfolioCards(courses: _seedCourses(locale))
                  : _PortfolioTable(courses: _seedCourses(locale)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Sub-builders ──────────────────────────────────────────────────────
  Widget _todayList(BuildContext context, AppLocale locale, AppThemeColors c) {
    final items = [
      _TodayItem(
        tag: _todayTagRevise.resolve(locale),
        tagColor: c.danger,
        title: _todayOneTitle.resolve(locale),
        meta: _todayOneMeta.resolve(locale),
        actionLabel: _todayActionOpenDraft.resolve(locale),
      ),
      _TodayItem(
        tag: _todayTagReview.resolve(locale),
        tagColor: c.accent,
        title: _todayTwoTitle.resolve(locale),
        meta: _todayTwoMeta.resolve(locale),
        actionLabel: _todayActionReview.resolve(locale),
      ),
      _TodayItem(
        tag: _todayTagReply.resolve(locale),
        tagColor: c.primary,
        title: _todayThreeTitle.resolve(locale),
        meta: _todayThreeMeta.resolve(locale),
        actionLabel: _todayActionTriage.resolve(locale),
      ),
      _TodayItem(
        tag: _todayTagPublish.resolve(locale),
        tagColor: c.success,
        title: _todayFourTitle.resolve(locale),
        meta: _todayFourMeta.resolve(locale),
        actionLabel: _todayActionResolve.resolve(locale),
      ),
    ];
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          TsStatusLine(
            tag: items[i].tag,
            tagColor: items[i].tagColor,
            title: items[i].title,
            meta: items[i].meta,
            trailing: TsButton(
              label: items[i].actionLabel,
              icon: Icons.arrow_forward_rounded,
              onPressed: () {},
            ),
          ),
          if (i != items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _insightsList(
      BuildContext context, AppLocale locale, AppThemeColors c) {
    final items = [
      _InsightItem(
        tagColor: c.danger,
        tag: _insightOneTag.resolve(locale),
        title: _insightOneTitle.resolve(locale),
        body: _insightOneBody.resolve(locale),
        action: _insightOneAction.resolve(locale),
        primary: true,
      ),
      _InsightItem(
        tagColor: c.accent,
        tag: _insightTwoTag.resolve(locale),
        title: _insightTwoTitle.resolve(locale),
        body: _insightTwoBody.resolve(locale),
        action: _insightTwoAction.resolve(locale),
      ),
      _InsightItem(
        tagColor: c.success,
        tag: _insightThreeTag.resolve(locale),
        title: _insightThreeTitle.resolve(locale),
        body: _insightThreeBody.resolve(locale),
        action: _insightThreeAction.resolve(locale),
      ),
    ];
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _InsightRow(item: items[i]),
          if (i != items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  List<_CourseRow> _seedCourses(AppLocale locale) => [
        _CourseRow(
          code: 'SQL/01',
          title: 'SQL for Analysts',
          learners: 1284,
          modules: 11,
          cohorts: 4,
          completion: 78,
          health: 62,
          drift: -4,
          version: '3.2',
          status: _statusLive.resolve(locale),
          statusKind: _Status.live,
          lastEdit: _lastEdit2h.resolve(locale),
        ),
        _CourseRow(
          code: 'FE/02',
          title: 'Frontend Sprint Bootcamp',
          learners: 612,
          modules: 14,
          cohorts: 2,
          completion: 71,
          health: 84,
          drift: 6,
          version: '3.1',
          status: _statusLive.resolve(locale),
          statusKind: _Status.live,
          lastEdit: _lastEditYesterday.resolve(locale),
        ),
        _CourseRow(
          code: 'DM/03',
          title: 'Discrete Math Core',
          learners: 388,
          modules: 9,
          cohorts: 1,
          completion: 64,
          health: 71,
          drift: -1,
          version: '3.0',
          status: _statusLive.resolve(locale),
          statusKind: _Status.live,
          lastEdit: _lastEdit3d.resolve(locale),
        ),
        _CourseRow(
          code: 'API/04',
          title: 'API Security Clinic',
          learners: 204,
          modules: 7,
          cohorts: 1,
          completion: 52,
          health: 41,
          drift: -11,
          version: '—',
          status: _statusReview.resolve(locale),
          statusKind: _Status.review,
          lastEdit: _lastEdit12h.resolve(locale),
        ),
        _CourseRow(
          code: 'ML/05',
          title: 'ML Foundations',
          learners: 0,
          modules: 5,
          cohorts: 0,
          completion: 0,
          health: 0,
          drift: 0,
          version: '—',
          status: _statusDraft.resolve(locale),
          statusKind: _Status.draft,
          lastEdit: _lastEditJustNow.resolve(locale),
        ),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Insight row
// ─────────────────────────────────────────────────────────────────────────────

class _InsightItem {
  _InsightItem({
    required this.tagColor,
    required this.tag,
    required this.title,
    required this.body,
    required this.action,
    this.primary = false,
  });
  final Color tagColor;
  final String tag, title, body, action;
  final bool primary;
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.item});
  final _InsightItem item;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TsTag(label: item.tag, color: item.tagColor),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.body,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: compact ? Alignment.centerLeft : Alignment.centerRight,
            child: item.primary
                ? TsButton.primary(
                    label: item.action,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {},
                  )
                : TsButton(
                    label: item.action,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {},
                  ),
          ),
        ],
      ),
    );
  }
}

class _TodayItem {
  _TodayItem({
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.meta,
    required this.actionLabel,
  });
  final String tag, title, meta, actionLabel;
  final Color tagColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// Portfolio · table (desktop) and cards (mobile)
// ─────────────────────────────────────────────────────────────────────────────

enum _Status { live, review, draft }

class _CourseRow {
  _CourseRow({
    required this.code,
    required this.title,
    required this.learners,
    required this.modules,
    required this.cohorts,
    required this.completion,
    required this.health,
    required this.drift,
    required this.version,
    required this.status,
    required this.statusKind,
    required this.lastEdit,
  });
  final String code, title, version, status, lastEdit;
  final int learners, modules, cohorts, completion, health, drift;
  final _Status statusKind;
}

class _PortfolioTable extends StatelessWidget {
  const _PortfolioTable({required this.courses});
  final List<_CourseRow> courses;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final headerStyle = TextStyle(
      color: colors.textSecondary,
      fontSize: 10,
      letterSpacing: 0.14,
      fontWeight: FontWeight.w600,
      fontFamily: 'monospace',
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width - 80,
        ),
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 56,
          dataRowMaxHeight: 64,
          columnSpacing: 18,
          horizontalMargin: 4,
          dividerThickness: 0.8,
          headingTextStyle: headerStyle,
          columns: [
            DataColumn(label: Text('COURSE', style: headerStyle)),
            DataColumn(label: Text('LEARNERS', style: headerStyle), numeric: true),
            DataColumn(label: Text('COMPLETION', style: headerStyle)),
            DataColumn(label: Text('HEALTH', style: headerStyle)),
            DataColumn(label: Text('DRIFT', style: headerStyle)),
            DataColumn(label: Text('VER', style: headerStyle)),
            DataColumn(label: Text('STATUS', style: headerStyle)),
          ],
          rows: [
            for (final c in courses)
              DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: Text(
                            c.code,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 10.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.title,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${c.modules} · ${c.cohorts} · ${c.lastEdit}',
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
                  DataCell(Text(
                    c.learners.toString().replaceAllMapped(
                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                          (m) => '${m.group(1)} ',
                        ),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                    ),
                  )),
                  DataCell(SizedBox(
                    width: 100,
                    child: _CompletionBar(value: c.completion / 100),
                  )),
                  DataCell(Text(
                    c.health == 0 ? '—' : '${c.health}',
                    style: TextStyle(
                      color: c.health == 0
                          ? colors.textSecondary
                          : c.health < 50
                              ? colors.danger
                              : c.health < 70
                                  ? colors.accent
                                  : colors.success,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  )),
                  DataCell(TsDelta(value: c.drift)),
                  DataCell(Text(
                    c.statusKind == _Status.draft ? '—' : 'v${c.version}',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                    ),
                  )),
                  DataCell(TsTag(
                    label: c.status,
                    color: c.statusKind == _Status.live
                        ? colors.success
                        : c.statusKind == _Status.review
                            ? colors.accent
                            : colors.textSecondary,
                  )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CompletionBar extends StatelessWidget {
  const _CompletionBar({required this.value});
  final double value;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = value == 0
        ? colors.divider
        : value < 0.6
            ? colors.danger
            : value < 0.75
                ? colors.accent
                : colors.success;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 5,
              backgroundColor: colors.surfaceSoft,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value == 0 ? '—' : '${(value * 100).round()}%',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 11.5,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _PortfolioCards extends StatelessWidget {
  const _PortfolioCards({required this.courses});
  final List<_CourseRow> courses;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        for (var i = 0; i < courses.length; i++) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceSoft.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.divider.withValues(alpha: 0.55)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      courses[i].code,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 10.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(),
                    TsTag(
                      label: courses[i].status,
                      color: courses[i].statusKind == _Status.live
                          ? colors.success
                          : courses[i].statusKind == _Status.review
                              ? colors.accent
                              : colors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  courses[i].title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${courses[i].modules} · ${courses[i].cohorts} · '
                  '${courses[i].lastEdit}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 12),
                _CompletionBar(value: courses[i].completion / 100),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TsEyebrow('LEARNERS'),
                          const SizedBox(height: 2),
                          Text(
                            courses[i].learners.toString(),
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontFamily: 'monospace',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TsEyebrow('HEALTH'),
                          const SizedBox(height: 2),
                          Text(
                            courses[i].health == 0
                                ? '—'
                                : '${courses[i].health}',
                            style: TextStyle(
                              color: courses[i].health == 0
                                  ? colors.textSecondary
                                  : courses[i].health < 50
                                      ? colors.danger
                                      : courses[i].health < 70
                                          ? colors.accent
                                          : colors.success,
                              fontFamily: 'monospace',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TsEyebrow('DRIFT'),
                          const SizedBox(height: 2),
                          TsDelta(value: courses[i].drift),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (i != courses.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Localized strings
// ─────────────────────────────────────────────────────────────────────────────

final _heroEyebrow = teacherText(
  ru: 'СЕГОДНЯ · ВТОРНИК',
  en: 'TODAY · TUESDAY',
  kk: 'БҮГІН · СЕЙСЕНБІ',
);
final _heroTitleTemplate = teacherText(
  ru: 'Доброе утро, {name}.  4 решения сегодня.',
  en: 'Good morning, {name}.  4 things need a decision today.',
  kk: 'Қайырлы таң, {name}.  Бүгін 4 шешім керек.',
);
final _heroSubtitle = teacherText(
  ru:
      'Здоровье курсов, сигналы от студентов и AI-предложения. Всё отфильтровано по вашим курсам.',
  en:
      'Course health, learner signals and AI proposals. Filtered to courses you author.',
  kk:
      'Курс денсаулығы, студент сигналдары және AI ұсыныстары. Сіздің курстарыңыз бойынша сүзілген.',
);
final _actionPreview = teacherText(
  ru: 'Просмотр студента',
  en: 'Student preview',
  kk: 'Студент көрінісі',
);
final _actionNew = teacherText(
  ru: 'Новый курс',
  en: 'New course',
  kk: 'Жаңа курс',
);

// KPI strings
final _kpiCoursesLabel = teacherText(
  ru: 'Активные курсы',
  en: 'Active courses',
  kk: 'Белсенді курстар',
);
final _kpiCoursesSub = teacherText(
  ru: '9 опубликовано · 3 в черновике',
  en: '9 live · 3 draft',
  kk: '9 жарияланған · 3 нобай',
);
final _kpiLearnersLabel = teacherText(
  ru: 'Активные ученики (30д)',
  en: 'Learners (active 30d)',
  kk: 'Белсенді оқушылар (30к)',
);
final _kpiLearnersSub = teacherText(
  ru: '684 активны на этой неделе',
  en: '684 active this week',
  kk: 'Осы аптада 684 белсенді',
);
final _kpiCompletionLabel = teacherText(
  ru: 'Среднее завершение',
  en: 'Avg completion',
  kk: 'Орташа аяқтау',
);
final _kpiCompletionSub = teacherText(
  ru: 'Лучший · CSS Lab 91%',
  en: 'Best · CSS Lab 91%',
  kk: 'Үздік · CSS Lab 91%',
);
final _kpiQnaLabel = teacherText(
  ru: 'Открытые вопросы',
  en: 'Pending Q&A',
  kk: 'Ашық сұрақтар',
);
final _kpiQnaSub = teacherText(
  ru: '2ч 14м среднее время ответа',
  en: '2h 14m avg first reply',
  kk: '2с 14м орташа жауап уақыты',
);

// Today list
final _todayEyebrow = teacherText(
  ru: 'ВАЖНОЕ НА СЕГОДНЯ',
  en: 'WHAT MATTERS TODAY',
  kk: 'БҮГІНГІ МАҢЫЗДЫ',
);
final _todayTitle = teacherText(
  ru: 'Рабочий список',
  en: 'Operating list',
  kk: 'Жұмыс тізімі',
);
final _todaySubtitle = teacherText(
  ru: 'Четыре пункта, отсортированные по влиянию на курсы.',
  en: 'Four items, ordered by impact on your courses this week.',
  kk: 'Курсқа әсері бойынша сұрыпталған төрт пункт.',
);
final _todayTagRevise =
    teacherText(ru: 'РЕВИЗИЯ', en: 'REVISE', kk: 'РЕВИЗИЯ');
final _todayTagReview =
    teacherText(ru: 'ПРОВЕРКА', en: 'REVIEW', kk: 'ТЕКСЕРУ');
final _todayTagReply = teacherText(ru: 'ОТВЕТ', en: 'REPLY', kk: 'ЖАУАП');
final _todayTagPublish =
    teacherText(ru: 'ПУБЛИКАЦИЯ', en: 'PUBLISH', kk: 'ЖАРИЯЛАУ');
final _todayActionOpenDraft = teacherText(
  ru: 'Открыть черновик',
  en: 'Open draft',
  kk: 'Нобайды ашу',
);
final _todayActionReview =
    teacherText(ru: 'Проверить', en: 'Review', kk: 'Тексеру');
final _todayActionTriage =
    teacherText(ru: 'Разобрать', en: 'Triage', kk: 'Сұрыптау');
final _todayActionResolve =
    teacherText(ru: 'Разрешить', en: 'Resolve', kk: 'Шешу');

final _todayOneTitle = teacherText(
  ru: 'Bridge-lesson перед OUTER joins',
  en: 'Bridge lesson before OUTER joins',
  kk: 'OUTER joins алдында bridge-сабақ',
);
final _todayOneMeta = teacherText(
  ru: 'SQL/01 · черновик 4 мин · от AI',
  en: 'SQL/01 · 4 min draft ready · by AI',
  kk: 'SQL/01 · 4 мин нобай · AI-дан',
);
final _todayTwoTitle = teacherText(
  ru: 'Одобрить 14 правок rubric от AI',
  en: 'Approve 14 AI rubric edits',
  kk: '14 AI rubric түзетуін мақұлдау',
);
final _todayTwoMeta = teacherText(
  ru: 'FE/02 · Sprint 3 capstone · от вас',
  en: 'FE/02 · Sprint 3 capstone · by you',
  kk: 'FE/02 · Sprint 3 capstone · сіздіктен',
);
final _todayThreeTitle = teacherText(
  ru: '12 вопросов от учеников',
  en: '12 learner questions pending',
  kk: '12 студент сұрағы күтуде',
);
final _todayThreeMeta = teacherText(
  ru: 'Среднее время первого ответа 2ч 14м',
  en: 'Avg first response 2h 14m',
  kk: 'Орташа алғашқы жауап 2с 14м',
);
final _todayFourTitle = teacherText(
  ru: 'Обновить версию курса (3 правки)',
  en: 'Push v3.3 with 3 pending edits',
  kk: 'v3.3 шығару (3 күтуде)',
);
final _todayFourMeta = teacherText(
  ru: 'SQL/01 · последняя публикация 11ч назад',
  en: 'SQL/01 · last publish 11h ago',
  kk: 'SQL/01 · соңғы жариялау 11с бұрын',
);

// Insights
final _insightsEyebrow = teacherText(
  ru: 'AI-ИНСАЙТЫ · 3 НОВЫХ',
  en: 'AI INSIGHTS · 3 NEW',
  kk: 'AI-ИНСАЙТТАР · 3 ЖАҢА',
);
final _insightsTitle = teacherText(
  ru: 'Что заметила система',
  en: 'What the system noticed',
  kk: 'Жүйе не байқады',
);
final _insightsSubtitle = teacherText(
  ru: 'Из funnel недели, quiz и объёма Q&A.',
  en: "Generated from this week's funnel, quizzes and Q&A volume.",
  kk: 'Funnel, quiz және Q&A көлемінен жасалды.',
);
final _insightOneTag =
    teacherText(ru: 'УДЕРЖАНИЕ', en: 'RETENTION', kk: 'ҰСТАУ');
final _insightOneTitle = teacherText(
  ru: 'Модуль joins теряет 39% учеников',
  en: 'Joins module is bleeding 39% of learners',
  kk: 'Joins модулі 39% оқушыны жоғалтады',
);
final _insightOneBody = teacherText(
  ru:
      'Падение между OUTER joins и Self joins превысило порог. Lab ниже теряет ещё 8%.',
  en:
      'Drop-off between OUTER and Self joins crossed your alert threshold. The lab below loses another 8%.',
  kk:
      'OUTER пен Self joins арасындағы құлдырау шегінен асып кетті. Lab тағы 8% жоғалтады.',
);
final _insightOneAction = teacherText(
  ru: 'Вставить AI bridge-lesson',
  en: 'Insert AI bridge lesson',
  kk: 'AI bridge-сабақ қосу',
);
final _insightTwoTag =
    teacherText(ru: 'ОЦЕНКА', en: 'ASSESSMENT', kk: 'БАҒА');
final _insightTwoTitle = teacherText(
  ru: 'Quiz Q4: точность 36%',
  en: 'Quiz item Q4 accuracy is 36% across cohorts',
  kk: 'Q4 quiz: дәлдік 36%',
);
final _insightTwoBody = teacherText(
  ru:
      'Self-joins плохо смоделированы в 2 из 3 distractors. Пересоберите distractors.',
  en:
      'Self-join cases are mis-modelled in 2 of 3 distractors. Regenerate them.',
  kk:
      'Self-joins 3 distractor ішінде 2-сінде дұрыс модельденбеген. Қайта жасаңыз.',
);
final _insightTwoAction = teacherText(
  ru: 'Открыть Assessment AI',
  en: 'Open in Assessment AI',
  kk: 'Assessment AI ашу',
);
final _insightThreeTag =
    teacherText(ru: 'КОНТЕНТ', en: 'CONTENT', kk: 'КОНТЕНТ');
final _insightThreeTitle = teacherText(
  ru: 'CSS Layout Lab — самый сильный модуль',
  en: 'CSS Layout Lab is your strongest module',
  kk: 'CSS Layout Lab — ең күшті модуль',
);
final _insightThreeBody = teacherText(
  ru: 'Quiz accuracy 88%, NPS +62. Подходит как шаблон для FE-модулей.',
  en: 'Quiz accuracy holds at 88% and NPS is +62. Use as a Frontend template.',
  kk: 'Quiz accuracy 88%, NPS +62. FE үлгісіне жарайды.',
);
final _insightThreeAction = teacherText(
  ru: 'Использовать как шаблон',
  en: 'Use as template',
  kk: 'Үлгі ретінде қолдану',
);

// Portfolio
final _portfolioEyebrow = teacherText(
  ru: 'ПОРТФОЛИО · 5 ИЗ 12',
  en: 'PORTFOLIO · 5 OF 12',
  kk: 'ПОРТФОЛИО · 5 / 12',
);
final _portfolioTitle =
    teacherText(ru: 'Ваши курсы', en: 'Your courses', kk: 'Сіздің курстарыңыз');
final _portfolioSubtitle = teacherText(
  ru:
      'Нажмите строку, чтобы открыть конструктор. Drift — направление за последние 14 дней.',
  en:
      'Click any row to open the Course Builder. Drift shows direction since the last 14d.',
  kk:
      'Конструкторға кіру үшін жолды басыңыз. Drift — соңғы 14 күн бағыты.',
);
final _statusLive = teacherText(ru: 'LIVE', en: 'LIVE', kk: 'LIVE');
final _statusReview =
    teacherText(ru: 'REVIEW', en: 'REVIEW', kk: 'REVIEW');
final _statusDraft = teacherText(ru: 'DRAFT', en: 'DRAFT', kk: 'НОБАЙ');
final _lastEdit2h = teacherText(ru: '2ч назад', en: 'edited 2h', kk: '2с бұрын');
final _lastEditYesterday =
    teacherText(ru: 'вчера', en: 'yesterday', kk: 'кеше');
final _lastEdit3d = teacherText(ru: '3д назад', en: 'edited 3d', kk: '3к бұрын');
final _lastEdit12h =
    teacherText(ru: '12ч назад', en: 'edited 12h', kk: '12с бұрын');
final _lastEditJustNow =
    teacherText(ru: 'только что', en: 'just now', kk: 'жаңа ғана');
