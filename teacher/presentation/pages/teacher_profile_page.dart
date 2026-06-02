// Teacher Studio · Profile — Phase 2.
//
// Layout:
//   - Hero card with avatar, name, role, focus tags
//   - Three stat tiles (Courses authored / Learners reached / Years on platform)
//   - Two-column split (collapses): What I teach + Bio  ┃  Working priorities + Learner reach
//
// All blocks adapt to mobile: split becomes a column, stat tiles stack.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../teacher_text.dart';
import '../widgets/teacher_studio_widgets.dart';

class TeacherProfilePage extends ConsumerStatefulWidget {
  const TeacherProfilePage({super.key});
  @override
  ConsumerState<TeacherProfilePage> createState() =>
      _TeacherProfilePageState();
}

class _TeacherProfilePageState extends ConsumerState<TeacherProfilePage> {
  final Set<int> _checked = {0, 1};

  @override
  Widget build(BuildContext context) {
    final demoState = ref.watch(demoAppControllerProvider);
    final locale = demoState.locale;
    final colors = context.appColors;
    final user = demoState.user;
    final name = user?.name ?? 'Aigerim Tursynbek';
    final email = user?.email ?? 'aigerim@zerdestudy.app';
    final initial = name.trim().isEmpty
        ? 'T'
        : name.trim().substring(0, 1).toUpperCase();

    return TsPageScrollView(
      children: [
        TsPageHeader(
          eyebrow: _heroEyebrow.resolve(locale),
          title: _heroTitle.resolve(locale),
          subtitle: _heroSubtitle.resolve(locale),
        ),

        // ── Identity card ────────────────────────────────────────────────
        TsCard(
          padding: const EdgeInsets.all(20),
          child: _IdentityBlock(
            name: name,
            email: email,
            initial: initial,
            locale: locale,
          ),
        ),

        // ── Stat tiles ──────────────────────────────────────────────────
        TsResponsiveGrid(
          desktopCols: 3,
          children: [
            TsKpiCard(
              label: _statCoursesLabel.resolve(locale),
              value: '12',
              accent: colors.primary,
              subtitle: _statCoursesSub.resolve(locale),
            ),
            TsKpiCard(
              label: _statLearnersLabel.resolve(locale),
              value: '11.4k',
              accent: colors.success,
              subtitle: _statLearnersSub.resolve(locale),
            ),
            TsKpiCard(
              label: _statYearsLabel.resolve(locale),
              value: '4',
              accent: colors.accent,
              subtitle: _statYearsSub.resolve(locale),
            ),
          ],
        ),

        // ── Split: teaching context (left) | priorities + reach (right) ──
        TsResponsiveSplit(
          leftFlex: 12,
          rightFlex: 10,
          left: TsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TsCardHeader(
                  eyebrow: _teachEyebrow.resolve(locale),
                  title: _teachTitle.resolve(locale),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in [
                      'SQL',
                      'Data modeling',
                      'Frontend',
                      'Discrete math',
                      'Systems',
                      'API design',
                      'ML foundations',
                    ])
                      TsTag(label: t, color: colors.primary),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: colors.divider.withValues(alpha: 0.55), height: 1),
                const SizedBox(height: 20),
                TsEyebrow(_bioEyebrow.resolve(locale)),
                const SizedBox(height: 10),
                Text(
                  _bioBody.resolve(locale),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13.5,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          right: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TsCardHeader(
                      eyebrow: _focusEyebrow.resolve(locale),
                      title: _focusTitle.resolve(locale),
                      subtitle: _focusSubtitle.resolve(locale),
                    ),
                    for (var i = 0; i < _focusItems(locale).length; i++) ...[
                      _Priority(
                        label: _focusItems(locale)[i],
                        checked: _checked.contains(i),
                        onToggle: () => setState(() {
                          if (_checked.contains(i)) {
                            _checked.remove(i);
                          } else {
                            _checked.add(i);
                          }
                        }),
                      ),
                      if (i != _focusItems(locale).length - 1)
                        const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TsCardHeader(
                      eyebrow: _reachEyebrow.resolve(locale),
                      eyebrowDot: colors.success,
                      title: _reachTitle.resolve(locale),
                    ),
                    _LearnerReach(locale: locale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<String> _focusItems(AppLocale l) => [
        _focusOne.resolve(l),
        _focusTwo.resolve(l),
        _focusThree.resolve(l),
        _focusFour.resolve(l),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Identity block
// ─────────────────────────────────────────────────────────────────────────────

class _IdentityBlock extends StatelessWidget {
  const _IdentityBlock({
    required this.name,
    required this.email,
    required this.initial,
    required this.locale,
  });
  final String name;
  final String email;
  final String initial;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final compact = MediaQuery.sizeOf(context).width < 600;

    final avatar = Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.accent, colors.accent.withValues(alpha: 0.55)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF1B0E02),
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _role.resolve(locale),
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            TsTag(label: _focusTag.resolve(locale), color: colors.primary),
            TsTag(label: _slaTag.resolve(locale), color: colors.success),
          ],
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [avatar, const SizedBox(height: 14), identity],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar,
        const SizedBox(width: 18),
        Expanded(child: identity),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Priority checklist item
// ─────────────────────────────────────────────────────────────────────────────

class _Priority extends StatelessWidget {
  const _Priority({
    required this.label,
    required this.checked,
    required this.onToggle,
  });
  final String label;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: checked
              ? colors.primary.withValues(alpha: 0.07)
              : colors.surfaceSoft.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: colors.divider.withValues(alpha: 0.55)),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: checked ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: checked ? colors.primary : colors.divider,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: checked
                  ? const Icon(Icons.check_rounded,
                      size: 11, color: Color(0xFF062623))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Learner reach ring + breakdown
// ─────────────────────────────────────────────────────────────────────────────

class _LearnerReach extends StatelessWidget {
  const _LearnerReach({required this.locale});
  final AppLocale locale;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TsRing(
          value: 0.74,
          color: colors.success,
          size: 84,
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TsEyebrow(_ringTopLabel.resolve(locale)),
              Text(
                '2 488',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  fontFamily: 'monospace',
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReachRow(
                color: colors.primary,
                label: _reach1.resolve(locale),
                value: '1 642',
                pct: 66,
              ),
              const SizedBox(height: 8),
              _ReachRow(
                color: colors.accent,
                label: _reach2.resolve(locale),
                value: '612',
                pct: 25,
              ),
              const SizedBox(height: 8),
              _ReachRow(
                color: const Color(0xFFB4A8FF),
                label: _reach3.resolve(locale),
                value: '234',
                pct: 9,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReachRow extends StatelessWidget {
  const _ReachRow({
    required this.color,
    required this.label,
    required this.value,
    required this.pct,
  });
  final Color color;
  final String label;
  final String value;
  final int pct;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: colors.textPrimary, fontSize: 12.5),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 5,
            backgroundColor: colors.surfaceSoft,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Strings
// ─────────────────────────────────────────────────────────────────────────────

final _heroEyebrow = teacherText(ru: 'ВЫ', en: 'YOU', kk: 'СІЗ');
final _heroTitle =
    teacherText(ru: 'Профиль', en: 'Profile', kk: 'Профиль');
final _heroSubtitle = teacherText(
  ru: 'Ваш публичный профиль и контекст работы на платформе.',
  en: 'Your public-facing identity and how your work appears on the platform.',
  kk: 'Платформадағы профиль мен жұмыс контекстіңіз.',
);

final _role = teacherText(
  ru: 'Старший преподаватель · Data & Systems',
  en: 'Senior Educator · Data & Systems',
  kk: 'Аға оқытушы · Data & Systems',
);
final _focusTag = teacherText(
  ru: 'Фокус · качество курсов',
  en: 'Focus · course quality',
  kk: 'Фокус · курс сапасы',
);
final _slaTag = teacherText(
  ru: 'Reply SLA · 24ч',
  en: 'Reply SLA · 24h',
  kk: 'Жауап SLA · 24с',
);

final _statCoursesLabel =
    teacherText(ru: 'Курсов', en: 'Courses authored', kk: 'Курстар');
final _statCoursesSub = teacherText(
  ru: 'опубликованных и черновых',
  en: 'published and draft',
  kk: 'жарияланған және нобай',
);
final _statLearnersLabel = teacherText(
  ru: 'Учеников охвачено',
  en: 'Learners reached',
  kk: 'Оқушылар қамтылды',
);
final _statLearnersSub = teacherText(
  ru: 'за всё время на платформе',
  en: 'all-time on platform',
  kk: 'платформадағы барлық уақыт',
);
final _statYearsLabel = teacherText(
  ru: 'Лет на платформе',
  en: 'Years on platform',
  kk: 'Жыл платформада',
);
final _statYearsSub = teacherText(
  ru: 'с момента регистрации',
  en: 'since onboarding',
  kk: 'тіркелгеннен бері',
);

final _teachEyebrow =
    teacherText(ru: 'ЧТО Я ПРЕПОДАЮ', en: 'WHAT I TEACH', kk: 'НЕНІ ОҚЫТАМЫН');
final _teachTitle = teacherText(
  ru: 'Темы и направления',
  en: 'Topics & specializations',
  kk: 'Тақырыптар',
);
final _bioEyebrow = teacherText(ru: 'БИО', en: 'BIO', kk: 'БИО');
final _bioBody = teacherText(
  ru:
      'Я создаю практические курсы для работающих data-аналитиков. Каждый новый курс начинается с диагноза: где предыдущая группа спотыкалась, и я перебираю урок, rubric и worked examples, пока funnel не выровняется. Цель knowledge graph — сделать эту диагностику видимой.',
  en:
      'I design hands-on courses for working data analysts. Most of what I publish starts as a tight diagnostic of where my prior cohorts stumbled — then I rebuild the lesson, the rubric, and the worked examples until the funnel holds. The point of the knowledge graph is to make that diagnostic visible.',
  kk:
      'Деректер аналитиктеріне арналған тәжірибелік курстар жасаймын. Әр курс — алдыңғы топ қай жерде шатасқанын талдау, содан кейін сабақ пен rubric-ті funnel тұрақтанғанша қайта құрастыру. Knowledge graph осы талдауды көрсету үшін керек.',
);

final _focusEyebrow =
    teacherText(ru: 'ЭТА НЕДЕЛЯ', en: 'THIS WEEK', kk: 'ОСЫ АПТА');
final _focusTitle = teacherText(
  ru: 'Рабочие приоритеты',
  en: 'Working priorities',
  kk: 'Жұмыс приоритеттері',
);
final _focusSubtitle = teacherText(
  ru: 'Отметьте, на чём фокус — AI подбирает подсказки вокруг этого.',
  en: 'Mark your focus; the system schedules AI suggestions around it.',
  kk: 'Назарыңызды белгілеңіз — AI ұсыныстары соған сай тізіледі.',
);

final _focusOne = teacherText(
  ru: 'Снизить drop-off на SQL/01 joins',
  en: 'Reduce drop-off on SQL/01 joins',
  kk: 'SQL/01 joins drop-off-ын азайту',
);
final _focusTwo = teacherText(
  ru: 'Запустить Frontend Sprint модуль 4',
  en: 'Ship Frontend Sprint module 4',
  kk: 'Frontend Sprint модуль 4 шығару',
);
final _focusThree = teacherText(
  ru: 'Сделать скелет ML Foundations',
  en: 'Draft ML Foundations skeleton',
  kk: 'ML Foundations қаңқасы',
);
final _focusFour = teacherText(
  ru: 'Обновить rubric CSS Lab',
  en: 'Refresh CSS Lab rubric',
  kk: 'CSS Lab rubric жаңарту',
);

final _reachEyebrow = teacherText(
  ru: 'ОХВАТ · 30Д',
  en: 'LEARNER REACH · 30D',
  kk: 'ҚАМТУ · 30К',
);
final _reachTitle = teacherText(
  ru: 'Откуда приходят ученики',
  en: 'Where your learners come from',
  kk: 'Оқушылар қайдан келеді',
);
final _ringTopLabel =
    teacherText(ru: 'АКТИВНО', en: 'ACTIVE', kk: 'БЕЛСЕНДІ');
final _reach1 = teacherText(
  ru: 'Возвращаются',
  en: 'Returning learners',
  kk: 'Қайта оралғандар',
);
final _reach2 = teacherText(
  ru: 'Новые за месяц',
  en: 'New this month',
  kk: 'Айдағы жаңалар',
);
final _reach3 = teacherText(
  ru: 'Реактивировались',
  en: 'Reactivated',
  kk: 'Қайта белсенділер',
);
