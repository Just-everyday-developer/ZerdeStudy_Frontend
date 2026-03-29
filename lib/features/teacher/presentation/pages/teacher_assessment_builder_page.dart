import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../providers/teacher_question_bank_provider.dart';
import '../teacher_text.dart';
import '../widgets/teacher_workspace_widgets.dart';

class TeacherAssessmentBuilderPage extends ConsumerWidget {
  const TeacherAssessmentBuilderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      demoAppControllerProvider.select((state) => state.locale),
    );
    final colors = context.appColors;
    final questions = ref.watch(teacherQuestionBankProvider);

    return TeacherPageScrollView(
      children: [
        TeacherSectionCard(
          title: _heroTitle.resolve(locale),
          subtitle: _heroSubtitle.resolve(locale),
          accent: colors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  TeacherTag(
                    label: _tagOne.resolve(locale),
                    accent: colors.primary,
                  ),
                  TeacherTag(
                    label: _tagTwo.resolve(locale),
                    accent: colors.accent,
                  ),
                  TeacherTag(
                    label: _tagThree.resolve(locale),
                    accent: colors.success,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton.primary(
                    label: _primaryAction.resolve(locale),
                    icon: Icons.rule_folder_rounded,
                    onPressed: () {},
                    maxWidth: 300,
                  ),
                  AppButton.secondary(
                    label: _importCsvLabel.resolve(locale),
                    icon: Icons.upload_file_rounded,
                    onPressed: () => _showImportDialog(
                      context: context,
                      ref: ref,
                      locale: locale,
                      format: _QuestionExchangeFormat.csv,
                    ),
                    maxWidth: 220,
                  ),
                  AppButton.secondary(
                    label: _importJsonLabel.resolve(locale),
                    icon: Icons.data_object_rounded,
                    onPressed: () => _showImportDialog(
                      context: context,
                      ref: ref,
                      locale: locale,
                      format: _QuestionExchangeFormat.json,
                    ),
                    maxWidth: 220,
                  ),
                  AppButton.secondary(
                    label: _exportCsvLabel.resolve(locale),
                    icon: Icons.ios_share_rounded,
                    onPressed: () => _showExportDialog(
                      context: context,
                      ref: ref,
                      locale: locale,
                      format: _QuestionExchangeFormat.csv,
                    ),
                    maxWidth: 220,
                  ),
                  AppButton.secondary(
                    label: _exportJsonLabel.resolve(locale),
                    icon: Icons.integration_instructions_rounded,
                    onPressed: () => _showExportDialog(
                      context: context,
                      ref: ref,
                      locale: locale,
                      format: _QuestionExchangeFormat.json,
                    ),
                    maxWidth: 220,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 860;
            final tiles = [
              TeacherMetricTile(
                label: _metricOneLabel.resolve(locale),
                value: '${questions.length}',
                hint: _metricOneHint.resolve(locale),
                icon: Icons.quiz_rounded,
                accent: colors.primary,
              ),
              TeacherMetricTile(
                label: _metricTwoLabel.resolve(locale),
                value: 'CSV / JSON',
                hint: _metricTwoHint.resolve(locale),
                icon: Icons.swap_horiz_rounded,
                accent: colors.accent,
              ),
              TeacherMetricTile(
                label: _metricThreeLabel.resolve(locale),
                value: '71%',
                hint: _metricThreeHint.resolve(locale),
                icon: Icons.task_alt_rounded,
                accent: colors.success,
              ),
            ];

            if (compact) {
              return Column(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    tiles[i],
                    if (i != tiles.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  Expanded(child: tiles[i]),
                  if (i != tiles.length - 1) const SizedBox(width: 12),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _exchangeTitle.resolve(locale),
          subtitle: _exchangeSubtitle.resolve(locale),
          accent: colors.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 760;
                  final cards = [
                    _FormatInfoCard(
                      title: _csvCardTitle.resolve(locale),
                      subtitle: _csvCardSubtitle.resolve(locale),
                      accent: colors.primary,
                      icon: Icons.table_rows_rounded,
                    ),
                    _FormatInfoCard(
                      title: _jsonCardTitle.resolve(locale),
                      subtitle: _jsonCardSubtitle.resolve(locale),
                      accent: colors.accent,
                      icon: Icons.data_object_rounded,
                    ),
                  ];

                  if (compact) {
                    return Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 12),
                        cards[1],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 12),
                      Expanded(child: cards[1]),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                _exchangeHint.resolve(locale),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _bankTitle.resolve(locale),
          subtitle: _bankSubtitle.resolve(locale),
          accent: colors.primary,
          child: Column(
            children: questions
                .take(4)
                .map(
                  (question) => Padding(
                    padding: EdgeInsets.only(
                      bottom: question == questions.take(4).last ? 0 : 12,
                    ),
                    child: TeacherStatusRow(
                      title: question.prompt,
                      subtitle:
                          '${question.module} • ${question.type} • ${question.tags.join(', ')}',
                      status: question.difficulty,
                      accent: _difficultyAccent(colors, question.difficulty),
                      trailing: Text(
                        question.correctAnswer,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _rubricTitle.resolve(locale),
          subtitle: _rubricSubtitle.resolve(locale),
          accent: colors.success,
          child: Column(children: _rubricRows(locale, colors)),
        ),
      ],
    );
  }

  Future<void> _showExportDialog({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocale locale,
    required _QuestionExchangeFormat format,
  }) async {
    final controller = ref.read(teacherQuestionBankProvider.notifier);
    final content = format == _QuestionExchangeFormat.csv
        ? controller.exportCsv()
        : controller.exportJson();
    final title = switch (format) {
      _QuestionExchangeFormat.csv => _exportCsvDialogTitle.resolve(locale),
      _QuestionExchangeFormat.json => _exportJsonDialogTitle.resolve(locale),
    };

    await showDialog<void>(
      context: context,
      builder: (context) {
        final colors = context.appColors;

        return Dialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: colors.divider),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _exportDialogSubtitle.resolve(locale),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: TextField(
                      readOnly: true,
                      maxLines: null,
                      controller: TextEditingController(text: content),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colors.surfaceSoft.withValues(alpha: 0.92),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: colors.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: colors.divider),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      AppButton.primary(
                        label: _copyPayloadLabel.resolve(locale),
                        icon: Icons.copy_all_rounded,
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: content));
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pop();
                          AppNotice.show(
                            context,
                            message: _payloadCopiedLabel.resolve(locale),
                            type: AppNoticeType.success,
                          );
                        },
                        maxWidth: 220,
                      ),
                      AppButton.secondary(
                        label: _closeDialogLabel.resolve(locale),
                        icon: Icons.close_rounded,
                        onPressed: () => Navigator.of(context).pop(),
                        maxWidth: 180,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showImportDialog({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocale locale,
    required _QuestionExchangeFormat format,
  }) async {
    final payloadController = TextEditingController(
      text: format == _QuestionExchangeFormat.csv
          ? _csvTemplate
          : _jsonTemplate,
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        final colors = context.appColors;
        final title = switch (format) {
          _QuestionExchangeFormat.csv => _importCsvDialogTitle.resolve(locale),
          _QuestionExchangeFormat.json => _importJsonDialogTitle.resolve(
            locale,
          ),
        };

        return Dialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: colors.divider),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _importDialogSubtitle.resolve(locale),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: TextField(
                      controller: payloadController,
                      maxLines: null,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: _importPayloadHint.resolve(locale),
                        filled: true,
                        fillColor: colors.surfaceSoft.withValues(alpha: 0.92),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: colors.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: colors.divider),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      AppButton.primary(
                        label: _confirmImportLabel.resolve(locale),
                        icon: Icons.publish_rounded,
                        onPressed: () {
                          try {
                            final controller = ref.read(
                              teacherQuestionBankProvider.notifier,
                            );
                            if (format == _QuestionExchangeFormat.csv) {
                              controller.importCsv(payloadController.text);
                            } else {
                              controller.importJson(payloadController.text);
                            }

                            Navigator.of(context).pop();
                            AppNotice.show(
                              context,
                              message: _importSuccessLabel.resolve(locale),
                              type: AppNoticeType.success,
                            );
                          } on FormatException catch (error) {
                            AppNotice.show(
                              context,
                              message: error.message,
                              type: AppNoticeType.error,
                            );
                          } catch (_) {
                            AppNotice.show(
                              context,
                              message: _importFailureLabel.resolve(locale),
                              type: AppNoticeType.error,
                            );
                          }
                        },
                        maxWidth: 240,
                      ),
                      AppButton.secondary(
                        label: _closeDialogLabel.resolve(locale),
                        icon: Icons.close_rounded,
                        onPressed: () => Navigator.of(context).pop(),
                        maxWidth: 180,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    payloadController.dispose();
  }

  List<Widget> _rubricRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _rubricOneTitle.resolve(locale),
        _rubricOneSubtitle.resolve(locale),
        _rubricOneStatus.resolve(locale),
        colors.success,
      ),
      (
        _rubricTwoTitle.resolve(locale),
        _rubricTwoSubtitle.resolve(locale),
        _rubricTwoStatus.resolve(locale),
        colors.accent,
      ),
    ];

    return [
      for (var i = 0; i < rows.length; i++) ...[
        TeacherStatusRow(
          title: rows[i].$1,
          subtitle: rows[i].$2,
          status: rows[i].$3,
          accent: rows[i].$4,
        ),
        if (i != rows.length - 1) const SizedBox(height: 12),
      ],
    ];
  }
}

enum _QuestionExchangeFormat { csv, json }

class _FormatInfoCard extends StatelessWidget {
  const _FormatInfoCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceSoft.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

Color _difficultyAccent(AppThemeColors colors, String difficulty) {
  return switch (difficulty.toLowerCase()) {
    'beginner' => colors.success,
    'advanced' => colors.danger,
    _ => colors.accent,
  };
}

const String _csvTemplate =
    'id,module,difficulty,type,prompt,option_a,option_b,option_c,option_d,correct_answer,explanation,tags\n'
    'sql_window_1,Analytics SQL,Intermediate,single_choice,Which clause is required before OVER()?,ORDER BY,PARTITION BY,FROM,WHERE,PARTITION BY,Window functions can partition result sets before applying OVER(),sql|window\n';

const String _jsonTemplate = '''
[
  {
    "id": "api_auth_1",
    "module": "API Security Clinic",
    "difficulty": "Intermediate",
    "type": "single_choice",
    "prompt": "Which token property helps reduce replay risk?",
    "options": [
      "Unlimited expiration",
      "Short lifetime",
      "No signature",
      "Plaintext storage"
    ],
    "correctAnswer": "Short lifetime",
    "explanation": "Short-lived tokens reduce the replay window if a token leaks.",
    "tags": ["security", "auth", "tokens"]
  }
]
''';

final _heroTitle = teacherText(
  ru: 'Quiz / Assignment Builder',
  en: 'Quiz / Assignment Builder',
  kk: 'Quiz / Assignment Builder',
);
final _heroSubtitle = teacherText(
  ru: 'Собирайте question bank, оценочные задания, критерии проверки и remediation-повторы в единой assessment зоне.',
  en: 'Build the question bank, graded work, rubrics, and remediation loops in one assessment zone.',
  kk: 'Question bank, бағаланатын тапсырмалар, rubric және remediation циклдарын бір assessment аймағында жинаңыз.',
);
final _tagOne = teacherText(
  ru: 'Question pool ready',
  en: 'Question pool ready',
  kk: 'Question pool ready',
);
final _tagTwo = teacherText(
  ru: 'Rubric-based review',
  en: 'Rubric-based review',
  kk: 'Rubric-based review',
);
final _tagThree = teacherText(
  ru: 'CSV / JSON sync',
  en: 'CSV / JSON sync',
  kk: 'CSV / JSON sync',
);
final _primaryAction = teacherText(
  ru: 'Открыть question bank',
  en: 'Open question bank',
  kk: 'Question bank ашу',
);
final _importCsvLabel = teacherText(
  ru: 'Импорт CSV',
  en: 'Import CSV',
  kk: 'CSV импорттау',
);
final _importJsonLabel = teacherText(
  ru: 'Импорт JSON',
  en: 'Import JSON',
  kk: 'JSON импорттау',
);
final _exportCsvLabel = teacherText(
  ru: 'Экспорт CSV',
  en: 'Export CSV',
  kk: 'CSV экспорттау',
);
final _exportJsonLabel = teacherText(
  ru: 'Экспорт JSON',
  en: 'Export JSON',
  kk: 'JSON экспорттау',
);
final _metricOneLabel = teacherText(
  ru: 'Вопросов в банке',
  en: 'Questions in bank',
  kk: 'Банктегі сұрақтар',
);
final _metricOneHint = teacherText(
  ru: 'Количество обновляется после каждого импорта или замены банка.',
  en: 'The count updates after every import or bank refresh.',
  kk: 'Саны әр импорттан немесе банк жаңаруынан кейін өзгереді.',
);
final _metricTwoLabel = teacherText(
  ru: 'Форматы обмена',
  en: 'Exchange formats',
  kk: 'Алмасу форматтары',
);
final _metricTwoHint = teacherText(
  ru: 'Поддержаны быстрые потоки импорта и экспорта для CSV и JSON.',
  en: 'Fast import and export flows are available for CSV and JSON.',
  kk: 'CSV және JSON үшін жылдам импорт пен экспорт ағымдары қолжетімді.',
);
final _metricThreeLabel = teacherText(
  ru: 'Средний submit rate',
  en: 'Average submit rate',
  kk: 'Орташа submit rate',
);
final _metricThreeHint = teacherText(
  ru: 'Домашние задания доходят до сабмита лучше, чем capstone.',
  en: 'Homework reaches submission more reliably than the capstone.',
  kk: 'Үй тапсырмалары capstone-ға қарағанда жиірек тапсырылады.',
);
final _exchangeTitle = teacherText(
  ru: 'Импорт и экспорт question bank',
  en: 'Question bank import and export',
  kk: 'Question bank импорт және экспорт',
);
final _exchangeSubtitle = teacherText(
  ru: 'Переносите вопросы между потоками, шаблонами и внешними редакторами без привязки к backend.',
  en: 'Move questions between cohorts, templates, and external editors without waiting on a backend.',
  kk: 'Сұрақтарды cohort, template және сыртқы редакторлар арасында backend-ке тәуелсіз тасымалдаңыз.',
);
final _csvCardTitle = teacherText(
  ru: 'CSV для табличного редактирования',
  en: 'CSV for spreadsheet editing',
  kk: 'Кестелік өңдеу үшін CSV',
);
final _csvCardSubtitle = teacherText(
  ru: 'Удобен для bulk-правок, тегов, уровней сложности и быстрых правок в таблицах.',
  en: 'Best for bulk edits, tags, difficulty levels, and spreadsheet workflows.',
  kk: 'Bulk-өзгерістер, тегтер, қиындық деңгейлері және кестелік workflow үшін ыңғайлы.',
);
final _jsonCardTitle = teacherText(
  ru: 'JSON для структурных шаблонов',
  en: 'JSON for structured templates',
  kk: 'Құрылымды шаблондар үшін JSON',
);
final _jsonCardSubtitle = teacherText(
  ru: 'Подходит для хранения вариантов, объяснений, тегов и последующей генерации.',
  en: 'Best for storing options, explanations, tags, and generation-ready payloads.',
  kk: 'Нұсқалар, түсіндірмелер, тегтер және генерацияға дайын payload үшін ыңғайлы.',
);
final _exchangeHint = teacherText(
  ru: 'Сейчас import/export работает через локальное окно обмена данными: можно вставить CSV/JSON payload, обновить question bank и скопировать экспортируемый результат.',
  en: 'The current import/export flow works through a local exchange dialog: paste CSV or JSON, refresh the bank, and copy the exported payload.',
  kk: 'Қазіргі import/export ағыны жергілікті data exchange терезесі арқылы жүреді: CSV немесе JSON енгізіп, банкіні жаңартып, export payload-ты көшіруге болады.',
);
final _bankTitle = teacherText(
  ru: 'Актуальные вопросы в банке',
  en: 'Current bank questions',
  kk: 'Банктегі өзекті сұрақтар',
);
final _bankSubtitle = teacherText(
  ru: 'После импорта здесь сразу видно, какие вопросы, модули и уровни сложности сейчас лежат в рабочем банке.',
  en: 'Imported questions appear here immediately so the teacher can verify the live bank state.',
  kk: 'Импортталған сұрақтар мұнда бірден көрінеді, сондықтан оқытушы жұмыс банкінің нақты күйін тексере алады.',
);
final _rubricTitle = teacherText(
  ru: 'Rubrics и ручная проверка',
  en: 'Rubrics and manual review',
  kk: 'Rubrics және қолмен тексеру',
);
final _rubricSubtitle = teacherText(
  ru: 'Преподавателю нужна прозрачная зона, где видно критерии, SLA по проверке и качество фидбэка.',
  en: 'Teachers need a clear area for criteria, review SLA, and feedback quality.',
  kk: 'Оқытушыға критерийлер, review SLA және feedback сапасы көрінетін аймақ керек.',
);
final _rubricOneTitle = teacherText(
  ru: 'Rubric templates',
  en: 'Rubric templates',
  kk: 'Rubric templates',
);
final _rubricOneSubtitle = teacherText(
  ru: 'Быстрые шаблоны для эссе, проекта, code review и peer feedback.',
  en: 'Fast templates for essays, projects, code review, and peer feedback.',
  kk: 'Essay, project, code review және peer feedback үшін жылдам шаблондар.',
);
final _rubricOneStatus = teacherText(
  ru: 'Reusable',
  en: 'Reusable',
  kk: 'Reusable',
);
final _rubricTwoTitle = teacherText(
  ru: 'Review queue',
  en: 'Review queue',
  kk: 'Review queue',
);
final _rubricTwoSubtitle = teacherText(
  ru: 'Очередь сабмитов должна показывать приоритет, дедлайн и краткую сводку попыток.',
  en: 'The review queue should expose priority, SLA, and a compact attempt summary.',
  kk: 'Review queue ішінде приоритет, SLA және қысқа attempt summary көрінуі керек.',
);
final _rubricTwoStatus = teacherText(
  ru: 'Operational view',
  en: 'Operational view',
  kk: 'Operational view',
);
final _exportCsvDialogTitle = teacherText(
  ru: 'Экспорт CSV',
  en: 'Export CSV',
  kk: 'CSV экспорт',
);
final _exportJsonDialogTitle = teacherText(
  ru: 'Экспорт JSON',
  en: 'Export JSON',
  kk: 'JSON экспорт',
);
final _exportDialogSubtitle = teacherText(
  ru: 'Скопируйте payload и вставьте его в таблицу, редактор или следующий pipeline.',
  en: 'Copy the payload and move it into a spreadsheet, editor, or the next workflow.',
  kk: 'Payload-ты көшіріп, оны кестеге, редакторға немесе келесі workflow-ға салыңыз.',
);
final _importCsvDialogTitle = teacherText(
  ru: 'Импорт CSV',
  en: 'Import CSV',
  kk: 'CSV импорт',
);
final _importJsonDialogTitle = teacherText(
  ru: 'Импорт JSON',
  en: 'Import JSON',
  kk: 'JSON импорт',
);
final _importDialogSubtitle = teacherText(
  ru: 'Вставьте подготовленный payload. После импорта текущий demo-bank заменится новым набором вопросов.',
  en: 'Paste the prepared payload. Import replaces the current demo bank with the new question set.',
  kk: 'Дайын payload-ты қойыңыз. Импорт ағымдағы demo-bank орнын жаңа сұрақтар жиынтығымен ауыстырады.',
);
final _importPayloadHint = teacherText(
  ru: 'Вставьте CSV или JSON payload',
  en: 'Paste the CSV or JSON payload',
  kk: 'CSV немесе JSON payload енгізіңіз',
);
final _confirmImportLabel = teacherText(
  ru: 'Применить импорт',
  en: 'Apply import',
  kk: 'Импортты қолдану',
);
final _copyPayloadLabel = teacherText(
  ru: 'Скопировать payload',
  en: 'Copy payload',
  kk: 'Payload көшіру',
);
final _payloadCopiedLabel = teacherText(
  ru: 'Экспорт скопирован в буфер обмена.',
  en: 'The export payload was copied to the clipboard.',
  kk: 'Export payload алмасу буферіне көшірілді.',
);
final _importSuccessLabel = teacherText(
  ru: 'Question bank обновлен.',
  en: 'Question bank updated.',
  kk: 'Question bank жаңартылды.',
);
final _importFailureLabel = teacherText(
  ru: 'Не удалось обработать импортируемый payload.',
  en: 'Unable to process the imported payload.',
  kk: 'Импортталған payload өңделмеді.',
);
final _closeDialogLabel = teacherText(ru: 'Закрыть', en: 'Close', kk: 'Жабу');
