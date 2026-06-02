// Teacher Studio · Q&A — Phase 2.
//
// Layout:
//   - Top KPI strip
//   - Inbox: list of questions on the left, detail (with AI draft + composer)
//     on the right. On mobile the right pane collapses into a full-screen
//     route triggered by tap.
//
// Mobile-friendly: column on < 900px, split on wider screens.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../teacher_text.dart';
import '../widgets/teacher_studio_widgets.dart';

class TeacherQnaPage extends ConsumerStatefulWidget {
  const TeacherQnaPage({super.key});
  @override
  ConsumerState<TeacherQnaPage> createState() => _TeacherQnaPageState();
}

class _TeacherQnaPageState extends ConsumerState<TeacherQnaPage> {
  String _filter = 'new';
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(
      demoAppControllerProvider.select((state) => state.locale),
    );
    final colors = context.appColors;
    final compact = MediaQuery.sizeOf(context).width < 900;
    final all = _seedQuestions(locale);
    final filtered = all.where((q) {
      if (_filter == 'all') return true;
      return q.status == _filter;
    }).toList();

    // Keep _selected in range
    final selectedIndex = _selected >= filtered.length ? 0 : _selected;
    final selected = filtered.isEmpty ? null : filtered[selectedIndex];

    return TsPageScrollView(
      children: [
        TsPageHeader(
          eyebrow: _heroEyebrow.resolve(locale),
          title: _heroTitle.resolve(locale),
          subtitle: _heroSubtitle.resolve(locale),
          actions: [
            TsButton(
              label: _sortAction.resolve(locale),
              icon: Icons.swap_vert_rounded,
              onPressed: () {},
            ),
            TsButton.primary(
              label: _autoDraftAction.resolve(locale),
              icon: Icons.auto_awesome_rounded,
              onPressed: () {},
            ),
          ],
        ),

        // KPI strip
        TsResponsiveGrid(
          desktopCols: 4,
          children: [
            TsKpiCard(
              label: _kpiOpenLabel.resolve(locale),
              value: '12',
              accent: colors.danger,
              subtitle: _kpiOpenSub.resolve(locale),
            ),
            TsKpiCard(
              label: _kpiAwaitLabel.resolve(locale),
              value: '4',
              accent: colors.accent,
              subtitle: _kpiAwaitSub.resolve(locale),
            ),
            TsKpiCard(
              label: _kpiAutoLabel.resolve(locale),
              value: '38',
              accent: colors.success,
              subtitle: _kpiAutoSub.resolve(locale),
            ),
            TsKpiCard(
              label: _kpiRateLabel.resolve(locale),
              value: '94%',
              accent: colors.primary,
              subtitle: _kpiRateSub.resolve(locale),
            ),
          ],
        ),

        // Inbox
        TsCard(
          padding: EdgeInsets.zero,
          child: compact
              ? _MobileInbox(
                  items: filtered,
                  filter: _filter,
                  onFilter: (f) => setState(() => _filter = f),
                  onTap: (q) =>
                      _openDetailRoute(context, q, locale),
                  locale: locale,
                )
              : SizedBox(
                  height: 560,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 360,
                        child: _DesktopList(
                          items: filtered,
                          filter: _filter,
                          selectedIndex: selectedIndex,
                          onFilter: (f) => setState(() {
                            _filter = f;
                            _selected = 0;
                          }),
                          onSelect: (i) => setState(() => _selected = i),
                          locale: locale,
                        ),
                      ),
                      Container(
                        width: 1,
                        color: colors.divider.withValues(alpha: 0.55),
                      ),
                      Expanded(
                        child: selected == null
                            ? _EmptyDetail(locale: locale)
                            : _QnaDetailPane(
                                question: selected,
                                locale: locale,
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  void _openDetailRoute(
      BuildContext context, _Question q, AppLocale locale) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      final colors = context.appColors;
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.backgroundElevated,
          title: Text(q.learner,
              style: TextStyle(color: colors.textPrimary, fontSize: 15)),
        ),
        body: _QnaDetailPane(question: q, locale: locale),
      );
    }));
  }

  List<_Question> _seedQuestions(AppLocale l) => [
        _Question(
          id: 'q1',
          learner: 'Madina K.',
          cohort: 'C-25/B',
          course: 'SQL/01',
          lesson: _lessonSelfJoins.resolve(l),
          asked: _ago12m.resolve(l),
          status: 'new',
          preview: _previewQ1.resolve(l),
          aiSuggested: true,
        ),
        _Question(
          id: 'q2',
          learner: 'Daniyar T.',
          cohort: 'C-24/B',
          course: 'SQL/01',
          lesson: _lessonOuterJoins.resolve(l),
          asked: _ago38m.resolve(l),
          status: 'new',
          preview: _previewQ2.resolve(l),
          aiSuggested: true,
        ),
        _Question(
          id: 'q3',
          learner: 'Aizada B.',
          cohort: 'C-25/A',
          course: 'FE/02',
          lesson: _lessonFlexbox.resolve(l),
          asked: _ago1h.resolve(l),
          status: 'answered',
          preview: _previewQ3.resolve(l),
        ),
        _Question(
          id: 'q4',
          learner: 'Ruslan O.',
          cohort: 'C-24/A',
          course: 'SQL/01',
          lesson: _lessonLab.resolve(l),
          asked: _ago2h.resolve(l),
          status: 'needs-rubric',
          preview: _previewQ4.resolve(l),
        ),
        _Question(
          id: 'q5',
          learner: 'Saya M.',
          cohort: 'C-25/B',
          course: 'DM/03',
          lesson: _lessonInclusion.resolve(l),
          asked: _ago4h.resolve(l),
          status: 'new',
          preview: _previewQ5.resolve(l),
          aiSuggested: true,
        ),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

class _Question {
  _Question({
    required this.id,
    required this.learner,
    required this.cohort,
    required this.course,
    required this.lesson,
    required this.asked,
    required this.status, // new | needs-rubric | answered
    required this.preview,
    this.aiSuggested = false,
  });
  final String id, learner, cohort, course, lesson, asked, status, preview;
  final bool aiSuggested;
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter chips
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.onFilter,
    required this.locale,
  });
  final String filter;
  final ValueChanged<String> onFilter;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final items = [
      ('new', _filterNew.resolve(locale), 3),
      ('needs-rubric', _filterAwait.resolve(locale), 1),
      ('answered', _filterDone.resolve(locale), 1),
      ('all', _filterAll.resolve(locale), null as int?),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final it in items) ...[
            InkWell(
              onTap: () => onFilter(it.$1),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: filter == it.$1
                      ? colors.primary.withValues(alpha: 0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: filter == it.$1
                        ? colors.primary.withValues(alpha: 0.3)
                        : colors.divider.withValues(alpha: 0.55),
                  ),
                ),
                child: Text(
                  it.$3 == null ? it.$2 : '${it.$2} · ${it.$3}',
                  style: TextStyle(
                    color: filter == it.$1
                        ? colors.primary
                        : colors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Desktop list (left pane)
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopList extends StatelessWidget {
  const _DesktopList({
    required this.items,
    required this.filter,
    required this.selectedIndex,
    required this.onFilter,
    required this.onSelect,
    required this.locale,
  });
  final List<_Question> items;
  final String filter;
  final int selectedIndex;
  final ValueChanged<String> onFilter;
  final ValueChanged<int> onSelect;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child:
              _FilterBar(filter: filter, onFilter: onFilter, locale: locale),
        ),
        Container(
          height: 1,
          color: colors.divider.withValues(alpha: 0.55),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    _emptyList.resolve(locale),
                    style: TextStyle(color: colors.textSecondary),
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final q = items[i];
                    final selected = i == selectedIndex;
                    return InkWell(
                      onTap: () => onSelect(i),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? colors.primary.withValues(alpha: 0.07)
                              : Colors.transparent,
                          border: Border(
                            left: BorderSide(
                              color: selected
                                  ? colors.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                            bottom: BorderSide(
                              color: colors.divider.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                        child: _QuestionRowBody(q: q),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile inbox (list-only, taps push detail route)
// ─────────────────────────────────────────────────────────────────────────────

class _MobileInbox extends StatelessWidget {
  const _MobileInbox({
    required this.items,
    required this.filter,
    required this.onFilter,
    required this.onTap,
    required this.locale,
  });
  final List<_Question> items;
  final String filter;
  final ValueChanged<String> onFilter;
  final ValueChanged<_Question> onTap;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child:
              _FilterBar(filter: filter, onFilter: onFilter, locale: locale),
        ),
        Container(
          height: 1,
          color: colors.divider.withValues(alpha: 0.55),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              _emptyList.resolve(locale),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
        for (var i = 0; i < items.length; i++) ...[
          InkWell(
            onTap: () => onTap(items[i]),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: _QuestionRowBody(q: items[i]),
            ),
          ),
          if (i != items.length - 1)
            Container(
              height: 1,
              color: colors.divider.withValues(alpha: 0.45),
            ),
        ],
      ],
    );
  }
}

class _QuestionRowBody extends StatelessWidget {
  const _QuestionRowBody({required this.q});
  final _Question q;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                q.learner,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              q.asked,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 10.5,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${q.course} · ${q.lesson} · ${q.cohort}',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 10.5,
            fontFamily: 'monospace',
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          q.preview,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            TsTag(
              label: q.status.replaceAll('-', ' '),
              color: q.status == 'new'
                  ? colors.danger
                  : q.status == 'needs-rubric'
                      ? colors.accent
                      : colors.success,
            ),
            if (q.aiSuggested) TsTag(label: 'AI draft', color: colors.accent),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail pane (used on both desktop split and mobile fullscreen)
// ─────────────────────────────────────────────────────────────────────────────

class _QnaDetailPane extends StatefulWidget {
  const _QnaDetailPane({required this.question, required this.locale});
  final _Question question;
  final AppLocale locale;
  @override
  State<_QnaDetailPane> createState() => _QnaDetailPaneState();
}

class _QnaDetailPaneState extends State<_QnaDetailPane> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant _QnaDetailPane old) {
    super.didUpdateWidget(old);
    if (old.question.id != widget.question.id) {
      _ctrl.clear();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final q = widget.question;
    final locale = widget.locale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    q.learner,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TsButton(
                    label: _openLesson.resolve(locale),
                    icon: Icons.remove_red_eye_outlined,
                    onPressed: () {},
                  ),
                  TsButton(
                    label: _showGraph.resolve(locale),
                    icon: Icons.account_tree_rounded,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${q.course} · ${q.lesson} · ${q.cohort} · ${q.asked}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          color: colors.divider.withValues(alpha: 0.55),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceSoft.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: colors.divider.withValues(alpha: 0.55)),
                  ),
                  child: Text(
                    q.preview,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13.5,
                      height: 1.55,
                    ),
                  ),
                ),
                if (q.aiSuggested) ...[
                  const SizedBox(height: 14),
                  TsCallout(
                    color: colors.primary,
                    icon: Icons.auto_awesome_rounded,
                    title:
                        'AI · ${_aiDraftReply.resolve(locale).toUpperCase()}',
                    body: _aiBody.resolve(locale).replaceAll(
                          '{name}',
                          q.learner.split(' ').first,
                        ),
                  ),
                ],
                const SizedBox(height: 14),
                TextField(
                  controller: _ctrl,
                  minLines: 3,
                  maxLines: 6,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: _composerHint.resolve(locale),
                    hintStyle: TextStyle(color: colors.textSecondary),
                    filled: true,
                    fillColor: colors.surfaceSoft.withValues(alpha: 0.65),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: colors.primary, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: [
                    TsButton.primary(
                      label: _sendReply.resolve(locale),
                      icon: Icons.send_rounded,
                      onPressed: () {},
                    ),
                    TsButton(
                      label: _useAi.resolve(locale),
                      icon: Icons.auto_awesome_rounded,
                      onPressed: () {},
                    ),
                    TsButton(
                      label: _broadcast.resolve(locale),
                      icon: Icons.campaign_rounded,
                      onPressed: () {},
                    ),
                    TsButton(
                      label: _pinFaq.resolve(locale),
                      icon: Icons.push_pin_rounded,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail({required this.locale});
  final AppLocale locale;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forum_rounded,
              size: 32, color: colors.textSecondary),
          const SizedBox(height: 12),
          Text(
            _emptyDetail.resolve(locale),
            style: TextStyle(color: colors.textSecondary),
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
  ru: 'ВОПРОСЫ СТУДЕНТОВ',
  en: 'LEARNER QUESTIONS',
  kk: 'СТУДЕНТ СҰРАҚТАРЫ',
);
final _heroTitle =
    teacherText(ru: 'Q&A · входящие', en: 'Q&A inbox', kk: 'Q&A — кіріс');
final _heroSubtitle = teacherText(
  ru:
      'Открытые вопросы по всем вашим курсам. AI предложит черновик ответа по теме урока.',
  en:
      'Pending questions across all your courses. AI suggests a first-draft reply scoped to the relevant lesson.',
  kk:
      'Барлық курстарыңыз бойынша ашық сұрақтар. AI сабақ тақырыбына сәйкес жауап нобайын ұсынады.',
);
final _sortAction =
    teacherText(ru: 'Сначала старые', en: 'Sort · oldest', kk: 'Алдымен ескі');
final _autoDraftAction = teacherText(
  ru: 'Авто-черновики ответов',
  en: 'Auto-draft replies',
  kk: 'Авто-нобай жауаптар',
);

final _kpiOpenLabel =
    teacherText(ru: 'Открытые', en: 'Open', kk: 'Ашық');
final _kpiOpenSub = teacherText(
  ru: '2ч 14м среднее время',
  en: '2h 14m avg first reply',
  kk: '2с 14м орташа',
);
final _kpiAwaitLabel = teacherText(
  ru: 'Ждут rubric',
  en: 'Awaiting rubric',
  kk: 'Rubric күтеді',
);
final _kpiAwaitSub =
    teacherText(ru: 'Lab #14 · joins', en: 'Lab #14 · joins', kk: 'Lab #14');
final _kpiAutoLabel = teacherText(
  ru: 'AI решил сам',
  en: 'Auto-resolved by AI',
  kk: 'AI өзі шешті',
);
final _kpiAutoSub =
    teacherText(ru: 'за 7 дней', en: 'last 7 days', kk: 'соңғы 7 күн');
final _kpiRateLabel =
    teacherText(ru: 'Reply rate', en: 'Your reply rate', kk: 'Жауап мөлшері');
final _kpiRateSub = teacherText(
  ru: 'в течение 24ч',
  en: 'within 24h',
  kk: '24с ішінде',
);

final _filterNew = teacherText(ru: 'Открытые', en: 'Open', kk: 'Ашық');
final _filterAwait =
    teacherText(ru: 'Ждут', en: 'Awaiting', kk: 'Күтуде');
final _filterDone =
    teacherText(ru: 'Готово', en: 'Done', kk: 'Дайын');
final _filterAll = teacherText(ru: 'Все', en: 'All', kk: 'Барлығы');
final _emptyList = teacherText(
  ru: 'Здесь пусто.',
  en: 'Nothing here yet.',
  kk: 'Әзірге бос.',
);

final _openLesson =
    teacherText(ru: 'Открыть урок', en: 'Open lesson', kk: 'Сабақты ашу');
final _showGraph =
    teacherText(ru: 'В графе', en: 'Show in graph', kk: 'Графта көрсету');
final _aiDraftReply = teacherText(
  ru: 'черновик ответа',
  en: 'draft reply',
  kk: 'жауап нобайы',
);
final _aiBody = teacherText(
  ru:
      'Привет, {name}. Дубликаты на self-join почти всегда — пропущенный предикат. Добавьте WHERE a.created_at > b.created_at, чтобы каждая пара считалась один раз. Если нужен последний заказ на пару — оберните в ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC) и отфильтруйте по 1.',
  en:
      'Hi {name} — duplicate rows on a self-join are almost always a missing predicate. Add WHERE a.created_at > b.created_at so each pair is counted once. For the latest order per pair, wrap with ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC) and filter to 1.',
  kk:
      'Сәлем, {name}. Self-join қайталанулары әдетте предикат жетпеуінен. WHERE a.created_at > b.created_at қосыңыз. Әр жұптың соңғы заказы үшін ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC) пайдаланып 1-ге сүзіңіз.',
);
final _composerHint = teacherText(
  ru: 'Напишите ответ или отредактируйте черновик AI…',
  en: 'Type your reply, or edit the AI draft above…',
  kk: 'Жауабыңызды жазыңыз немесе AI нобайын өңдеңіз…',
);
final _sendReply =
    teacherText(ru: 'Отправить', en: 'Send reply', kk: 'Жіберу');
final _useAi = teacherText(
  ru: 'Взять AI-черновик',
  en: 'Use AI draft',
  kk: 'AI-нобайын алу',
);
final _broadcast = teacherText(
  ru: 'Сохранить и разослать группе',
  en: 'Save & broadcast to cohort',
  kk: 'Сақтап топқа жіберу',
);
final _pinFaq = teacherText(
  ru: 'Закрепить в FAQ урока',
  en: 'Pin to lesson FAQ',
  kk: 'Сабақ FAQ-ына бекіту',
);
final _emptyDetail = teacherText(
  ru: 'Выберите вопрос слева',
  en: 'Select a question on the left',
  kk: 'Сол жақтан сұрақ таңдаңыз',
);

// Question previews + lesson labels
final _lessonSelfJoins = teacherText(
  ru: 'Self & cross joins',
  en: 'Self & cross joins',
  kk: 'Self & cross joins',
);
final _lessonOuterJoins =
    teacherText(ru: 'OUTER joins', en: 'OUTER joins', kk: 'OUTER joins');
final _lessonFlexbox = teacherText(
  ru: 'Flexbox layout',
  en: 'Flexbox layout',
  kk: 'Flexbox layout',
);
final _lessonLab = teacherText(
  ru: 'Lab · 12 join puzzles',
  en: 'Lab · 12 join puzzles',
  kk: 'Lab · 12 join puzzles',
);
final _lessonInclusion = teacherText(
  ru: 'Inclusion-exclusion',
  en: 'Inclusion-exclusion',
  kk: 'Inclusion-exclusion',
);
final _ago12m = teacherText(ru: '12 мин', en: '12m', kk: '12м');
final _ago38m = teacherText(ru: '38 мин', en: '38m', kk: '38м');
final _ago1h = teacherText(ru: '1 ч', en: '1h', kk: '1с');
final _ago2h = teacherText(ru: '2 ч', en: '2h', kk: '2с');
final _ago4h = teacherText(ru: '4 ч', en: '4h', kk: '4с');

final _previewQ1 = teacherText(
  ru:
      'Получаю дубликаты строк, когда делаю self-join таблицы orders по user_id. Как оставить только последний заказ для каждой пары?',
  en:
      'I get duplicate rows when I self-join the orders table on user_id. Is there a way to keep only the latest order per pair?',
  kk:
      'Orders кестесін user_id бойынша self-join жасағанда қайталанатын жолдар шығады. Әр жұптың тек соңғысын қалай қалдыруға болады?',
);
final _previewQ2 = teacherText(
  ru: 'Когда LEFT JOIN может вернуть больше строк, чем сама левая таблица?',
  en: 'Could you walk through when a LEFT JOIN can produce more rows than the left table?',
  kk:
      'LEFT JOIN сол кестеден көп жол қашан қайтаратынын түсіндіріп бересіз бе?',
);
final _previewQ3 = teacherText(
  ru: 'Спасибо за диаграмму — наконец-то стало понятно.',
  en: 'Thanks for the diagram — finally clicked.',
  kk: 'Диаграмма үшін рахмет — енді түсінікті болды.',
);
final _previewQ4 = teacherText(
  ru:
      'Сдал puzzle #7, но авто-проверка засчитала как неверный, хотя результат совпадает. Прикладываю скриншот.',
  en:
      'Submitted puzzle #7 but the auto-grader marked it wrong even though the result set matches. Attaching screenshot.',
  kk:
      'Puzzle #7 тапсырдым, бірақ нәтиже сәйкес келсе де, авто-тексерші қате деп тапты. Скриншот қосып отырмын.',
);
final _previewQ5 = teacherText(
  ru:
      'Откуда интуитивно берётся |A ∩ B ∩ C|? Я разобрал алгебру, но не складывается.',
  en:
      "Where does the |A ∩ B ∩ C| term come from intuitively? I followed the algebra but it doesn't click.",
  kk:
      '|A ∩ B ∩ C| мүшесі қайдан шығады? Алгебраны түсіндім, бірақ интуитивті емес.',
);
